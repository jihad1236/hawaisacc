import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/loggin/model/cardio_log_item.dart';
import 'package:hawiisaac/features/loggin/services/loggin_api_service.dart';

class MainLogginController extends GetxController {
  MainLogginController({LogginApiService? apiService})
      : _apiService = apiService ?? LogginApiService();

  final LogginApiService _apiService;

  // ── States ─────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<CardioLogItem> cardioLogs = <CardioLogItem>[].obs;

  // Backward compatibility
  final RxString message = 'no exercice loog add exercize'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCardioLogs();
  }

  Future<void> fetchCardioLogs({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final logs = await _apiService.getCardioLogs();
      cardioLogs.assignAll(logs);

      if (logs.isEmpty) {
        message.value = 'No cardio workout logs found';
      } else {
        message.value = '${logs.length} cardio logs';
      }
    } on AuthException catch (e) {
      debugPrint('[MainLogginController] AuthException: ${e.message}');
      errorMessage.value = e.message;
    } catch (e, stack) {
      debugPrint('[MainLogginController] Unexpected error: $e\n$stack');
      errorMessage.value = 'Failed to load cardio logs. Please try again.';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ── Computed Stats ─────────────────────────────────────────────
  int get totalWorkouts => cardioLogs.length;

  int get totalMinutes => cardioLogs.fold<int>(
        0,
        (sum, item) => sum + item.timeMinutes,
      );

  double get totalDistanceKm => cardioLogs.fold<double>(
        0.0,
        (sum, item) => sum + (double.tryParse(item.distanceKm) ?? 0.0),
      );

  double get avgSpeedKmh {
    if (cardioLogs.isEmpty) return 0.0;
    final totalSpeed = cardioLogs.fold<double>(
      0.0,
      (sum, item) => sum + (double.tryParse(item.speedKmh) ?? 0.0),
    );
    return totalSpeed / cardioLogs.length;
  }
}
