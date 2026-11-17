import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/in_app_purchase_service.dart';
import 'package:hawiisaac/features/profile/services/subscription_api_service.dart';

class PremiumController extends GetxController {
  PremiumController({
    SubscriptionApiService? subscriptionApiService,
  }) : _subscriptionApiService =
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
      // 1. Refresh store product details
      await InAppPurchaseService.instance.loadProducts();

      // 2. Fetch backend plans
      final backendPlans =
          await _subscriptionApiService.getSubscriptionPlans();

      if (backendPlans.isNotEmpty) {
        final plan = backendPlans.first;
        final monthlyId = Platform.isIOS
            ? plan.appleMonthlyProductId
            : plan.googleMonthlyProductId;
        final yearlyId = Platform.isIOS
            ? plan.appleYearlyProductId
            : plan.googleYearlyProductId;

        final storeMonthly = InAppPurchaseService.instance.getProduct(monthlyId);
        final storeYearly = InAppPurchaseService.instance.getProduct(yearlyId);

        plans.assignAll([
          {
            'label': 'Pro',
            'title': 'Monthly',
            'product_id': monthlyId,
            'price': storeMonthly?.price.replaceAll(RegExp(r'[^0-9.]'), '') ??
                plan.monthlyPrice,
            'currency': storeMonthly?.currencySymbol ?? '\$',
            'billing': 'Billed monthly',
            'badge': 'Flexible',
          },
          {
            'label': 'Pro',
            'title': 'Yearly',
            'product_id': yearlyId,
            'price': storeYearly?.price.replaceAll(RegExp(r'[^0-9.]'), '') ??
                plan.yearlyPrice,
            'currency': storeYearly?.currencySymbol ?? '\$',
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
      debugPrint('[PremiumController] Launching store purchase sheet for ${storeProduct.id}');
      await InAppPurchaseService.instance.buyProduct(storeProduct);
    } else {
      debugPrint('[PremiumController] Product $productId not yet cached, re-querying store...');
      await InAppPurchaseService.instance.loadProducts();
      final retryProduct = InAppPurchaseService.instance.getProduct(productId);

      if (retryProduct != null) {
        await InAppPurchaseService.instance.buyProduct(retryProduct);
      } else {
        AppLoadingService.showError(
          'Store Unavailable',
          'Could not connect to Google Play or App Store for $productId. Please verify store account.',
        );
      }
    }
  }

  Future<void> onRestorePurchases() async {
    await InAppPurchaseService.instance.restorePurchases();
  }
}
