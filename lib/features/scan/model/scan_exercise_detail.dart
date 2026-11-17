class ScanExerciseStep {
  const ScanExerciseStep({
    required this.id,
    required this.order,
    required this.description,
  });

  final int id;
  final int order;
  final String description;

  factory ScanExerciseStep.fromJson(Map<String, dynamic> json) {
    return ScanExerciseStep(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      description: json['description']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'description': description,
      };
}

class ScanExerciseDetail {
  const ScanExerciseDetail({
    required this.id,
    required this.title,
    required this.name,
    this.image,
    this.video,
    required this.description,
    this.tags = const <String>[],
    this.primaryMuscle = '',
    this.secondaryMuscles = const <String>[],
    this.difficulty = '',
    this.exerciseType = '',
    this.sets = '',
    this.reps = '',
    this.rest = '',
    this.level = '',
    this.flag = '',
    this.durationMinutes = 0,
    this.steps = const <ScanExerciseStep>[],
    this.instructions = const <String>[],
    this.equipmentTitle = '',
    this.equipmentImage = '',
    this.isBookmarked = false,
  });

  final int id;
  final String title;
  final String name;
  final String? image;
  final String? video;
  final String description;
  final List<String> tags;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String difficulty;
  final String exerciseType;
  final String sets;
  final String reps;
  final String rest;
  final String level;
  final String flag;
  final int durationMinutes;
  final List<ScanExerciseStep> steps;
  final List<String> instructions;
  final String equipmentTitle;
  final String equipmentImage;
  final bool isBookmarked;

  String get displayName => title.isNotEmpty ? title : name;

  List<String> get displayTags {
    if (tags.isNotEmpty) return tags;
    final list = <String>[];
    if (primaryMuscle.isNotEmpty) list.add(primaryMuscle);
    list.addAll(secondaryMuscles);
    return list;
  }

  List<String> get displaySteps {
    if (steps.isNotEmpty) {
      return steps.map((s) => s.description).toList(growable: false);
    }
    if (instructions.isNotEmpty) return instructions;
    if (description.isNotEmpty) return [description];
    return const <String>[];
  }

  factory ScanExerciseDetail.fromJson(Map<String, dynamic> json) {
    String? rawImage = json['image']?.toString().trim();
    if (rawImage != null && rawImage.startsWith('http://')) {
      rawImage = rawImage.replaceFirst('http://', 'https://');
    }

    String? rawVideo = json['video']?.toString().trim();
    if (rawVideo != null && rawVideo.startsWith('http://')) {
      rawVideo = rawVideo.replaceFirst('http://', 'https://');
    }

    final rawTags = json['tags'];
    final tagsList = rawTags is List
        ? rawTags.map((e) => e?.toString().trim() ?? '').where((s) => s.isNotEmpty).toList()
        : const <String>[];

    String primary = '';
    final secondary = <String>[];
    final muscles = json['muscles'];
    if (muscles is Map) {
      primary = muscles['primary']?.toString().trim() ?? '';
      final sec = muscles['secondary'];
      if (sec is List) {
        secondary.addAll(
          sec.map((e) => e?.toString().trim() ?? '').where((s) => s.isNotEmpty),
        );
      }
    }

    final rawSteps = json['steps'];
    final stepList = rawSteps is List
        ? rawSteps
            .whereType<Map>()
            .map(
              (item) => ScanExerciseStep.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList(growable: false)
        : const <ScanExerciseStep>[];

    final rawInst = json['instructions'];
    final instList = rawInst is List
        ? rawInst.map((e) => e?.toString().trim() ?? '').where((s) => s.isNotEmpty).toList()
        : const <String>[];

    String eqTitle = '';
    String eqImage = '';
    final eqDetails = json['equipment_details'];
    if (eqDetails is List && eqDetails.isNotEmpty && eqDetails.first is Map) {
      final firstEq = eqDetails.first as Map;
      eqTitle = firstEq['title']?.toString() ?? firstEq['name']?.toString() ?? '';
      eqImage = firstEq['image']?.toString() ?? '';
      if (eqImage.startsWith('http://')) {
        eqImage = eqImage.replaceFirst('http://', 'https://');
      }
    }

    final rec = json['recommendation'];
    String setsVal = json['sets']?.toString().trim() ?? '';
    String repsVal = json['reps']?.toString().trim() ?? '';
    String restVal = json['rest']?.toString().trim() ?? '';

    if (rec is Map) {
      if (setsVal.isEmpty && rec['sets'] != null) {
        setsVal = rec['sets'].toString();
      }
      if (repsVal.isEmpty && rec['reps'] != null) {
        repsVal = rec['reps'].toString();
      }
      if (restVal.isEmpty && rec['rest_seconds'] != null) {
        restVal = '${rec['rest_seconds']}s';
      }
    }

    return ScanExerciseDetail(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString().trim() ?? json['name']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ?? json['title']?.toString().trim() ?? '',
      image: rawImage,
      video: rawVideo,
      description: json['description']?.toString().trim() ?? '',
      tags: tagsList,
      primaryMuscle: primary,
      secondaryMuscles: secondary,
      difficulty: json['difficulty']?.toString().trim() ?? '',
      exerciseType: json['exercise_type']?.toString().trim() ?? '',
      sets: setsVal,
      reps: repsVal,
      rest: restVal,
      level: json['level']?.toString().trim() ?? '',
      flag: json['flag']?.toString().trim() ?? '',
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      steps: stepList,
      instructions: instList,
      equipmentTitle: eqTitle,
      equipmentImage: eqImage,
      isBookmarked: json['is_bookmarked'] == true,
    );
  }
}
