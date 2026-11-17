import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hawiisaac/features/loggin/controller/logging_controller.dart';

class BottomNavigationController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    if (_currentIndex.value != index) {
      _currentIndex.value = index;
    }
    // Auto-refresh active session when user taps the Log tab (index 2)
    if (index == 2 && Get.isRegistered<LoggingController>()) {
      Get.find<LoggingController>().loadActiveSession(showLoading: false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('BottomNavigationController initialized');
  }

  @override
  void onClose() {
    super.onClose();
    debugPrint('BottomNavigationController disposed');
  }
}
