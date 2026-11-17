import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/profile/controller/user_subscription_controller.dart';
import 'package:hawiisaac/features/profile/model/subscription_model.dart';
import 'package:hawiisaac/features/profile/services/subscription_api_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class InAppPurchaseService {
  InAppPurchaseService._();
  static final InAppPurchaseService instance = InAppPurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionApiService _apiService = SubscriptionApiService();

  static const String monthlyProductId = 'hykx_pro_monthly';
  static const String yearlyProductId = 'hykx_pro_yearly';
  static const Set<String> productIds = {monthlyProductId, yearlyProductId};

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isAvailable = false.obs;
  final RxBool isPurchasing = false.obs;

  void initialize() {
    try {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;

      _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription?.cancel();
        },
        onError: (dynamic error) {
          debugPrint('[InAppPurchaseService] PurchaseStream error: $error');
          isPurchasing.value = false;
          AppLoadingService.dismiss();
        },
      );

      loadProducts();
    } catch (e) {
      debugPrint('[InAppPurchaseService] Initialize error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> loadProducts() async {
    try {
      final available = await _iap.isAvailable();
      isAvailable.value = available;
      if (!available) {
        debugPrint(
          '[InAppPurchaseService] InAppPurchase store unavailable on this device',
        );
        return;
      }

      final response = await _iap.queryProductDetails(productIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
          '[InAppPurchaseService] Products not found in store: ${response.notFoundIDs}',
        );
      }
      products.assignAll(response.productDetails);
      debugPrint(
        '[InAppPurchaseService] Successfully loaded ${products.length} products: ${products.map((p) => '${p.id}:${p.price}').join(', ')}',
      );
    } catch (e) {
      debugPrint(
        '[InAppPurchaseService] Error querying products or connecting to store: $e',
      );
      isAvailable.value = false;
    }
  }

  ProductDetails? getProduct(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (isPurchasing.value) return false;
    isPurchasing.value = true;
    AppLoadingService.showLoading('Opening store checkout...');

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      final started = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!started) {
        isPurchasing.value = false;
        AppLoadingService.dismiss();
      }
      return started;
    } catch (e) {
      debugPrint('[InAppPurchaseService] Buy error: $e');
      isPurchasing.value = false;
      AppLoadingService.dismiss();
      AppLoadingService.showError('Purchase Failed', e.toString());
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      AppLoadingService.showLoading('Restoring purchases...');
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('[InAppPurchaseService] Restore error: $e');
      AppLoadingService.dismiss();
      AppLoadingService.showError('Restore Failed', e.toString());
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint(
            '[InAppPurchaseService] Pending purchase: ${purchaseDetails.productID}',
          );
          isPurchasing.value = true;
          AppLoadingService.showLoading('Processing purchase...');
          break;

        case PurchaseStatus.error:
          debugPrint(
            '[InAppPurchaseService] Purchase error: ${purchaseDetails.error}',
          );
          isPurchasing.value = false;
          AppLoadingService.dismiss();
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          AppLoadingService.showError(
            'Purchase Error',
            purchaseDetails.error?.message ?? 'Failed to complete transaction.',
          );
          break;

        case PurchaseStatus.canceled:
          debugPrint('[InAppPurchaseService] Purchase canceled by user');
          isPurchasing.value = false;
          AppLoadingService.dismiss();
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          debugPrint(
            '[InAppPurchaseService] Verifying purchase: ${purchaseDetails.productID}',
          );
          AppLoadingService.showLoading('Verifying with server...');
          final success = await _verifyPurchaseWithBackend(purchaseDetails);
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          isPurchasing.value = false;
          AppLoadingService.dismiss();

          if (success) {
            AppLoadingService.showSuccess(
              'Subscription Active',
              'Welcome to HYKX Pro! Your entitlements have been unlocked.',
            );
            if (Get.isRegistered<UserSubscriptionController>()) {
              Get.find<UserSubscriptionController>().refreshStatus();
            }
          } else {
            AppLoadingService.showError(
              'Verification Failed',
              'Could not verify purchase with the server. Please contact support.',
            );
          }
          break;
      }
    }
  }

  Future<bool> _verifyPurchaseWithBackend(
    PurchaseDetails purchaseDetails,
  ) async {
    final isYearly = purchaseDetails.productID.contains('yearly');
    final cycle = isYearly ? 'yearly' : 'monthly';

    try {
      if (Platform.isAndroid) {
        String token = '';
        String orderId = purchaseDetails.purchaseID ?? '';

        if (purchaseDetails is GooglePlayPurchaseDetails) {
          token = purchaseDetails.billingClientPurchase.purchaseToken;
          orderId = purchaseDetails.billingClientPurchase.orderId.isNotEmpty
              ? purchaseDetails.billingClientPurchase.orderId
              : (purchaseDetails.purchaseID ?? '');
        }

        if (token.isEmpty) {
          token = purchaseDetails.verificationData.serverVerificationData
              .trim();
        }

        final req = GooglePlayVerifyRequest(
          productId: purchaseDetails.productID,
          purchaseToken: token,
          orderId: orderId,
          packageName: 'com.hykx.app',
          billingCycle: cycle,
        );

        return await _apiService.verifyGooglePlayPurchase(req);
      } else if (Platform.isIOS) {
        String originalTxId = '';
        String txId = purchaseDetails.purchaseID ?? '';

        if (purchaseDetails is AppStorePurchaseDetails) {
          originalTxId =
              purchaseDetails
                  .skPaymentTransaction
                  .originalTransaction
                  ?.transactionIdentifier ??
              purchaseDetails.skPaymentTransaction.transactionIdentifier ??
              '';
          txId =
              purchaseDetails.skPaymentTransaction.transactionIdentifier ??
              (purchaseDetails.purchaseID ?? '');
        }

        if (originalTxId.isEmpty) {
          originalTxId = purchaseDetails.verificationData.serverVerificationData
              .trim();
        }
        if (originalTxId.isEmpty) {
          originalTxId = txId;
        }

        final req = AppleVerifyRequest(
          productId: purchaseDetails.productID,
          originalTransactionId: originalTxId,
          transactionId: txId,
          billingCycle: cycle,
        );

        return await _apiService.verifyApplePurchase(req);
      }
      return false;
    } catch (e) {
      debugPrint('[InAppPurchaseService] Backend verify error: $e');
      return false;
    }
  }

  /// Restore purchases against backend Endpoint 4
  Future<bool> syncRestoredPurchasesWithBackend(
    List<PurchaseDetails> purchases,
  ) async {
    try {
      final items = <RestorePurchaseItem>[];

      for (final p in purchases) {
        if (Platform.isAndroid) {
          String token = '';
          String orderId = p.purchaseID ?? '';
          if (p is GooglePlayPurchaseDetails) {
            token = p.billingClientPurchase.purchaseToken;
            orderId = p.billingClientPurchase.orderId;
          }
          if (token.isEmpty) {
            token = p.verificationData.serverVerificationData.trim();
          }

          items.add(
            RestorePurchaseItem(
              store: 'google_play',
              productId: p.productID,
              purchaseToken: token,
              transactionId: orderId,
            ),
          );
        } else if (Platform.isIOS) {
          String origId = '';
          if (p is AppStorePurchaseDetails) {
            origId =
                p
                    .skPaymentTransaction
                    .originalTransaction
                    ?.transactionIdentifier ??
                p.skPaymentTransaction.transactionIdentifier ??
                '';
          }
          if (origId.isEmpty) {
            origId = p.purchaseID ?? '';
          }

          items.add(
            RestorePurchaseItem(
              store: 'apple_app_store',
              productId: p.productID,
              originalTransactionId: origId,
              transactionId: p.purchaseID,
            ),
          );
        }
      }

      if (items.isEmpty) return false;

      final res = await _apiService.restorePurchases(
        RestorePurchasesRequest(purchases: items),
      );

      if (res.isPremium) {
        if (Get.isRegistered<UserSubscriptionController>()) {
          Get.find<UserSubscriptionController>().refreshStatus();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[InAppPurchaseService] Restore sync error: $e');
      return false;
    }
  }
}
