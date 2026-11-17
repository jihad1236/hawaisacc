import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/home/model/browse_workout_item.dart';
import 'package:hawiisaac/features/home/services/browse_workouts_api_service.dart';

class BrowseWorkoutFilter {
  const BrowseWorkoutFilter({required this.label, required this.value});

  final String label;
  final String value;
}

class BrowseWorkoutsController extends GetxController {
  final BrowseWorkoutsApiService _apiService = BrowseWorkoutsApiService();

  final filters = const [
    BrowseWorkoutFilter(label: 'All', value: 'all'),
    BrowseWorkoutFilter(label: 'Upper Body', value: 'upper_body'),
    BrowseWorkoutFilter(label: 'Lower Body', value: 'lower_body'),
    BrowseWorkoutFilter(label: 'Core', value: 'core'),
  ];

  final RxList<BrowseWorkoutItem> workouts = <BrowseWorkoutItem>[].obs;
  final RxInt selectedFilterIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  int _requestId = 0;

  BrowseWorkoutFilter get selectedFilter => filters[selectedFilterIndex.value];

  @override
  void onInit() {
    super.onInit();
    fetchWorkouts();
  }

  Future<void> selectFilter(int index) async {
    if (index == selectedFilterIndex.value) return;
    selectedFilterIndex.value = index;
    await fetchWorkouts();
  }

  Future<void> refreshWorkouts() => fetchWorkouts();

  Future<void> fetchWorkouts() async {
    final requestId = ++_requestId;
    isLoading.value = true;
    errorMessage.value = '';
    workouts.clear();

    try {
      final result = await _apiService.getWorkouts(
        region: selectedFilter.value,
      );
      if (requestId != _requestId) return;
      workouts.assignAll(result);
    } catch (error) {
      if (requestId != _requestId) return;
      debugPrint('[BrowseWorkoutsController] Error: $error');
      errorMessage.value =
          'Unable to load workouts. Please check your connection and try again.';
    } finally {
      if (requestId == _requestId) {
        isLoading.value = false;
      }
    }
  }
}
