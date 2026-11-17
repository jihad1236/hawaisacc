import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiisaac/features/progress/model/progress_analytics_models.dart';

void main() {
  group('Progress Analytics Models Test', () {
    const rawJson1m = '''
{
    "period": "1m",
    "date_range_display": "Sep 05 - Oct 05, 2026",
    "start_date": "2026-09-05",
    "end_date": "2026-10-05",
    "total_volume_lifted": 9268.0,
    "total_volume_display": "9,268 kg",
    "volume_unit": "kg",
    "volume_subtitle": "↑ Total Volume Lifted",
    "volume_trend_direction": "up",
    "volume_delta_display": "+12%",
    "volume_chart": [
        {"date": "2026-09-05", "label": "Sep 05", "volume": 0.0},
        {"date": "2026-09-09", "label": "Sep 09", "volume": 0.0},
        {"date": "2026-09-13", "label": "Sep 13", "volume": 1500.0},
        {"date": "2026-09-17", "label": "Sep 17", "volume": 1500.0},
        {"date": "2026-09-21", "label": "Sep 21", "volume": 0.0},
        {"date": "2026-09-25", "label": "Sep 25", "volume": 0.0},
        {"date": "2026-09-29", "label": "Sep 29", "volume": 0.0},
        {"date": "2026-10-03", "label": "Oct 03", "volume": 0.0}
    ],
    "metrics": {
        "workouts": {
            "value": 46,
            "display": "46",
            "subtitle": "↑ 46 sessions",
            "delta": "+46",
            "trend_direction": "up"
        },
        "avg_duration": {
            "value_minutes": 1421,
            "display": "1421m",
            "subtitle": "→ Stable",
            "trend_direction": "stable"
        },
        "total_sets": {
            "value": 51,
            "display": "51",
            "subtitle": "↑ 51 sets",
            "delta": "+51",
            "trend_direction": "up"
        },
        "best_streak": {
            "value_days": 1,
            "display": "1d",
            "subtitle": "↑ New PR",
            "trend_direction": "up"
        }
    },
    "personal_records": [
        {
            "id": 6,
            "title": "Deadlift 1RM",
            "exercise_name": "Deadlift 1RM",
            "weight_kg": "160.00",
            "weight_display": "160 kg",
            "reps": 1,
            "achieved_date": "2026-09-20",
            "date_display": "Sep 20 · barbell",
            "equipment": "barbell",
            "delta_display": "↑ +10kg",
            "icon": "deadlift"
        },
        {
            "id": 5,
            "title": "Back Squat 1RM",
            "exercise_name": "Back Squat 1RM",
            "weight_kg": "135.00",
            "weight_display": "135 kg",
            "reps": 1,
            "achieved_date": "2026-09-25",
            "date_display": "Sep 25 · barbell",
            "equipment": "barbell",
            "delta_display": "↑ +7.5kg",
            "icon": "squat"
        },
        {
            "id": 4,
            "title": "Bench Press 1RM",
            "exercise_name": "Bench Press 1RM",
            "weight_kg": "102.50",
            "weight_display": "102.5 kg",
            "reps": 1,
            "achieved_date": "2026-09-29",
            "date_display": "Sep 29 · barbell",
            "equipment": "barbell",
            "delta_display": "↑ +5kg",
            "icon": "bench_press"
        }
    ]
}
''';

    test('parses live 1m API response accurately', () {
      final map = jsonDecode(rawJson1m) as Map<String, dynamic>;
      final response = ProgressAnalyticsResponse.fromJson(map);

      expect(response.period, equals('1m'));
      expect(response.dateRangeDisplay, equals('Sep 05 - Oct 05, 2026'));
      expect(response.totalVolumeLifted, equals(9268.0));
      expect(response.totalVolumeDisplay, equals('9,268 kg'));
      expect(response.volumeSubtitle, equals('↑ Total Volume Lifted'));
      expect(response.volumeTrendDirection, equals('up'));
      expect(response.volumeDeltaDisplay, equals('+12%'));

      // Chart points
      expect(response.volumeChart.length, equals(8));
      expect(response.volumeChart.first.label, equals('Sep 05'));
      expect(response.volumeChart.last.label, equals('Oct 03'));

      // 4 Metrics
      expect(response.metrics.workouts.display, equals('46'));
      expect(response.metrics.workouts.subtitle, equals('↑ 46 sessions'));
      expect(response.metrics.avgDuration.display, equals('1421m'));
      expect(response.metrics.totalSets.display, equals('51'));
      expect(response.metrics.bestStreak.display, equals('1d'));
      expect(response.metrics.bestStreak.subtitle, equals('↑ New PR'));

      // Personal Records
      expect(response.personalRecords.length, equals(3));
      expect(response.personalRecords[0].title, equals('Deadlift 1RM'));
      expect(response.personalRecords[0].weightDisplay, equals('160 kg'));
      expect(response.personalRecords[0].deltaDisplay, equals('↑ +10kg'));
      expect(response.personalRecords[0].icon, equals('deadlift'));

      expect(response.personalRecords[2].title, equals('Bench Press 1RM'));
      expect(response.personalRecords[2].weightDisplay, equals('102.5 kg'));
      expect(response.personalRecords[2].icon, equals('bench_press'));
    });

    test('handles empty or partial JSON gracefully with fallback defaults', () {
      final response = ProgressAnalyticsResponse.fromJson({});

      expect(response.period, equals('1m'));
      expect(response.dateRangeDisplay, isEmpty);
      expect(response.totalVolumeLifted, equals(0.0));
      expect(response.volumeChart, isEmpty);
      expect(response.metrics.workouts.display, equals('0'));
      expect(response.metrics.bestStreak.display, equals('0d'));
      expect(response.personalRecords, isEmpty);
    });
  });
}
