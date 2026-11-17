import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/scan/model/equipment_category.dart';
import 'package:hawiisaac/features/scan/model/equipment_item.dart';
import 'package:hawiisaac/features/scan/model/equipment_reference.dart';
import 'package:hawiisaac/features/scan/model/muscle_group.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class EquipmentController extends GetxController {
  final EquipmentApiService _equipmentApiService = EquipmentApiService();

  // ─── Text Editing Controllers ───────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isDetailLoading = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt selectedEquipmentIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  // ─── Screen Content ─────────────────────────────────────────────────────────
  final RxString appBarTitle = 'Equipment'.obs;
  final RxString searchHint = 'Search equipment'.obs;
  final RxString buttonText = 'Continue'.obs;

  // ─── Category Filters ────────────────────────────────────────────────────────
  final RxList<String> categories = <String>[].obs;

  // ─── Equipment List ──────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> allEquipments =
      <Map<String, dynamic>>[].obs;
  final RxList<EquipmentCategory> apiCategories = <EquipmentCategory>[].obs;
  final RxList<EquipmentItem> apiEquipments = <EquipmentItem>[].obs;
  final RxList<MuscleGroup> muscleGroups = <MuscleGroup>[].obs;

  // ─── Computed: Filtered Equipment ────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredEquipments {
    final query = searchQuery.value.trim().toLowerCase();
    final selectedCategory = categories.isNotEmpty
        ? categories[selectedCategoryIndex.value]
        : 'All';

    return allEquipments.where((eq) {
      final name = (eq['name']?.toString() ?? '').toLowerCase();
      final title = (eq['title']?.toString() ?? '').toLowerCase();
      final category = eq['category']?.toString() ?? '';

      final matchesSearch =
          query.isEmpty || name.contains(query) || title.contains(query);
      final matchesCategory = selectedCategory == 'All' ||
          category.toLowerCase() == selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchEquipments();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchEquipments() async {
    if (!StorageService.hasAccessToken) {
      isLoading.value = false;
      await StorageService.clearAuthSession();
      if (Get.currentRoute != AppRoute.getLoginScreen()) {
        Get.offAllNamed(AppRoute.getLoginScreen());
        AppLoadingService.showError(
          'Login Required',
          'Please log in to continue.',
        );
      }
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final responses = await Future.wait([
        _equipmentApiService
            .getCategories()
            .catchError((_) => <EquipmentCategory>[]),
        _equipmentApiService.getEquipments(),
      ]);

      final fetchedCategories = responses[0] as List<EquipmentCategory>;
      final fetchedEquipments = responses[1] as List<EquipmentItem>;

      apiCategories.assignAll(fetchedCategories);

      // Build category lookup map: id -> name
      final categoryMap = <int, String>{
        for (final cat in fetchedCategories) cat.id: cat.name,
      };

      // Resolve category names on equipments
      final resolvedEquipments = fetchedEquipments.map((eq) {
        final catName = eq.effectiveCategoryName.isNotEmpty &&
                eq.effectiveCategoryName != 'Equipment'
            ? eq.effectiveCategoryName
            : (categoryMap[eq.categoryId] ?? eq.category.name);
        if (catName.isNotEmpty &&
            (eq.category.name.isEmpty || eq.categoryName.isEmpty)) {
          return eq.copyWith(
            category: EquipmentReference(id: eq.categoryId, name: catName),
            categoryName: catName,
          );
        }
        return eq;
      }).toList();

      apiEquipments.assignAll(resolvedEquipments);

      // Extract unique categories present in the equipment list
      final presentCategoryNames = <String>[];
      for (final eq in resolvedEquipments) {
        final name = eq.effectiveCategoryName.trim();
        if (name.isNotEmpty &&
            name != 'Equipment' &&
            !presentCategoryNames.contains(name)) {
          presentCategoryNames.add(name);
        }
      }

      if (presentCategoryNames.isEmpty && fetchedCategories.isNotEmpty) {
        presentCategoryNames.addAll(fetchedCategories.map((c) => c.name));
      }

      categories.assignAll([
        'All',
        ...presentCategoryNames,
      ]);

      allEquipments.assignAll(resolvedEquipments.map(_equipmentToMap));

      selectedCategoryIndex.value = 0;
      selectedEquipmentIndex.value = allEquipments.isEmpty ? -1 : 0;
    } on AuthException catch (error) {
      if (error.statusCode == 401) {
        await StorageService.clearAuthSession();
        if (Get.currentRoute != AppRoute.getLoginScreen()) {
          Get.offAllNamed(AppRoute.getLoginScreen());
          AppLoadingService.showError(
            'Session Expired',
            'Your session has expired. Please log in to continue.',
          );
        }
        return;
      }
      if (allEquipments.isEmpty) {
        errorMessage.value = error.message;
        _showError(error.message);
      }
    } catch (_) {
      if (allEquipments.isEmpty) {
        errorMessage.value = 'Something went wrong. Please try again.';
        _showError(errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Methods ────────────────────────────────────────────────────────────────

  void onCategorySelected(int index) {
    selectedCategoryIndex.value = index;
    selectedEquipmentIndex.value = filteredEquipments.isEmpty ? -1 : 0;
  }

  void onEquipmentSelected(int index) {
    selectedEquipmentIndex.value = index;
  }

  void onBackTapped() {
    Get.back();
  }

  Future<void> onContinueTapped() async {
    if (selectedEquipmentIndex.value < 0 ||
        selectedEquipmentIndex.value >= filteredEquipments.length) {
      AppLoadingService.showError(
        'Select Equipment',
        'Please select an equipment to continue.',
      );
      return;
    }

    final selectedEquipment = filteredEquipments[selectedEquipmentIndex.value];
    final equipmentId = int.tryParse(selectedEquipment['id']?.toString() ?? '');
    final equipmentName = (selectedEquipment['title']?.toString().isNotEmpty == true
            ? selectedEquipment['title']?.toString()
            : selectedEquipment['name']?.toString())
        ?.trim() ?? '';
    final equipmentImageUrl =
        selectedEquipment['image']?.toString().trim() ?? '';
    final recommendedExercises = selectedEquipment['recommendedExercises'];

    Get.toNamed(
      AppRoute.getMatchedEquipmentScreen(),
      arguments: <String, dynamic>{
        'showMismatchPrompt': false,
        'equipment': selectedEquipment,
        if (equipmentId != null && equipmentId > 0) 'equipmentId': equipmentId,
        if (equipmentName.isNotEmpty) 'equipmentName': equipmentName,
        if (equipmentImageUrl.isNotEmpty)
          'equipmentImageUrl': equipmentImageUrl,
        'recommendedExercises': ?recommendedExercises,
        'matchText': equipmentName.isNotEmpty
            ? 'You selected $equipmentName manually.'
            : 'Equipment selected successfully',
      },
    );
  }

  Future<EquipmentItem?> fetchEquipmentDetail(int id) async {
    isDetailLoading.value = true;

    try {
      return await _equipmentApiService.getEquipmentById(id);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isDetailLoading.value = false;
    }

    return null;
  }

  Future<void> fetchCategoryDetail(int id) async {
    try {
      await _equipmentApiService.getCategoryById(id);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    }
  }

  Future<void> fetchMuscleGroupDetail(int id) async {
    try {
      await _equipmentApiService.getMuscleGroupById(id);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    }
  }

  Map<String, dynamic> _equipmentToMap(EquipmentItem equipment) {
    return <String, dynamic>{
      'id': equipment.id,
      'name': equipment.name,
      'title': equipment.title,
      'description': equipment.description,
      'category': equipment.effectiveCategoryName.isNotEmpty
          ? equipment.effectiveCategoryName
          : 'Equipment',
      'categoryId': equipment.categoryId,
      'categoryName': equipment.categoryName,
      'image': equipment.image,
      'linkedExercises': equipment.linkedExercises,
      'recommendedExercises': equipment.recommendedExercises
          .map((exercise) => exercise.toJson())
          .toList(growable: false),
      'totalScans': equipment.totalScans,
      'matchAccuracy': equipment.matchAccuracy,
      'exerciseCount': equipment.linkedExercises,
    };
  }

  void _showError(String message) {
    AppLoadingService.showError('Equipment Failed', message);
  }

  void onNavHomeTapped() {}
  void onNavScanTapped() {}
  void onNavAddTapped() {}
  void onNavStatsTapped() {}
}
