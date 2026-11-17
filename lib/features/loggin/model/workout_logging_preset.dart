import 'package:get/get.dart';

/// The client-side logging template received from the exercise detail screen.
///
/// The active-session API stores logged sets, but it does not currently return
/// the recommended set/reps template from the workout detail API. This model
/// bridges that gap while the user moves from detail to logging.
class WorkoutLoggingPreset {
  final int exerciseId;
  final String title;
  final int? targetSetCount;
  final int? targetReps;
  final double initialKg;
  final String tags;
  final bool isCardio;

  const WorkoutLoggingPreset({
    required this.exerciseId,
    this.title = '',
    this.targetSetCount,
    this.targetReps,
    this.initialKg = 0.0,
    this.tags = '',
    this.isCardio = false,
  });

  factory WorkoutLoggingPreset.fromDetail({
    required int exerciseId,
    required String title,
    required String sets,
    required String reps,
    required String kg,
    required String tags,
    required bool isCardio,
  }) {
    return WorkoutLoggingPreset(
      exerciseId: exerciseId,
      title: title,
      targetSetCount: WorkoutTargetParser.parseSets(sets),
      targetReps: WorkoutTargetParser.parseReps(reps),
      initialKg: WorkoutTargetParser.parseWeight(kg),
      tags: tags,
      isCardio: isCardio,
    );
  }

  factory WorkoutLoggingPreset.fromArguments(Map<dynamic, dynamic> arguments) {
    final exerciseId =
        int.tryParse(arguments['exercise_id']?.toString() ?? '') ??
        int.tryParse(arguments['session_workout_id']?.toString() ?? '') ??
        1;

    return WorkoutLoggingPreset.fromDetail(
      exerciseId: exerciseId,
      title: arguments['title']?.toString() ?? '',
      sets: arguments['sets']?.toString() ?? '',
      reps: arguments['reps']?.toString() ?? '',
      kg: arguments['kg']?.toString() ?? '',
      tags: arguments['tags']?.toString() ?? '',
      isCardio: arguments['is_cardio'] == true,
    );
  }
}

/// Parses the compact target strings returned by workout detail APIs.
class WorkoutTargetParser {
  static int? parseSets(String? value) {
    return _parse(value, useUpperBound: true, max: 10);
  }

  static int? parseReps(String? value) {
    return _parse(value, useUpperBound: false, max: 999);
  }

  static double parseWeight(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 0.0;
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(text);
    return double.tryParse(match?.group(0) ?? '') ?? 0.0;
  }

  static int? _parse(
    String? value, {
    required bool useUpperBound,
    required int max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final match = RegExp(
      r'^(\d+)(?:\s*[-–—]\s*(\d+))?\s*(?:sets?|reps?)?$',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;

    final first = int.tryParse(match.group(1) ?? '');
    final second = int.tryParse(match.group(2) ?? '');
    final parsed = second == null
        ? first
        : (useUpperBound ? (first! > second ? first : second) : first);

    if (parsed == null || parsed <= 0) return null;
    return parsed.clamp(1, max);
  }
}

/// A short-lived handoff between exercise detail and the logging tab.
class WorkoutLoggingPresetStore extends GetxService {
  final Map<int, WorkoutLoggingPreset> _presets = {};

  static WorkoutLoggingPresetStore get shared {
    if (Get.isRegistered<WorkoutLoggingPresetStore>()) {
      return Get.find<WorkoutLoggingPresetStore>();
    }
    return Get.put(WorkoutLoggingPresetStore(), permanent: true);
  }

  void save(WorkoutLoggingPreset preset) {
    if (preset.exerciseId <= 0) return;
    _presets[preset.exerciseId] = preset;
  }

  WorkoutLoggingPreset? find(int exerciseId) => _presets[exerciseId];

  void clearAll() => _presets.clear();
}
