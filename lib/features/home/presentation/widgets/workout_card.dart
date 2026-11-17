import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';

/// Reusable Workout Card matching Figma Node 1:2205 and HomeScreen
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.workout,
    required this.isDark,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
    this.width = 250,
    this.height = 280,
    this.isBookmarkLoading = false,
  });

  final DashboardWorkoutItem workout;
  final bool isDark;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final double? width;
  final double? height;
  final bool isBookmarkLoading;

  static String formatWorkoutMeta(DashboardWorkoutItem workout) {
    final durationStr = workout.durationDisplay.isNotEmpty
        ? workout.durationDisplay
        : (workout.durationMinutes > 0 ? '${workout.durationMinutes} min' : '');

    final rawLevel = workout.level.isNotEmpty
        ? workout.level
        : workout.levelDisplay;
    final levelStr = rawLevel.isNotEmpty
        ? rawLevel[0].toUpperCase() + rawLevel.substring(1)
        : '';

    if (durationStr.isNotEmpty && levelStr.isNotEmpty) {
      return '$durationStr, $levelStr';
    } else if (durationStr.isNotEmpty) {
      return durationStr;
    } else if (levelStr.isNotEmpty) {
      return levelStr;
    }
    return 'Workout';
  }

  static String formatImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return trimmed.replaceFirst('http://', 'https://');
    }
    return trimmed;
  }

  static Widget cardPlaceholder(DashboardWorkoutItem workout, bool isDark) {
    final gradientThemes = [
      [const Color(0xFF2C3E50), const Color(0xFF1A252F)],
      [const Color(0xFF1E3A8A), const Color(0xFF172554)],
      [const Color(0xFF14532D), const Color(0xFF052E16)],
      [const Color(0xFF581C87), const Color(0xFF3B0764)],
      [const Color(0xFF7C2D12), const Color(0xFF451A03)],
    ];
    final colorPair = gradientThemes[workout.id % gradientThemes.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colorPair,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          size: 48.sp,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = workout.image != null && workout.image!.trim().isNotEmpty;
    final cardWidth = width == double.infinity ? double.infinity : width?.w;
    final cardHeight = height?.h;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image or Themed Gradient Fallback
              if (hasImage)
                CachedNetworkImage(
                  imageUrl: formatImageUrl(workout.image!),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => AppShimmer(
                    child: Container(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      cardPlaceholder(workout, isDark),
                )
              else
                cardPlaceholder(workout, isDark),

              // 2. Gradient Overlay (Figma Node 1:2207)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),

              // 3. Bookmark Button at Top-Right (Figma Node 1:2208: 28px circle)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Material(
                  color: isBookmarked ? AppColors.primaryColor : Colors.white,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isBookmarkLoading ? null : onBookmarkTap,
                    child: SizedBox(
                      width: 28.w,
                      height: 28.w,
                      child: Center(
                        child: isBookmarkLoading
                            ? SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF111111),
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/icons/bookmark-01.svg',
                                width: 16.w,
                                height: 16.w,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF111111),
                                  BlendMode.srcIn,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Bottom Details: Title (20px SemiBold) & Meta (16px Regular) (Figma Node 1:2210)
              Positioned(
                bottom: 14.h,
                left: 12.w,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workout.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      formatWorkoutMeta(workout),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
