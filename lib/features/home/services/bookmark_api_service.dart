import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/model/bookmarked_workout_model.dart';

class BookmarkApiService {
  BookmarkApiService({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Map<String, String> get _headers {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in to manage bookmarks.',
        statusCode: 401,
      );
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  /// Toggles bookmark for workout/plan. Returns true if now bookmarked, false if removed.
  Future<bool> toggleBookmark(int workoutId) async {
    final url = ApiEndpoint.workoutBookmark(workoutId);
    debugPrint('BookmarkApiService.toggleBookmark: POST $url');

    final data = await _apiClient.postJson(
      url: url,
      body: const <String, dynamic>{},
      headers: _headers,
      logLabel: 'Toggle Bookmark ($workoutId)',
      showDebugLog: true,
    );

    final isBookmarked = data['bookmarked'] == true;
    debugPrint('BookmarkApiService: workoutId=$workoutId bookmarked=$isBookmarked');
    return isBookmarked;
  }

  /// Fetches all bookmarked workouts.
  Future<List<BookmarkedWorkoutItem>> getBookmarks() async {
    final url = ApiEndpoint.bookmarks;
    debugPrint('BookmarkApiService.getBookmarks: GET $url');

    final data = await _apiClient.getList(
      url: url,
      headers: _headers,
      logLabel: 'Get Bookmarks',
      showDebugLog: true,
    );

    final items = data
        .whereType<Map<String, dynamic>>()
        .map((json) => BookmarkedWorkoutItem.fromJson(json))
        .toList();

    debugPrint('BookmarkApiService: fetched ${items.length} bookmarks');
    return items;
  }
}
