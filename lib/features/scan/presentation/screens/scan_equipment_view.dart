import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_secondary_button.dart';
import 'package:hawiisaac/features/scan/controller/scan_equipment.dart';

class ScanEquipmentView extends StatefulWidget {
  const ScanEquipmentView({super.key});

  @override
  State<ScanEquipmentView> createState() => _ScanEquipmentViewState();
}

class _ScanEquipmentViewState extends State<ScanEquipmentView>
    with SingleTickerProviderStateMixin {
  late final ScanEquipmentController controller;
  late final AnimationController _animController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ScanEquipmentController());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : AppColors.white,
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 132.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            _cameraCard(context),
            SizedBox(height: 28.h),
            _scanButton(),
            SizedBox(height: 12.h),
            _manualButton(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ─── Fixed Header (Figma Topbar: Node 1:3156) ─────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final contentColor = isDark ? AppColors.white : AppColors.blackColor;
    final bgColor = isDark ? null : AppColors.white;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: controller.onBackTapped,
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 20.sp,
          color: contentColor,
        ),
      ),
      title: Text(
        'Scan equipment',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: contentColor,
        ),
      ),
    );
  }

  // ─── Camera Card (Figma Frame 61: Node 1:3162) ─────────────────────

  Widget _cameraCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      height: 380.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          Obx(() {
            if (controller.isCameraInitialized.value &&
                controller.cameraController != null) {
              return FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width:
                      controller.cameraController!.value.previewSize?.height ??
                      1,
                  height:
                      controller.cameraController!.value.previewSize?.width ??
                      1,
                  child: CameraPreview(controller.cameraController!),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }),

          // Figma Frame 60 (Node 1:3163): 258w x 264h Corner Brackets & Scan Line
          Positioned(
            top: 46.h,
            left: 0,
            right: 0,
            child: Center(child: _scanFrame()),
          ),

          // Figma Text (Node 1:3172): "Hold steady - scanning"
          Positioned(
            bottom: 18.h,
            left: 16.w,
            right: 16.w,
            child: Obx(
              () => Center(
                child: Text(
                  controller.isProcessingScan.value
                      ? 'Analyzing equipment...'
                      : 'Hold steady - scanning',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),

          // Processing Overlay
          Obx(() {
            if (!controller.isProcessingScan.value) {
              return const SizedBox.shrink();
            }

            return Container(
              color: Colors.black.withValues(alpha: 0.55),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Scanning equipment...',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Scan Frame (Figma Frame 60: Node 1:3163: 258w x 264h) ────────

  Widget _scanFrame() {
    final frameWidth = 258.w;
    final frameHeight = 264.h;
    final bracketSize = 35.w;
    final lineWidth = 200.5.w;
    const strokeWidth = 3.0;

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: Stack(
        children: [
          // Top-Left Bracket (Figma Vector 2)
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: bracketSize,
              height: bracketSize,
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  isTop: true,
                  isLeft: true,
                  color: AppColors.primaryColor,
                  strokeWidth: strokeWidth,
                ),
              ),
            ),
          ),

          // Top-Right Bracket (Figma Vector 3)
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: bracketSize,
              height: bracketSize,
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  isTop: true,
                  isLeft: false,
                  color: AppColors.primaryColor,
                  strokeWidth: strokeWidth,
                ),
              ),
            ),
          ),

          // Bottom-Left Bracket (Figma Vector 4)
          Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: bracketSize,
              height: bracketSize,
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  isTop: false,
                  isLeft: true,
                  color: AppColors.primaryColor,
                  strokeWidth: strokeWidth,
                ),
              ),
            ),
          ),

          // Bottom-Right Bracket (Figma Vector 5)
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: bracketSize,
              height: bracketSize,
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  isTop: false,
                  isLeft: false,
                  color: AppColors.primaryColor,
                  strokeWidth: strokeWidth,
                ),
              ),
            ),
          ),

          // Animated Scanning Line (Figma Vector 6: 200.5px centered)
          _scanLine(frameHeight, lineWidth, (frameWidth - lineWidth) / 2),
        ],
      ),
    );
  }

  // ─── Animated Scan Line (Figma Vector 6) ───────────────────────────

  Widget _scanLine(double frameHeight, double lineWidth, double leftOffset) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Positioned(
        top: 10.h + (frameHeight - 20.h) * _animation.value,
        left: leftOffset,
        child: Container(
          width: lineWidth,
          height: 2.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primaryColor.withValues(alpha: 0.85),
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.85),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.7),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Action Buttons ───────────────────────────────────────────────

  Widget _scanButton() {
    return Obx(
      () => CustomPrimaryButton(
        text: 'Scan',
        onTap: controller.onScanNow,
        isLoading: controller.isProcessingScan.value,
        height: 52.h,
        borderRadius: 12,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
      ),
    );
  }

  Widget _manualButton() {
    return Obx(
      () => CustomSecondaryButton(
        text: 'Choose equipment manually',
        onTap: controller.isProcessingScan.value
            ? null
            : controller.onChooseManually,
        height: 52.h,
        borderRadius: 12,
        backgroundColor: const Color(0xFF1A1A1A),
        textColor: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
      ),
    );
  }
}

// ─── Corner Bracket Painter (Exact Figma Vectors 2, 3, 4, 5) ────────

class _CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;
  final double strokeWidth;

  const _CornerBracketPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final half = strokeWidth / 2;

    if (isTop && isLeft) {
      // Top-Left (Figma Vector 2: M 1.5, 36.5 V 1.5 H 36.5)
      path.moveTo(half, size.height);
      path.lineTo(half, half);
      path.lineTo(size.width, half);
    } else if (isTop && !isLeft) {
      // Top-Right (Figma Vector 3: Mirrored horizontally)
      path.moveTo(0, half);
      path.lineTo(size.width - half, half);
      path.lineTo(size.width - half, size.height);
    } else if (!isTop && isLeft) {
      // Bottom-Left (Figma Vector 4: Mirrored vertically)
      path.moveTo(half, 0);
      path.lineTo(half, size.height - half);
      path.lineTo(size.width, size.height - half);
    } else {
      // Bottom-Right (Figma Vector 5: Mirrored both)
      path.moveTo(0, size.height - half);
      path.lineTo(size.width - half, size.height - half);
      path.lineTo(size.width - half, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) =>
      oldDelegate.isTop != isTop ||
      oldDelegate.isLeft != isLeft ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
