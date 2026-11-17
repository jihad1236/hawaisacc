import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/scan/model/equipment_item.dart';
import 'package:hawiisaac/features/scan/model/workout_item.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class MatchedEquipmentController extends GetxController {
  MatchedEquipmentController();

  final EquipmentApiService _equipmentApiService = EquipmentApiService();

  final RxBool isLoading = true.obs;
  final RxBool showMismatchPrompt = false.obs;
  final RxInt selectedIndex = 0.obs;

  final RxString appBarTitle = 'Equipments'.obs;
  final RxString matchText = 'Equipment matched successfully'.obs;
  final RxString sectionTitle = 'Recommended exercise'.obs;
  final RxString buttonText = 'Continue'.obs;
  final RxString equipmentImageUrl = ''.obs;
  final RxString selectedEquipmentName = ''.obs;
  final RxString equipmentDescription = ''.obs;
  final RxString equipmentCategory = ''.obs;
  final RxDouble confidence = 0.0.obs;
  final RxInt selectedEquipmentId = 0.obs;

  final RxList<Map<String, dynamic>> exercises = <Map<String, dynamic>>[].obs;

  final List<int> _recommendedWorkoutIds = <int>[];
  final List<String> _detectedEquipment = <String>[];
  final List<Map<String, dynamic>> _recommendedExercisePayload =
      <Map<String, dynamic>>[];
  bool _hasEquipmentPayload = false;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    fetchMatchedData();
  }

  Future<void> fetchMatchedData() async {
    isLoading.value = true;

    try {
      EquipmentItem? equipment;
      if (selectedEquipmentId.value > 0) {
        try {
          equipment = await _equipmentApiService.getEquipmentById(
            selectedEquipmentId.value,
          );
        } catch (_) {
          // If direct fetch fails, fallback to loaded detail
        }
      }

      if (equipment == null && !_hasEquipmentPayload) {
        equipment = await _loadEquipmentDetail();
      }

      if (equipment != null) {
        _applyEquipmentDetail(equipment);
      }

      if (_recommendedExercisePayload.isNotEmpty) {
        exercises.assignAll(
          _recommendedExercisePayload.map(_scanExerciseToMap),
        );
      } else {
        final workouts = await _loadRecommendedExercises();
        exercises.assignAll(_recommendedWorkouts(workouts).map(_workoutToMap));
      }
      selectedIndex.value = exercises.isEmpty ? -1 : 0;
      _refreshMatchText();
    } on AuthException catch (error) {
      AppLoadingService.showError('Matched Equipment Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Matched Equipment Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onExerciseSelected(int index) {
    selectedIndex.value = index;
  }

  void onBackTapped() {
    Get.back();
  }

  void dismissMismatchPrompt() {
    showMismatchPrompt.value = false;
  }

  void onScanAgainTapped() {
    dismissMismatchPrompt();
    Get.back();
  }

  void onChooseManuallyTapped() {
    dismissMismatchPrompt();
    Get.offNamed(AppRoute.getEquipmentView());
  }

  void onContinueTapped() {
    if (selectedIndex.value < 0 || exercises.isEmpty) {
      AppLoadingService.showError(
        'Select Exercise',
        'Please select an exercise to continue.',
      );
      return;
    }

    Get.toNamed(
      AppRoute.exeesiceDetailScreen,
      arguments: exercises[selectedIndex.value],
    );
  }

  Future<EquipmentItem?> _loadEquipmentDetail() async {
    if (selectedEquipmentId.value > 0) {
      return _equipmentApiService.getEquipmentById(selectedEquipmentId.value);
    }

    final equipmentName = selectedEquipmentName.value.trim().toLowerCase();
    if (equipmentName.isEmpty) return null;

    final equipments = await _equipmentApiService.getEquipments(limit: 100);
    EquipmentItem? matched;

    for (final item in equipments) {
      if (item.name.trim().toLowerCase() == equipmentName) {
        matched = item;
        break;
      }
    }

    matched ??= equipments.cast<EquipmentItem?>().firstWhere(
      (item) =>
          item != null &&
          (item.name.trim().toLowerCase().contains(equipmentName) ||
              equipmentName.contains(item.name.trim().toLowerCase())),
      orElse: () => null,
    );

    if (matched == null) return null;

    selectedEquipmentId.value = matched.id;
    return _equipmentApiService.getEquipmentById(matched.id);
  }

  void _readArguments() {
    final arguments = Get.arguments;
    if (arguments is int) {
      selectedEquipmentId.value = arguments;
      return;
    }
    if (arguments is! Map<String, dynamic>) {
      if (selectedEquipmentId.value == 0 && Get.parameters['id'] != null) {
        selectedEquipmentId.value = int.tryParse(Get.parameters['id']!) ?? 0;
      }
      return;
    }

    showMismatchPrompt.value = arguments['showMismatchPrompt'] == true;

    final equipment = arguments['equipment'];
    if (equipment is Map) {
      _applyEquipmentMap(
        equipment.map((key, value) => MapEntry(key.toString(), value)),
      );
      _hasEquipmentPayload = true;
    }

    selectedEquipmentId.value =
        int.tryParse(arguments['equipmentId']?.toString() ?? '') ??
        selectedEquipmentId.value;

    final equipmentName = arguments['equipmentName']?.toString().trim() ?? '';
    if (equipmentName.isNotEmpty) {
      selectedEquipmentName.value = equipmentName;
    }

    final imageUrl = arguments['equipmentImageUrl']?.toString().trim() ?? '';
    if (imageUrl.isNotEmpty) {
      equipmentImageUrl.value = _normalizeUrl(imageUrl);
      _hasEquipmentPayload = true;
    }

    final matchMessage = arguments['matchText']?.toString().trim() ?? '';
    if (matchMessage.isNotEmpty) {
      matchText.value = matchMessage;
    }

    confidence.value =
        double.tryParse(arguments['confidence']?.toString() ?? '') ?? 0;

    final recommended = arguments['recommendedWorkoutIds'];
    if (recommended is List) {
      _recommendedWorkoutIds
        ..clear()
        ..addAll(
          recommended
              .map((item) => int.tryParse(item?.toString() ?? ''))
              .whereType<int>(),
        );
    }

    final recommendedExercises = arguments['recommendedExercises'];
    if (recommendedExercises is List) {
      _recommendedExercisePayload
        ..clear()
        ..addAll(
          recommendedExercises.whereType<Map>().map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
    }

    final detected = arguments['detectedEquipment'];
    if (detected is List) {
      _detectedEquipment
        ..clear()
        ..addAll(
          detected
              .map((item) => item?.toString().trim() ?? '')
              .where((item) => item.isNotEmpty),
        );
    }
  }

  void _applyEquipmentMap(Map<String, dynamic> equipment) {
    final id = int.tryParse(equipment['id']?.toString() ?? '');
    if (id != null && id > 0) {
      selectedEquipmentId.value = id;
    }

    final name = equipment['name']?.toString().trim().isNotEmpty == true
        ? equipment['name'].toString().trim()
        : equipment['title']?.toString().trim() ?? '';
    if (name.isNotEmpty) {
      selectedEquipmentName.value = name;
    }

    equipmentDescription.value =
        equipment['description']?.toString().trim() ?? '';
    equipmentCategory.value = equipment['category']?.toString().trim() ?? '';
    equipmentImageUrl.value = _normalizeUrl(
      equipment['image']?.toString().trim() ?? '',
    );
  }

  void _applyEquipmentDetail(EquipmentItem equipment) {
    selectedEquipmentId.value = equipment.id;
    final name = equipment.title.isNotEmpty ? equipment.title : equipment.name;
    selectedEquipmentName.value = name;
    equipmentDescription.value = equipment.description;
    equipmentCategory.value = equipment.effectiveCategoryName;
    equipmentImageUrl.value = _normalizeUrl(equipment.image);
    if (equipment.recommendedExercises.isNotEmpty) {
      _recommendedExercisePayload
        ..clear()
        ..addAll(
          equipment.recommendedExercises.map((e) => e.toJson()),
        );
    }
  }

  Future<List<WorkoutItem>> _loadRecommendedExercises() async {
    if (selectedEquipmentId.value > 0) {
      return _equipmentApiService.getWorkouts(
        equipmentId: selectedEquipmentId.value,
        limit: 20,
      );
    }

    return _equipmentApiService.getWorkouts(limit: 100);
  }

  List<WorkoutItem> _recommendedWorkouts(List<WorkoutItem> workouts) {
    if (_recommendedWorkoutIds.isNotEmpty) {
      final workoutsById = <int, WorkoutItem>{
        for (final workout in workouts) workout.id: workout,
      };
      final recommended = _recommendedWorkoutIds
          .map((id) => workoutsById[id])
          .whereType<WorkoutItem>()
          .toList(growable: false);
      if (recommended.isNotEmpty) return recommended;
    }

    final matchingWorkouts = _matchingWorkouts(workouts);
    if (matchingWorkouts.isNotEmpty) {
      return matchingWorkouts.take(6).toList(growable: false);
    }

    return const <WorkoutItem>[];
  }

  List<WorkoutItem> _matchingWorkouts(List<WorkoutItem> workouts) {
    final equipmentId = selectedEquipmentId.value;
    final equipmentName = selectedEquipmentName.value.trim().toLowerCase();

    return workouts
        .where((workout) {
          if (equipmentId > 0 && workout.equipment.id == equipmentId) {
            return true;
          }
          if (equipmentName.isEmpty) return false;

          final workoutEquipmentName = workout.equipment.name
              .trim()
              .toLowerCase();
          return workoutEquipmentName == equipmentName ||
              workoutEquipmentName.contains(equipmentName) ||
              equipmentName.contains(workoutEquipmentName);
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _workoutToMap(WorkoutItem workout) {
    return <String, dynamic>{
      'id': workout.id,
      'title': workout.name,
      'description': workout.description,
      'imageUrl': workout.banner,
      'category': workout.category.name,
      'equipment': workout.equipment.name,
      'workoutType': workout.workoutType,
      'metValue': workout.metValue,
      'muscleGroups': workout.muscleGroups
          .map((muscleGroup) => muscleGroup.name)
          .toList(growable: false),
      'tags': workout.tags,
      'sets': workout.sets,
      'reps': workout.reps,
      'rest': workout.rest,
      'time': workout.time,
      'duration': workout.duration,
      'distance': workout.distance,
      'speed': workout.speed,
      'incline': workout.incline,
      'uses': workout.uses,
      'video': workout.video,
    };
  }

  Map<String, dynamic> _scanExerciseToMap(Map<String, dynamic> exercise) {
    final durationMinutes = exercise['duration_minutes']?.toString() ?? '';
    final level = exercise['level']?.toString().trim() ?? '';

    return <String, dynamic>{
      'id': int.tryParse(exercise['id']?.toString() ?? '') ?? 0,
      'title': exercise['title']?.toString().trim().isNotEmpty == true
          ? exercise['title'].toString().trim()
          : exercise['name']?.toString().trim() ?? '',
      'description': exercise['description']?.toString().trim() ?? '',
      'imageUrl': _normalizeUrl(exercise['image']?.toString().trim() ?? ''),
      'category': level.isNotEmpty ? level : 'Exercise',
      'equipment': selectedEquipmentName.value,
      'workoutType': level,
      'metValue': 0.0,
      'muscleGroups': const <String>[],
      'tags': level,
      'sets': '',
      'reps': '',
      'rest': '',
      'time': '',
      'duration': durationMinutes.isNotEmpty ? '$durationMinutes min' : '',
      'distance': 0.0,
      'speed': 0.0,
      'incline': 0.0,
      'uses': const <String>[],
      'video': _normalizeUrl(exercise['video']?.toString().trim() ?? ''),
    };
  }

  void _refreshMatchText() {
    if (matchText.value.trim().isNotEmpty &&
        matchText.value != 'Equipment matched successfully') {
      return;
    }

    if (selectedEquipmentName.value.trim().isNotEmpty) {
      matchText.value =
          'Your scanned image matches ${selectedEquipmentName.value}.';
      return;
    }

    if (_detectedEquipment.isNotEmpty) {
      matchText.value =
          'Detected ${_detectedEquipment.join(', ')} from your scan.';
    }
  }

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return trimmed.replaceFirst('http://', 'https://');
    }

    return trimmed;
  }
}
