import 'package:flutter_test/flutter_test.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/home/model/plan_detail_model.dart';
import 'package:hawiisaac/features/loggin/model/record_workout_session_models.dart';
import 'package:hawiisaac/features/progress/model/progress_summary_model.dart';
import 'package:hawiisaac/features/profile/model/subscription_model.dart';

void main() {
  group('v2.1 Bespoke Workouts & Schedule Tests', () {
    test('parses 4-Day Cycle schedule with Push, Pull, Legs, Rest', () {
      final json = {
        'id': 61,
        'title': 'Resistance Training - Full Body Split Program',
        'location': 'gym',
        'duration_minutes': 30,
        'duration_display': '30 min',
        'level': 'intermediate',
        'level_display': 'INT',
        'calories_burn': 210,
        'total_days': 4,
        'exercise_count': 30,
        'schedule': [
          {
            'id': 5,
            'day_number': 1,
            'day_name': 'Day 1',
            'split_name': 'Push',
            'title': 'Day 1: Push',
            'focus': 'Chest, shoulders, triceps',
            'is_rest_day': false,
            'order': 1,
            'exercise_count': 10,
            'exercises': [
              {
                'id': 181,
                'order': 1,
                'title': 'Alternating Dumbbell Bench Press',
                'subtitle': 'Chest - Pectoralis • Free Weights',
                'target_muscles': ['Chest - Pectoralis', 'Upper Body'],
                'time_seconds': 45,
                'time_display': '45s',
              }
            ],
          },
          {
            'id': 8,
            'day_number': 4,
            'day_name': 'Day 4',
            'split_name': 'Rest',
            'title': 'Day 4: Rest / Recovery',
            'focus': 'Recovery',
            'is_rest_day': true,
            'rest_note': 'Recovery; repeat cycle or take additional rest days',
            'order': 4,
            'exercise_count': 0,
            'exercises': [],
          }
        ],
      };

      final plan = PlanDetailResponse.fromJson(json);

      expect(plan.id, 61);
      expect(plan.location, 'gym');
      expect(plan.totalDays, 4);
      expect(plan.schedule.length, 2);

      final day1 = plan.schedule[0];
      expect(day1.splitName, 'Push');
      expect(day1.isRestDay, isFalse);
      expect(day1.exercises.length, 1);
      expect(day1.exercises.first.title, 'Alternating Dumbbell Bench Press');

      final day4 = plan.schedule[1];
      expect(day4.splitName, 'Rest');
      expect(day4.isRestDay, isTrue);
      expect(day4.restNote, contains('Recovery'));
    });

    test('verifies Plan URL endpoints', () {
      expect(ApiEndpoint.plans(), contains('/api/plans/'));
      expect(
        ApiEndpoint.plans(location: 'gym', level: 'intermediate'),
        contains('location=gym&level=intermediate'),
      );
      expect(ApiEndpoint.planById(61, day: 1), contains('/api/plans/61/?day=1'));
      expect(ApiEndpoint.planSchedule(61), contains('/api/plans/61/schedule/'));
      expect(ApiEndpoint.planDay(61, 'push'), contains('/api/plans/61/days/push/'));
    });
  });

  group('v2.1 Record Workout Session Tests', () {
    test('serializes RecordWorkoutSessionRequest accurately', () {
      const request = RecordWorkoutSessionRequest(
        planId: 61,
        workoutDay: 'Day 1: Push',
        dayNumber: 1,
        workoutDate: '2026-11-01',
        durationMinutes: 45,
        caloriesBurned: 280,
        note: 'Felt strong',
        exercises: [
          RecordWorkoutExerciseItem(
            workoutId: 41,
            customTitle: 'Alternating Dumbbell Bench Press',
            sets: [
              RecordWorkoutSetItem(
                setNumber: 1,
                weightKg: 20.0,
                reps: 12,
                isCompleted: true,
              )
            ],
          )
        ],
      );

      final json = request.toJson();
      expect(json['plan_id'], 61);
      expect(json['workout_day'], 'Day 1: Push');
      expect(json['day_number'], 1);
      expect(json['duration_minutes'], 45);
      expect(json['exercises'], isA<List>());
      final ex = (json['exercises'] as List).first as Map;
      expect(ex['custom_title'], 'Alternating Dumbbell Bench Press');
    });

    test('parses RecordWorkoutSessionResponse accurately', () {
      final json = {
        'session_id': 14,
        'title': 'Resistance Training - Full Body Split Program - Day 1: Push',
        'status': 'completed',
        'duration_seconds': 2700,
        'timer_display': '45:00',
        'calories_burned': 280,
        'total_volume': 665.0,
        'total_volume_display': '665 kg',
        'total_sets': 3,
        'exercise_count': 1,
        'muscle_groups': ['Chest - Pectoralis', 'Upper Body'],
      };

      final response = RecordWorkoutSessionResponse.fromJson(json);
      expect(response.sessionId, 14);
      expect(response.totalVolume, 665.0);
      expect(response.totalVolumeDisplay, '665 kg');
      expect(response.muscleGroups, contains('Chest - Pectoralis'));
    });
  });

  group('v2.1 Progress Summary Tests', () {
    test('parses ProgressSummaryResponse with daily breakdown', () {
      final json = {
        'period': '1w',
        'is_single_day': false,
        'date_range': {
          'start_date': '2026-10-26',
          'end_date': '2026-11-01',
          'display': 'Oct 26 - Nov 01, 2026',
        },
        'summary': {
          'workouts_count': 4,
          'exercise_count': 24,
          'total_duration_minutes': 180,
          'total_volume_kg': 12800.0,
          'total_volume_display': '12,800 kg',
          'total_sets': 72,
          'calories_burned': 1150,
          'muscle_groups_trained': ['Back', 'Biceps', 'Chest'],
        },
        'daily_breakdown': [
          {
            'date': '2026-10-26',
            'day_name': 'Monday',
            'workouts_count': 1,
            'duration_minutes': 45,
            'volume_kg': 3200.0,
            'sets': 18,
            'exercise_count': 6,
            'muscle_groups': ['Chest'],
          }
        ],
        'sessions': [
          {
            'session_id': 14,
            'title': 'Resistance Training',
            'status': 'completed',
            'workout_day': 'Day 1: Push',
            'total_volume': 3200.0,
            'total_volume_display': '3,200 kg',
            'total_sets': 18,
            'duration_seconds': 2700,
            'calories_burned': 280,
          }
        ],
        'best_streak_days': 5,
      };

      final summary = ProgressSummaryResponse.fromJson(json);
      expect(summary.period, '1w');
      expect(summary.summary.workoutsCount, 4);
      expect(summary.summary.totalVolumeKg, 12800.0);
      expect(summary.summary.muscleGroupsTrained, contains('Chest'));
      expect(summary.dailyBreakdown.length, 1);
      expect(summary.sessions.first.sessionId, 14);
      expect(summary.bestStreakDays, 5);
    });
  });

  group('v2.1 Subscription & Entitlements Tests', () {
    test('parses active premium subscription status', () {
      final json = {
        'is_premium': true,
        'has_subscription': true,
        'status': 'active',
        'is_valid': true,
        'entitlements': [
          'bespoke_workout_plans',
          'ai_equipment_scanner',
          'advanced_progress_analytics',
        ],
        'subscription': {
          'id': 1,
          'status': 'active',
          'billing_cycle': 'yearly',
          'payment_source': 'google_play',
          'plan': 1,
          'plan_title': 'HYKX Pro',
          'plan_tier': 'PRO',
        },
      };

      final status = SubscriptionStatusResponse.fromJson(json);
      expect(status.isPremium, isTrue);
      expect(status.entitlements, contains('bespoke_workout_plans'));
      expect(status.subscription?.planTitle, 'HYKX Pro');
    });
  });
}
