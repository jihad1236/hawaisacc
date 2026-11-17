import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/workout_profile_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/workout_profile_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class WorkoutProfileController extends GetxController {
  final WorkoutProfileService _profileService = WorkoutProfileService();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxString selectedGoal = 'muscle_gain'.obs;
  final RxString selectedLevel = 'intermediate'.obs;
  final RxString selectedLocation = 'gym'.obs;
  final RxInt workoutDays = 4.obs;
  final RxInt sessionDuration = 45.obs;
  final RxBool isLoading = false.obs;

  // ─── Options (aligned with guidance.md) ──────────────────────────────────────
  static const List<Map<String, String>> goalOptions = [
    {'value': 'muscle_gain', 'label': 'Muscle Gain', 'desc': 'Build muscle & increase size'},
    {'value': 'fat_loss', 'label': 'Fat Loss', 'desc': 'Burn calories & get shredded'},
    {'value': 'strength', 'label': 'Strength', 'desc': 'Lift heavier & increase power'},
    {'value': 'endurance', 'label': 'Endurance', 'desc': 'Improve stamina & cardiovascular fitness'},
    {'value': 'general_fitness', 'label': 'General Fitness', 'desc': 'Stay active & maintain overall health'},
  ];

  static const List<Map<String, String>> levelOptions = [
    {'value': 'beginner', 'label': 'Beginner', 'desc': 'New to training or getting back in'},
    {'value': 'intermediate', 'label': 'Intermediate', 'desc': 'Consistent with regular workouts'},
    {'value': 'advanced', 'label': 'Advanced', 'desc': 'Years of structured training'},
  ];

  static const List<Map<String, String>> locationOptions = [
    {'value': 'gym', 'label': 'Gym', 'desc': 'Full gym machines, barbells & dumbbells'},
    {'value': 'home', 'label': 'Home', 'desc': 'Dumbbells, bodyweight & basic gear'},
  ];

  static const List<int> durationOptions = [15, 30, 45, 60, 90];

  @override
  void onInit() {
    super.onInit();
    loadExistingProfile();
  }

  Future<void> loadExistingProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (profile.goal != null && profile.goal!.isNotEmpty) {
        selectedGoal.value = profile.goal!;
      }
      if (profile.level != null && profile.level!.isNotEmpty) {
        selectedLevel.value = profile.level!;
      }
      if (profile.location != null && profile.location!.isNotEmpty) {
        selectedLocation.value = profile.location!;
      }
      if (profile.workoutDays != null && profile.workoutDays! > 0) {
        workoutDays.value = profile.workoutDays!;
      }
      if (profile.sessionDuration != null && profile.sessionDuration! > 0) {
        sessionDuration.value = profile.sessionDuration!;
      }
    } catch (e) {
      debugPrint('WorkoutProfileController: profile load notice ($e)');
    }
  }

  void setGoal(String goal) => selectedGoal.value = goal;
  void setLevel(String level) => selectedLevel.value = level;
  void setLocation(String loc) => selectedLocation.value = loc;
  void setWorkoutDays(int days) => workoutDays.value = days;
  void setSessionDuration(int mins) => sessionDuration.value = mins;

  Future<void> submitProfile() async {
    isLoading.value = true;

    try {
      final request = WorkoutProfileRequest(
        goal: selectedGoal.value,
        level: selectedLevel.value,
        location: selectedLocation.value,
        workoutDays: workoutDays.value,
        sessionDuration: sessionDuration.value,
      );

      await _profileService.updateFullProfile(request);

      await StorageService.setHasSelectedUnits(true);
      AppLoadingService.showSuccess('Profile Ready', 'Your workout plan is configured!');
      Get.offAllNamed(AppRoute.getBottomNavigationScreen());
    } on AuthException catch (e) {
      AppLoadingService.showError('Profile Setup Failed', e.message);
    } catch (e) {
      AppLoadingService.showError('Error', 'Failed to save workout profile. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
