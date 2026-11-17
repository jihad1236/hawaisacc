class RecordWorkoutSetItem {
  final int setNumber;
  final double weightKg;
  final int reps;
  final bool isCompleted;

  const RecordWorkoutSetItem({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.isCompleted = true,
  });

  Map<String, dynamic> toJson() => {
    'set_number': setNumber,
    'weight_kg': weightKg,
    'reps': reps,
    'is_completed': isCompleted,
  };

  factory RecordWorkoutSetItem.fromJson(Map<String, dynamic> json) {
    return RecordWorkoutSetItem(
      setNumber: int.tryParse(json['set_number']?.toString() ?? '') ?? 1,
      weightKg: double.tryParse(json['weight_kg']?.toString() ?? '') ?? 0.0,
      reps: int.tryParse(json['reps']?.toString() ?? '') ?? 0,
      isCompleted: json['is_completed'] != false,
    );
  }
}

class RecordWorkoutExerciseItem {
  final int? workoutId;
  final String customTitle;
  final String note;
  final List<RecordWorkoutSetItem> sets;

  const RecordWorkoutExerciseItem({
    this.workoutId,
    required this.customTitle,
    this.note = '',
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
    if (workoutId != null) 'workout_id': workoutId,
    'custom_title': customTitle,
    if (note.isNotEmpty) 'note': note,
    'sets': sets.map((s) => s.toJson()).toList(growable: false),
  };

  factory RecordWorkoutExerciseItem.fromJson(Map<String, dynamic> json) {
    final setsJson = json['sets'];
    return RecordWorkoutExerciseItem(
      workoutId: int.tryParse(json['workout_id']?.toString() ?? ''),
      customTitle: json['custom_title']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      sets: setsJson is List
          ? setsJson
              .map((s) => RecordWorkoutSetItem.fromJson(
                  Map<String, dynamic>.from(s as Map)))
              .toList(growable: false)
          : const [],
    );
  }
}

class RecordWorkoutSessionRequest {
  final int? planId;
  final String workoutDay;
  final int dayNumber;
  final String workoutDate;
  final int durationMinutes;
  final int caloriesBurned;
  final String note;
  final List<RecordWorkoutExerciseItem> exercises;

  const RecordWorkoutSessionRequest({
    this.planId,
    required this.workoutDay,
    this.dayNumber = 1,
    required this.workoutDate,
    required this.durationMinutes,
    this.caloriesBurned = 0,
    this.note = '',
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    if (planId != null) 'plan_id': planId,
    'workout_day': workoutDay,
    'day_number': dayNumber,
    'workout_date': workoutDate,
    'duration_minutes': durationMinutes,
    'calories_burned': caloriesBurned,
    if (note.isNotEmpty) 'note': note,
    'exercises': exercises.map((e) => e.toJson()).toList(growable: false),
  };
}

class RecordWorkoutSessionResponse {
  final int sessionId;
  final String title;
  final String status;
  final int? planId;
  final String? planTitle;
  final String? workoutDay;
  final int? dayNumber;
  final String? workoutDate;
  final String? startedAt;
  final String? completedAt;
  final int durationSeconds;
  final String timerDisplay;
  final int caloriesBurned;
  final double totalVolume;
  final String totalVolumeDisplay;
  final int totalSets;
  final int exerciseCount;
  final List<String> muscleGroups;
  final String note;
  final int completedExercises;

  const RecordWorkoutSessionResponse({
    required this.sessionId,
    required this.title,
    required this.status,
    this.planId,
    this.planTitle,
    this.workoutDay,
    this.dayNumber,
    this.workoutDate,
    this.startedAt,
    this.completedAt,
    this.durationSeconds = 0,
    this.timerDisplay = '00:00',
    this.caloriesBurned = 0,
    this.totalVolume = 0.0,
    this.totalVolumeDisplay = '0 kg',
    this.totalSets = 0,
    this.exerciseCount = 0,
    this.muscleGroups = const [],
    this.note = '',
    this.completedExercises = 0,
  });

  factory RecordWorkoutSessionResponse.fromJson(Map<String, dynamic> json) {
    final mgJson = json['muscle_groups'];
    final idVal = int.tryParse(json['session_id']?.toString() ?? '') ??
        int.tryParse(json['id']?.toString() ?? '') ??
        0;

    final volumeVal =
        double.tryParse(json['total_volume']?.toString() ?? '') ?? 0.0;

    return RecordWorkoutSessionResponse(
      sessionId: idVal,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
      planId: int.tryParse(json['plan_id']?.toString() ?? ''),
      planTitle: json['plan_title']?.toString(),
      workoutDay: json['workout_day']?.toString(),
      dayNumber: int.tryParse(json['day_number']?.toString() ?? ''),
      workoutDate: json['workout_date']?.toString(),
      startedAt: json['started_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      durationSeconds:
          int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
      timerDisplay: json['timer_display']?.toString() ?? '00:00',
      caloriesBurned:
          int.tryParse(json['calories_burned']?.toString() ?? '') ?? 0,
      totalVolume: volumeVal,
      totalVolumeDisplay: json['total_volume_display']?.toString() ??
          '${volumeVal.toStringAsFixed(0)} kg',
      totalSets: int.tryParse(json['total_sets']?.toString() ?? '') ?? 0,
      exerciseCount:
          int.tryParse(json['exercise_count']?.toString() ?? '') ?? 0,
      muscleGroups: mgJson is List
          ? mgJson.map((e) => e.toString()).toList(growable: false)
          : const [],
      note: json['note']?.toString() ?? '',
      completedExercises:
          int.tryParse(json['completed_exercises']?.toString() ?? '') ?? 0,
    );
  }
}
