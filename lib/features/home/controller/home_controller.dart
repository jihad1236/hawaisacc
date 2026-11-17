import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';
import 'package:hawiisaac/features/home/services/bookmark_api_service.dart';
import 'package:hawiisaac/features/home/services/dashboard_api_service.dart';
import 'package:hawiisaac/features/progress/services/progress_api_service.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class HomeController extends GetxController {
  final DashboardApiService _dashboardApiService = DashboardApiService();
  final BookmarkApiService _bookmarkApiService = BookmarkApiService();
  final ProgressApiService _progressApiService = ProgressApiService();

  // ── States ─────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // ── User Info ──────────────────────────────────────────────────
  final RxString userName = 'User'.obs;
  final RxString userInitials = 'U'.obs;
  final RxnString profileImage = RxnString();
  final RxString greeting = 'Good Morning'.obs;

  // ── Stats ──────────────────────────────────────────────────────
  final RxString daysStreak = '0'.obs;
  final RxString streakDisplay = '0 Days streak'.obs;
  final RxString thisWeek = '0'.obs;
  final RxString thisWeekDisplay = '0/5'.obs;
  final RxString caloriesBurned = '0'.obs;
  final RxString caloriesBurnedDisplay = '0'.obs;
  final RxInt weeklyCompleted = 0.obs;
  final RxInt weeklyGoal = 5.obs;

  // ── Today's Progress ───────────────────────────────────────────
  final RxBool isTodayProgressLoading = true.obs;
  final Rxn<ProgressSummary> todayProgress = Rxn<ProgressSummary>();
  int _todayProgressRequestId = 0;

  // ── Recent Activities (Backward Compatibility) ────────────────
  final RxList<DashboardRecentActivity> recentActivities =
      <DashboardRecentActivity>[].obs;

  // ── Tabs ───────────────────────────────────────────────────────
  final RxList<String> tabs = <String>[
    'For You',
    'Browse',
    'Expert Tips',
    'Trending',
  ].obs;
  final RxInt selectedTabIndex = 0.obs;

  // ── Plans & Content ───────────────────────────────────────────
  final RxList<DashboardWorkoutItem> forYouPlans = <DashboardWorkoutItem>[].obs;
  final RxList<DashboardWorkoutItem> browsePlans = <DashboardWorkoutItem>[].obs;
  final RxList<DashboardExpertTip> expertTips = <DashboardExpertTip>[].obs;
  final RxList<DashboardWorkoutItem> trendingPlans =
      <DashboardWorkoutItem>[].obs;

  // Backward compatibility lists for legacy observers & BookmarksController
  final RxList<DashboardWorkoutItem> forYouWorkouts =
      <DashboardWorkoutItem>[].obs;
  final RxList<DashboardWorkoutItem> warmUpWorkouts =
      <DashboardWorkoutItem>[].obs;
  final RxList<DashboardWorkoutItem> perfectForHomeWorkouts =
      <DashboardWorkoutItem>[].obs;
  final RxList<DashboardWorkoutItem> expertTipsWorkouts =
      <DashboardWorkoutItem>[].obs;
  final RxList<DashboardWorkoutItem> trendingWorkouts =
      <DashboardWorkoutItem>[].obs;
  final RxList<DashboardBrowseCategory> browseCategories =
      <DashboardBrowseCategory>[].obs;

  // Bookmarking
  final RxSet<int> bookmarkedWorkoutIds = <int>{}.obs;
  final RxnInt bookmarkingContentId = RxnInt();

  // Backward compatibility lists for BookmarksController
  final RxList<ContentItem> featuredContents = <ContentItem>[].obs;
  final RxList<ContentItem> moreContents = <ContentItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    greeting.value = _currentGreeting();
    fetchDashboard();
    fetchTodayProgress();
  }

  bool get hasTodayProgress {
    final progress = todayProgress.value;
    if (progress == null) return false;
    return progress.totalWorkouts > 0 ||
        progress.totalSets > 0 ||
        progress.avgDuration > 0;
  }

  Future<void> fetchTodayProgress() async {
    final requestId = ++_todayProgressRequestId;
    isTodayProgressLoading.value = true;
    // Never render a previous response while the new Today request is running.
    todayProgress.value = null;

    try {
      final response = await _progressApiService.getProgress(period: 'today');
      if (requestId != _todayProgressRequestId) return;

      debugPrint(
        '[HomeController] Today progress response period=${response.period}, '
        'workouts=${response.metrics.workouts.value}, '
        'sets=${response.metrics.totalSets.value}, '
        'duration=${response.metrics.avgDuration.value}',
      );

      todayProgress.value = ProgressSummary(
        totalWorkouts: response.metrics.workouts.value,
        totalSets: response.metrics.totalSets.value,
        totalVolume: response.totalVolumeLifted,
        avgDuration: response.metrics.avgDuration.value,
      );
    } catch (error) {
      if (requestId != _todayProgressRequestId) return;
      debugPrint('[HomeController] Today progress error: $error');
      todayProgress.value = null;
    } finally {
      if (requestId == _todayProgressRequestId) {
        isTodayProgressLoading.value = false;
      }
    }
  }

  Future<void> refreshHome() async {
    await Future.wait([fetchDashboard(isRefresh: true), fetchTodayProgress()]);
  }

  String get selectedTab =>
      selectedTabIndex.value < tabs.length ? tabs[selectedTabIndex.value] : '';

  void onTabSelected(int index) {
    if (selectedTabIndex.value == index) return;
    selectedTabIndex.value = index;
  }

  Future<void> fetchDashboard({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final dashboard = await _dashboardApiService.getDashboard();

      // Update User Info
      userName.value = dashboard.name.isNotEmpty
          ? dashboard.name
          : (dashboard.username.isNotEmpty ? dashboard.username : 'User');
      userInitials.value = dashboard.initials.isNotEmpty
          ? dashboard.initials
          : _initialsFor(userName.value);
      profileImage.value = dashboard.profileImage;
      greeting.value = dashboard.greeting.isNotEmpty
          ? dashboard.greeting
          : _currentGreeting();

      // Update Stats
      daysStreak.value = dashboard.streakDays.toString();
      streakDisplay.value = dashboard.streakDisplay.isNotEmpty
          ? dashboard.streakDisplay
          : '${dashboard.streakDays} Days streak';
      weeklyCompleted.value = dashboard.weeklyCompleted;
      weeklyGoal.value = dashboard.weeklyGoal;
      thisWeek.value = dashboard.thisWeekDisplay.isNotEmpty
          ? dashboard.thisWeekDisplay
          : (dashboard.weeklyGoal > 0
                ? '${dashboard.weeklyCompleted}/${dashboard.weeklyGoal}'
                : dashboard.weeklyCompleted.toString());
      thisWeekDisplay.value = dashboard.thisWeekDisplay;
      caloriesBurned.value = dashboard.caloriesBurnedDisplay.isNotEmpty
          ? dashboard.caloriesBurnedDisplay
          : _formatNumber(dashboard.caloriesBurned);
      caloriesBurnedDisplay.value = dashboard.caloriesBurnedDisplay;

      // Update Tabs
      if (dashboard.tabs.isNotEmpty) {
        tabs.assignAll(dashboard.tabs);
      }

      // Update Plans
      forYouPlans.assignAll(dashboard.forYouPlans);
      browsePlans.assignAll(dashboard.browsePlans);
      expertTips.assignAll(dashboard.expertTips);
      trendingPlans.assignAll(dashboard.trendingPlans);

      // Populate bookmarkedWorkoutIds from API items if marked
      for (final plan in [
        ...dashboard.forYouPlans,
        ...dashboard.browsePlans,
        ...dashboard.trendingPlans,
      ]) {
        if (plan.isBookmarked) {
          bookmarkedWorkoutIds.add(plan.id);
        }
      }

      // Backward compatibility sync
      forYouWorkouts.assignAll(dashboard.forYouPlans);
      trendingWorkouts.assignAll(dashboard.trendingPlans);
      _syncBackwardCompatibleContents();

      errorMessage.value = '';
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      if (!isRefresh) {
        AppLoadingService.showError('Dashboard Error', e.message);
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching dashboard: $e');
      errorMessage.value = 'Failed to load dashboard data. Please try again.';
      if (!isRefresh) {
        AppLoadingService.showError('Dashboard Error', errorMessage.value);
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void _syncBackwardCompatibleContents() {
    featuredContents.assignAll(
      forYouPlans.map((w) => _workoutToContentItem(w, 'For You')),
    );
    moreContents.assignAll(
      browsePlans.map((w) => _workoutToContentItem(w, 'Browse')),
    );
  }

  ContentItem _workoutToContentItem(DashboardWorkoutItem item, String feed) {
    return ContentItem(
      id: item.id,
      title: item.title,
      feedType: feed,
      contentType: item.level,
      workouts: const [],
      summary: item.subtitle.isNotEmpty
          ? item.subtitle
          : '${item.durationDisplay.isNotEmpty ? item.durationDisplay : '${item.durationMinutes} min'} • ${item.level}',
      body: item.description,
      image: item.image ?? '',
      video: '',
      isActive: true,
      isFree: true,
      createdAt: null,
      updatedAt: null,
      bookmarkCount: 0,
      shareCount: 0,
      reactionCount: 0,
      viewCount: 0,
      isBookmarked: isWorkoutBookmarked(item.id),
      myReaction: '',
    );
  }

  bool isWorkoutBookmarked(int id) {
    return bookmarkedWorkoutIds.contains(id);
  }

  Future<void> toggleWorkoutBookmark(DashboardWorkoutItem item) async {
    final wasBookmarked = isWorkoutBookmarked(item.id);

    // Optimistic local update for responsive UI
    if (wasBookmarked) {
      bookmarkedWorkoutIds.remove(item.id);
    } else {
      bookmarkedWorkoutIds.add(item.id);
    }
    _syncBackwardCompatibleContents();

    try {
      final isNowBookmarked = await _bookmarkApiService.toggleBookmark(item.id);
      if (isNowBookmarked) {
        bookmarkedWorkoutIds.add(item.id);
        AppLoadingService.showSuccess(
          'Saved',
          '"${item.title}" added to bookmarks',
        );
      } else {
        bookmarkedWorkoutIds.remove(item.id);
        AppLoadingService.showSuccess(
          'Removed',
          '"${item.title}" removed from bookmarks',
        );
      }
      _syncBackwardCompatibleContents();
    } on AuthException catch (e) {
      // Rollback on auth error
      if (wasBookmarked) {
        bookmarkedWorkoutIds.add(item.id);
      } else {
        bookmarkedWorkoutIds.remove(item.id);
      }
      _syncBackwardCompatibleContents();
      AppLoadingService.showError('Bookmark Failed', e.message);
    } catch (e) {
      // Rollback on network/generic error
      if (wasBookmarked) {
        bookmarkedWorkoutIds.add(item.id);
      } else {
        bookmarkedWorkoutIds.remove(item.id);
      }
      _syncBackwardCompatibleContents();
      AppLoadingService.showError(
        'Bookmark Failed',
        'Could not update bookmark. Please try again.',
      );
    }
  }

  void syncWorkoutBookmark(int id, bool isBookmarked) {
    if (isBookmarked) {
      bookmarkedWorkoutIds.add(id);
    } else {
      bookmarkedWorkoutIds.remove(id);
    }
    _syncBackwardCompatibleContents();
  }

  void applyBookmarkResult(ContentBookmarkResult result) {
    if (result.isBookmarked) {
      bookmarkedWorkoutIds.add(result.contentId);
    } else {
      bookmarkedWorkoutIds.remove(result.contentId);
    }
    _syncBackwardCompatibleContents();
  }

  void onBookmarkTap() {
    Get.toNamed(AppRoute.getBookmarksScreen());
  }

  void onNotificationTap() => Get.toNamed(AppRoute.getNotificationsScreen());

  void onWorkoutTap(DashboardWorkoutItem item) {
    Get.toNamed(
      AppRoute.getWarmUpDetailsScreen(),
      arguments: {
        'id': item.id.toString(),
        'title': item.title,
        'image': item.image ?? '',
        'duration': item.durationDisplay.isNotEmpty
            ? item.durationDisplay
            : '${item.durationMinutes} min',
        'level': item.levelDisplay.isNotEmpty ? item.levelDisplay : item.level,
        'tags': item.categoryName ?? item.level,
        'sets': '-',
        'reps': '-',
        'rest': '-',
      },
    );
  }

  void onExpertTipTap(DashboardExpertTip tip) {
    Get.toNamed(AppRoute.getContentDetailsScreen(), arguments: tip);
  }

  String _currentGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value
        .toStringAsFixed(1)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      final str = parts.first;
      return str.isNotEmpty ? str[0].toUpperCase() : 'U';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
