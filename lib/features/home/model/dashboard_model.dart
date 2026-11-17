class DashboardWorkoutItem {
  final int id;
  final String title;
  final String description;
  final String? image;
  final int totalTimeSeconds;
  final int durationMinutes;
  final String durationDisplay;
  final String level;
  final String levelDisplay;
  final int estimatedCalories;
  final int caloriesBurn;
  final String equipmentNote;
  final int? category;
  final String? categoryName;
  final String subtitle;
  final int exerciseCount;
  final bool isBookmarked;

  const DashboardWorkoutItem({
    required this.id,
    required this.title,
    this.description = '',
    this.image,
    this.totalTimeSeconds = 0,
    this.durationMinutes = 0,
    this.durationDisplay = '',
    this.level = '',
    this.levelDisplay = '',
    this.estimatedCalories = 0,
    this.caloriesBurn = 0,
    this.equipmentNote = '',
    this.category,
    this.categoryName,
    this.subtitle = '',
    this.exerciseCount = 0,
    this.isBookmarked = false,
  });

  factory DashboardWorkoutItem.fromJson(Map<String, dynamic> json) {
    final duration =
        int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0;
    final durDisplay =
        json['duration_display']?.toString() ??
        (duration > 0 ? '$duration min' : '');

    return DashboardWorkoutItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      totalTimeSeconds:
          int.tryParse(json['total_time_seconds']?.toString() ?? '') ?? 0,
      durationMinutes: duration,
      durationDisplay: durDisplay,
      level: json['level']?.toString() ?? '',
      levelDisplay: json['level_display']?.toString() ?? '',
      estimatedCalories:
          int.tryParse(json['estimated_calories']?.toString() ?? '') ?? 0,
      caloriesBurn:
          int.tryParse(json['calories_burn']?.toString() ?? '') ?? 0,
      equipmentNote: json['equipment_note']?.toString() ?? '',
      category: int.tryParse(json['category']?.toString() ?? ''),
      categoryName: json['category_name']?.toString(),
      subtitle: json['subtitle']?.toString() ?? '',
      exerciseCount:
          int.tryParse(json['exercise_count']?.toString() ?? '') ?? 0,
      isBookmarked: json['is_bookmarked'] == true,
    );
  }

  DashboardWorkoutItem copyWith({
    int? id,
    String? title,
    String? description,
    String? image,
    int? totalTimeSeconds,
    int? durationMinutes,
    String? durationDisplay,
    String? level,
    String? levelDisplay,
    int? estimatedCalories,
    int? caloriesBurn,
    String? equipmentNote,
    int? category,
    String? categoryName,
    String? subtitle,
    int? exerciseCount,
    bool? isBookmarked,
  }) {
    return DashboardWorkoutItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationDisplay: durationDisplay ?? this.durationDisplay,
      level: level ?? this.level,
      levelDisplay: levelDisplay ?? this.levelDisplay,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      caloriesBurn: caloriesBurn ?? this.caloriesBurn,
      equipmentNote: equipmentNote ?? this.equipmentNote,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      subtitle: subtitle ?? this.subtitle,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

typedef DashboardPlanItem = DashboardWorkoutItem;

class DashboardEquipmentDetail {
  final int id;
  final String title;
  final String name;
  final String? image;

  const DashboardEquipmentDetail({
    required this.id,
    required this.title,
    required this.name,
    this.image,
  });

  factory DashboardEquipmentDetail.fromJson(Map<String, dynamic> json) {
    return DashboardEquipmentDetail(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}

class DashboardExpertTip {
  final int id;
  final String title;
  final String contentType;
  final String description;
  final String contentUrl;
  final String? image;
  final List<DashboardEquipmentDetail> equipmentDetails;
  final String createdAt;
  final bool isBookmarked;

  const DashboardExpertTip({
    required this.id,
    required this.title,
    this.contentType = 'guide',
    this.description = '',
    this.contentUrl = '',
    this.image,
    this.equipmentDetails = const [],
    this.createdAt = '',
    this.isBookmarked = false,
  });

  factory DashboardExpertTip.fromJson(Map<String, dynamic> json) {
    final eqJson = json['equipment_details'];
    return DashboardExpertTip(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? 'guide',
      description: json['description']?.toString() ?? '',
      contentUrl: json['content_url']?.toString() ?? '',
      image: json['image']?.toString(),
      equipmentDetails: eqJson is List
          ? eqJson
              .whereType<Map<String, dynamic>>()
              .map(DashboardEquipmentDetail.fromJson)
              .toList(growable: false)
          : const [],
      createdAt: json['created_at']?.toString() ?? '',
      isBookmarked: json['is_bookmarked'] == true,
    );
  }

  DashboardExpertTip copyWith({
    int? id,
    String? title,
    String? contentType,
    String? description,
    String? contentUrl,
    String? image,
    List<DashboardEquipmentDetail>? equipmentDetails,
    String? createdAt,
    bool? isBookmarked,
  }) {
    return DashboardExpertTip(
      id: id ?? this.id,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      description: description ?? this.description,
      contentUrl: contentUrl ?? this.contentUrl,
      image: image ?? this.image,
      equipmentDetails: equipmentDetails ?? this.equipmentDetails,
      createdAt: createdAt ?? this.createdAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class DashboardBrowseCategory {
  final String name;
  final List<DashboardWorkoutItem> workouts;

  const DashboardBrowseCategory({required this.name, required this.workouts});

  factory DashboardBrowseCategory.fromJson(Map<String, dynamic> json) {
    final workoutsJson = json['workouts'];
    return DashboardBrowseCategory(
      name: json['name']?.toString() ?? '',
      workouts: workoutsJson is List
          ? workoutsJson
              .whereType<Map<String, dynamic>>()
              .map(DashboardWorkoutItem.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}

class DashboardRecentActivity {
  final int id;
  final String title;
  final String time;
  final String date;
  final int sets;
  final int durationMinutes;
  final String icon;

  const DashboardRecentActivity({
    required this.id,
    required this.title,
    this.time = '',
    this.date = '',
    this.sets = 0,
    this.durationMinutes = 0,
    this.icon = 'upper',
  });

  factory DashboardRecentActivity.fromJson(
    Map<String, dynamic> json, [
    int index = 0,
  ]) {
    const fallbackIcons = ['upper', 'leg', 'pull'];
    final id =
        int.tryParse(
          json['id']?.toString() ?? json['session_id']?.toString() ?? '',
        ) ??
        0;
    final title =
        json['title']?.toString() ?? json['name']?.toString() ?? 'Workout';
    final sets =
        int.tryParse(
          json['sets']?.toString() ?? json['set_count']?.toString() ?? '',
        ) ??
        0;
    final duration =
        int.tryParse(
          json['duration_minutes']?.toString() ??
              json['duration']?.toString() ??
              '',
        ) ??
        0;
    final timeStr =
        json['time']?.toString() ??
        json['day_label']?.toString() ??
        (duration > 0 ? '$duration min' : '');
    final icon =
        json['icon']?.toString() ?? fallbackIcons[index % fallbackIcons.length];

    return DashboardRecentActivity(
      id: id,
      title: title,
      time: timeStr,
      date: json['date']?.toString() ?? '',
      sets: sets,
      durationMinutes: duration,
      icon: icon,
    );
  }
}

class DashboardResponse {
  final String username;
  final String name;
  final String initials;
  final String? profileImage;
  final String greeting;
  final int streakDays;
  final String streakDisplay;
  final int weeklyCompleted;
  final int weeklyGoal;
  final String thisWeekDisplay;
  final double caloriesBurned;
  final String caloriesBurnedDisplay;
  final List<String> tabs;
  final List<DashboardWorkoutItem> forYouPlans;
  final List<DashboardWorkoutItem> browsePlans;
  final List<DashboardExpertTip> expertTips;
  final List<DashboardWorkoutItem> trendingPlans;

  // Backward compatibility getters
  List<DashboardWorkoutItem> get forYou => forYouPlans;
  List<DashboardWorkoutItem> get warmUp => const [];
  List<DashboardWorkoutItem> get perfectForHome => const [];
  List<DashboardWorkoutItem> get trending => trendingPlans;
  List<DashboardBrowseCategory> get browse => const [];
  List<DashboardRecentActivity> get recentActivity => const [];

  const DashboardResponse({
    required this.username,
    this.name = '',
    this.initials = '',
    this.profileImage,
    required this.greeting,
    required this.streakDays,
    this.streakDisplay = '',
    required this.weeklyCompleted,
    required this.weeklyGoal,
    this.thisWeekDisplay = '',
    required this.caloriesBurned,
    this.caloriesBurnedDisplay = '',
    required this.tabs,
    required this.forYouPlans,
    required this.browsePlans,
    required this.expertTips,
    required this.trendingPlans,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final tabsJson = json['tabs'];
    final forYouJson = json['for_you_plans'] ?? json['for_you'];
    final browseJson = json['browse_plans'] ?? json['browse'];
    final expertTipsJson = json['expert_tips'];
    final trendingJson = json['trending_plans'] ?? json['trending'];

    List<DashboardWorkoutItem> parsePlanList(dynamic data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(DashboardWorkoutItem.fromJson)
            .toList(growable: false);
      }
      return const [];
    }

    return DashboardResponse(
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      initials: json['initials']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      greeting: json['greeting']?.toString() ?? '',
      streakDays: int.tryParse(json['streak_days']?.toString() ?? '') ?? 0,
      streakDisplay: json['streak_display']?.toString() ?? '',
      weeklyCompleted:
          int.tryParse(json['weekly_completed']?.toString() ?? '') ?? 0,
      weeklyGoal: int.tryParse(json['weekly_goal']?.toString() ?? '') ?? 0,
      thisWeekDisplay: json['this_week_display']?.toString() ?? '',
      caloriesBurned:
          double.tryParse(json['calories_burned']?.toString() ?? '') ?? 0.0,
      caloriesBurnedDisplay: json['calories_burned_display']?.toString() ?? '',
      tabs: tabsJson is List
          ? tabsJson.map((e) => e.toString()).toList(growable: false)
          : const ['For You', 'Browse', 'Expert Tips', 'Trending'],
      forYouPlans: parsePlanList(forYouJson),
      browsePlans: parsePlanList(browseJson),
      expertTips: expertTipsJson is List
          ? expertTipsJson
              .whereType<Map<String, dynamic>>()
              .map(DashboardExpertTip.fromJson)
              .toList(growable: false)
          : const [],
      trendingPlans: parsePlanList(trendingJson),
    );
  }
}
