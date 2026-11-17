import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/loggin/model/active_workout_session_models.dart';
import 'package:hawiisaac/features/loggin/model/cardio_log_item.dart';
import 'package:hawiisaac/features/loggin/model/record_workout_session_models.dart';

class LogginApiService {
  LogginApiService({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  // ── 1. Fetch Active Session & Timer ──────────────────────────────
  Future<ActiveWorkoutSessionResponse> getActiveSession() async {
    final url = ApiEndpoint.activeWorkoutSession;
    debugPrint('[API HIT][GET] /workout-sessions/active/ -> $url');

    try {
      final data = await _apiClient.get(
        url: url,
        headers: _authHeaders,
        logLabel: 'GET /workout-sessions/active/',
        showDebugLog: true,
      );

      final response = ActiveWorkoutSessionResponse.fromJson(data);
      debugPrint(
        'Parsed active session: hasActive=${response.hasActiveSession}, '
        'exercisesCount=${response.exercises.length}, timer=${response.timerDisplay}',
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('[LogginApiService] AuthException getting active session: ${e.message} (${e.statusCode})');
      // If 404 or backend returns empty message, treat as no active session
      if (e.statusCode == 404) {
        return ActiveWorkoutSessionResponse.empty(
          message: e.message.isNotEmpty ? e.message : 'Add any workout to show your log',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('[LogginApiService] Error getting active session: $e');
      rethrow;
    }
  }

  // ── 2. Add Exercise to Active Session ("Add to workout") ──────────
  Future<ActiveWorkoutSessionResponse> addExerciseToSession({
    required int exerciseId,
    int targetTimeSeconds = 45,
  }) async {
    final url = ApiEndpoint.addExerciseToActiveSession;
    final body = <String, dynamic>{
      'exercise_id': exerciseId,
      'target_time_seconds': targetTimeSeconds,
    };

    debugPrint('[API HIT][POST] /workout-sessions/active/add-exercise/ -> $url');
    debugPrint('Body: ${jsonEncode(body)}');

    try {
      final data = await _apiClient.postJson(
        url: url,
        body: body,
        headers: _authHeaders,
        logLabel: 'POST /workout-sessions/active/add-exercise/',
        showDebugLog: true,
      );

      return ActiveWorkoutSessionResponse.fromJson(data);
    } on AuthException catch (e) {
      debugPrint('[LogginApiService] add-exercise error: ${e.message} (${e.statusCode})');
      // If no active session exists, start a new one automatically
      if (e.statusCode == 400 || e.statusCode == 404) {
        debugPrint('[LogginApiService] Attempting to start workout session via /start/');
        return await startWorkoutSession(workoutId: exerciseId);
      }
      rethrow;
    }
  }

  // ── 2b. Start New Workout Session ─────────────────────────────────
  Future<ActiveWorkoutSessionResponse> startWorkoutSession({
    int? planId,
    int? workoutId,
    bool resume = false,
  }) async {
    final url = ApiEndpoint.startWorkoutSession;
    final body = <String, dynamic>{
      'plan_id': ?planId,
      if (workoutId != null) ...{
        'workout_id': workoutId,
        'exercise_id': workoutId,
      },
      'resume': resume,
    };

    debugPrint('[API HIT][POST] /workout-sessions/start/ -> $url');
    debugPrint('Body: ${jsonEncode(body)}');

    final data = await _apiClient.postJson(
      url: url,
      body: body,
      headers: _authHeaders,
      logLabel: 'POST /workout-sessions/start/',
      showDebugLog: true,
    );

    return ActiveWorkoutSessionResponse.fromJson(data);
  }

  // ── 3. Log a Strength / Bodyweight Set ────────────────────────────
  Future<ActiveExerciseSet> logStrengthSet({
    required int exerciseId,
    required int setNumber,
    required double weightKg,
    required int reps,
    required bool isCompleted,
  }) async {
    final url = ApiEndpoint.activeSessionSets;
    final body = <String, dynamic>{
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'is_completed': isCompleted,
    };

    debugPrint('[API HIT][POST] /workout-sessions/active/sets/ -> $url');
    debugPrint('Body: ${jsonEncode(body)}');

    final data = await _apiClient.postJson(
      url: url,
      body: body,
      headers: _authHeaders,
      logLabel: 'POST /workout-sessions/active/sets/',
      showDebugLog: true,
    );

    return ActiveExerciseSet.fromJson(data);
  }

  // ── 4. Log Cardio Metrics ─────────────────────────────────────────
  Future<ActiveCardioMetric> logCardioSet({
    required int exerciseId,
    required int durationSeconds,
    required double distanceKm,
    required double speedKmh,
    required double inclinePercent,
  }) async {
    final url = ApiEndpoint.activeSessionCardio;
    final body = <String, dynamic>{
      'exercise_id': exerciseId,
      'duration_seconds': durationSeconds,
      'distance_km': distanceKm,
      'speed_kmh': speedKmh,
      'incline_percent': inclinePercent,
    };

    debugPrint('[API HIT][POST] /workout-sessions/active/cardio/ -> $url');
    debugPrint('Body: ${jsonEncode(body)}');

    final data = await _apiClient.postJson(
      url: url,
      body: body,
      headers: _authHeaders,
      logLabel: 'POST /workout-sessions/active/cardio/',
      showDebugLog: true,
    );

    return ActiveCardioMetric.fromJson(data);
  }

  // ── 5. Add / Update Exercise Note ─────────────────────────────────
  Future<bool> updateExerciseNote({
    required int exerciseId,
    required String note,
  }) async {
    final url = ApiEndpoint.activeSessionNotes;
    final body = <String, dynamic>{
      'exercise_id': exerciseId,
      'note': note,
    };

    debugPrint('[API HIT][POST] /workout-sessions/active/notes/ -> $url');
    debugPrint('Body: ${jsonEncode(body)}');

    try {
      final data = await _apiClient.postJson(
        url: url,
        body: body,
        headers: _authHeaders,
        logLabel: 'POST /workout-sessions/active/notes/',
        showDebugLog: true,
      );

      return data['success'] == true || data['status'] == 'success' || data.isNotEmpty;
    } catch (e) {
      debugPrint('[LogginApiService] Note update failed: $e');
      return false;
    }
  }

  // ── 6. Complete Single Exercise ───────────────────────────────────
  Future<ActiveWorkoutSessionResponse> completeActiveExercise(int exerciseId) async {
    final url = ApiEndpoint.completeActiveExercise(exerciseId);
    debugPrint('[API HIT][POST] /workout-sessions/active/exercises/$exerciseId/complete/ -> $url');

    final data = await _apiClient.postJson(
      url: url,
      body: <String, dynamic>{},
      headers: _authHeaders,
      logLabel: 'POST /workout-sessions/active/exercises/$exerciseId/complete/',
      showDebugLog: true,
    );

    return ActiveWorkoutSessionResponse.fromJson(data);
  }

  Future<void> completeExercise(int exerciseId) async {
    await completeActiveExercise(exerciseId);
  }

  // ── 7. Finish Whole Workout Session ───────────────────────────────
  Future<ActiveWorkoutSessionResponse> finishActiveSession() async {
    final url = ApiEndpoint.finishActiveSession;
    debugPrint('[API HIT][POST] /workout-sessions/active/finish/ -> $url');

    final data = await _apiClient.postJson(
      url: url,
      body: <String, dynamic>{},
      headers: _authHeaders,
      logLabel: 'POST /workout-sessions/active/finish/',
      showDebugLog: true,
    );

    return ActiveWorkoutSessionResponse.fromJson(data);
  }

  // ── 8. Record Completed Workout Session (Endpoint 3.1) ───────────
  Future<RecordWorkoutSessionResponse> recordWorkoutSession(
    RecordWorkoutSessionRequest request,
  ) async {
    final url = ApiEndpoint.recordWorkoutSession;
    debugPrint('[API HIT][POST] /workout-sessions/record/ -> $url');

    final data = await _apiClient.postJson(
      url: url,
      body: request.toJson(),
      headers: _authHeaders,
      logLabel: 'POST /workout-sessions/record/',
      showDebugLog: true,
    );

    final response = RecordWorkoutSessionResponse.fromJson(data);
    debugPrint(
      'Recorded session: id=${response.sessionId}, volume=${response.totalVolumeDisplay}, sets=${response.totalSets}',
    );
    return response;
  }

  // ── Legacy / Historical Cardio Logs ───────────────────────────────
  Future<List<CardioLogItem>> getCardioLogs() async {
    final url = ApiEndpoint.cardioLogs;
    debugPrint('[API HIT][GET] /logs/cardio/ -> $url');

    final data = await _apiClient.getList(
      url: url,
      logLabel: 'Get Cardio Logs',
      headers: _authHeaders,
      showDebugLog: true,
    );

    final logs = data
        .whereType<Map>()
        .map((item) => CardioLogItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    debugPrint('Get Cardio Logs parsed successfully: count=${logs.length}');
    return logs;
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      debugPrint('[LogginApiService] No access token found in StorageService');
      return const <String, String>{};
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }
}
