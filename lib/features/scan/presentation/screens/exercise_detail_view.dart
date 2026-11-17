import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/core/utils/logging/logger.dart';
import 'package:hawiisaac/features/scan/controller/exercise_detail_controller.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────
class ExerciseDetailView extends StatelessWidget {
  const ExerciseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExerciseDetailController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildDetailLoadingSkeleton(context);
        }

        if (controller.hasError.value) {
          return _buildErrorState(context, controller);
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroMedia(controller),
                      SizedBox(height: 16.h),
                      _exerciseInfo(context, controller),
                      if (controller.muscleTags.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _muscleTags(context, controller),
                      ],
                      if (controller.sets.isNotEmpty ||
                          controller.reps.isNotEmpty ||
                          controller.rest.isNotEmpty ||
                          controller.duration.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _statCards(context, controller),
                      ],
                      if (controller.steps.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        _howToSection(context, controller),
                      ],
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              _addToWorkoutButton(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailLoadingSkeleton(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ShimmerBox(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 0,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 220.w, height: 32.h, radius: 8),
                        SizedBox(height: 10.h),
                        ShimmerBox(width: 140.w, height: 16.h, radius: 6),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            ShimmerBox(width: 70.w, height: 28.h, radius: 20),
                            SizedBox(width: 8.w),
                            ShimmerBox(width: 70.w, height: 28.h, radius: 20),
                            SizedBox(width: 8.w),
                            ShimmerBox(width: 85.w, height: 28.h, radius: 20),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 64.h,
                                radius: 8,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 64.h,
                                radius: 8,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 64.h,
                                radius: 8,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        ShimmerBox(width: 120.w, height: 22.h, radius: 6),
                        SizedBox(height: 12.h),
                        ShimmerBox(
                          width: double.infinity,
                          height: 110.h,
                          radius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: ShimmerBox(width: double.infinity, height: 52.h, radius: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ExerciseDetailController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.blackColor;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: titleColor,
                    size: 20.r,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 32.r,
                        color: const Color(0xFF848484),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load exercise',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      controller.errorMessage.value.isNotEmpty
                          ? controller.errorMessage.value
                          : 'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF848484),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: controller.retry,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 18.r,
                              color: AppColors.blackColor,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Try Again',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────────────────────────────────────────

  /// Top hero illustration / video with back button
  Widget _heroMedia(ExerciseDetailController controller) {
    return Stack(
      children: [
        ExerciseHeroMedia(
          imageUrl: controller.imageUrl,
          videoUrl: controller.videoUrl,
        ),
        Positioned(
          top: 12.h,
          left: 12.w,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18.r,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Exercise name + category (Figma: 32px Bold + 14px subtitle)
  Widget _exerciseInfo(
    BuildContext context,
    ExerciseDetailController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.blackColor;

    final subtitleParts = <String>[];
    if (controller.category.isNotEmpty) subtitleParts.add(controller.category);
    if (controller.muscleGroup.isNotEmpty) {
      subtitleParts.add(controller.muscleGroup);
    }
    final subtitle = subtitleParts.join(' . ');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.exerciseName,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: titleColor,
              height: 1.2,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF848484),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Horizontally scrollable muscle chips (#DDFCFF bg, #01555E text)
  Widget _muscleTags(
    BuildContext context,
    ExerciseDetailController controller,
  ) {
    if (controller.muscleTags.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark
        ? const Color(0xFF01555E).withValues(alpha: 0.25)
        : const Color(0xFFDDFCFF);
    final chipTextColor = isDark
        ? const Color(0xFFDDFCFF)
        : const Color(0xFF01555E);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: controller.muscleTags.keys.map((tag) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(80.r),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: chipTextColor,
                  height: 1.4,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Sets / Reps / Rest cards (Figma: rounded-8px, #F5F5F5 bg, 1px border #EAEAEA)
  Widget _statCards(BuildContext context, ExerciseDetailController controller) {
    final stats = <Widget>[];

    if (controller.sets.isNotEmpty) {
      stats.add(_statCard(context, value: controller.sets, label: 'SETS'));
    }
    if (controller.reps.isNotEmpty) {
      stats.add(_statCard(context, value: controller.reps, label: 'REPS'));
    }
    if (controller.rest.isNotEmpty) {
      stats.add(_statCard(context, value: controller.rest, label: 'REST(s)'));
    }
    if (stats.isEmpty && controller.duration.isNotEmpty) {
      stats.add(
        _statCard(context, value: controller.duration, label: 'DURATION'),
      );
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            stats[i],
          ],
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? Theme.of(context).cardColor
        : const Color(0xFFF5F5F5);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEAEAEA);
    final titleColor = isDark ? Colors.white : AppColors.blackColor;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor, width: 1.w),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: titleColor,
                height: 1.3,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF848484),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "How to use" section (Figma: #F5F5F5 container, cyan #00E5FF circle with step number)
  Widget _howToSection(
    BuildContext context,
    ExerciseDetailController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? Theme.of(context).cardColor
        : const Color(0xFFF5F5F5);
    final titleColor = isDark ? Colors.white : AppColors.blackColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to use',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: titleColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: List.generate(controller.steps.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index != controller.steps.length - 1 ? 16.h : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cyan numbered circle (28x28)
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          controller.steps[index],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: titleColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Pinned "Add to workout" CTA button (Figma: #1A1A1A, 52px height, 12px radius)
  Widget _addToWorkoutButton(
    BuildContext context,
    ExerciseDetailController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final btnTextColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      child: GestureDetector(
        onTap: controller.addToWorkout,
        child: Container(
          height: 52.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: btnBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: Obx(
            () => controller.isStartingWorkout.value
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: CircularProgressIndicator(
                      color: btnTextColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Add to workout',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: btnTextColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class ExerciseHeroMedia extends StatefulWidget {
  const ExerciseHeroMedia({
    super.key,
    required this.imageUrl,
    required this.videoUrl,
  });

  final String imageUrl;
  final String videoUrl;

  @override
  State<ExerciseHeroMedia> createState() => _ExerciseHeroMediaState();
}

class _ExerciseHeroMediaState extends State<ExerciseHeroMedia> {
  VideoPlayerController? _videoController;
  bool _hasVideoError = false;
  int _loadToken = 0;

  bool get _shouldShowVideo =>
      widget.videoUrl.trim().isNotEmpty && !_hasVideoError;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant ExerciseHeroMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeVideoController();
      _hasVideoError = false;
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final rawUrl = widget.videoUrl.trim();
    if (rawUrl.isEmpty) return;
    final videoUrl = rawUrl.startsWith('http://')
        ? rawUrl.replaceFirst('http://', 'https://')
        : rawUrl;
    final loadToken = ++_loadToken;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _videoController = controller;
      await controller.initialize();
      if (!mounted || loadToken != _loadToken) {
        controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(1.0);
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
      if (mounted) setState(() {});
    } catch (error) {
      AppLoggerHelper.warning('Exercise video failed to load: $error');
      if (mounted && loadToken == _loadToken) {
        setState(() {
          _videoController = null;
          _hasVideoError = true;
        });
      }
    }
  }

  void _disposeVideoController() {
    _loadToken++;
    final controller = _videoController;
    _videoController = null;
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldShowVideo) {
      return _videoPlayer();
    }

    return _fallbackImage();
  }

  Widget _videoPlayer() {
    final isReady = _videoController?.value.isInitialized ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        child: ColoredBox(
          color: mediaBg,
          child: isReady
              ? _initializedVideoPlayer(_videoController!)
              : _buildVideoLoadingState(),
        ),
      ),
    );
  }

  Widget _buildVideoLoadingState() {
    final rawUrl = widget.imageUrl.trim();
    if (rawUrl.isNotEmpty) {
      final imageUrl = rawUrl.startsWith('http://')
          ? rawUrl.replaceFirst('http://', 'https://')
          : rawUrl;

      return Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.startsWith('http'))
            Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            )
          else
            Image.asset(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
          const ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            radius: 0,
          ),
        ],
      );
    }

    return const ShimmerBox(
      width: double.infinity,
      height: double.infinity,
      radius: 0,
    );
  }

  Widget _initializedVideoPlayer(VideoPlayerController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      color: mediaBg,
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: controller.value.size.width > 0
              ? controller.value.size.width
              : 16,
          height: controller.value.size.height > 0
              ? controller.value.size.height
              : 9,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackBg = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF9FAFB);
    final rawUrl = widget.imageUrl.trim();
    final imageUrl = rawUrl.startsWith('http://')
        ? rawUrl.replaceFirst('http://', 'https://')
        : rawUrl;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        child: Container(
          width: double.infinity,
          color: fallbackBg,
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const ShimmerBox(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 0,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildNoImagePlaceholder(),
                )
              : (imageUrl.isNotEmpty
                    ? Image.asset(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildNoImagePlaceholder(),
                      )
                    : _buildNoImagePlaceholder()),
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.fitness_center_rounded,
        size: 56.r,
        color: AppColors.primaryColor.withValues(alpha: 0.5),
      ),
    );
  }
}
