import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/model/plan_detail_model.dart';
import 'package:hawiisaac/features/home/services/plan_api_service.dart';
import 'package:hawiisaac/features/loggin/services/loggin_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class WarmUpDetailsController extends GetxController {
  final PlanApiService _planApiService = PlanApiService();
  final LogginApiService _logginApiService = LogginApiService();

  final Rxn<Map<String, String>> workout = Rxn<Map<String, String>>();
  final Rxn<PlanDetailResponse> planDetail = Rxn<PlanDetailResponse>();
  final RxBool isLoading = true.obs;
  final RxBool isStartingExercise = false.obs;
  final RxString errorMessage = ''.obs;

  // ── 4-Day Cycle Schedule Support ──────────────────────────────────────────
  final RxInt selectedDayIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      workout.value = args.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    final id = int.tryParse(workout.value?['id'] ?? '');
    if (id != null && id > 0) {
      debugPrint('WarmUpDetails init: loading plan detail for id=$id');
      fetchPlanDetail(id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchPlanDetail(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final detail = await _planApiService.getPlanById(id);
      planDetail.value = detail;
      selectedDayIndex.value = 0;
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      AppLoadingService.showError('Plan Failed', error.message);
    } catch (e) {
      debugPrint('Error fetching plan detail: $e');
      errorMessage.value = 'Failed to load plan details. Please try again.';
      AppLoadingService.showError('Plan Failed', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void selectDay(int index) {
    if (hasSchedule && index >= 0 && index < scheduleDays.length) {
      selectedDayIndex.value = index;
    }
  }

  bool get hasSchedule =>
      planDetail.value != null && planDetail.value!.schedule.isNotEmpty;

  List<PlanScheduleDayItem> get scheduleDays =>
      planDetail.value?.schedule ?? const <PlanScheduleDayItem>[];

  PlanScheduleDayItem? get currentScheduleDay {
    if (!hasSchedule) return null;
    final idx = selectedDayIndex.value;
    if (idx >= 0 && idx < scheduleDays.length) {
      return scheduleDays[idx];
    }
    return scheduleDays.first;
  }

  bool get isCurrentDayRest => currentScheduleDay?.isRestDay ?? false;

  String get appBarTitle {
    final loc = planDetail.value?.location.trim();
    if (loc != null && loc.isNotEmpty) {
      return '${_titleCase(loc)} Workout Split';
    }
    final cat = planDetail.value?.categoryName?.trim();
    if (cat != null && cat.isNotEmpty) return cat;
    final tag = workout.value?['tags']?.trim();
    if (tag != null && tag.isNotEmpty) return tag;
    return 'Workout Plan';
  }

  String get planTitle {
    final title = planDetail.value?.title.trim();
    if (title != null && title.isNotEmpty) return title;
    return workout.value?['title'] ?? 'Full Body Split Program';
  }

  String get planSubtitle {
    final sub = planDetail.value?.subtitle.trim();
    if (sub != null && sub.isNotEmpty) {
      return sub.replaceAll('•', '.');
    }
    final note = planDetail.value?.equipmentNote.trim();
    final cat = planDetail.value?.categoryName?.trim();
    final level = planDetail.value?.level.trim();
    final parts = [
      if (note != null && note.isNotEmpty) note,
      if (cat != null && cat.isNotEmpty) cat,
      if (level != null && level.isNotEmpty) _titleCase(level),
    ];
    if (parts.isNotEmpty) return parts.join(' . ');
    return 'Free Weights & Machines . Strength & Weights . Intermediate';
  }

  String get calBurn => '${planDetail.value?.caloriesBurn ?? 210}';

  String get durationDisplay =>
      planDetail.value?.durationDisplay.isNotEmpty == true
          ? planDetail.value!.durationDisplay
          : '${planDetail.value?.durationMinutes ?? 30} min';

  String get exercisesCount {
    if (hasSchedule && currentScheduleDay != null) {
      return '${currentScheduleDay!.exerciseCount}';
    }
    return '${planDetail.value?.exercises.length ?? planDetail.value?.exerciseCount ?? 5}';
  }

  String get levelText {
    final lvlDisplay = planDetail.value?.levelDisplay.trim();
    if (lvlDisplay != null && lvlDisplay.isNotEmpty) return lvlDisplay;
    final lvl = planDetail.value?.level.trim();
    if (lvl != null && lvl.isNotEmpty) {
      if (lvl.toLowerCase().contains('begin')) return 'BGN';
      if (lvl.toLowerCase().contains('inter')) return 'INT';
      if (lvl.toLowerCase().contains('adv') ||
          lvl.toLowerCase().contains('hard')) {
        return 'ADV';
      }
      return lvl.toUpperCase();
    }
    return 'INT';
  }

  List<PlanExerciseItem> get exercises {
    if (hasSchedule && currentScheduleDay != null) {
      return currentScheduleDay!.exercises;
    }
    return planDetail.value?.exercises ?? const <PlanExerciseItem>[];
  }

  Future<void> onStartExercise() async {
    final plan = planDetail.value;
    final planId = plan?.id ?? int.tryParse(workout.value?['id'] ?? '');
    if (planId == null || planId <= 0) return;
    if (isStartingExercise.value) return;

    if (isCurrentDayRest) {
      AppLoadingService.showSuccess(
        'Rest & Recovery',
        'Today is programmed for recovery! Allow muscles to rebuild before starting the next cycle.',
      );
      return;
    }

    final activeDay = currentScheduleDay;
    final sessionDayTitle = activeDay != null
        ? '${plan?.title ?? planTitle} - ${activeDay.title}'
        : (plan?.title ?? planTitle);

    isStartingExercise.value = true;
    try {
      final sessionResponse = await _logginApiService.startWorkoutSession(
        planId: planId,
        resume: false,
      );

      Get.toNamed(
        AppRoute.getAiExerciseSessionScreen(),
        arguments: <String, dynamic>{
          'session_id': sessionResponse.sessionId ?? sessionResponse.id,
          'title': sessionResponse.title.isNotEmpty
              ? sessionResponse.title
              : sessionDayTitle,
          'plan_id': planId,
          'workout_day': activeDay?.title ?? 'Day 1: Push',
          'day_number': activeDay?.dayNumber ?? 1,
          'session': sessionResponse.toJson(),
        },
      );
    } on AuthException catch (error) {
      AppLoadingService.showError('Start Failed', error.message);
    } catch (e) {
      debugPrint('Start workout session error: $e');
      if (plan != null) {
        _navigateToDirectSession(plan, activeDay);
      }
    } finally {
      isStartingExercise.value = false;
    }
  }

  void _navigateToDirectSession(
    PlanDetailResponse plan,
    PlanScheduleDayItem? day,
  ) {
    final list = day != null && day.exercises.isNotEmpty
        ? day.exercises
        : plan.exercises;

    final sessionTitle =
        day != null ? '${plan.title} - ${day.title}' : plan.title;

    Get.toNamed(
      AppRoute.getAiExerciseSessionScreen(),
      arguments: <String, dynamic>{
        'title': sessionTitle,
        'plan_id': plan.id,
        'workout_day': day?.title ?? 'Day 1: Push',
        'day_number': day?.dayNumber ?? 1,
        'workouts': list.map((e) {
          return {
            'id': e.workoutId ?? e.id,
            'order': e.order > 0 ? e.order : (list.indexOf(e) + 1),
            'name': e.title,
            'tags': e.subtitle.isNotEmpty
                ? e.subtitle
                : (e.targetMuscles.isNotEmpty
                    ? e.targetMuscles.join(' . ')
                    : planSubtitle),
            'details': e.description,
            'duration': '${e.timeSeconds > 0 ? e.timeSeconds : 45}s',
            'note': '',
            'workout_type': 'strength',
          };
        }).toList(),
      },
    );
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }
}
