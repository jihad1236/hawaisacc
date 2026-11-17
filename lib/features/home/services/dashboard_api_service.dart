import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';

class DashboardApiService {
  DashboardApiService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<DashboardResponse> getDashboard() async {
    final url = ApiEndpoint.dashboard;
    debugPrint('[API HIT][GET] /dashboard/ -> $url');

    final data = await _apiClient.get(
      url: url,
      logLabel: 'Get Dashboard',
      headers: _authHeaders,
      showDebugLog: true,
    );

    final dashboard = DashboardResponse.fromJson(data);
    debugPrint(
      'Get Dashboard parsed successfully: username=${dashboard.username}, '
      'streak=${dashboard.streakDays}, '
      'forYouPlans=${dashboard.forYouPlans.length}, '
      'browsePlans=${dashboard.browsePlans.length}, '
      'trendingPlans=${dashboard.trendingPlans.length}, '
      'expertTips=${dashboard.expertTips.length}',
    );
    return dashboard;
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      debugPrint('[DashboardApiService] No access token found in StorageService');
      return const <String, String>{};
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }
}
