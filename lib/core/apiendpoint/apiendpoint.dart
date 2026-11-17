class ApiEndpoint {
  ApiEndpoint._();

  static const String baseUrl = 'https://api.hykxapp.com/api';

  static const String login = '$baseUrl/auth/login/';
  static const String googleAuth = '$baseUrl/auth/google/';
  static const String logout = '$baseUrl/auth/logout/';
  static const String firebaseAuth = '$baseUrl/auth/firebase';
  static const String verifyToken = '$baseUrl/auth/verify-token';
  static const String sendOtp = '$baseUrl/auth/send_otp';
  static const String verifyOtp = '$baseUrl/auth/verify_otp';
  static const String verifyEmail = '$baseUrl/auth/verify-email/';
  static const String verifyResetOtp = '$baseUrl/auth/verify-reset-otp/';
  static const String signup = '$baseUrl/auth/signup/';
  static const String resetPassword = '$baseUrl/auth/reset-password/';
  static const String changePassword = '$baseUrl/auth/change-password/';
  static const String forgotPassword = '$baseUrl/auth/forgot-password/';
  static const String userPreference = '$baseUrl/user/preference/';
  static const String authUnits = '$baseUrl/auth/units/';
  static const String workoutProfile = '$baseUrl/auth/workout-profile/';
  static const String profile = '$baseUrl/auth/profile/';
  static const String currentUser = '$baseUrl/user/users/me';
  static String userById(String id) => '$baseUrl/user/users/$id';
  static const String dashboard = '$baseUrl/dashboard/';

  // ── Workout Plans & 4-Day Schedules (developer-guide-bespoke-workouts-and-updates.md) ──
  static String plans({
    String? location,
    String? goal,
    String? level,
  }) {
    final queryParams = <String>[
      if (location != null && location.isNotEmpty) 'location=${Uri.encodeQueryComponent(location)}',
      if (goal != null && goal.isNotEmpty) 'goal=${Uri.encodeQueryComponent(goal)}',
      if (level != null && level.isNotEmpty) 'level=${Uri.encodeQueryComponent(level)}',
    ];
    return queryParams.isEmpty ? '$baseUrl/plans/' : '$baseUrl/plans/?${queryParams.join('&')}';
  }

  static String planById(int id, {dynamic day}) {
    if (day != null && day.toString().isNotEmpty) {
      return '$baseUrl/plans/$id/?day=${Uri.encodeQueryComponent(day.toString())}';
    }
    return '$baseUrl/plans/$id/';
  }

  static String planSchedule(int id) => '$baseUrl/plans/$id/schedule/';
  static String planDay(int id, dynamic day) =>
      '$baseUrl/plans/$id/days/${Uri.encodeQueryComponent(day.toString())}/';

  static String workouts({int? equipmentId, int offset = 0, int limit = 20}) {
    final queryParams = <String>[
      if (equipmentId != null && equipmentId > 0) 'equipment_id=$equipmentId',
      'offset=$offset',
      'limit=$limit',
    ];

    return '$baseUrl/workouts/?${queryParams.join('&')}';
  }

  static String browseWorkouts({
    String? bodyRegion,
    int page = 1,
    int pageSize = 50,
  }) {
    final queryParams = <String>[
      if (bodyRegion != null && bodyRegion.trim().isNotEmpty)
        'body_region=${Uri.encodeQueryComponent(bodyRegion)}',
      'page=$page',
      'page_size=$pageSize',
    ];

    return '$baseUrl/workouts/?${queryParams.join('&')}';
  }

  static String equipments({int? offset, int? limit}) => '$baseUrl/equipment/';

  static String muscleGroups({int offset = 0, int limit = 20}) =>
      '$baseUrl/muscle-groups/?offset=$offset&limit=$limit';

  static String equipmentCategories({int? offset, int? limit}) =>
      '$baseUrl/categories/';

  static String workoutById(int id) => '$baseUrl/workouts/$id/';
  static String workoutStartLog(int id) => '$baseUrl/workouts/$id/start-log';
  static const String scanEquipment = '$baseUrl/scan/';
  static String scanExerciseById(int id) => '$baseUrl/scan/$id/';
  static const String aiScanEquipmentUpload = scanEquipment;
  static const String aiVerifyEquipment = '$baseUrl/ai/verify-equipment';

  static String contents({
    bool isActive = true,
    String? feed,
    int offset = 0,
    int? limit,
  }) {
    final queryParams = <String>[
      'is_active=$isActive',
      if (feed != null && feed.trim().isNotEmpty) 'feed=$feed',
      'offset=$offset',
      if (limit != null) 'limit=$limit',
    ];

    return '$baseUrl/content/contents/?${queryParams.join('&')}';
  }

  static String contentById(int id) => '$baseUrl/content/contents/$id';
  static String contentStartLog(int id) =>
      '$baseUrl/content/contents/$id/start-log';

  static String contentBookmarks(int id) =>
      '$baseUrl/content/contents/$id/bookmarks';

  static String contentBookmarkCount(int id) =>
      '$baseUrl/content/contents/$id/bookmarks/count';

  static String expertTips({int? offset, int? limit}) {
    final queryParams = <String>[
      if (offset != null) 'offset=$offset',
      if (limit != null) 'limit=$limit',
    ];
    final query = queryParams.isEmpty ? '' : '?${queryParams.join('&')}';
    return '$baseUrl/expert-tips/$query';
  }

  static String expertTipById(int id) => '$baseUrl/expert-tips/$id/';

  static String equipmentById(int id) => '$baseUrl/equipment/$id/';

  static String muscleGroupById(int id) => '$baseUrl/muscle-groups/$id/';

  static String equipmentCategoryById(int id) => '$baseUrl/categories/$id/';

  static const String sessions = '$baseUrl/sessions/sessions';
  static String activeSession() => '$sessions/active';
  static String sessionById(int id) => '$sessions/$id';
  static String completeSession(int id) => '$sessions/$id/complete';
  static String cardioLog() => '$baseUrl/sessions/cardio-log';
  static String completeSessionWorkout(int id) =>
      '$baseUrl/sessions/session-workouts/$id/complete';
  static String setLog() => '$baseUrl/sessions/set-log';
  static const String cardioLogs = '$baseUrl/logs/cardio/';

  // ── Active Workout Sessions (logging_guidance.md) ─────────────────────────
  static const String activeWorkoutSession =
      '$baseUrl/workout-sessions/active/';
  static const String addExerciseToActiveSession =
      '$baseUrl/workout-sessions/active/add-exercise/';
  static const String startWorkoutSession = '$baseUrl/workout-sessions/start/';
  static const String activeSessionSets =
      '$baseUrl/workout-sessions/active/sets/';
  static const String activeSessionCardio =
      '$baseUrl/workout-sessions/active/cardio/';
  static const String activeSessionNotes =
      '$baseUrl/workout-sessions/active/notes/';
  static String completeActiveExercise(int exerciseId) =>
      '$baseUrl/workout-sessions/active/exercises/$exerciseId/complete/';
  static const String finishActiveSession =
      '$baseUrl/workout-sessions/active/finish/';
  static const String recordWorkoutSession =
      '$baseUrl/workout-sessions/record/';

  static String sessionsList({
    required String userId,
    int offset = 0,
    int limit = 20,
  }) => '$sessions?user_id=$userId&offset=$offset&limit=$limit';

  // ── Workout Progress Summary APIs (Section 4) ───────────────────────────
  static String progress({String period = '1m'}) =>
      '$baseUrl/progress/summary/?period=${Uri.encodeQueryComponent(period)}';

  static String progressSummaryEndpoint({
    String? date,
    String? period,
    String? startDate,
    String? endDate,
  }) {
    final params = <String>[
      if (date != null && date.isNotEmpty) 'date=${Uri.encodeQueryComponent(date)}',
      if (period != null && period.isNotEmpty) 'period=${Uri.encodeQueryComponent(period)}',
      if (startDate != null && startDate.isNotEmpty) 'start_date=${Uri.encodeQueryComponent(startDate)}',
      if (endDate != null && endDate.isNotEmpty) 'end_date=${Uri.encodeQueryComponent(endDate)}',
    ];
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl/progress/summary/$query';
  }

  static String progressSummary({String? startDate, String? endDate}) {
    final params = <String>[
      if (startDate != null) 'start_date=$startDate',
      if (endDate != null) 'end_date=$endDate',
    ];
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl/progress/summary/$query';
  }

  static String progressChart({String? startDate, String? endDate}) {
    final params = <String>[
      if (startDate != null) 'start_date=$startDate',
      if (endDate != null) 'end_date=$endDate',
    ];
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl/sessions/progress/chart$query';
  }

  static String progressBests({
    int limit = 3,
    String? startDate,
    String? endDate,
  }) {
    final params = <String>[
      'limit=$limit',
      if (startDate != null) 'start_date=$startDate',
      if (endDate != null) 'end_date=$endDate',
    ];
    return '$baseUrl/sessions/progress/bests?${params.join('&')}';
  }

  static String progressHighlights({required String userId}) =>
      '$baseUrl/sessions/progress/highlights?user_id=${Uri.encodeQueryComponent(userId)}';

  static String progressRecentActivity({
    required String userId,
    int limit = 5,
  }) =>
      '$baseUrl/sessions/progress/recent-activity?user_id=${Uri.encodeQueryComponent(userId)}&limit=$limit';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notifications = '$baseUrl/notifications/';
  static const String notificationUnreadCount =
      '$baseUrl/notifications/unread-count/';
  static String notificationMarkRead(dynamic id) =>
      '$baseUrl/notifications/$id/mark-read/';
  static const String notificationMarkAllRead =
      '$baseUrl/notifications/mark-all-read/';
  static const String adminNotifications = '$baseUrl/notifications/';
  static String adminNotificationMarkRead(String id) =>
      '$baseUrl/notifications/$id/read/';
  static const String adminNotificationMarkAllRead =
      '$baseUrl/notifications/mark-all-read/';

  // ── Bookmarks (bookmark_guidance.md) ──────────────────────────────────────
  static const String bookmarks = '$baseUrl/bookmarks/';
  static String workoutBookmark(int id) => '$baseUrl/workouts/$id/bookmark/';

  // ── Subscriptions & Entitlements (Section 5) ─────────────────────────────
  static const String subscriptionStatus = '$baseUrl/subscriptions/status/';
  static const String subscriptionMySubscription =
      '$baseUrl/subscriptions/my-subscription/';
  static const String subscriptionPlans = '$baseUrl/subscriptions/plans/';
  static const String subscriptionRestore =
      '$baseUrl/subscriptions/restore/';
  static const String googlePlayVerify =
      '$baseUrl/subscriptions/google-play/verify/';
  static const String appleVerify = '$baseUrl/subscriptions/apple/verify/';
}
