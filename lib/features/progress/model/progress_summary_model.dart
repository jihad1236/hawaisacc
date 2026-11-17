class ProgressDateRange {
  final String startDate;
  final String endDate;
  final String display;

  const ProgressDateRange({
    this.startDate = '',
    this.endDate = '',
    this.display = '',
  });

  factory ProgressDateRange.fromJson(Map<String, dynamic> json) {
    return ProgressDateRange(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      display: json['display']?.toString() ?? '',
    );
  }
}

class ProgressMetricSummary {
  final int workoutsCount;
  final int exerciseCount;
  final int totalDurationMinutes;
  final double totalVolumeKg;
  final String totalVolumeDisplay;
  final int totalSets;
  final int caloriesBurned;
  final List<String> muscleGroupsTrained;

  const ProgressMetricSummary({
    this.workoutsCount = 0,
    this.exerciseCount = 0,
    this.totalDurationMinutes = 0,
    this.totalVolumeKg = 0.0,
    this.totalVolumeDisplay = '0 kg',
    this.totalSets = 0,
    this.caloriesBurned = 0,
    this.muscleGroupsTrained = const [],
  });

  factory ProgressMetricSummary.fromJson(Map<String, dynamic> json) {
    final musclesJson = json['muscle_groups_trained'];
    final vol = double.tryParse(json['total_volume_kg']?.toString() ?? '') ?? 0.0;

    return ProgressMetricSummary(
      workoutsCount: int.tryParse(json['workouts_count']?.toString() ?? '') ?? 0,
      exerciseCount: int.tryParse(json['exercise_count']?.toString() ?? '') ?? 0,
      totalDurationMinutes:
          int.tryParse(json['total_duration_minutes']?.toString() ?? '') ?? 0,
      totalVolumeKg: vol,
      totalVolumeDisplay: json['total_volume_display']?.toString() ??
          '${vol.toStringAsFixed(0)} kg',
      totalSets: int.tryParse(json['total_sets']?.toString() ?? '') ?? 0,
      caloriesBurned:
          int.tryParse(json['calories_burned']?.toString() ?? '') ?? 0,
      muscleGroupsTrained: musclesJson is List
          ? musclesJson.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

class DailyBreakdownItem {
  final String date;
  final String dayName;
  final int workoutsCount;
  final int durationMinutes;
  final double volumeKg;
  final int sets;
  final int exerciseCount;
  final List<String> muscleGroups;

  const DailyBreakdownItem({
    required this.date,
    this.dayName = '',
    this.workoutsCount = 0,
    this.durationMinutes = 0,
    this.volumeKg = 0.0,
    this.sets = 0,
    this.exerciseCount = 0,
    this.muscleGroups = const [],
  });

  factory DailyBreakdownItem.fromJson(Map<String, dynamic> json) {
    final mgJson = json['muscle_groups'];
    return DailyBreakdownItem(
      date: json['date']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
      workoutsCount:
          int.tryParse(json['workouts_count']?.toString() ?? '') ?? 0,
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      volumeKg: double.tryParse(json['volume_kg']?.toString() ?? '') ?? 0.0,
      sets: int.tryParse(json['sets']?.toString() ?? '') ?? 0,
      exerciseCount:
          int.tryParse(json['exercise_count']?.toString() ?? '') ?? 0,
      muscleGroups: mgJson is List
          ? mgJson.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

class ProgressSessionItem {
  final int sessionId;
  final String title;
  final String status;
  final String workoutDay;
  final double totalVolume;
  final String totalVolumeDisplay;
  final int totalSets;
  final int durationSeconds;
  final int caloriesBurned;

  const ProgressSessionItem({
    required this.sessionId,
    required this.title,
    this.status = 'completed',
    this.workoutDay = '',
    this.totalVolume = 0.0,
    this.totalVolumeDisplay = '0 kg',
    this.totalSets = 0,
    this.durationSeconds = 0,
    this.caloriesBurned = 0,
  });

  factory ProgressSessionItem.fromJson(Map<String, dynamic> json) {
    final vol = double.tryParse(json['total_volume']?.toString() ?? '') ?? 0.0;
    return ProgressSessionItem(
      sessionId: int.tryParse(json['session_id']?.toString() ?? '') ??
          int.tryParse(json['id']?.toString() ?? '') ??
          0,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
      workoutDay: json['workout_day']?.toString() ?? '',
      totalVolume: vol,
      totalVolumeDisplay: json['total_volume_display']?.toString() ??
          '${vol.toStringAsFixed(0)} kg',
      totalSets: int.tryParse(json['total_sets']?.toString() ?? '') ?? 0,
      durationSeconds:
          int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
      caloriesBurned:
          int.tryParse(json['calories_burned']?.toString() ?? '') ?? 0,
    );
  }
}

class ProgressSummaryResponse {
  final String period;
  final bool isSingleDay;
  final ProgressDateRange dateRange;
  final String? workoutDate;
  final ProgressMetricSummary summary;
  final List<DailyBreakdownItem> dailyBreakdown;
  final List<ProgressSessionItem> sessions;
  final int bestStreakDays;

  const ProgressSummaryResponse({
    this.period = '1w',
    this.isSingleDay = false,
    this.dateRange = const ProgressDateRange(),
    this.workoutDate,
    this.summary = const ProgressMetricSummary(),
    this.dailyBreakdown = const [],
    this.sessions = const [],
    this.bestStreakDays = 0,
  });

  factory ProgressSummaryResponse.fromJson(Map<String, dynamic> json) {
    final drJson = json['date_range'];
    final sumJson = json['summary'];
    final dailyJson = json['daily_breakdown'];
    final sessionsJson = json['sessions'];

    return ProgressSummaryResponse(
      period: json['period']?.toString() ?? '1w',
      isSingleDay: json['is_single_day'] == true,
      dateRange: drJson is Map<String, dynamic>
          ? ProgressDateRange.fromJson(drJson)
          : (drJson is Map
              ? ProgressDateRange.fromJson(Map<String, dynamic>.from(drJson))
              : const ProgressDateRange()),
      workoutDate: json['workout_date']?.toString(),
      summary: sumJson is Map<String, dynamic>
          ? ProgressMetricSummary.fromJson(sumJson)
          : (sumJson is Map
              ? ProgressMetricSummary.fromJson(Map<String, dynamic>.from(sumJson))
              : const ProgressMetricSummary()),
      dailyBreakdown: dailyJson is List
          ? dailyJson
              .map((e) =>
                  DailyBreakdownItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false)
          : const [],
      sessions: sessionsJson is List
          ? sessionsJson
              .map((e) =>
                  ProgressSessionItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false)
          : const [],
      bestStreakDays:
          int.tryParse(json['best_streak_days']?.toString() ?? '') ?? 0,
    );
  }
}
