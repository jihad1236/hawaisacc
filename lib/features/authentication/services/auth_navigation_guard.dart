import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/workout_profile_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class AuthNavigationGuard {
  AuthNavigationGuard._();

  static final WorkoutProfileService _profileService = WorkoutProfileService();

  /// Directs authenticated user based on their onboarding completion status
  static Future<void> handlePostAuthNavigation() async {
    if (!StorageService.hasAccessToken) {
      Get.offAllNamed(AppRoute.getAuthOptionsScreen());
      return;
    }

    try {
      debugPrint('AuthNavigationGuard: checking workout profile status...');
      final profile = await _profileService.getProfile();

      if (profile.isCompleted) {
        debugPrint('AuthNavigationGuard: profile completed -> home');
        await StorageService.setHasSelectedUnits(true);
        Get.offAllNamed(AppRoute.getBottomNavigationScreen());
      } else {
        debugPrint('AuthNavigationGuard: profile incomplete -> onboarding');
        if (StorageService.hasSelectedUnits) {
          Get.offAllNamed(AppRoute.getWorkoutProfileScreen());
        } else {
          Get.offAllNamed(AppRoute.getSelectUnitsScreen());
        }
      }
    } catch (error) {
      debugPrint('AuthNavigationGuard: check failed ($error), fallback to local state');
      if (StorageService.hasSelectedUnits) {
        Get.offAllNamed(AppRoute.getBottomNavigationScreen());
      } else {
        Get.offAllNamed(AppRoute.getSelectUnitsScreen());
      }
    }
  }
}
