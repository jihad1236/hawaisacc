import 'package:flutter_test/flutter_test.dart';
import 'package:hawiisaac/features/home/model/plan_detail_model.dart';
import 'package:hawiisaac/features/loggin/model/active_workout_session_models.dart';

void main() {
  group('Workout Flow Live API Payload Tests', () {
    test('parses Plan Details API response (GET /api/plans/2/)', () {
      final json = <String, dynamic>{
        "id": 2,
        "title": "Core Crusher",
        "description":
            "A focused core workout targeting abs, obliques, and lower back for a stronger midsection.",
        "image": null,
        "goal": "general_fitness",
        "location": "gym",
        "min_session_duration": 30,
        "max_session_duration": 60,
        "min_days_per_week": 3,
        "max_days_per_week": 3,
        "total_time_seconds": 300,
        "duration_minutes": 5,
        "duration_display": "5 min",
        "level": "intermediate",
        "level_display": "INT",
        "estimated_calories": 60,
        "calories_burn": 60,
        "equipment_note": "No equipment",
        "category": 12,
        "category_name": "Body Weight",
        "subtitle": "No equipment • Body Weight • Intermediate",
        "exercise_count": 7,
        "exercises": [
          {
            "id": 9,
            "order": 1,
            "title": "Plank Hold",
            "subtitle": "",
            "target_muscles": [],
            "description": "Core. Shoulders.",
            "time_seconds": 45,
            "time_display": "45s",
            "workout_id": 17,
          },
          {
            "id": 10,
            "order": 2,
            "title": "Bicycle Crunch",
            "subtitle": "",
            "target_muscles": [],
            "description": "Abs. Obliques.",
            "time_seconds": 45,
            "time_display": "45s",
            "workout_id": null,
          },
        ],
      };

      final plan = PlanDetailResponse.fromJson(json);
      expect(plan.id, equals(2));
      expect(plan.title, equals('Core Crusher'));
      expect(plan.durationMinutes, equals(5));
      expect(plan.levelDisplay, equals('INT'));
      expect(plan.exerciseCount, equals(7));
      expect(plan.exercises.length, equals(2));
      expect(plan.exercises[0].title, equals('Plank Hold'));
      expect(plan.exercises[0].timeSeconds, equals(45));
      expect(plan.exercises[0].workoutId, equals(17));
      expect(plan.exercises[1].title, equals('Bicycle Crunch'));
    });

    test('parses Start Exercise API response (POST /api/workout-sessions/start/)', () {
      final json = <String, dynamic>{
        "session_id": 12,
        "id": 12,
        "title": "Core Crusher",
        "status": "in_progress",
        "has_active_session": true,
        "started_at": "2026-10-05T05:22:16.646543Z",
        "completed_at": null,
        "duration_seconds": 0,
        "elapsed_seconds": 0,
        "timer_display": "00:00",
        "calories_burned": 0,
        "total_exercises": 7,
        "completed_exercises": 0,
        "current_exercise": {
          "id": 17,
          "title": "Plank Hold",
          "name": "Plank Hold",
          "log_type": "duration",
        },
        "next_exercise": {
          "id": 47,
          "title": "Bicycle Crunch",
          "order": 2,
          "target_time_seconds": 45,
        },
        "exercises": [
          {
            "id": 25,
            "exercise_id": 17,
            "title": "Plank Hold",
            "name": "Plank Hold",
            "subtitle": "Core • Shoulders",
            "muscles": ["Core", "Shoulders"],
            "order": 1,
            "status": "in_progress",
            "is_done": false,
            "log_type": "duration",
            "target_time_seconds": 45,
            "time_display": "45s",
            "timer_presets": ["00", "45"],
          },
          {
            "id": 26,
            "exercise_id": 47,
            "title": "Bicycle Crunch",
            "name": "Bicycle Crunch",
            "subtitle": "Obliques • Core",
            "muscles": ["Obliques", "Core"],
            "order": 2,
            "status": "pending",
            "is_done": false,
            "log_type": "cardio",
            "target_time_seconds": 45,
            "time_display": "45s",
            "timer_presets": ["00", "45"],
          },
        ],
      };

      final response = ActiveWorkoutSessionResponse.fromJson(json);
      expect(response.sessionId, equals(12));
      expect(response.title, equals('Core Crusher'));
      expect(response.hasActiveSession, isTrue);
      expect(response.totalExercises, equals(7));
      expect(response.completedExercises, equals(0));
      expect(response.currentExercise?.id, equals(17));
      expect(response.nextExercise?.id, equals(47));
      expect(response.exercises.length, equals(2));
      expect(response.exercises[0].exerciseId, equals(17));
      expect(response.exercises[0].status, equals('in_progress'));
      expect(response.exercises[0].isDone, isFalse);
      expect(response.exercises[0].timerPresets, equals(['00', '45']));
    });

    test('parses Complete Exercise API response (POST /active/exercises/<id>/complete/)', () {
      final json = <String, dynamic>{
        "session_id": 12,
        "id": 12,
        "title": "Core Crusher",
        "status": "in_progress",
        "has_active_session": true,
        "duration_seconds": 0,
        "elapsed_seconds": 636,
        "timer_display": "10:36",
        "calories_burned": 0,
        "total_exercises": 7,
        "completed_exercises": 2,
        "exercises": [
          {
            "id": 25,
            "exercise_id": 17,
            "title": "Plank Hold",
            "status": "completed",
            "is_done": true,
            "log_type": "duration",
            "target_time_seconds": 45,
          },
          {
            "id": 26,
            "exercise_id": 47,
            "title": "Bicycle Crunch",
            "status": "completed",
            "is_done": true,
            "log_type": "cardio",
            "target_time_seconds": 45,
          },
          {
            "id": 27,
            "exercise_id": 30,
            "title": "Leg Raise",
            "status": "in_progress",
            "is_done": false,
            "log_type": "strength",
            "target_time_seconds": 45,
          },
        ],
      };

      final response = ActiveWorkoutSessionResponse.fromJson(json);
      expect(response.completedExercises, equals(2));
      expect(response.exercises[0].isDone, isTrue);
      expect(response.exercises[1].isDone, isTrue);
      expect(response.exercises[2].status, equals('in_progress'));
      expect(response.exercises[2].isDone, isFalse);
    });

    test('parses Finish Workout API response (POST /api/workout-sessions/active/finish/)', () {
      final json = <String, dynamic>{
        "session_id": 12,
        "id": 12,
        "title": "Core Crusher",
        "status": "completed",
        "has_active_session": false,
        "duration_seconds": 753,
        "elapsed_seconds": 753,
        "timer_display": "12:33",
        "calories_burned": 72,
        "total_exercises": 7,
        "completed_exercises": 3,
      };

      final response = ActiveWorkoutSessionResponse.fromJson(json);
      expect(response.hasActiveSession, isFalse);
      expect(response.status, equals('completed'));
      expect(response.caloriesBurned, equals(72));
      expect(response.durationSeconds, equals(753));
    });

    test('parses Empty Log State (Screen 4)', () {
      final json = <String, dynamic>{
        "active_session": null,
        "has_active_session": false,
        "detail": "No active workout session found.",
        "message": "Add any workout to show your log",
      };

      final response = ActiveWorkoutSessionResponse.fromJson(json);
      expect(response.hasActiveSession, isFalse);
      expect(response.message, equals('Add any workout to show your log'));
      expect(response.exercises, isEmpty);
    });
  });
}
