class ActiveWorkoutSessionResponse {
  final int? id;
  final int? sessionId;
  final String title;
  final String status;
  final bool hasActiveSession;
  final String timerDisplay;
  final int elapsedSeconds;
  final int durationSeconds;
  final double caloriesBurned;
  final int totalExercises;
  final int completedExercises;
  final String message;
  final ActiveExerciseSummary? currentExercise;
  final ActiveExerciseSummary? nextExercise;
  final List<ActiveExerciseItem> exercises;

  const ActiveWorkoutSessionResponse({
    this.id,
    this.sessionId,
    this.title = 'Custom Workout',
    this.status = 'in_progress',
    required this.hasActiveSession,
    this.timerDisplay = '00:00',
    this.elapsedSeconds = 0,
    this.durationSeconds = 0,
    this.caloriesBurned = 0.0,
    this.totalExercises = 0,
    this.completedExercises = 0,
    this.message = '',
    this.currentExercise,
    this.nextExercise,
    this.exercises = const [],
  });

  factory ActiveWorkoutSessionResponse.empty({String? message}) {
    return ActiveWorkoutSessionResponse(
      hasActiveSession: false,
      message: message ?? 'Add any workout to show your log',
      exercises: const [],
    );
  }

  factory ActiveWorkoutSessionResponse.fromJson(Map<String, dynamic> json) {
    // If backend returns { "active_session": null, "has_active_session": false, ... }
    final dynamic activeSessionRaw = json['active_session'] ?? json['session'];
    final Map<String, dynamic> data = (activeSessionRaw is Map)
        ? Map<String, dynamic>.from(activeSessionRaw)
        : json;

    final bool isExplicitlyInactive = json['has_active_session'] == false ||
        data['has_active_session'] == false ||
        data['status']?.toString().toLowerCase() == 'completed';

    final hasActive = !isExplicitlyInactive &&
        (json['has_active_session'] == true ||
            data['has_active_session'] == true ||
            (data['exercises'] is List && (data['exercises'] as List).isNotEmpty) ||
            (data['id'] != null && data['id'] != 0));

    final hasSessionId = data['session_id'] != null ||
        data['id'] != null ||
        json['session_id'] != null ||
        json['id'] != null;

    if (!hasActive && !hasSessionId && json['has_active_session'] == false) {
      return ActiveWorkoutSessionResponse.empty(
        message: json['message']?.toString() ?? data['message']?.toString(),
      );
    }

    final rawExercises = data['exercises'] ?? json['exercises'];
    final List<ActiveExerciseItem> parsedExercises = [];
    if (rawExercises is List) {
      for (final item in rawExercises) {
        if (item is Map) {
          parsedExercises.add(
            ActiveExerciseItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final rawElapsed = data['elapsed_seconds'] ?? json['elapsed_seconds'];
    final elapsedSec = int.tryParse(rawElapsed?.toString() ?? '') ?? 0;
    final rawDuration = data['duration_seconds'] ?? json['duration_seconds'];
    final durationSec = int.tryParse(rawDuration?.toString() ?? '') ?? elapsedSec;

    final rawCurEx = data['current_exercise'] ?? json['current_exercise'];
    final rawNextEx = data['next_exercise'] ?? json['next_exercise'];

    final curSummary = rawCurEx is Map
        ? ActiveExerciseSummary.fromJson(Map<String, dynamic>.from(rawCurEx))
        : null;
    final nextSummary = rawNextEx is Map
        ? ActiveExerciseSummary.fromJson(Map<String, dynamic>.from(rawNextEx))
        : null;

    return ActiveWorkoutSessionResponse(
      id: int.tryParse((data['id'] ?? json['id'])?.toString() ?? ''),
      sessionId: int.tryParse((data['session_id'] ?? json['session_id'])?.toString() ?? ''),
      title: (data['title'] ?? json['title'])?.toString() ?? 'Custom Workout',
      status: (data['status'] ?? json['status'])?.toString() ?? 'in_progress',
      hasActiveSession: hasActive,
      timerDisplay: (data['timer_display'] ?? json['timer_display'])?.toString() ?? '00:00',
      elapsedSeconds: elapsedSec,
      durationSeconds: durationSec,
      caloriesBurned: double.tryParse((data['calories_burned'] ?? json['calories_burned'])?.toString() ?? '') ?? 0.0,
      totalExercises: int.tryParse((data['total_exercises'] ?? json['total_exercises'])?.toString() ?? '') ?? parsedExercises.length,
      completedExercises: int.tryParse((data['completed_exercises'] ?? json['completed_exercises'])?.toString() ?? '') ?? 0,
      message: (data['message'] ?? json['message'])?.toString() ?? '',
      currentExercise: curSummary,
      nextExercise: nextSummary,
      exercises: parsedExercises,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'title': title,
      'status': status,
      'has_active_session': hasActiveSession,
      'timer_display': timerDisplay,
      'elapsed_seconds': elapsedSeconds,
      'duration_seconds': durationSeconds,
      'calories_burned': caloriesBurned,
      'total_exercises': totalExercises,
      'completed_exercises': completedExercises,
      'message': message,
      if (currentExercise != null) 'current_exercise': currentExercise!.toJson(),
      if (nextExercise != null) 'next_exercise': nextExercise!.toJson(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class ActiveExerciseSummary {
  final int id;
  final String title;
  final String name;
  final int order;
  final int targetTimeSeconds;
  final String logType;

  const ActiveExerciseSummary({
    required this.id,
    this.title = '',
    this.name = '',
    this.order = 0,
    this.targetTimeSeconds = 0,
    this.logType = '',
  });

  factory ActiveExerciseSummary.fromJson(Map<String, dynamic> json) {
    return ActiveExerciseSummary(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      targetTimeSeconds:
          int.tryParse(json['target_time_seconds']?.toString() ?? '') ?? 0,
      logType: json['log_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'name': name,
        'order': order,
        'target_time_seconds': targetTimeSeconds,
        'log_type': logType,
      };
}

class ActiveExerciseItem {
  final int id;
  final int exerciseId;
  final String title;
  final String logType; // 'strength', 'cardio', 'duration', 'bodyweight'
  final String categoryName;
  final List<String> muscles;
  final String status;
  final bool isDone;
  final String note;
  final int order;
  final String subtitle;
  final int targetTimeSeconds;
  final String timeDisplay;
  final String targetMinutes;
  final String targetSeconds;
  final List<String> timerPresets;
  final List<ActiveExerciseSet> sets;
  final List<ActiveCardioMetric> cardioLogs;

  const ActiveExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.title,
    required this.logType,
    this.categoryName = '',
    this.muscles = const [],
    this.status = 'in_progress',
    this.isDone = false,
    this.note = '',
    this.order = 0,
    this.subtitle = '',
    this.targetTimeSeconds = 45,
    this.timeDisplay = '45s',
    this.targetMinutes = '00',
    this.targetSeconds = '45',
    this.timerPresets = const ['00', '45'],
    this.sets = const [],
    this.cardioLogs = const [],
  });

  factory ActiveExerciseItem.fromJson(Map<String, dynamic> json) {
    final rawMuscles = json['muscles'];
    final List<String> parsedMuscles = [];
    if (rawMuscles is List) {
      for (final m in rawMuscles) {
        if (m != null) parsedMuscles.add(m.toString());
      }
    } else if (rawMuscles is Map) {
      if (rawMuscles['primary'] != null) {
        parsedMuscles.add(rawMuscles['primary'].toString());
      }
      if (rawMuscles['secondary'] is List) {
        for (final m in rawMuscles['secondary']) {
          if (m != null) parsedMuscles.add(m.toString());
        }
      }
    }

    final rawSets = json['sets'];
    final List<ActiveExerciseSet> parsedSets = [];
    if (rawSets is List) {
      for (final s in rawSets) {
        if (s is Map<String, dynamic>) {
          parsedSets.add(ActiveExerciseSet.fromJson(s));
        }
      }
    }

    final rawCardio = json['cardio_logs'] ?? json['cardio_log'];
    final List<ActiveCardioMetric> parsedCardio = [];
    if (rawCardio is List) {
      for (final c in rawCardio) {
        if (c is Map<String, dynamic>) {
          parsedCardio.add(ActiveCardioMetric.fromJson(c));
        }
      }
    } else if (rawCardio is Map<String, dynamic>) {
      parsedCardio.add(ActiveCardioMetric.fromJson(rawCardio));
    }

    final rawPresets = json['timer_presets'];
    final List<String> parsedPresets = [];
    if (rawPresets is List) {
      for (final p in rawPresets) {
        if (p != null) parsedPresets.add(p.toString());
      }
    }

    final targetSec = int.tryParse(json['target_time_seconds']?.toString() ?? '') ??
        int.tryParse(json['time_seconds']?.toString() ?? '') ??
        45;

    final logTypeVal = (json['log_type'] ?? 'strength').toString().toLowerCase().trim();

    return ActiveExerciseItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      exerciseId: int.tryParse((json['exercise_id'] ?? json['workout_id'])?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Exercise',
      logType: logTypeVal.isNotEmpty ? logTypeVal : 'strength',
      categoryName: json['category_name']?.toString() ?? '',
      muscles: parsedMuscles,
      status: json['status']?.toString() ?? 'in_progress',
      isDone: json['is_done'] == true || (json['status']?.toString().toLowerCase() == 'completed'),
      note: json['note']?.toString() ?? '',
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      subtitle: json['subtitle']?.toString() ?? '',
      targetTimeSeconds: targetSec,
      timeDisplay: json['time_display']?.toString() ?? '${targetSec}s',
      targetMinutes: json['target_minutes']?.toString() ?? (targetSec ~/ 60).toString().padLeft(2, '0'),
      targetSeconds: json['target_seconds']?.toString() ?? (targetSec % 60).toString().padLeft(2, '0'),
      timerPresets: parsedPresets.isNotEmpty
          ? parsedPresets
          : [
              (targetSec ~/ 60).toString().padLeft(2, '0'),
              (targetSec % 60).toString().padLeft(2, '0'),
            ],
      sets: parsedSets,
      cardioLogs: parsedCardio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'title': title,
      'log_type': logType,
      'category_name': categoryName,
      'muscles': muscles,
      'status': status,
      'is_done': isDone,
      'note': note,
      'order': order,
      'subtitle': subtitle,
      'target_time_seconds': targetTimeSeconds,
      'time_display': timeDisplay,
      'target_minutes': targetMinutes,
      'target_seconds': targetSeconds,
      'timer_presets': timerPresets,
      'sets': sets.map((s) => s.toJson()).toList(),
      'cardio_logs': cardioLogs.map((c) => c.toJson()).toList(),
    };
  }

  ActiveExerciseItem copyWith({
    int? id,
    int? exerciseId,
    String? title,
    String? logType,
    String? categoryName,
    List<String>? muscles,
    String? status,
    bool? isDone,
    String? note,
    int? order,
    String? subtitle,
    int? targetTimeSeconds,
    String? timeDisplay,
    String? targetMinutes,
    String? targetSeconds,
    List<String>? timerPresets,
    List<ActiveExerciseSet>? sets,
    List<ActiveCardioMetric>? cardioLogs,
  }) {
    return ActiveExerciseItem(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      title: title ?? this.title,
      logType: logType ?? this.logType,
      categoryName: categoryName ?? this.categoryName,
      muscles: muscles ?? this.muscles,
      status: status ?? this.status,
      isDone: isDone ?? this.isDone,
      note: note ?? this.note,
      order: order ?? this.order,
      subtitle: subtitle ?? this.subtitle,
      targetTimeSeconds: targetTimeSeconds ?? this.targetTimeSeconds,
      timeDisplay: timeDisplay ?? this.timeDisplay,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      timerPresets: timerPresets ?? this.timerPresets,
      sets: sets ?? this.sets,
      cardioLogs: cardioLogs ?? this.cardioLogs,
    );
  }
}

class ActiveExerciseSet {
  final int? id;
  final int setNumber;
  final double weightKg;
  final int reps;
  final bool isCompleted;

  const ActiveExerciseSet({
    this.id,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    required this.isCompleted,
  });

  factory ActiveExerciseSet.fromJson(Map<String, dynamic> json) {
    return ActiveExerciseSet(
      id: int.tryParse(json['id']?.toString() ?? ''),
      setNumber: int.tryParse(json['set_number']?.toString() ?? '') ??
          int.tryParse(json['order']?.toString() ?? '') ??
          1,
      weightKg: double.tryParse((json['weight_kg'] ?? json['weight'])?.toString() ?? '') ?? 0.0,
      reps: int.tryParse(json['reps']?.toString() ?? '') ?? 0,
      isCompleted: json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'is_completed': isCompleted,
    };
  }

  ActiveExerciseSet copyWith({
    int? id,
    int? setNumber,
    double? weightKg,
    int? reps,
    bool? isCompleted,
  }) {
    return ActiveExerciseSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActiveCardioMetric {
  final int? id;
  final int durationSeconds;
  final double distanceKm;
  final double speedKmh;
  final double inclinePercent;

  const ActiveCardioMetric({
    this.id,
    required this.durationSeconds,
    required this.distanceKm,
    required this.speedKmh,
    required this.inclinePercent,
  });

  factory ActiveCardioMetric.fromJson(Map<String, dynamic> json) {
    return ActiveCardioMetric(
      id: int.tryParse(json['id']?.toString() ?? ''),
      durationSeconds: int.tryParse((json['duration_seconds'] ?? json['time_minutes'])?.toString() ?? '') ??
          ((double.tryParse(json['time_minutes']?.toString() ?? '') ?? 0) * 60).round(),
      distanceKm: double.tryParse((json['distance_km'] ?? json['distance'])?.toString() ?? '') ?? 0.0,
      speedKmh: double.tryParse((json['speed_kmh'] ?? json['speed'])?.toString() ?? '') ?? 0.0,
      inclinePercent: double.tryParse((json['incline_percent'] ?? json['incline'])?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'duration_seconds': durationSeconds,
      'distance_km': distanceKm,
      'speed_kmh': speedKmh,
      'incline_percent': inclinePercent,
    };
  }
}
