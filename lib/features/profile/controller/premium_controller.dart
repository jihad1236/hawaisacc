import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/in_app_purchase_service.dart';
import 'package:hawiisaac/features/profile/services/subscription_api_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumController extends GetxController {
  PremiumController({SubscriptionApiService? subscriptionApiService})
    : _subscriptionApiService =
          subscriptionApiService ?? SubscriptionApiService();

  // ─── Header ──────────────────────────────────────────────────────
  final String appName = 'HYKX';
  final String tagLabel = 'Pro';
  final String headline = 'Get full access to HYKX Pro';
  final RxBool isLoading = false.obs;
  final SubscriptionApiService _subscriptionApiService;

  // ─── Feature List (HYKX Pro Benefits) ───────────────────────────
  final List<String> features = [
    'Bespoke 4-day workout splits (Push/Pull/Legs/Rest)',
    'AI Equipment Recognition Scanner',
    'Advanced Progress Analytics & Daily Stats',
    'Unlimited workout session tracking',
    'Custom workout routines & priority support',
  ];

  // ─── Plans ───────────────────────────────────────────────────────
  final RxInt selectedPlanIndex = 1.obs; // 0 = Monthly, 1 = Yearly (default)

  final RxList<Map<String, String>> plans = <Map<String, String>>[
    {
      'label': 'Pro',
      'title': 'Monthly',
      'product_id': 'hykx_pro_monthly',
      'price': '14.99',
      'currency': '\$',
      'billing': 'Billed monthly',
      'badge': 'Flexible',
    },
    {
      'label': 'Pro',
      'title': 'Yearly',
      'product_id': 'hykx_pro_yearly',
      'price': '119.99',
      'currency': '\$',
      'billing': 'Billed yearly',
      'badge': 'Save 33%',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadStoreAndBackendPlans();
  }

  Future<void> loadStoreAndBackendPlans() async {
    isLoading.value = true;
    try {
      // 1. Fetch backend plans first to get dynamic product IDs
      final backendPlans = await _subscriptionApiService.getSubscriptionPlans();

      final dynamicIds = <String>{};
      if (backendPlans.isNotEmpty) {
        for (final plan in backendPlans) {
          final mId = Platform.isIOS
              ? plan.appleMonthlyProductId
              : plan.googleMonthlyProductId;
          final yId = Platform.isIOS
              ? plan.appleYearlyProductId
              : plan.googleYearlyProductId;
          if (mId.isNotEmpty) dynamicIds.add(mId);
          if (yId.isNotEmpty) dynamicIds.add(yId);
        }
      }

      // 2. Refresh store product details with the configured product IDs
      await InAppPurchaseService.instance.loadProducts(dynamicIds);

      if (backendPlans.isNotEmpty) {
        final plan = backendPlans.first;
        final monthlyId = Platform.isIOS
            ? plan.appleMonthlyProductId
            : plan.googleMonthlyProductId;
        final yearlyId = Platform.isIOS
            ? plan.appleYearlyProductId
            : plan.googleYearlyProductId;

        final storeMonthly = InAppPurchaseService.instance.getProduct(
          monthlyId,
        );
        final storeYearly = InAppPurchaseService.instance.getProduct(yearlyId);

        plans.assignAll([
          {
            'label': 'Pro',
            'title': 'Monthly',
            'product_id': monthlyId,
            'price': _formatStorePrice(storeMonthly, plan.monthlyPrice),
            'currency': storeMonthly?.currencySymbol.trim().isNotEmpty == true
                ? storeMonthly!.currencySymbol
                : '\$',
            'billing': 'Billed monthly',
            'badge': 'Flexible',
          },
          {
            'label': 'Pro',
            'title': 'Yearly',
            'product_id': yearlyId,
            'price': _formatStorePrice(storeYearly, plan.yearlyPrice),
            'currency': storeYearly?.currencySymbol.trim().isNotEmpty == true
                ? storeYearly!.currencySymbol
                : '\$',
            'billing': 'Billed yearly',
            'badge': 'Save 33%',
          },
        ]);
      }
    } catch (e) {
      debugPrint('[PremiumController] Error loading plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _formatStorePrice(ProductDetails? product, String fallbackPrice) {
    if (product == null) return fallbackPrice;
    if (product.rawPrice > 0) {
      if (product.rawPrice % 1 == 0) {
        return product.rawPrice.toInt().toString();
      }
      return product.rawPrice.toStringAsFixed(2);
    }
    final cleaned = product.price.replaceAll(RegExp(r'[^0-9.,]'), '').trim();
    if (cleaned.endsWith('.00') || cleaned.endsWith(',00')) {
      return cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.isNotEmpty ? cleaned : fallbackPrice;
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  // ─── CTA ─────────────────────────────────────────────────────────
  String get ctaLabel {
    final title = plans[selectedPlanIndex.value]['title'];
    return 'Subscribe to $title Plan';
  }

  Future<void> onSubscribe() async {
    if (isLoading.value) return;

    final selectedPlan = plans[selectedPlanIndex.value];
    final planTitle = selectedPlan['title'] ?? 'Premium';
    final productId = selectedPlan['product_id'] ?? 'hykx_pro_yearly';

    debugPrint(
      '[PremiumController] Subscribe tapped: plan=$planTitle, product=$productId',
    );

    // Native In-App Purchase (Google Play Billing / Apple StoreKit)
    final storeProduct = InAppPurchaseService.instance.getProduct(productId);

    if (storeProduct != null) {
      debugPrint(
        '[PremiumController] Launching store purchase sheet for ${storeProduct.id}',
      );
      await InAppPurchaseService.instance.buyProduct(storeProduct);
    } else {
      debugPrint(
        '[PremiumController] Product $productId not yet cached, re-querying store...',
      );
      await InAppPurchaseService.instance.loadProducts({productId});
      final retryProduct = InAppPurchaseService.instance.getProduct(productId);

      if (retryProduct != null) {
        await InAppPurchaseService.instance.buyProduct(retryProduct);
      } else {
        AppLoadingService.showError(
          'Product Not Found in Store',
          'Could not retrieve "$productId" from Google Play or App Store. Please ensure the subscription and active base plan are configured in Google Play Console / App Store Connect and testing opt-in is accepted.',
        );
      }
    }
  }

  Future<void> onRestorePurchases() async {
    await InAppPurchaseService.instance.restorePurchases();
  }
}
