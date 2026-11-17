import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';
import 'package:hawiisaac/features/home/services/bookmark_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class BookmarksController extends GetxController {
  final BookmarkApiService _bookmarkApiService = BookmarkApiService();

  // ── Observables ────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DashboardWorkoutItem> bookmarks = <DashboardWorkoutItem>[].obs;
  final RxnInt removingBookmarkId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
  }

  void onBackTap() => Get.back();

  Future<void> refreshBookmarks() => fetchBookmarks(isRefresh: true);

  Future<void> fetchBookmarks({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final items = await _bookmarkApiService.getBookmarks();

      final homeController =
          Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
      final allHomePlans = homeController != null
          ? [
              ...homeController.forYouPlans,
              ...homeController.browsePlans,
              ...homeController.trendingPlans,
            ]
          : <DashboardWorkoutItem>[];

      final mapped = items.map((raw) {
        var item = raw.toDashboardWorkoutItem();
        // Enrich from HomeController plans if available (e.g. for richer images or subtitles)
        final match = allHomePlans.firstWhereOrNull((p) => p.id == item.id);
        if (match != null) {
          item = item.copyWith(
            image: (item.image != null && item.image!.isNotEmpty)
                ? item.image
                : match.image,
            description: item.description.isNotEmpty
                ? item.description
                : match.description,
            categoryName: item.categoryName ?? match.categoryName,
            subtitle: match.subtitle,
            equipmentNote: match.equipmentNote,
          );
        }
        return item;
      }).toList();

      bookmarks.assignAll(mapped);
      errorMessage.value = '';

      // Sync with HomeController's bookmarkedWorkoutIds if registered
      if (homeController != null) {
        for (final item in items) {
          homeController.syncWorkoutBookmark(item.id, true);
        }
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      if (!isRefresh) {
        AppLoadingService.showError('Bookmarks Error', e.message);
      }
    } catch (e) {
      debugPrint('[BookmarksController] Error fetching bookmarks: $e');
      errorMessage.value = 'Failed to load bookmarks. Please try again.';
      if (!isRefresh) {
        AppLoadingService.showError('Bookmarks Error', errorMessage.value);
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void onContentTap(DashboardWorkoutItem item) {
    Get.toNamed(
      AppRoute.getWarmUpDetailsScreen(),
      arguments: {
        'id': item.id.toString(),
        'title': item.title,
        'image': item.image ?? '',
        'duration': item.durationDisplay.isNotEmpty
            ? item.durationDisplay
            : (item.durationMinutes > 0 ? '${item.durationMinutes} min' : ''),
        'level': item.levelDisplay.isNotEmpty ? item.levelDisplay : item.level,
        'tags': item.categoryName ?? item.equipmentNote,
        'sets': '-',
        'reps': '-',
        'rest': '-',
        'video': '',
        'description': item.description,
      },
    );
  }

  Future<void> removeBookmark(DashboardWorkoutItem item) async {
    if (removingBookmarkId.value != null) return;

    removingBookmarkId.value = item.id;

    // Optimistically remove from list
    final existingIndex = bookmarks.indexWhere((b) => b.id == item.id);
    if (existingIndex != -1) {
      bookmarks.removeAt(existingIndex);
    }

    // Sync HomeController
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().syncWorkoutBookmark(item.id, false);
    }

    try {
      final isStillBookmarked =
          await _bookmarkApiService.toggleBookmark(item.id);

      if (isStillBookmarked) {
        // Toggle returned true, meaning it was re-added rather than removed
        if (existingIndex != -1 && existingIndex <= bookmarks.length) {
          bookmarks.insert(existingIndex, item);
        } else {
          bookmarks.add(item);
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().syncWorkoutBookmark(item.id, true);
        }
      } else {
        AppLoadingService.showSuccess(
          'Removed',
          '"${item.title}" removed from bookmarks',
        );
      }
    } on AuthException catch (e) {
      // Revert optimistic removal
      if (existingIndex != -1 && existingIndex <= bookmarks.length) {
        bookmarks.insert(existingIndex, item);
      } else {
        bookmarks.add(item);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().syncWorkoutBookmark(item.id, true);
      }
      AppLoadingService.showError('Bookmark Failed', e.message);
    } catch (e) {
      // Revert optimistic removal
      if (existingIndex != -1 && existingIndex <= bookmarks.length) {
        bookmarks.insert(existingIndex, item);
      } else {
        bookmarks.add(item);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().syncWorkoutBookmark(item.id, true);
      }
      AppLoadingService.showError(
        'Bookmark Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      removingBookmarkId.value = null;
    }
  }

  bool isRemovingBookmark(int id) => removingBookmarkId.value == id;
}
