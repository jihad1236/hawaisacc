import 'package:hawiisaac/features/scan/model/equipment_reference.dart';

class RecommendedExercise {
  const RecommendedExercise({
    required this.id,
    required this.title,
    required this.name,
    required this.description,
    this.image,
    this.level = '',
    this.durationMinutes = 0,
  });

  final int id;
  final String title;
  final String name;
  final String description;
  final String? image;
  final String level;
  final int durationMinutes;

  factory RecommendedExercise.fromJson(Map<String, dynamic> json) {
    var rawImage = json['image']?.toString().trim();
    if (rawImage != null && rawImage.startsWith('http://')) {
      rawImage = rawImage.replaceFirst('http://', 'https://');
    }

    return RecommendedExercise(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString().trim() ??
          json['name']?.toString().trim() ??
          '',
      name: json['name']?.toString().trim() ??
          json['title']?.toString().trim() ??
          '',
      description: json['description']?.toString().trim() ?? '',
      image: rawImage,
      level: json['level']?.toString().trim() ?? '',
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'name': name,
      'description': description,
      if (image != null) 'image': image,
      'level': level,
      'duration_minutes': durationMinutes,
    };
  }
}

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    this.categoryId = 0,
    this.categoryName = '',
    required this.category,
    required this.name,
    this.title = '',
    required this.description,
    required this.image,
    this.linkedExercises = 0,
    this.recommendedExercises = const <RecommendedExercise>[],
    this.totalScans = 0,
    this.matchAccuracy = '0.00',
    required this.createdAt,
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final EquipmentReference category;
  final String name;
  final String title;
  final String description;
  final String image;
  final int linkedExercises;
  final List<RecommendedExercise> recommendedExercises;
  final int totalScans;
  final String matchAccuracy;
  final DateTime? createdAt;

  String get displayName => title.isNotEmpty ? title : name;

  String get effectiveCategoryName {
    if (categoryName.isNotEmpty) return categoryName;
    if (category.name.isNotEmpty) return category.name;
    return 'Equipment';
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    final rawTitle = json['title']?.toString().trim() ?? '';
    final rawName = json['name']?.toString().trim() ?? '';
    final finalName = rawTitle.isNotEmpty ? rawTitle : rawName;
    final catName = json['category_name']?.toString().trim() ?? '';

    int catId = 0;
    EquipmentReference catRef;
    if (json['category'] is Map<String, dynamic>) {
      catRef = EquipmentReference.fromJson(
        json['category'] as Map<String, dynamic>,
      );
      catId = catRef.id;
    } else if (json['category'] is num) {
      catId = (json['category'] as num).toInt();
      catRef = EquipmentReference(id: catId, name: catName);
    } else {
      catId = int.tryParse(json['category']?.toString() ?? '') ?? 0;
      catRef = EquipmentReference(id: catId, name: catName);
    }

    if (catName.isNotEmpty && catRef.name.isEmpty) {
      catRef = EquipmentReference(id: catId, name: catName);
    }

    var rawImage = json['image']?.toString().trim() ?? '';
    if (rawImage.startsWith('http://')) {
      rawImage = rawImage.replaceFirst('http://', 'https://');
    }

    final rawExercises = json['recommended_exercises'];
    final recExercises = rawExercises is List
        ? rawExercises
            .whereType<Map>()
            .map(
              (item) => RecommendedExercise.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList(growable: false)
        : const <RecommendedExercise>[];

    return EquipmentItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      categoryId: catId,
      categoryName: catName,
      category: catRef,
      name: finalName,
      title: finalName,
      description: json['description']?.toString() ?? '',
      image: rawImage,
      linkedExercises:
          int.tryParse(json['linked_exercises']?.toString() ?? '') ?? 0,
      recommendedExercises: recExercises,
      totalScans: int.tryParse(json['total_scans']?.toString() ?? '') ?? 0,
      matchAccuracy: json['match_accuracy']?.toString() ?? '0.00',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  EquipmentItem copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    EquipmentReference? category,
    String? name,
    String? title,
    String? description,
    String? image,
    int? linkedExercises,
    List<RecommendedExercise>? recommendedExercises,
    int? totalScans,
    String? matchAccuracy,
    DateTime? createdAt,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      category: category ?? this.category,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      linkedExercises: linkedExercises ?? this.linkedExercises,
      recommendedExercises:
          recommendedExercises ?? this.recommendedExercises,
      totalScans: totalScans ?? this.totalScans,
      matchAccuracy: matchAccuracy ?? this.matchAccuracy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category': categoryId > 0 ? categoryId : category.id,
      'category_name': categoryName,
      'title': title,
      'name': name,
      'description': description,
      'image': image,
      'linked_exercises': linkedExercises,
      'recommended_exercises':
          recommendedExercises.map((e) => e.toJson()).toList(),
      'total_scans': totalScans,
      'match_accuracy': matchAccuracy,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
