import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/home/model/plan_detail_model.dart';

class PlanApiService {
  PlanApiService({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  /// List Workout Plans with optional filters (location: gym/home, goal, level)
  Future<List<PlanDetailResponse>> getPlans({
    String? location,
    String? goal,
    String? level,
  }) async {
    final url = ApiEndpoint.plans(location: location, goal: goal, level: level);
    debugPrint('[API HIT][GET] /plans/ -> $url');

    final dynamic data = await _apiClient.get(
      url: url,
      logLabel: 'Get Workout Plans',
      headers: _authHeaders,
      showDebugLog: true,
    );

    if (data is List) {
      return data
          .map((e) =>
              PlanDetailResponse.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    }
    return const [];
  }

  /// Retrieve full plan details including 4-day schedule, with optional ?day= filter
  Future<PlanDetailResponse> getPlanById(int id, {dynamic day}) async {
    final url = ApiEndpoint.planById(id, day: day);
    debugPrint('[API HIT][GET] /plans/$id/ -> $url');

    final dynamic data = await _apiClient.get(
      url: url,
      logLabel: 'Get Plan Detail (id=$id, day=$day)',
      headers: _authHeaders,
      showDebugLog: true,
    );

    final plan = PlanDetailResponse.fromJson(data as Map<String, dynamic>);
    debugPrint(
      'Get Plan Detail parsed: id=${plan.id}, title=${plan.title}, schedule=${plan.schedule.length}, exercises=${plan.exercises.length}',
    );
    return plan;
  }

  /// Retrieve 4-day schedule only
  Future<List<PlanScheduleDayItem>> getPlanSchedule(int id) async {
    final url = ApiEndpoint.planSchedule(id);
    debugPrint('[API HIT][GET] /plans/$id/schedule/ -> $url');

    final dynamic data = await _apiClient.get(
      url: url,
      logLabel: 'Get Plan Schedule (id=$id)',
      headers: _authHeaders,
      showDebugLog: true,
    );

    if (data is List) {
      return data
          .map((e) =>
              PlanScheduleDayItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    }
    return const [];
  }

  /// Retrieve exercises and instructions for a selected schedule day (e.g. day=1 or day=push)
  Future<PlanScheduleDayItem> getPlanDay(int id, dynamic day) async {
    final url = ApiEndpoint.planDay(id, day);
    debugPrint('[API HIT][GET] /plans/$id/days/$day/ -> $url');

    final dynamic data = await _apiClient.get(
      url: url,
      logLabel: 'Get Plan Day (id=$id, day=$day)',
      headers: _authHeaders,
      showDebugLog: true,
    );

    return PlanScheduleDayItem.fromJson(data as Map<String, dynamic>);
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      debugPrint('[PlanApiService] No access token found in StorageService');
      return const <String, String>{};
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }
}
