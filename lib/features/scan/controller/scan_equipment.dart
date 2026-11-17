import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_secondary_button.dart';
import 'package:hawiisaac/features/bottom_navigation/controllers/bottom_navigation_controller.dart';
import 'package:hawiisaac/features/scan/model/scan_result.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanEquipmentController extends GetxController {
  final EquipmentApiService _equipmentApiService = EquipmentApiService();

  // ── Detection Modes ────────────────────────────────────────────
  final List<String> detectionModes = [
    'Auto detect',
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Bodyweight',
    'Cardio',
  ];

  final RxInt selectedModeIndex = 0.obs;

  // ── Scanner State ──────────────────────────────────────────────
  final RxBool isScanning = true.obs;
  final RxBool isProcessingScan = false.obs;
  final RxBool hasScanFeedback = false.obs;
  final RxBool isScanFeedbackError = false.obs;
  final RxString scanFeedbackTitle = ''.obs;
  final RxString scanFeedbackMessage = ''.obs;

  CameraController? cameraController;
  final RxBool isCameraInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        AppLoadingService.showError(
          'Permission Denied',
          'Camera permission is required',
        );
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        AppLoadingService.showError(
          'Camera Error',
          'No cameras available on this device',
        );
        return;
      }

      // Explicitly select the back camera
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      AppLoadingService.showError('Camera Error', 'Failed to initialize: $e');
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  void onModeSelected(int index) {
    selectedModeIndex.value = index;
  }

  void onChooseManually() {
    Get.toNamed(AppRoute.getEquipmentView());
  }

  void onBackTapped() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else if (Get.isRegistered<BottomNavigationController>()) {
      Get.find<BottomNavigationController>().changeTab(0);
    } else {
      Get.back();
    }
  }

  Future<void> onScanNow() async {
    if (isProcessingScan.value) return;
    if (!isCameraInitialized.value || cameraController == null) {
      AppLoadingService.showError(
        'Camera Not Ready',
        'Please wait for the camera to finish loading.',
      );
      return;
    }

    isProcessingScan.value = true;
    _clearScanFeedback();
    try {
      final image = await cameraController!.takePicture();
      if (selectedModeIndex.value == 0) {
        final result = await _equipmentApiService.scanEquipmentUpload(
          image.path,
        );
        _handleAutoDetectResult(result, image.path);
      } else {
        final equipmentName = detectionModes[selectedModeIndex.value];
        final result = await _equipmentApiService.verifyEquipment(
          equipmentName: equipmentName,
          imagePath: image.path,
        );
        _handleVerificationResult(result, image.path, equipmentName);
      }
    } on AuthException catch (error) {
      final message = _scanFailureMessage(error);
      _showScanFeedback(title: 'Scan failed', message: message, isError: true);
      AppLoadingService.showError('Scan Failed', message);
    } catch (_) {
      _showScanFeedback(
        title: 'Scan failed',
        message: 'Something went wrong while scanning. Please try again.',
        isError: true,
      );
      AppLoadingService.showError(
        'Scan Failed',
        'Something went wrong while scanning. Please try again.',
      );
    } finally {
      isProcessingScan.value = false;
    }
  }

  // Description text based on selected mode
  String get modeTitle {
    switch (selectedModeIndex.value) {
      case 1:
        return 'Point at a Barbell';
      case 2:
        return 'Point at a Dumbbell';
      case 3:
        return 'Point at a Machine';
      case 4:
        return 'Point at a Cable machine';
      case 5:
        return 'Point at Bodyweight area';
      case 6:
        return 'Point at Cardio equipment';
      default:
        return 'Point at any equipment';
    }
  }

  String get modeSubtitle {
    switch (selectedModeIndex.value) {
      case 1:
        return 'The scanner identifies barbells and loads barbell exercises automatically';
      case 2:
        return 'The scanner identifies dumbbells and loads dumbbell exercises automatically';
      case 3:
        return 'The scanner identifies gym machines and loads machine exercises automatically';
      case 4:
        return 'The scanner identifies cable machines and loads cable exercises automatically';
      case 5:
        return 'The scanner identifies bodyweight space and loads exercises automatically';
      case 6:
        return 'The scanner identifies cardio machines and loads cardio workouts automatically';
      default:
        return 'The scanner identifies gym equipment and loads exercise automatically';
    }
  }

  String get scanButtonText => 'Scan';

  String _scanFailureMessage(AuthException error) {
    final normalized = error.message.toLowerCase();
    if (error.statusCode == 502 ||
        normalized.contains('gemini_api_key') ||
        normalized.contains('not configured')) {
      return 'Scan service is not available right now. Please contact support or try again later.';
    }

    return error.message;
  }

  void _handleAutoDetectResult(EquipmentScanResult result, String imagePath) {
    if (!result.hasMatch) {
      _showNoMatchDialog(
        message: result.errorMessage.isNotEmpty
            ? result.errorMessage
            : 'Not the right match? Select manually or scan again.',
      );
      return;
    }

    Get.toNamed(
      AppRoute.getMatchedEquipmentScreen(),
      arguments: <String, dynamic>{
        'showMismatchPrompt': true,
        'equipmentId': result.primaryEquipmentId,
        'equipmentName': result.primaryEquipment,
        'equipment': result.equipment,
        'equipmentImageUrl': result.equipmentImage,
        'confidence': result.confidence,
        'matchText': result.primaryEquipment.trim().isNotEmpty
            ? 'Detected ${result.primaryEquipment}'
            : 'Equipment detected successfully',
        'recommendedWorkoutIds': result.recommendedWorkoutIds,
        'recommendedExercises': result.recommendedExercises,
        'detectedEquipment': result.equipmentDetected,
        'scanImagePath': imagePath,
      },
    );
  }

  void _handleVerificationResult(
    EquipmentVerificationResult result,
    String imagePath,
    String equipmentName,
  ) {
    if (!result.success || !result.isMatch) {
      _showNoMatchDialog(
        message: result.message.isNotEmpty
            ? result.message
            : 'The scanned image did not match $equipmentName. You can try scanning again or choose manually.',
      );
      return;
    }

    Get.toNamed(
      AppRoute.getMatchedEquipmentScreen(),
      arguments: <String, dynamic>{
        'showMismatchPrompt': true,
        'equipmentName': equipmentName,
        'matchText': result.message.isNotEmpty
            ? result.message
            : 'Yes, this is $equipmentName',
        'confidence': result.confidence,
        'scanImagePath': imagePath,
      },
    );
  }

  void _showNoMatchDialog({String? message}) {
    final context = Get.context;
    final isDark = context != null
        ? Theme.of(context).brightness == Brightness.dark
        : false;

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.14),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 32.sp,
                  color: isDark ? AppColors.primaryColor : const Color(0xFF01555E),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No Equipment Matched',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111111),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                (message != null && message.trim().isNotEmpty)
                    ? message
                    : 'Not the right match? Select manually or scan again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF757575),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              CustomPrimaryButton(
                text: 'Scan Again',
                onTap: () => Get.back(),
                height: 48.h,
                borderRadius: 12,
              ),
              SizedBox(height: 10.h),
              CustomSecondaryButton(
                text: 'Choose Manually',
                onTap: () {
                  Get.back();
                  onChooseManually();
                },
                height: 48.h,
                borderRadius: 12,
                backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _clearScanFeedback() {
    hasScanFeedback.value = false;
    isScanFeedbackError.value = false;
    scanFeedbackTitle.value = '';
    scanFeedbackMessage.value = '';
  }

  void _showScanFeedback({
    required String title,
    required String message,
    required bool isError,
  }) {
    scanFeedbackTitle.value = title;
    scanFeedbackMessage.value = message;
    isScanFeedbackError.value = isError;
    hasScanFeedback.value = true;
  }
}
