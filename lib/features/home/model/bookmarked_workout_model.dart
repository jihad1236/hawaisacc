import 'package:hawiisaac/features/home/model/dashboard_model.dart';

class BookmarkedWorkoutItem {
  final int id;
  final String title;
  final String? image;
  final String? video;
  final String description;
  final int durationMinutes;
  final String durationDisplay;
  final String level;
  final String levelDisplay;
  final String flag;
  final String? categoryName;
  final bool isBookmarked;
  final List<String> equipmentNames;
  final List<String> tags;
  final String? sets;
  final String? reps;
  final String? rest;

  const BookmarkedWorkoutItem({
    required this.id,
    required this.title,
    this.image,
    this.video,
    this.description = '',
    this.durationMinutes = 0,
    this.durationDisplay = '',
    this.level = 'all',
    this.levelDisplay = '',
    this.flag = 'gym',
    this.categoryName,
    this.isBookmarked = true,
    this.equipmentNames = const [],
    this.tags = const [],
    this.sets,
    this.reps,
    this.rest,
  });

  factory BookmarkedWorkoutItem.fromJson(Map<String, dynamic> json) {
    final rawEquip = json['equipment_names'];
    final equipments = <String>[];
    if (rawEquip is List) {
      for (final e in rawEquip) {
        if (e != null && e.toString().trim().isNotEmpty) {
          equipments.add(e.toString().trim());
        }
      }
    }

    final rawTags = json['tags'];
    final parsedTags = <String>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t != null && t.toString().trim().isNotEmpty) {
          parsedTags.add(t.toString().trim());
        }
      }
    }

    final duration = json['duration_minutes'] is num
        ? (json['duration_minutes'] as num).toInt()
        : (int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0);

    final title = (json['title'] ?? json['name'])?.toString() ?? '';
    final level = (json['level'] ?? json['difficulty'])?.toString() ?? 'all';

    return BookmarkedWorkoutItem(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      title: title,
      image: json['image']?.toString(),
      video: json['video']?.toString(),
      description: json['description']?.toString() ?? '',
      durationMinutes: duration,
      durationDisplay: json['duration_display']?.toString() ??
          (duration > 0 ? '$duration min' : ''),
      level: level,
      levelDisplay: json['level_display']?.toString() ??
          (level.isNotEmpty ? level.toUpperCase() : 'ALL'),
      flag: (json['flag'] ?? json['exercise_type'])?.toString() ?? 'gym',
      categoryName: json['category_name']?.toString(),
      isBookmarked: json['is_bookmarked'] != false,
      equipmentNames: equipments,
      tags: parsedTags,
      sets: json['sets']?.toString(),
      reps: json['reps']?.toString(),
      rest: json['rest']?.toString(),
    );
  }

  String get metaDisplay {
    final parts = <String>[];
    if (durationDisplay.isNotEmpty) {
      parts.add(durationDisplay);
    } else if (durationMinutes > 0) {
      parts.add('$durationMinutes min');
    }

    if (levelDisplay.isNotEmpty) {
      parts.add(levelDisplay);
    } else if (level.isNotEmpty) {
      parts.add(level.toUpperCase());
    }

    if (equipmentNames.isNotEmpty) {
      parts.add(equipmentNames.first);
    } else if (categoryName != null && categoryName!.isNotEmpty) {
      parts.add(categoryName!);
    }

    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'video': video,
      'description': description,
      'duration_minutes': durationMinutes,
      'duration_display': durationDisplay,
      'level': level,
      'level_display': levelDisplay,
      'flag': flag,
      'category_name': categoryName,
      'is_bookmarked': isBookmarked,
      'equipment_names': equipmentNames,
      'tags': tags,
      'sets': sets,
      'reps': reps,
      'rest': rest,
    };
  }

  DashboardWorkoutItem toDashboardWorkoutItem() {
    return DashboardWorkoutItem(
      id: id,
      title: title,
      description: description,
      image: image,
      totalTimeSeconds: durationMinutes * 60,
      durationMinutes: durationMinutes,
      durationDisplay: durationDisplay,
      level: level,
      levelDisplay: levelDisplay,
      categoryName: categoryName,
      isBookmarked: isBookmarked,
    );
  }
}
