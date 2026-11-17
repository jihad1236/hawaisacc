import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/profile/model/subscription_model.dart';
import 'package:hawiisaac/features/profile/services/subscription_api_service.dart';

class UserSubscriptionController extends GetxController {
  UserSubscriptionController({SubscriptionApiService? apiService})
      : _apiService = apiService ?? SubscriptionApiService();

  final SubscriptionApiService _apiService;

  final RxBool isLoading = false.obs;
  final RxBool isPremium = false.obs;
  final RxBool hasSubscription = false.obs;
  final RxString status = 'none'.obs;
  final RxList<String> entitlements = <String>[].obs;
  final Rxn<UserSubscriptionDetails> subscription =
      Rxn<UserSubscriptionDetails>();

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasAccessToken) {
      refreshStatus();
    }
  }

  Future<void> refreshStatus() async {
    if (!StorageService.hasAccessToken) {
      isPremium.value = false;
      hasSubscription.value = false;
      entitlements.clear();
      subscription.value = null;
      return;
    }

    isLoading.value = true;
    try {
      final res = await _apiService.getSubscriptionStatus();
      isPremium.value = res.isPremium;
      hasSubscription.value = res.hasSubscription;
      status.value = res.status;
      entitlements.assignAll(res.entitlements);
      subscription.value = res.subscription;

      debugPrint(
        '[UserSubscriptionController] Updated: isPremium=${isPremium.value}, entitlements=${entitlements.length}',
      );
    } catch (e) {
      debugPrint('[UserSubscriptionController] Error loading status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Feature entitlement check (e.g. 'bespoke_workout_plans', 'ai_equipment_scanner', 'advanced_progress_analytics')
  bool hasEntitlement(String entitlement) {
    if (isPremium.value) {
      if (entitlements.isEmpty) return true; // Default full access when premium
      return entitlements.contains(entitlement);
    }
    return false;
  }
}
