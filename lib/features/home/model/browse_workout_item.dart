class BrowseWorkoutItem {
  const BrowseWorkoutItem({
    required this.id,
    required this.title,
    this.description = '',
    this.image,
    this.bodyPart = '',
    this.bodyRegion = '',
    this.durationMinutes = 0,
    this.calories = 0,
    this.difficulty = '',
    this.targetMuscles = const [],
    this.equipmentNames = const [],
    this.sets = '',
    this.reps = '',
    this.rest = '',
    this.isBookmarked = false,
  });

  final int id;
  final String title;
  final String description;
  final String? image;
  final String bodyPart;
  final String bodyRegion;
  final int durationMinutes;
  final int calories;
  final String difficulty;
  final List<String> targetMuscles;
  final List<String> equipmentNames;
  final String sets;
  final String reps;
  final String rest;
  final bool isBookmarked;

  factory BrowseWorkoutItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final categoryMap = category is Map
        ? Map<String, dynamic>.from(category)
        : const <String, dynamic>{};

    return BrowseWorkoutItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: (json['title'] ?? json['name'])?.toString() ?? 'Workout',
      description:
          (json['short_description'] ?? json['description'])?.toString() ?? '',
      image: _firstString([
        json['image'],
        json['thumbnail_url'],
        json['image_url'],
      ]),
      bodyPart:
          (json['body_part'] ?? json['category_name'] ?? categoryMap['name'])
              ?.toString() ??
          '',
      bodyRegion:
          (json['body_region'] ?? categoryMap['body_region'])?.toString() ?? '',
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      calories:
          int.tryParse(
            (json['calories'] ?? json['estimated_calories'])?.toString() ?? '',
          ) ??
          0,
      difficulty: (json['difficulty'] ?? json['level'])?.toString() ?? '',
      targetMuscles: _stringList(
        json['target_muscles'] ?? json['muscles'] ?? json['tags'],
      ),
      equipmentNames: _stringList(
        json['equipment_names'] ?? json['equipment_requirements'],
      ),
      sets: json['sets']?.toString() ?? '',
      reps: json['reps']?.toString() ?? '',
      rest: json['rest']?.toString() ?? '',
      isBookmarked: json['is_bookmarked'] == true,
    );
  }

  String get metaDisplay {
    final parts = <String>[];
    if (bodyPart.isNotEmpty) parts.add(bodyPart);
    if (durationMinutes > 0) parts.add('$durationMinutes min');
    if (difficulty.isNotEmpty) {
      parts.add(_capitalize(difficulty));
    }
    return parts.isEmpty ? 'Workout' : parts.join(' • ');
  }

  Map<String, dynamic> get detailArguments => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': image ?? '',
    'workoutType': 'strength',
    'sets': sets,
    'reps': reps,
    'rest': rest,
    'duration': durationMinutes > 0 ? '$durationMinutes min' : '',
    'muscleGroups': targetMuscles,
  };

  static String? _firstString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') return text;
    }
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is Map) {
            return (item['name'] ?? item['title'])?.toString() ?? '';
          }
          return item?.toString() ?? '';
        })
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty && item != 'null')
        .toList(growable: false);
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
