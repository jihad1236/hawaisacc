import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/progress/controller/progress_controller.dart';
import 'package:hawiisaac/features/progress/model/progress_analytics_models.dart';
import 'package:hawiisaac/features/progress/presentation/widgets/progress_share_dialog.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProgressController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      appBar: _buildAppBar(context, controller, isDark),
      body: Obx(
        () => controller.isLoading.value
            ? _loadingSkeleton(context)
            : RefreshIndicator(
                onRefresh: controller.refreshProgress,
                color: AppColors.primaryColor,
                backgroundColor: Theme.of(context).cardColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 132.h),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        _filterTabs(context, controller),
                        SizedBox(height: 20.h),
                        _volumeCard(context, controller),
                        SizedBox(height: 16.h),
                        _chartCard(context, controller),
                        SizedBox(height: 16.h),
                        _statsGrid(context, controller),
                        SizedBox(height: 24.h),
                        _muscleGroupsSection(context, controller),
                        SizedBox(height: 24.h),
                        _dailyBreakdownSection(context, controller),
                        SizedBox(height: 24.h),
                        _recentSessionsSection(context, controller),
                        SizedBox(height: 28.h),
                        _personalBestSection(context, controller),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ─── Fixed Top AppBar (Figma Node 25:7227) ─────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ProgressController controller,
    bool isDark,
  ) {
    final titleColor = isDark ? Colors.white : const Color(0xFF111111);
    final subTextColor = isDark
        ? const Color(0xFFA0A0A0)
        : const Color(0xFF848484);
    final borderColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFEAEAEA);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    // final shareBgColor = isDark
    //     ? const Color(0xFF1E1E1E)
    //     : const Color(0xFFF5F5F5);

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 64.h,
      automaticallyImplyLeading: false,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Progress',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: titleColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2.h),
          Obx(
            () => Text(
              controller.dateRange.value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: subTextColor,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => ProgressShareDialog.show(context, controller),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share_outlined,
                        size: 15.sp,
                        color: titleColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: borderColor, height: 1.0),
      ),
    );
  }

  Widget _loadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 10.w),
                child: ShimmerBox(width: 54.w, height: 34.h, radius: 22),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ShimmerBox(width: double.infinity, height: 130.h, radius: 16),
          SizedBox(height: 16.h),
          ShimmerBox(width: double.infinity, height: 220.h, radius: 16),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 100.h, radius: 14)),
              SizedBox(width: 12.w),
              Expanded(child: ShimmerBox(height: 100.h, radius: 14)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 100.h, radius: 14)),
              SizedBox(width: 12.w),
              Expanded(child: ShimmerBox(height: 100.h, radius: 14)),
            ],
          ),
          SizedBox(height: 28.h),
          const ShimmerBox(width: 120, height: 20, radius: 8),
          SizedBox(height: 14.h),
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ShimmerBox(
                width: double.infinity,
                height: 76.h,
                radius: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Tabs ──────────────────────────────────────────────────

  Widget _filterTabs(BuildContext context, ProgressController controller) {
    return Obx(
      () => Row(
        children: controller.filterTabs.asMap().entries.map((entry) {
          final isSelected = entry.key == controller.selectedFilterIndex.value;
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: GestureDetector(
              onTap: () => controller.onFilterSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.blackColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Volume Card ──────────────────────────────────────────────────

  Widget _volumeCard(BuildContext context, ProgressController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Volume Lifted',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(
                () => Text(
                  controller.totalVolume.value,
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Obx(
                  () => Text(
                    controller.volumeUnit.value,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final isDown = controller.volumeTrendDirection.value == 'down';
            final trendColor = isDown ? Colors.red : AppColors.primaryColor;
            final trendIcon = isDown
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded;

            return Row(
              children: [
                Icon(trendIcon, size: 14.sp, color: trendColor),
                SizedBox(width: 4.w),
                Text(
                  controller.volumeSubtitle.value
                      .replaceAll('↑ ', '')
                      .replaceAll('↓ ', ''),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
                if (controller.volumeDeltaDisplay.value.isNotEmpty) ...[
                  SizedBox(width: 6.w),
                  Text(
                    '(${controller.volumeDeltaDisplay.value})',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: trendColor,
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Chart Card ───────────────────────────────────────────────────

  Widget _chartCard(BuildContext context, ProgressController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Volume Lifted',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 140.h,
            child: Obx(() {
              final points = controller.chartPoints.toList();
              if (points.isEmpty) {
                return Center(
                  child: Text(
                    'No workout volume for this period',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              }

              return CustomPaint(
                size: Size(double.infinity, 140.h),
                painter: _LineChartPainter(
                  points: points,
                  lineColor: AppColors.primaryColor,
                  fillColor: AppColors.primaryColor.withValues(alpha: 0.15),
                  dotColor: AppColors.primaryColor,
                  dotBorderColor: Theme.of(context).cardColor,
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  controller.chartStartLabel.value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Obx(
                () => Text(
                  controller.chartEndLabel.value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Grid (2x2) ─────────────────────────────────────────────

  Widget _statsGrid(BuildContext context, ProgressController controller) {
    return Obx(() {
      final cards = controller.statCards;
      if (cards.length < 4) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard(context, data: cards[0])),
              SizedBox(width: 12.w),
              Expanded(child: _statCard(context, data: cards[1])),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _statCard(context, data: cards[2])),
              SizedBox(width: 12.w),
              Expanded(child: _statCard(context, data: cards[3])),
            ],
          ),
        ],
      );
    });
  }

  // ─── Stat Card ────────────────────────────────────────────────────

  Widget _statCard(BuildContext context, {required Map<String, String> data}) {
    final trend = data['trendDirection'] ?? 'stable';
    final changeColor = trend == 'up'
        ? AppColors.primaryColor
        : trend == 'down'
        ? Colors.red
        : Colors.grey.shade500;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['label']!,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data['value']!,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data['change']!,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Muscle Groups Trained Section (Section 4) ────────────────────
  Widget _muscleGroupsSection(
    BuildContext context,
    ProgressController controller,
  ) {
    return Obx(() {
      final muscles = controller.muscleGroupsTrained;
      if (muscles.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Muscle Groups Trained',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: muscles.map((muscle) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  muscle,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  // ─── Daily Breakdown Section (Section 4) ──────────────────────────
  Widget _dailyBreakdownSection(
    BuildContext context,
    ProgressController controller,
  ) {
    return Obx(() {
      final breakdown = controller.dailyBreakdown;
      if (breakdown.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Breakdown',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              separatorBuilder: (ctx, i) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
              ),
              itemBuilder: (context, index) {
                final day = breakdown[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.dayName.isNotEmpty ? day.dayName : day.date,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            day.date,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            day.workoutsCount > 0
                                ? '${day.volumeKg.toStringAsFixed(0)} kg'
                                : 'Rest',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: day.workoutsCount > 0
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            day.workoutsCount > 0
                                ? '${day.workoutsCount} workout • ${day.sets} sets'
                                : 'No workouts',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  // ─── Recent Completed Sessions (Section 4) ────────────────────────
  Widget _recentSessionsSection(
    BuildContext context,
    ProgressController controller,
  ) {
    return Obx(() {
      final sessions = controller.summarySessions;
      if (sessions.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed Sessions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              separatorBuilder: (ctx, i) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
              ),
              itemBuilder: (context, index) {
                final s = sessions[index];
                final durationMin = (s.durationSeconds / 60).round();

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.primaryColor,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title.isNotEmpty ? s.title : 'Workout Session',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              s.workoutDay.isNotEmpty
                                  ? '${s.workoutDay} • ${s.totalSets} sets'
                                  : '${s.totalSets} sets',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            s.totalVolumeDisplay.isNotEmpty
                                ? s.totalVolumeDisplay
                                : '${s.totalVolume.toStringAsFixed(0)} kg',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${durationMin}m • ${s.caloriesBurned} cal',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  // ─── Personal Best Section ────────────────────────────────────────

  Widget _personalBestSection(
    BuildContext context,
    ProgressController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Best',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 14.h),
        Obx(() {
          final prs = controller.personalRecords;
          if (prs.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'No personal records yet. Log workouts to record PRs!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              children: prs.asMap().entries.map((entry) {
                return _personalBestTile(
                  context,
                  pb: entry.value,
                  showDivider: entry.key < prs.length - 1,
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  // ─── Personal Best Tile ───────────────────────────────────────────

  IconData _resolveIcon(String icon) {
    final lower = icon.toLowerCase();
    if (lower.contains('bench')) {
      return Icons.fitness_center_rounded;
    } else if (lower.contains('squat')) {
      return Icons.directions_run_rounded;
    } else if (lower.contains('deadlift')) {
      return Icons.sports_gymnastics_rounded;
    }
    return Icons.fitness_center_rounded;
  }

  Widget _personalBestTile(
    BuildContext context, {
    required PersonalRecordItem pb,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _resolveIcon(pb.icon),
                  size: 22.sp,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(width: 12.w),
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pb.title.isNotEmpty ? pb.title : pb.exerciseName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      pb.dateDisplay.isNotEmpty
                          ? pb.dateDisplay
                          : (pb.equipment.isNotEmpty
                                ? '${pb.achievedDate} · ${pb.equipment}'
                                : pb.achievedDate),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              // Value & change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pb.weightDisplay.isNotEmpty
                        ? pb.weightDisplay
                        : '${pb.weightKg.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  if (pb.deltaDisplay.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      pb.deltaDisplay,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
            indent: 14.w,
            endIndent: 14.w,
          ),
      ],
    );
  }
}

// ─── Line Chart Painter ───────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;
  final Color dotBorderColor;

  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.dotBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = dotBorderColor
      ..style = PaintingStyle.fill;

    // Convert normalized points to canvas coordinates with top & bottom padding
    const verticalPadding = 12.0;
    final usableHeight = size.height - verticalPadding * 2;

    List<Offset> offsets = points.map((p) {
      return Offset(
        p.x * size.width,
        verticalPadding + (1 - p.y) * usableHeight,
      );
    }).toList();

    // Build smooth cubic bezier path
    final linePath = Path();
    final fillPath = Path();

    linePath.moveTo(offsets[0].dx, offsets[0].dy);
    fillPath.moveTo(offsets[0].dx, size.height);
    fillPath.lineTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final curr = offsets[i];
      final next = offsets[i + 1];
      final cp1 = Offset((curr.dx + next.dx) / 2, curr.dy);
      final cp2 = Offset((curr.dx + next.dx) / 2, next.dy);

      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }

    fillPath.lineTo(offsets.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    for (final offset in offsets) {
      canvas.drawCircle(offset, 5, dotBorderPaint);
      canvas.drawCircle(offset, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    if (oldDelegate.points.length != points.length ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.dotBorderColor != dotBorderColor) {
      return true;
    }

    for (var i = 0; i < points.length; i++) {
      final oldPoint = oldDelegate.points[i];
      final point = points[i];
      if (oldPoint.x != point.x || oldPoint.y != point.y) {
        return true;
      }
    }

    return false;
  }
}
