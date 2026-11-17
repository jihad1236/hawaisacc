import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_secondary_button.dart';
import 'package:hawiisaac/features/scan/controller/matched_equipment_controller.dart';
import 'package:video_player/video_player.dart';

class MatchedEquipmentView extends StatelessWidget {
  const MatchedEquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MatchedEquipmentController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton(context);
        }

        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          _buildEquipmentHero(context, controller),
                          SizedBox(height: 24.h),
                          _buildSectionTitle(
                            context,
                            controller.sectionTitle.value,
                          ),
                          SizedBox(height: 16.h),
                          _buildExerciseList(context, controller),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                  _buildContinueButton(context, controller),
                ],
              ),
            ),
            if (controller.showMismatchPrompt.value)
              _buildMismatchPrompt(context, controller),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Top AppBar
  // ─────────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.blackColor;
    final borderColor = isDark
        ? Theme.of(context).dividerColor
        : const Color(0xFFEAEAEA);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: titleColor, size: 22.r),
        onPressed: controller.onBackTapped,
      ),
      centerTitle: true,
      title: Obx(
        () => Text(
          controller.appBarTitle.value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(color: borderColor, height: 1.h),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Equipment Hero (Image + Centered Name)
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEquipmentHero(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.blackColor;
    final imageUrl = controller.equipmentImageUrl.value;
    final equipmentName = controller.selectedEquipmentName.value.isNotEmpty
        ? controller.selectedEquipmentName.value
        : 'Equipment';

    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 220.h,
            width: double.infinity,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildHeroPlaceholder(context),
                  )
                : _buildHeroPlaceholder(context),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            equipmentName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: titleColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.fitness_center_rounded,
        size: 72.r,
        color: AppColors.primaryColor,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Section Title
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.blackColor;

    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: titleColor,
        height: 1.2,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Recommended Exercise List
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildExerciseList(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    if (controller.exercises.isEmpty) {
      return _emptyState(
        context,
        'No recommended exercises found for this equipment.',
      );
    }

    return Column(
      children: List.generate(
        controller.exercises.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _buildExerciseCard(context, controller, index),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    MatchedEquipmentController controller,
    int index,
  ) {
    final exercise = controller.exercises[index];
    final isSelected = controller.selectedIndex.value == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.blackColor;

    final unselectedCardBg = isDark
        ? Theme.of(context).cardColor
        : const Color(0xFFF5F5F5);
    final selectedCardBg = isDark
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.white;

    final imageUrl = (exercise['imageUrl'] ??
            exercise['image'] ??
            exercise['banner'])
        ?.toString()
        .trim() ??
        '';
    final videoUrl = (exercise['video'] ?? exercise['videoUrl'])
        ?.toString()
        .trim() ??
        '';

    return GestureDetector(
      onTap: () => controller.onExerciseSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedCardBg : unselectedCardBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 1.5.w,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exercise['title']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    exercise['description']?.toString() ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF848484),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _buildExerciseMedia(
              videoUrl: videoUrl,
              imageUrl: imageUrl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseMedia({
    required String videoUrl,
    required String imageUrl,
  }) {
    return _ExerciseThumbnailMedia(
      videoUrl: videoUrl,
      imageUrl: imageUrl,
    );
  }


  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Continue Button
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildContinueButton(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final btnTextColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      child: GestureDetector(
        onTap: controller.onContinueTapped,
        child: Container(
          height: 52.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: btnBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: Text(
            controller.buttonText.value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: btnTextColor,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Mismatch Prompt Modal
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildMismatchPrompt(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.30),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF171717) : Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.sentiment_dissatisfied_outlined,
                            size: 20.r,
                            color: AppColors.blackColor,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Not the right match?',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.dismissMismatchPrompt,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.close,
                            size: 22.r,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        'No problem. You can select the correct equipment manually or scan again for a better result.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.5,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomSecondaryButton(
                            text: 'Select manually',
                            onTap: controller.onChooseManuallyTapped,
                            height: 48.h,
                            borderRadius: 14,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: controller.onScanAgainTapped,
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Scan again',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202020) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.white70 : Colors.grey.shade600,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Loading Skeleton
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ShimmerBox(width: 220.w, height: 200.h, radius: 12),
            ),
            SizedBox(height: 16.h),
            Center(
              child: ShimmerBox(width: 160.w, height: 28.h, radius: 8),
            ),
            SizedBox(height: 24.h),
            ShimmerBox(width: 200.w, height: 22.h, radius: 8),
            SizedBox(height: 16.h),
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 100.h,
                  radius: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exercise Thumbnail Media (Auto-looping Video -> Image -> Equipment Icon)
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseThumbnailMedia extends StatefulWidget {
  final String videoUrl;
  final String imageUrl;

  const _ExerciseThumbnailMedia({
    required this.videoUrl,
    required this.imageUrl,
  });

  @override
  State<_ExerciseThumbnailMedia> createState() => _ExerciseThumbnailMediaState();
}

class _ExerciseThumbnailMediaState extends State<_ExerciseThumbnailMedia> {
  VideoPlayerController? _videoController;
  bool _hasVideoError = false;
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant _ExerciseThumbnailMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeVideo();
      _hasVideoError = false;
      _initVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    _loadToken++;
    final controller = _videoController;
    _videoController = null;
    controller?.dispose();
  }

  Future<void> _initVideo() async {
    final rawUrl = widget.videoUrl.trim();
    if (rawUrl.isEmpty) return;

    final videoUrl = rawUrl.startsWith('http://')
        ? rawUrl.replaceFirst('http://', 'https://')
        : rawUrl;
    final currentToken = ++_loadToken;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _videoController = controller;
      await controller.initialize();
      if (!mounted || currentToken != _loadToken) {
        controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();
      controller.addListener(() {
        if (!mounted) return;
        if (controller.value.isInitialized &&
            !controller.value.isPlaying &&
            !controller.value.hasError &&
            controller.value.duration > Duration.zero) {
          controller.play();
        }
      });
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted && currentToken == _loadToken) {
        setState(() {
          _videoController = null;
          _hasVideoError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVideoReady =
        _videoController != null &&
        _videoController!.value.isInitialized &&
        !_hasVideoError;

    return Container(
      width: 101.w,
      height: 86.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: isVideoReady
            ? _buildVideoView()
            : _buildImageOrIcon(context),
      ),
    );
  }

  Widget _buildVideoView() {
    return IgnorePointer(
      child: SizedBox(
        width: 101.w,
        height: 86.h,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _videoController!.value.size.width > 0
                ? _videoController!.value.size.width
                : 101,
            height: _videoController!.value.size.height > 0
                ? _videoController!.value.size.height
                : 86,
            child: VideoPlayer(_videoController!),
          ),
        ),
      ),
    );
  }

  Widget _buildImageOrIcon(BuildContext context) {
    final rawUrl = widget.imageUrl.trim();
    if (rawUrl.isNotEmpty) {
      final imageUrl = rawUrl.startsWith('http://')
          ? rawUrl.replaceFirst('http://', 'https://')
          : rawUrl;
      return Image.network(
        imageUrl,
        width: 101.w,
        height: 86.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildEquipmentIcon(),
      );
    }
    return _buildEquipmentIcon();
  }

  Widget _buildEquipmentIcon() {
    return Center(
      child: Icon(
        Icons.fitness_center_rounded,
        size: 36.r,
        color: AppColors.primaryColor,
      ),
    );
  }
}
