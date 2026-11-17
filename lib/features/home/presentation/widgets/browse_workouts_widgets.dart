import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/browse_workouts_controller.dart';
import 'package:hawiisaac/features/home/model/browse_workout_item.dart';

class BrowseWorkoutsIntro extends StatelessWidget {
  const BrowseWorkoutsIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find your next workout',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111111),
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Choose a body part and train with purpose.',
            style: TextStyle(
              color: isDark ? const Color(0xFF9DA9BC) : const Color(0xFF727B8A),
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class BrowseWorkoutsFilterBar extends StatelessWidget {
  const BrowseWorkoutsFilterBar({super.key, required this.controller});

  final BrowseWorkoutsController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 42.h,
      child: Obx(() {
        // Read the observable in this builder scope. Reading it only from
        // ListView's itemBuilder makes GetX report an improper Obx usage.
        final selectedIndex = controller.selectedFilterIndex.value;

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          scrollDirection: Axis.horizontal,
          itemCount: controller.filters.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final filter = controller.filters[index];
            final isSelected = selectedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark
                          ? const Color(0xFF1A2230)
                          : const Color(0xFFF4F5F7)),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : (isDark
                            ? const Color(0xFF2B384D)
                            : const Color(0xFFE4E7EC)),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(22.r),
                onTap: () => controller.selectFilter(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Center(
                    child: Text(
                      filter.label,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF062126)
                            : (isDark ? Colors.white : const Color(0xFF5F6877)),
                        fontSize: 12.5.sp,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class BrowseWorkoutsList extends StatelessWidget {
  const BrowseWorkoutsList({
    super.key,
    required this.controller,
    required this.onWorkoutTap,
  });

  final BrowseWorkoutsController controller;
  final ValueChanged<BrowseWorkoutItem> onWorkoutTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.workouts.isEmpty) {
        return const BrowseWorkoutsSkeletonList();
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.workouts.isEmpty) {
        return _BrowseWorkoutsMessage(
          icon: Icons.wifi_off_rounded,
          title: 'Unable to load workouts',
          message: controller.errorMessage.value,
          actionLabel: 'Try again',
          onAction: controller.refreshWorkouts,
        );
      }

      if (controller.workouts.isEmpty) {
        return const _BrowseWorkoutsMessage(
          icon: Icons.fitness_center_rounded,
          title: 'No workouts found',
          message: 'Try another body part to explore more exercises.',
        );
      }

      return RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: controller.refreshWorkouts,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 120.h),
          itemCount: controller.workouts.length,
          separatorBuilder: (_, _) => SizedBox(height: 11.h),
          itemBuilder: (context, index) {
            final workout = controller.workouts[index];
            return BrowseWorkoutCard(
              workout: workout,
              onTap: () => onWorkoutTap(workout),
            );
          },
        ),
      );
    });
  }
}

class BrowseWorkoutCard extends StatelessWidget {
  const BrowseWorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
  });

  final BrowseWorkoutItem workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF171D28) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF17202A);
    final secondaryColor = isDark
        ? const Color(0xFF9DA9BC)
        : const Color(0xFF778190);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? const Color(0xFF29364A) : const Color(0xFFE8EBF0),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              _WorkoutThumbnail(workout: workout, isDark: isDark),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      workout.metaDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (workout.targetMuscles.isNotEmpty) ...[
                      SizedBox(height: 7.h),
                      Text(
                        workout.targetMuscles.take(2).join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.sp,
                color: isDark
                    ? const Color(0xFF73819A)
                    : const Color(0xFF9AA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutThumbnail extends StatelessWidget {
  const _WorkoutThumbnail({required this.workout, required this.isDark});

  final BrowseWorkoutItem workout;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final image = workout.image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: SizedBox(
        width: 76.w,
        height: 76.w,
        child: image == null || image.isEmpty
            ? _placeholder
            : CachedNetworkImage(
                imageUrl: _httpsUrl(image),
                fit: BoxFit.cover,
                placeholder: (_, _) => AppShimmer(child: _placeholder),
                errorWidget: (_, _, _) => _placeholder,
              ),
      ),
    );
  }

  Widget get _placeholder => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? const [Color(0xFF203A52), Color(0xFF152431)]
            : const [Color(0xFFE7F8F8), Color(0xFFD7EAF0)],
      ),
    ),
    child: Icon(
      Icons.fitness_center_rounded,
      color: isDark
          ? Colors.white.withValues(alpha: 0.6)
          : const Color(0xFF3B7F88),
      size: 30.sp,
    ),
  );

  String _httpsUrl(String url) =>
      url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url;
}

class BrowseWorkoutsSkeletonList extends StatelessWidget {
  const BrowseWorkoutsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
      itemCount: 6,
      separatorBuilder: (_, _) => SizedBox(height: 11.h),
      itemBuilder: (_, _) => AppShimmer(
        child: Container(
          height: 98.h,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF202938)
                : const Color(0xFFE7EBF0),
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}

class _BrowseWorkoutsMessage extends StatelessWidget {
  const _BrowseWorkoutsMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(32.w, 70.h, 32.w, 20.h),
      children: [
        Center(
          child: Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34.sp, color: AppColors.primaryColor),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? const Color(0xFF9DA9BC) : const Color(0xFF737B88),
            fontSize: 13.sp,
            height: 1.45,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: 18.h),
          Center(
            child: OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(actionLabel!),
            ),
          ),
        ],
      ],
    );
  }
}
