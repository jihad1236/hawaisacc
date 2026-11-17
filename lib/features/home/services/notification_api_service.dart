import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/home/model/notification_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationApiService {
  NotificationApiService({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;
  static const String _dismissedNotificationIdsKey =
      'dismissed_notification_ids';

  Map<String, String> get _headers {
    if (!StorageService.hasAccessToken) {
      return const <String, String>{};
    }
    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  /// 1. Fetch user notifications list: GET /api/notifications/
  /// Strictly fetches real notifications from backend. Returns [] if empty or on error.
  Future<List<NotificationItem>> getNotifications() async {
    final dismissedIds = await getDismissedNotificationIds();

    try {
      final url = ApiEndpoint.notifications;
      debugPrint('[API HIT][GET] /notifications/ -> $url');

      final dynamic response = await _apiClient.requestJson(
        method: 'GET',
        url: url,
        logLabel: 'Get Notifications',
        headers: _headers,
        showDebugLog: true,
      );

      final List<dynamic> rawList;
      if (response is List) {
        rawList = response;
      } else if (response is Map<String, dynamic>) {
        if (response['results'] is List) {
          rawList = response['results'] as List<dynamic>;
        } else if (response['data'] is List) {
          rawList = response['data'] as List<dynamic>;
        } else if (response['notifications'] is List) {
          rawList = response['notifications'] as List<dynamic>;
        } else {
          rawList = const <dynamic>[];
        }
      } else {
        rawList = const <dynamic>[];
      }

      final items = <NotificationItem>[];
      for (final raw in rawList) {
        if (raw is Map<String, dynamic>) {
          final item = NotificationItem.fromJson(raw);
          if (!dismissedIds.contains(item.id)) {
            items.add(item);
          }
        }
      }

      debugPrint('[NotificationApiService] Loaded ${items.length} notifications from backend');
      return items;
    } catch (e) {
      debugPrint('[NotificationApiService] Error fetching notifications: $e');
      return const <NotificationItem>[];
    }
  }

  /// 2. Fetch unread count for badge: GET /api/notifications/unread-count/
  Future<int> getUnreadCount() async {
    try {
      final url = ApiEndpoint.notificationUnreadCount;
      debugPrint('[API HIT][GET] /notifications/unread-count/ -> $url');

      final dynamic response = await _apiClient.requestJson(
        method: 'GET',
        url: url,
        logLabel: 'Get Unread Count',
        headers: _headers,
        showDebugLog: true,
      );

      if (response is Map<String, dynamic> &&
          response['unread_count'] != null) {
        final count = response['unread_count'];
        if (count is int) return count;
        return int.tryParse(count.toString()) ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('[NotificationApiService] Error getting unread count: $e');
      return 0;
    }
  }

  /// 3. Mark single notification as read: PATCH /api/notifications/`<id>`/mark-read/
  Future<bool> markAsRead(dynamic notificationId) async {
    try {
      final url = ApiEndpoint.notificationMarkRead(notificationId);
      debugPrint('[API HIT][PATCH] /notifications/$notificationId/mark-read/ -> $url');

      await _apiClient.patchJson(
        url: url,
        body: const <String, dynamic>{},
        logLabel: 'Mark Notification Read',
        headers: _headers,
        showDebugLog: true,
      );
      return true;
    } catch (e) {
      debugPrint('[NotificationApiService] Mark as read API error: $e');
      return false;
    }
  }

  /// 4. Mark all notifications as read: POST /api/notifications/mark-all-read/
  Future<bool> markAllAsRead() async {
    try {
      final url = ApiEndpoint.notificationMarkAllRead;
      debugPrint('[API HIT][POST] /notifications/mark-all-read/ -> $url');

      await _apiClient.postJson(
        url: url,
        body: const <String, dynamic>{},
        logLabel: 'Mark All Notifications Read',
        headers: _headers,
        showDebugLog: true,
      );
      return true;
    } catch (e) {
      debugPrint('[NotificationApiService] Mark all read API error: $e');
      return false;
    }
  }

  /// Dismisses notification locally
  Future<void> dismissNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dismissedNotificationIdsKey) ?? <String>[];
    if (!list.contains(notificationId)) {
      list.add(notificationId);
      await prefs.setStringList(_dismissedNotificationIdsKey, list);
    }
  }

  Future<Set<String>> getDismissedNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dismissedNotificationIdsKey) ?? <String>[];
    return list.toSet();
  }
}
