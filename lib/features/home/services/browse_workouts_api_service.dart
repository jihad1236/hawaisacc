import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/home/model/browse_workout_item.dart';

class BrowseWorkoutsApiService {
  BrowseWorkoutsApiService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<List<BrowseWorkoutItem>> getWorkouts({
    String region = 'all',
    int page = 1,
    int pageSize = 50,
  }) async {
    final normalizedRegion = region == 'all' ? null : region;
    final url = ApiEndpoint.browseWorkouts(
      bodyRegion: normalizedRegion,
      page: page,
      pageSize: pageSize,
    );
    debugPrint('[API HIT][GET] /workouts/ browse region=$region -> $url');

    final dynamic data = await _apiClient.requestJson(
      method: 'GET',
      url: url,
      headers: _authHeaders,
      logLabel: 'Get Browse Workouts',
      showDebugLog: true,
    );

    // The documented API returns {results: [...]}, while the currently
    // deployed endpoint returns a plain list. Support both contracts.
    final rawItems = data is List
        ? data
        : (data is Map ? data['results'] : const <dynamic>[]);
    if (rawItems is! List) {
      return const <BrowseWorkoutItem>[];
    }

    final items = rawItems
        .whereType<Map>()
        .map(
          (item) => BrowseWorkoutItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    debugPrint('Get Browse Workouts parsed count=${items.length}');
    return items;
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      return const <String, String>{};
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }
}
