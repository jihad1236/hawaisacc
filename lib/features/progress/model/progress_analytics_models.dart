class ProgressAnalyticsResponse {
  final String period;
  final String dateRangeDisplay;
  final String startDate;
  final String endDate;
  final double totalVolumeLifted;
  final String totalVolumeDisplay;
  final String volumeUnit;
  final String volumeSubtitle;
  final String volumeTrendDirection;
  final String volumeDeltaDisplay;
  final List<VolumeChartPoint> volumeChart;
  final ProgressMetrics metrics;
  final List<PersonalRecordItem> personalRecords;

  const ProgressAnalyticsResponse({
    this.period = '1m',
    this.dateRangeDisplay = '',
    this.startDate = '',
    this.endDate = '',
    this.totalVolumeLifted = 0.0,
    this.totalVolumeDisplay = '0 kg',
    this.volumeUnit = 'kg',
    this.volumeSubtitle = 'Total Volume Lifted',
    this.volumeTrendDirection = 'stable',
    this.volumeDeltaDisplay = '',
    this.volumeChart = const [],
    this.metrics = const ProgressMetrics(),
    this.personalRecords = const [],
  });

  factory ProgressAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return ProgressAnalyticsResponse(
      period: json['period']?.toString() ?? '1m',
      dateRangeDisplay: json['date_range_display']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalVolumeLifted: _toDouble(json['total_volume_lifted']),
      totalVolumeDisplay: json['total_volume_display']?.toString() ?? '0 kg',
      volumeUnit: json['volume_unit']?.toString() ?? 'kg',
      volumeSubtitle:
          json['volume_subtitle']?.toString() ?? 'Total Volume Lifted',
      volumeTrendDirection:
          json['volume_trend_direction']?.toString() ?? 'stable',
      volumeDeltaDisplay: json['volume_delta_display']?.toString() ?? '',
      volumeChart:
          (json['volume_chart'] as List<dynamic>?)
              ?.map(
                (item) =>
                    VolumeChartPoint.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      metrics: json['metrics'] is Map<String, dynamic>
          ? ProgressMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : const ProgressMetrics(),
      personalRecords:
          (json['personal_records'] as List<dynamic>?)
              ?.map(
                (item) =>
                    PersonalRecordItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class VolumeChartPoint {
  final String date;
  final String label;
  final double volume;

  const VolumeChartPoint({
    required this.date,
    required this.label,
    required this.volume,
  });

  factory VolumeChartPoint.fromJson(Map<String, dynamic> json) {
    return VolumeChartPoint(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      volume: ProgressAnalyticsResponse._toDouble(json['volume']),
    );
  }
}

class ProgressMetrics {
  final MetricItem workouts;
  final MetricItem avgDuration;
  final MetricItem totalSets;
  final MetricItem bestStreak;

  const ProgressMetrics({
    this.workouts = const MetricItem(label: 'Workout', display: '0'),
    this.avgDuration = const MetricItem(label: 'Avg Duration', display: '0m'),
    this.totalSets = const MetricItem(label: 'Total Sets', display: '0'),
    this.bestStreak = const MetricItem(label: 'Best Streak', display: '0d'),
  });

  factory ProgressMetrics.fromJson(Map<String, dynamic> json) {
    return ProgressMetrics(
      workouts: json['workouts'] is Map<String, dynamic>
          ? MetricItem.fromJson(
              'Workout',
              json['workouts'] as Map<String, dynamic>,
            )
          : const MetricItem(label: 'Workout', display: '0'),
      avgDuration: json['avg_duration'] is Map<String, dynamic>
          ? MetricItem.fromJson(
              'Avg Duration',
              json['avg_duration'] as Map<String, dynamic>,
            )
          : const MetricItem(label: 'Avg Duration', display: '0m'),
      totalSets: json['total_sets'] is Map<String, dynamic>
          ? MetricItem.fromJson(
              'Total Sets',
              json['total_sets'] as Map<String, dynamic>,
            )
          : const MetricItem(label: 'Total Sets', display: '0'),
      bestStreak: json['best_streak'] is Map<String, dynamic>
          ? MetricItem.fromJson(
              'Best Streak',
              json['best_streak'] as Map<String, dynamic>,
            )
          : const MetricItem(label: 'Best Streak', display: '0d'),
    );
  }
}

class MetricItem {
  final String label;
  final int value;
  final String display;
  final String subtitle;
  final String? delta;
  final String trendDirection;

  const MetricItem({
    required this.label,
    this.value = 0,
    required this.display,
    this.subtitle = '',
    this.delta,
    this.trendDirection = 'stable',
  });

  factory MetricItem.fromJson(String label, Map<String, dynamic> json) {
    // Note: some metrics use `value`, `value_minutes`, or `value_days`
    final val =
        json['value'] ?? json['value_minutes'] ?? json['value_days'] ?? 0;

    return MetricItem(
      label: label,
      value: val is num ? val.toInt() : (int.tryParse(val.toString()) ?? 0),
      display: json['display']?.toString() ?? '0',
      subtitle: json['subtitle']?.toString() ?? '',
      delta: json['delta']?.toString(),
      trendDirection: json['trend_direction']?.toString() ?? 'stable',
    );
  }
}

class PersonalRecordItem {
  final int id;
  final String title;
  final String exerciseName;
  final double weightKg;
  final String weightDisplay;
  final int reps;
  final String achievedDate;
  final String dateDisplay;
  final String equipment;
  final String deltaDisplay;
  final String icon;

  const PersonalRecordItem({
    required this.id,
    required this.title,
    required this.exerciseName,
    required this.weightKg,
    required this.weightDisplay,
    required this.reps,
    required this.achievedDate,
    required this.dateDisplay,
    required this.equipment,
    required this.deltaDisplay,
    required this.icon,
  });

  factory PersonalRecordItem.fromJson(Map<String, dynamic> json) {
    return PersonalRecordItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      exerciseName: json['exercise_name']?.toString() ?? '',
      weightKg: ProgressAnalyticsResponse._toDouble(json['weight_kg']),
      weightDisplay: json['weight_display']?.toString() ?? '',
      reps: json['reps'] is num ? (json['reps'] as num).toInt() : 1,
      achievedDate: json['achieved_date']?.toString() ?? '',
      dateDisplay: json['date_display']?.toString() ?? '',
      equipment: json['equipment']?.toString() ?? '',
      deltaDisplay: json['delta_display']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'bench_press',
    );
  }
}
