import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/home/model/notification_item.dart';
import 'package:hawiisaac/features/home/services/notification_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class NotificationsController extends GetxController {
  NotificationsController({NotificationApiService? apiService})
      : _apiService = apiService ?? NotificationApiService();

  final NotificationApiService _apiService;

  // ── States ──────────────────────────────────────────────────────────────
  // Starts completely empty — NO static or dummy data
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Getters ─────────────────────────────────────────────────────────────
  bool get hasUnread => unreadCount.value > 0;
  bool get isEmptyList => notifications.isEmpty;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[NotificationsController] onInit called, fetching notifications...');
    loadNotifications();
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      debugPrint('[NotificationsController] Loading notifications from API...');

      final items = await _apiService.getNotifications();
      notifications.assignAll(items);
      debugPrint('[NotificationsController] Notifications loaded: ${items.length} items');

      await fetchUnreadCount();
    } catch (e) {
      debugPrint('[NotificationsController] Failed to load notifications: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
      notifications.clear();
      unreadCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    try {
      isRefreshing.value = true;
      hasError.value = false;
      debugPrint('[NotificationsController] Pull-to-refresh triggered...');

      final items = await _apiService.getNotifications();
      notifications.assignAll(items);

      await fetchUnreadCount();
    } catch (e) {
      debugPrint('[NotificationsController] Refresh failed: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await _apiService.getUnreadCount();
      if (count > 0) {
        unreadCount.value = count;
      } else {
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
      debugPrint('[NotificationsController] Unread count: ${unreadCount.value}');
    } catch (e) {
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    }
  }

  Future<void> markAsRead(NotificationItem item) async {
    if (!item.isRead) {
      // Optimistic update
      final index = notifications.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        notifications[index] = item.copyWith(isRead: true);
      }
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
      debugPrint('[NotificationsController] Marking notification ${item.id} as read...');
      await _apiService.markAsRead(item.id);
    }

    _handleNotificationLink(item.link);
  }

  void _handleNotificationLink(String? link) {
    if (link == null || link.trim().isEmpty) return;

    final normalized = link.trim().toLowerCase();
    if (normalized.contains('subscript') || normalized.contains('premium')) {
      Get.toNamed(AppRoute.getPremiumScreen());
    } else if (normalized.contains('workout') ||
        normalized.contains('warmup') ||
        normalized.contains('plan')) {
      Get.toNamed(AppRoute.getBottomNavigationScreen());
    }
  }

  Future<void> markAllAsRead() async {
    if (!hasUnread && notifications.every((n) => n.isRead)) return;

    // Optimistic update
    final updated = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifications.assignAll(updated);
    unreadCount.value = 0;
    debugPrint('[NotificationsController] Marking all notifications as read...');

    await _apiService.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    final item = notifications.firstWhereOrNull((n) => n.id == id);
    if (item != null && !item.isRead && unreadCount.value > 0) {
      unreadCount.value--;
    }
    notifications.removeWhere((n) => n.id == id);
    debugPrint('[NotificationsController] Deleting notification $id...');
    await _apiService.dismissNotification(id);
  }
}
