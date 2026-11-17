import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/profile/model/subscription_model.dart';

class SubscriptionApiService {
  SubscriptionApiService({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in to manage your subscription.',
        statusCode: 401,
      );
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  /// Endpoint 5.1: Check Entitlement & Subscription Status
  Future<SubscriptionStatusResponse> getSubscriptionStatus() async {
    final url = ApiEndpoint.subscriptionStatus;
    debugPrint('[API HIT][GET] /subscriptions/status/ -> $url');

    try {
      final data = await _apiClient.get(
        url: url,
        headers: _authHeaders,
        logLabel: 'GET /subscriptions/status/',
        showDebugLog: true,
      );

      final status = SubscriptionStatusResponse.fromJson(data);
      debugPrint(
        'Subscription status: isPremium=${status.isPremium}, status=${status.status}, entitlements=${status.entitlements.length}',
      );
      return status;
    } catch (e) {
      debugPrint('Error getting subscription status: $e');
      return const SubscriptionStatusResponse();
    }
  }

  /// Fetch Available Store Plans
  Future<List<SubscriptionPlanItem>> getSubscriptionPlans() async {
    final url = ApiEndpoint.subscriptionPlans;
    debugPrint('[API HIT][GET] /subscriptions/plans/ -> $url');

    try {
      final List<dynamic> data = await _apiClient.getList(
        url: url,
        headers: _authHeaders,
        logLabel: 'GET /subscriptions/plans/',
        showDebugLog: true,
      );

      return data
          .map((e) =>
              SubscriptionPlanItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    } catch (e) {
      debugPrint('Error fetching subscription plans: $e');
      // Fallback default HYKX Pro plan
      return const [
        SubscriptionPlanItem(
          id: 1,
          title: 'HYKX Pro',
          tierBadge: 'PRO',
          monthlyPrice: '14.99',
          yearlyPrice: '119.99',
          googleMonthlyProductId: 'hykx_pro_monthly',
          googleYearlyProductId: 'hykx_pro_yearly',
          appleMonthlyProductId: 'hykx_pro_monthly',
          appleYearlyProductId: 'hykx_pro_yearly',
          benefits: [
            'Bespoke 4-day workout splits (Push/Pull/Legs/Rest)',
            'AI Equipment Recognition Scanner',
            'Advanced Progress Analytics & Daily Stats',
            'Unlimited workout session history',
            'Custom workout routines & priority support',
          ],
        ),
      ];
    }
  }

  /// Endpoint 5.2.A: Google Play Verification
  Future<bool> verifyGooglePlayPurchase(
    GooglePlayVerifyRequest request,
  ) async {
    final url = ApiEndpoint.googlePlayVerify;
    debugPrint('[API HIT][POST] /subscriptions/google-play/verify/ -> $url');

    final data = await _apiClient.postJson(
      url: url,
      body: request.toJson(),
      headers: _authHeaders,
      logLabel: 'POST /subscriptions/google-play/verify/',
      showDebugLog: true,
    );

    return data['is_valid'] == true || data['is_premium'] == true;
  }

  /// Endpoint 5.2.B: Apple App Store Verification
  Future<bool> verifyApplePurchase(
    AppleVerifyRequest request,
  ) async {
    final url = ApiEndpoint.appleVerify;
    debugPrint('[API HIT][POST] /subscriptions/apple/verify/ -> $url');

    final data = await _apiClient.postJson(
      url: url,
      body: request.toJson(),
      headers: _authHeaders,
      logLabel: 'POST /subscriptions/apple/verify/',
      showDebugLog: true,
    );

    return data['is_valid'] == true || data['is_premium'] == true;
  }

  /// Section 4: Restore Purchases
  Future<RestorePurchasesResponse> restorePurchases(
    RestorePurchasesRequest request,
  ) async {
    final url = ApiEndpoint.subscriptionRestore;
    debugPrint('[API HIT][POST] /subscriptions/restore/ -> $url');

    final data = await _apiClient.postJson(
      url: url,
      body: request.toJson(),
      headers: _authHeaders,
      logLabel: 'POST /subscriptions/restore/',
      showDebugLog: true,
    );

    return RestorePurchasesResponse.fromJson(data);
  }
}
