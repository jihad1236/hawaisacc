class PlanExerciseItem {
  final int id;
  final int order;
  final String title;
  final String subtitle;
  final List<String> targetMuscles;
  final String description;
  final int timeSeconds;
  final String timeDisplay;
  final int? workoutId;
  final String? image;
  final int? planDay;
  final int? dayNumber;
  final String? dayName;
  final String? muscleGroup;
  final String? difficultyLevel;
  final String? ulc;
  final String? movementPattern;
  final String? modality;
  final String? joint;

  const PlanExerciseItem({
    required this.id,
    this.order = 0,
    required this.title,
    this.subtitle = '',
    this.targetMuscles = const [],
    this.description = '',
    this.timeSeconds = 0,
    this.timeDisplay = '',
    this.workoutId,
    this.image,
    this.planDay,
    this.dayNumber,
    this.dayName,
    this.muscleGroup,
    this.difficultyLevel,
    this.ulc,
    this.movementPattern,
    this.modality,
    this.joint,
  });

  factory PlanExerciseItem.fromJson(Map<String, dynamic> json) {
    final musclesJson = json['target_muscles'];
    final timeSec = int.tryParse(json['time_seconds']?.toString() ?? '') ?? 0;

    return PlanExerciseItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      targetMuscles: musclesJson is List
          ? musclesJson.map((e) => e.toString()).toList(growable: false)
          : const [],
      description: json['description']?.toString() ?? '',
      timeSeconds: timeSec,
      timeDisplay:
          json['time_display']?.toString() ??
          (timeSec > 0 ? '${timeSec}s' : ''),
      workoutId: int.tryParse(json['workout_id']?.toString() ?? ''),
      image: json['image']?.toString(),
      planDay: int.tryParse(json['plan_day']?.toString() ?? ''),
      dayNumber: int.tryParse(json['day_number']?.toString() ?? ''),
      dayName: json['day_name']?.toString(),
      muscleGroup: json['muscle_group']?.toString(),
      difficultyLevel: json['difficulty_level']?.toString(),
      ulc: json['ulc']?.toString(),
      movementPattern: json['movement_pattern']?.toString(),
      modality: json['modality']?.toString(),
      joint: json['joint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'title': title,
    'subtitle': subtitle,
    'target_muscles': targetMuscles,
    'description': description,
    'time_seconds': timeSeconds,
    'time_display': timeDisplay,
    if (workoutId != null) 'workout_id': workoutId,
    if (image != null) 'image': image,
    if (planDay != null) 'plan_day': planDay,
    if (dayNumber != null) 'day_number': dayNumber,
    if (dayName != null) 'day_name': dayName,
    if (muscleGroup != null) 'muscle_group': muscleGroup,
    if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
    if (ulc != null) 'ulc': ulc,
    if (movementPattern != null) 'movement_pattern': movementPattern,
    if (modality != null) 'modality': modality,
    if (joint != null) 'joint': joint,
  };
}

class PlanScheduleDayItem {
  final int id;
  final int dayNumber;
  final String dayName;
  final String splitName;
  final String title;
  final String focus;
  final bool isRestDay;
  final String restNote;
  final int order;
  final int exerciseCount;
  final List<PlanExerciseItem> exercises;

  const PlanScheduleDayItem({
    required this.id,
    required this.dayNumber,
    required this.dayName,
    required this.splitName,
    required this.title,
    required this.focus,
    this.isRestDay = false,
    this.restNote = '',
    this.order = 1,
    this.exerciseCount = 0,
    this.exercises = const [],
  });

  factory PlanScheduleDayItem.fromJson(Map<String, dynamic> json) {
    final exList = json['exercises'];
    final dayNum = int.tryParse(json['day_number']?.toString() ?? '') ?? 1;
    final split = json['split_name']?.toString() ?? '';
    final dName = json['day_name']?.toString() ?? 'Day $dayNum';
    final parsedTitle =
        json['title']?.toString() ??
        (split.isNotEmpty ? '$dName: $split' : dName);

    return PlanScheduleDayItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      dayNumber: dayNum,
      dayName: dName,
      splitName: split,
      title: parsedTitle,
      focus: json['focus']?.toString() ?? '',
      isRestDay: json['is_rest_day'] == true,
      restNote: json['rest_note']?.toString() ?? '',
      order: int.tryParse(json['order']?.toString() ?? '') ?? dayNum,
      exerciseCount:
          int.tryParse(json['exercise_count']?.toString() ?? '') ??
          (exList is List ? exList.length : 0),
      exercises: exList is List
          ? exList
                .whereType<Map>()
                .map(
                  (e) =>
                      PlanExerciseItem.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'day_number': dayNumber,
    'day_name': dayName,
    'split_name': splitName,
    'title': title,
    'focus': focus,
    'is_rest_day': isRestDay,
    'rest_note': restNote,
    'order': order,
    'exercise_count': exerciseCount,
    'exercises': exercises.map((e) => e.toJson()).toList(growable: false),
  };
}

class PlanDetailResponse {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String location;
  final String goal;
  final int minSessionDuration;
  final int maxSessionDuration;
  final int minDaysPerWeek;
  final int maxDaysPerWeek;
  final int totalTimeSeconds;
  final int durationMinutes;
  final String durationDisplay;
  final String level;
  final String levelDisplay;
  final int estimatedCalories;
  final int caloriesBurn;
  final String equipmentNote;
  final int? category;
  final String? categoryName;
  final String subtitle;
  final int totalDays;
  final int exerciseCount;
  final List<PlanScheduleDayItem> schedule;
  final List<PlanExerciseItem> exercises;

  const PlanDetailResponse({
    required this.id,
    required this.title,
    this.description = '',
    this.image,
    this.location = '',
    this.goal = '',
    this.minSessionDuration = 0,
    this.maxSessionDuration = 0,
    this.minDaysPerWeek = 0,
    this.maxDaysPerWeek = 0,
    this.totalTimeSeconds = 0,
    this.durationMinutes = 0,
    this.durationDisplay = '',
    this.level = '',
    this.levelDisplay = '',
    this.estimatedCalories = 0,
    this.caloriesBurn = 0,
    this.equipmentNote = '',
    this.category,
    this.categoryName,
    this.subtitle = '',
    this.totalDays = 0,
    this.exerciseCount = 0,
    this.schedule = const [],
    this.exercises = const [],
  });

  factory PlanDetailResponse.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'];
    final scheduleJson = json['schedule'];
    final duration =
        int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0;

    final parsedSchedule = scheduleJson is List
        ? scheduleJson
              .whereType<Map>()
              .map(
                (e) =>
                    PlanScheduleDayItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(growable: false)
        : const <PlanScheduleDayItem>[];

    List<PlanExerciseItem> parsedExercises = exercisesJson is List
        ? exercisesJson
              .whereType<Map>()
              .map(
                (e) => PlanExerciseItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(growable: false)
        : const <PlanExerciseItem>[];

    // If flat exercises list is empty but schedule has days with exercises, populate from schedule
    if (parsedExercises.isEmpty && parsedSchedule.isNotEmpty) {
      final flattened = <PlanExerciseItem>[];
      for (final day in parsedSchedule) {
        flattened.addAll(day.exercises);
      }
      parsedExercises = flattened;
    }

    return PlanDetailResponse(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      location: json['location']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      minSessionDuration:
          int.tryParse(json['min_session_duration']?.toString() ?? '') ?? 0,
      maxSessionDuration:
          int.tryParse(json['max_session_duration']?.toString() ?? '') ?? 0,
      minDaysPerWeek:
          int.tryParse(json['min_days_per_week']?.toString() ?? '') ?? 0,
      maxDaysPerWeek:
          int.tryParse(json['max_days_per_week']?.toString() ?? '') ?? 0,
      totalTimeSeconds:
          int.tryParse(json['total_time_seconds']?.toString() ?? '') ?? 0,
      durationMinutes: duration,
      durationDisplay:
          json['duration_display']?.toString() ??
          (duration > 0 ? '$duration min' : ''),
      level: json['level']?.toString() ?? '',
      levelDisplay: json['level_display']?.toString() ?? '',
      estimatedCalories:
          int.tryParse(json['estimated_calories']?.toString() ?? '') ?? 0,
      caloriesBurn:
          int.tryParse(json['calories_burn']?.toString() ?? '') ??
          int.tryParse(json['estimated_calories']?.toString() ?? '') ??
          0,
      equipmentNote: json['equipment_note']?.toString() ?? '',
      category: int.tryParse(json['category']?.toString() ?? ''),
      categoryName: json['category_name']?.toString(),
      subtitle: json['subtitle']?.toString() ?? '',
      totalDays:
          int.tryParse(json['total_days']?.toString() ?? '') ??
          (parsedSchedule.isNotEmpty ? parsedSchedule.length : 0),
      exerciseCount:
      int.tryParse(json['exercise_count']?.toString() ?? '') ??
          parsedExercises.length,
      schedule: parsedSchedule,
      exercises: parsedExercises,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    if (image != null) 'image': image,
    'location': location,
    'goal': goal,
    'min_session_duration': minSessionDuration,
    'max_session_duration': maxSessionDuration,
    'min_days_per_week': minDaysPerWeek,
    'max_days_per_week': maxDaysPerWeek,
    'total_time_seconds': totalTimeSeconds,
    'duration_minutes': durationMinutes,
    'duration_display': durationDisplay,
    'level': level,
    'level_display': levelDisplay,
    'estimated_calories': estimatedCalories,
    'calories_burn': caloriesBurn,
    'equipment_note': equipmentNote,
    if (category != null) 'category': category,
    if (categoryName != null) 'category_name': categoryName,
    'subtitle': subtitle,
    'total_days': totalDays,
    'exercise_count': exerciseCount,
    'schedule': schedule.map((s) => s.toJson()).toList(growable: false),
    'exercises': exercises.map((e) => e.toJson()).toList(growable: false),
  };
}
