class UserSubscriptionDetails {
  final int id;
  final String status;
  final String billingCycle;
  final String paymentSource;
  final int planId;
  final String planTitle;
  final String planTier;
  final List<String> planBenefits;
  final bool isValid;
  final String? startedAt;
  final String? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String? canceledAt;
  final String? createdAt;

  const UserSubscriptionDetails({
    required this.id,
    this.status = 'active',
    this.billingCycle = 'monthly',
    this.paymentSource = 'google_play',
    this.planId = 1,
    this.planTitle = 'HYKX Pro',
    this.planTier = 'PRO',
    this.planBenefits = const [],
    this.isValid = true,
    this.startedAt,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.canceledAt,
    this.createdAt,
  });

  factory UserSubscriptionDetails.fromJson(Map<String, dynamic> json) {
    final benefits = json['plan_benefits'];
    return UserSubscriptionDetails(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'active',
      billingCycle: json['billing_cycle']?.toString() ?? 'monthly',
      paymentSource: json['payment_source']?.toString() ?? '',
      planId: int.tryParse(json['plan']?.toString() ?? '') ?? 1,
      planTitle: json['plan_title']?.toString() ?? 'HYKX Pro',
      planTier: json['plan_tier']?.toString() ?? 'PRO',
      planBenefits: benefits is List
          ? benefits.map((e) => e.toString()).toList(growable: false)
          : const [],
      isValid: json['is_valid'] == true,
      startedAt: json['started_at']?.toString(),
      currentPeriodEnd: json['current_period_end']?.toString(),
      cancelAtPeriodEnd: json['cancel_at_period_end'] == true,
      canceledAt: json['canceled_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class SubscriptionStatusResponse {
  final bool isPremium;
  final bool hasSubscription;
  final String status;
  final bool isValid;
  final String message;
  final List<String> entitlements;
  final UserSubscriptionDetails? subscription;

  const SubscriptionStatusResponse({
    this.isPremium = false,
    this.hasSubscription = false,
    this.status = 'none',
    this.isValid = false,
    this.message = '',
    this.entitlements = const [],
    this.subscription,
  });

  factory SubscriptionStatusResponse.fromJson(Map<String, dynamic> json) {
    final entJson = json['entitlements'];
    final subJson = json['subscription'];

    return SubscriptionStatusResponse(
      isPremium: json['is_premium'] == true,
      hasSubscription: json['has_subscription'] == true,
      status: json['status']?.toString() ?? 'none',
      isValid: json['is_valid'] == true,
      message: json['message']?.toString() ?? '',
      entitlements: entJson is List
          ? entJson.map((e) => e.toString()).toList(growable: false)
          : const [],
      subscription: subJson is Map<String, dynamic>
          ? UserSubscriptionDetails.fromJson(subJson)
          : (subJson is Map
              ? UserSubscriptionDetails.fromJson(
                  Map<String, dynamic>.from(subJson))
              : null),
    );
  }
}

class SubscriptionPlanItem {
  final int id;
  final String title;
  final String tierBadge;
  final String monthlyPrice;
  final String yearlyPrice;
  final String googleMonthlyProductId;
  final String googleYearlyProductId;
  final String appleMonthlyProductId;
  final String appleYearlyProductId;
  final List<String> benefits;

  const SubscriptionPlanItem({
    required this.id,
    required this.title,
    this.tierBadge = 'PRO',
    this.monthlyPrice = '14.99',
    this.yearlyPrice = '119.99',
    this.googleMonthlyProductId = 'hykx_pro_monthly',
    this.googleYearlyProductId = 'hykx_pro_yearly',
    this.appleMonthlyProductId = 'hykx_pro_monthly',
    this.appleYearlyProductId = 'hykx_pro_yearly',
    this.benefits = const [],
  });

  factory SubscriptionPlanItem.fromJson(Map<String, dynamic> json) {
    final bJson = json['benefits'];
    return SubscriptionPlanItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 1,
      title: json['title']?.toString() ?? 'HYKX Pro',
      tierBadge: json['tier_badge']?.toString() ?? 'PRO',
      monthlyPrice: json['monthly_price']?.toString() ?? '14.99',
      yearlyPrice: json['yearly_price']?.toString() ?? '119.99',
      googleMonthlyProductId:
          json['google_monthly_product_id']?.toString() ?? 'hykx_pro_monthly',
      googleYearlyProductId:
          json['google_yearly_product_id']?.toString() ?? 'hykx_pro_yearly',
      appleMonthlyProductId:
          json['apple_monthly_product_id']?.toString() ?? 'hykx_pro_monthly',
      appleYearlyProductId:
          json['apple_yearly_product_id']?.toString() ?? 'hykx_pro_yearly',
      benefits: bJson is List
          ? bJson.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

class GooglePlayVerifyRequest {
  final String productId;
  final String purchaseToken;
  final String orderId;
  final String packageName;
  final String billingCycle;

  const GooglePlayVerifyRequest({
    required this.productId,
    required this.purchaseToken,
    required this.orderId,
    this.packageName = 'com.hykx.app',
    this.billingCycle = 'monthly',
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'purchase_token': purchaseToken,
    'order_id': orderId,
    'package_name': packageName,
    'billing_cycle': billingCycle,
  };
}

class AppleVerifyRequest {
  final String productId;
  final String originalTransactionId;
  final String transactionId;
  final String? signedTransactionInfo;
  final String billingCycle;

  const AppleVerifyRequest({
    required this.productId,
    required this.originalTransactionId,
    required this.transactionId,
    this.signedTransactionInfo,
    this.billingCycle = 'yearly',
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'original_transaction_id': originalTransactionId,
    'transaction_id': transactionId,
    if (signedTransactionInfo != null)
      'signed_transaction_info': signedTransactionInfo,
    'billing_cycle': billingCycle,
  };
}

class RestorePurchaseItem {
  final String store; // "google_play" or "apple_app_store"
  final String productId;
  final String? purchaseToken;
  final String? transactionId;
  final String? originalTransactionId;
  final String? signedTransactionInfo;

  const RestorePurchaseItem({
    required this.store,
    required this.productId,
    this.purchaseToken,
    this.transactionId,
    this.originalTransactionId,
    this.signedTransactionInfo,
  });

  Map<String, dynamic> toJson() => {
    'store': store,
    'product_id': productId,
    if (purchaseToken != null) 'purchase_token': purchaseToken,
    if (transactionId != null) 'transaction_id': transactionId,
    if (originalTransactionId != null)
      'original_transaction_id': originalTransactionId,
    if (signedTransactionInfo != null)
      'signed_transaction_info': signedTransactionInfo,
  };
}

class RestorePurchasesRequest {
  final List<RestorePurchaseItem> purchases;

  const RestorePurchasesRequest({required this.purchases});

  Map<String, dynamic> toJson() => {
    'purchases': purchases.map((p) => p.toJson()).toList(growable: false),
  };
}

class RestorePurchasesResponse {
  final bool success;
  final bool isPremium;
  final int restoredCount;
  final String message;
  final UserSubscriptionDetails? subscription;

  const RestorePurchasesResponse({
    this.success = false,
    this.isPremium = false,
    this.restoredCount = 0,
    this.message = '',
    this.subscription,
  });

  factory RestorePurchasesResponse.fromJson(Map<String, dynamic> json) {
    final subJson = json['subscription'];
    return RestorePurchasesResponse(
      success: json['success'] == true,
      isPremium: json['is_premium'] == true,
      restoredCount:
          int.tryParse(json['restored_count']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      subscription: subJson is Map<String, dynamic>
          ? UserSubscriptionDetails.fromJson(subJson)
          : (subJson is Map
              ? UserSubscriptionDetails.fromJson(
                  Map<String, dynamic>.from(subJson))
              : null),
    );
  }
}
