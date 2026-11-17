import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/loggin/services/loggin_api_service.dart';
import 'package:hawiisaac/features/scan/model/scan_exercise_detail.dart';
import 'package:hawiisaac/features/scan/model/workout_item.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/features/sessions/services/session_api_service.dart';
import 'package:hawiisaac/features/bottom_navigation/controllers/bottom_navigation_controller.dart';
import 'package:hawiisaac/features/loggin/controller/logging_controller.dart';
import 'package:hawiisaac/features/loggin/model/workout_logging_preset.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class ExerciseDetailController extends GetxController {
  final SessionApiService _sessionApiService = SessionApiService();
  final EquipmentApiService _equipmentApiService = EquipmentApiService();
  final LogginApiService _logginApiService = LogginApiService();
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isStartingWorkout = false.obs;

  // ─── Exercise Info ───────────────────────────────────────────────
  String exerciseName = '';
  String category = '';
  String muscleGroup = '';
  String imageUrl = '';
  String videoUrl = '';
  int workoutId = 0;
  bool isCardioWorkout = false;

  // ─── Stats ───────────────────────────────────────────────────────
  String sets = '';
  String reps = '';
  String rest = '';
  String duration = '';
  String time = '';
  String distance = '';
  String speed = '';
  String incline = '';
  String kg = '';

  // ─── Muscle Tags ─────────────────────────────────────────────────
  Map<String, bool> muscleTags = {};

  // ─── How-to Steps ────────────────────────────────────────────────
  List<String> steps = [];

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments is Map) {
      _applyWorkout(arguments);
    }

    _loadWorkoutDetail();
  }

  void retry() {
    _loadWorkoutDetail();
  }

  // ─── Actions ─────────────────────────────────────────────────────
  Future<void> addToWorkout() async {
    if (isStartingWorkout.value) return;
    await _startWorkoutLog();
  }

  void _applyWorkout(Map<dynamic, dynamic> workout) {
    workoutId = int.tryParse(workout['id']?.toString() ?? '') ?? 0;
    final title = workout['title']?.toString() ?? '';
    final description = workout['description']?.toString() ?? '';
    final categoryValue = workout['category']?.toString() ?? '';
    final equipmentValue = workout['equipment']?.toString() ?? '';
    final imageValue = workout['imageUrl']?.toString() ?? '';
    final videoValue = workout['video']?.toString() ?? '';
    final workoutTypeValue = workout['workoutType']?.toString() ?? '';
    final usesValue = workout['uses'];

    if (title.isNotEmpty) exerciseName = title;
    if (categoryValue.isNotEmpty) category = categoryValue;
    if (equipmentValue.isNotEmpty) muscleGroup = equipmentValue;
    if (imageValue.isNotEmpty) imageUrl = imageValue;
    if (videoValue.isNotEmpty) videoUrl = videoValue;
    isCardioWorkout =
        workoutTypeValue.toLowerCase() == 'cardio' ||
        time.isNotEmpty ||
        distance.isNotEmpty ||
        speed.isNotEmpty ||
        incline.isNotEmpty;

    sets = workout['sets']?.toString().trim() ?? '';
    reps = workout['reps']?.toString().trim() ?? '';
    rest = workout['rest']?.toString().trim() ?? '';
    duration = workout['duration']?.toString().trim() ?? '';
    time = _normalizeMetricValue(workout['time']);
    distance = _normalizeMetricValue(workout['distance']);
    speed = _normalizeMetricValue(workout['speed']);
    incline = _normalizeMetricValue(workout['incline']);
    kg = _normalizeMetricValue(workout['kg'] ?? workout['weight']);

    final muscles = workout['muscleGroups'];
    if (muscles is List && muscles.isNotEmpty) {
      muscleTags = {
        for (final entry in muscles.asMap().entries)
          entry.value.toString(): entry.key == 0,
      };
    } else {
      muscleTags = {};
    }

    if (usesValue is List && usesValue.isNotEmpty) {
      steps = usesValue.map((use) => use.toString()).toList(growable: false);
    } else if (description.isNotEmpty) {
      steps = [description];
    } else {
      steps = [];
    }
  }

  Future<void> _loadWorkoutDetail() async {
    if (workoutId <= 0) {
      isLoading.value = false;
      if (exerciseName.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'Exercise information is missing.';
      }
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      try {
        final scanDetail = await _equipmentApiService.getScanExerciseById(
          workoutId,
        );
        _applyScanExerciseDetail(scanDetail);
        isLoading.value = false;
        return;
      } catch (e) {
        debugPrint('Scan exercise detail API error, trying workout detail: $e');
      }

      final detail = await _equipmentApiService.getWorkoutById(workoutId);
      _applyWorkoutDetail(detail);
    } on AuthException catch (error) {
      if (exerciseName.isEmpty) {
        hasError.value = true;
        errorMessage.value = error.message;
      } else {
        AppLoadingService.showError('Exercise Load Failed', error.message);
      }
    } catch (_) {
      if (exerciseName.isEmpty) {
        hasError.value = true;
        errorMessage.value =
            'Unable to load exercise details. Please check your connection.';
      } else {
        AppLoadingService.showError(
          'Exercise Load Failed',
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _applyScanExerciseDetail(ScanExerciseDetail detail) {
    workoutId = detail.id;
    exerciseName = detail.displayName;
    category = detail.flag.isNotEmpty
        ? detail.flag
        : (detail.exerciseType.isNotEmpty ? detail.exerciseType : '');
    muscleGroup = detail.primaryMuscle.isNotEmpty
        ? detail.primaryMuscle
        : (detail.difficulty.isNotEmpty ? detail.difficulty : '');

    if (detail.image != null && detail.image!.isNotEmpty) {
      imageUrl = detail.image!;
    }
    if (detail.video != null && detail.video!.isNotEmpty) {
      videoUrl = detail.video!;
    }

    sets = detail.sets;
    reps = detail.reps;
    rest = detail.rest;
    if (detail.durationMinutes > 0) {
      duration = '${detail.durationMinutes} min';
    }

    final tags = detail.displayTags;
    if (tags.isNotEmpty) {
      muscleTags = {for (final tag in tags) tag: true};
    } else {
      muscleTags = {};
    }

    steps = detail.displaySteps;
  }

  void _applyWorkoutDetail(WorkoutItem workout) {
    workoutId = workout.id;
    exerciseName = workout.name.isNotEmpty ? workout.name : exerciseName;
    category = workout.category.name.isNotEmpty
        ? workout.category.name
        : category;
    muscleGroup = workout.equipment.name.isNotEmpty
        ? workout.equipment.name
        : muscleGroup;
    imageUrl = workout.banner.isNotEmpty ? workout.banner : imageUrl;
    videoUrl = workout.video.isNotEmpty ? workout.video : videoUrl;
    isCardioWorkout = workout.workoutType.toLowerCase() == 'cardio';

    if (workout.sets.isNotEmpty) sets = workout.sets;
    if (workout.reps.isNotEmpty) reps = workout.reps;
    if (workout.rest.isNotEmpty) rest = workout.rest;
    time = _normalizeMetricValue(workout.time);
    if (time.isEmpty) {
      time = _normalizeMetricValue(workout.duration);
    }
    distance = _normalizeMetricValue(workout.distance);
    speed = _normalizeMetricValue(workout.speed);
    incline = _normalizeMetricValue(workout.incline);
    isCardioWorkout =
        workout.workoutType.toLowerCase() == 'cardio' ||
        time.isNotEmpty ||
        distance.isNotEmpty ||
        speed.isNotEmpty ||
        incline.isNotEmpty;

    if (workout.muscleGroups.isNotEmpty) {
      muscleTags = {
        for (final entry in workout.muscleGroups.asMap().entries)
          entry.value.name: entry.key == 0,
      };
    }

    if (workout.description.trim().isNotEmpty) {
      steps = <String>[workout.description.trim()];
    }

    if (workout.uses.isNotEmpty) {
      steps = <String>[
        if (workout.description.trim().isNotEmpty) workout.description.trim(),
        ...workout.uses.map((use) => 'Best for ${use.toString()}'),
      ];
    }
  }

  Future<void> _startWorkoutLog() async {
    if (workoutId <= 0) {
      AppLoadingService.showError(
        'Start Failed',
        'Workout information is missing.',
      );
      return;
    }

    isStartingWorkout.value = true;

    try {
      debugPrint(
        'Add to workout tapped: workoutId=$workoutId, title=$exerciseName',
      );

      // The active-session endpoint stores logged sets, but does not accept
      // the workout detail's recommended sets/reps template. Keep the typed
      // template available for the Logging tab before changing tabs.
      WorkoutLoggingPresetStore.shared.save(
        WorkoutLoggingPreset.fromDetail(
          exerciseId: workoutId,
          title: exerciseName,
          sets: sets,
          reps: reps,
          kg: kg,
          tags: muscleGroup,
          isCardio: isCardioWorkout || category.toLowerCase() == 'cardio',
        ),
      );

      try {
        final session = await _logginApiService.addExerciseToSession(
          exerciseId: workoutId,
          targetTimeSeconds: 45,
        );
        debugPrint(
          'Add to workout response session: hasActive=${session.hasActiveSession}, id=${session.id}',
        );
      } catch (e) {
        debugPrint('addExerciseToSession error (will proceed to logging): $e');
        // Fallback to legacy startWorkoutLog if active endpoint is unavailable
        try {
          await _sessionApiService.startWorkoutLog(workoutId);
        } catch (_) {}
      }

      // ── Trigger auto-refresh of Logging screen ──
      if (Get.isRegistered<LoggingController>()) {
        Get.find<LoggingController>().loadActiveSession(showLoading: false);
      }

      AppLoadingService.showSuccess(
        'Added to Workout',
        '$exerciseName added to your workout log!',
      );

      // If user came from bottom navigation, switch to Log tab (Tab 2)
      if (Get.isRegistered<BottomNavigationController>()) {
        final navController = Get.find<BottomNavigationController>();
        navController.changeTab(2);
        // Pop back to root of bottom nav if ExerciseDetail was pushed on top
        Get.until(
          (route) =>
              route.settings.name == AppRoute.getBottomNavigationScreen() ||
              route.isFirst,
        );
      } else {
        Get.toNamed(
          AppRoute.getLoggingScreen(),
          arguments: <String, dynamic>{
            'exercise_id': workoutId,
            'title': exerciseName,
            'tags': muscleGroup,
            'sets': sets,
            'reps': reps,
            'rest': rest,
            'time': time,
            'distance': distance,
            'speed': speed,
            'incline': incline,
            'kg': kg,
            'is_cardio': isCardioWorkout || category.toLowerCase() == 'cardio',
          },
        );
      }
    } on AuthException catch (error) {
      debugPrint('Start workout auth error: ${error.message}');
      AppLoadingService.showError('Start Failed', error.message);
    } catch (error) {
      debugPrint('Start workout unexpected error: $error');
      AppLoadingService.showError(
        'Start Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isStartingWorkout.value = false;
    }
  }

  String _normalizeMetricValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') {
      return '';
    }
    if (text == '0' || text == '0.0') {
      return '';
    }
    return text;
  }
}
