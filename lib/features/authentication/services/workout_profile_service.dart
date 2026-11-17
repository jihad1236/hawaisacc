import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/workout_profile.dart';
import 'package:hawiisaac/features/authentication/model/workout_profile_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class WorkoutProfileService {
  WorkoutProfileService({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  /// Fetches current workout profile (GET /api/auth/workout-profile/)
  Future<WorkoutProfile> getProfile() async {
    final data = await _apiClient.get(
      url: ApiEndpoint.workoutProfile,
      headers: _authHeaders,
      logLabel: 'Get Workout Profile',
      showDebugLog: true,
    );

    final profile = WorkoutProfile.fromJson(data);
    debugPrint(
      'WorkoutProfile fetched: goal=${profile.goal}, '
      'level=${profile.level}, location=${profile.location}, '
      'days=${profile.workoutDays}, duration=${profile.sessionDuration}, '
      'isCompleted=${profile.isCompleted}',
    );
    return profile;
  }

  /// Full update (PUT /api/auth/workout-profile/)
  Future<WorkoutProfile> updateFullProfile(WorkoutProfileRequest request) async {
    final data = await _apiClient.putJson(
      url: ApiEndpoint.workoutProfile,
      body: request.toJson(),
      headers: _authHeaders,
      logLabel: 'Update Full Workout Profile',
      showDebugLog: true,
    );

    final profile = WorkoutProfile.fromJson(data);
    debugPrint('WorkoutProfile full update: isCompleted=${profile.isCompleted}');
    return profile;
  }

  /// Partial update (PATCH /api/auth/workout-profile/)
  Future<WorkoutProfile> updatePartialProfile(Map<String, dynamic> payload) async {
    final data = await _apiClient.patchJson(
      url: ApiEndpoint.workoutProfile,
      body: payload,
      headers: _authHeaders,
      logLabel: 'Update Partial Workout Profile',
      showDebugLog: true,
    );

    final profile = WorkoutProfile.fromJson(data);
    debugPrint('WorkoutProfile partial update: isCompleted=${profile.isCompleted}');
    return profile;
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in again to view your workout profile.',
        statusCode: 401,
      );
    }

    return <String, String>{
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }
}
