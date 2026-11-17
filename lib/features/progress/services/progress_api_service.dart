import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/progress/model/progress_analytics_models.dart';
import 'package:hawiisaac/features/progress/model/progress_summary_model.dart';

class ProgressApiService {
  ProgressApiService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Map<String, String> get _headers {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in again to load progress.',
        statusCode: 401,
      );
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  /// v2.1 Endpoint 4.1: Progress Summary (Single day or period with breakdown)
  Future<ProgressSummaryResponse> getProgressSummary({
    String? date,
    String? period = '1w',
    String? startDate,
    String? endDate,
  }) async {
    final url = ApiEndpoint.progressSummaryEndpoint(
      date: date,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
    debugPrint('[API HIT][GET] /progress/summary/ -> $url');

    final data = await _apiClient.get(
      url: url,
      headers: _headers,
      logLabel: 'Get Progress Summary (period=$period, date=$date)',
      showDebugLog: true,
    );

    final response = ProgressSummaryResponse.fromJson(data);
    debugPrint(
      'ProgressSummary parsed: period=${response.period}, volume=${response.summary.totalVolumeDisplay}, workouts=${response.summary.workoutsCount}',
    );
    return response;
  }

  /// Legacy / Combined Progress Analytics
  Future<ProgressAnalyticsResponse> getProgress({String period = '1m'}) async {
    final url = ApiEndpoint.progress(period: period);
    debugPrint('ProgressApiService: GET $url');

    try {
      final data = await _apiClient.get(
        url: url,
        headers: _headers,
        logLabel: 'Get Progress ($period)',
        showDebugLog: true,
      );

      final response = ProgressAnalyticsResponse.fromJson(data);
      return response;
    } catch (e) {
      debugPrint('ProgressApiService: falling back to summary endpoint: $e');
      final summary = await getProgressSummary(period: period);
      return ProgressAnalyticsResponse(
        period: summary.period,
        dateRangeDisplay: summary.dateRange.display,
        totalVolumeDisplay: summary.summary.totalVolumeDisplay,
        totalVolumeLifted: summary.summary.totalVolumeKg,
      );
    }
  }
}
