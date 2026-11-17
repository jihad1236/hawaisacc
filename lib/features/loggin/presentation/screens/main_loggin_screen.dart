import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/loggin/controller/main_loggin_controller.dart';
import 'package:hawiisaac/features/loggin/model/cardio_log_item.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class MainLogginScreen extends StatelessWidget {
  const MainLogginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainLogginController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          onRefresh: () => controller.fetchCardioLogs(isRefresh: true),
          child: Obx(() {
            // Error State
            if (controller.errorMessage.value.isNotEmpty &&
                controller.cardioLogs.isEmpty &&
                !controller.isLoading.value) {
              return _buildErrorState(context, controller, isDark);
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _buildTopBar(context, controller, isDark),
                        SizedBox(height: 16.h),
                        if (!controller.isLoading.value &&
                            controller.cardioLogs.isNotEmpty)
                          _buildSummaryBanner(controller, isDark),
                        SizedBox(height: 16.h),
                        _buildSectionHeader(context, controller, isDark),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    bottom: 130.h,
                  ),
                  sliver: _buildContent(controller, isDark),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────
  Widget _buildTopBar(
    BuildContext context,
    MainLogginController controller,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF111111);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Logs',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Your cardio & running history',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Start Workout Button
            InkWell(
              onTap: () => Get.toNamed(AppRoute.loggingScreen),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 18.sp,
                      color: const Color(0xFF111111),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Log',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Summary Banner ─────────────────────────────────────────────────
  Widget _buildSummaryBanner(MainLogginController controller, bool isDark) {
    final cardBg = isDark ? const Color(0xFF141414) : const Color(0xFFF5F9FA);
    final borderColor =
        isDark ? const Color(0xFF222222) : const Color(0xFFE0EAEB);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Total Sessions',
            value: '${controller.totalWorkouts}',
            icon: Icons.fitness_center_rounded,
            isDark: isDark,
          ),
          Container(
            height: 36.h,
            width: 1,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFDCDCDC),
          ),
          _buildStatItem(
            label: 'Total Time',
            value: '${controller.totalMinutes} min',
            icon: Icons.timer_outlined,
            isDark: isDark,
          ),
          Container(
            height: 36.h,
            width: 1,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFDCDCDC),
          ),
          _buildStatItem(
            label: 'Total Distance',
            value: '${controller.totalDistanceKm.toStringAsFixed(1)} km',
            icon: Icons.place_outlined,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: AppColors.primaryColor,
            ),
            SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark ? const Color(0xFF888888) : const Color(0xFF777777),
          ),
        ),
      ],
    );
  }

  // ── Section Header ─────────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context,
    MainLogginController controller,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Sessions',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        if (controller.isRefreshing.value)
          SizedBox(
            width: 14.r,
            height: 14.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          )
        else
          Text(
            '${controller.cardioLogs.length} logged',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? const Color(0xFF777777) : const Color(0xFF888888),
            ),
          ),
      ],
    );
  }

  // ── Content Sliver ─────────────────────────────────────────────────
  Widget _buildContent(MainLogginController controller, bool isDark) {
    if (controller.isLoading.value) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildSkeletonCard(isDark),
          childCount: 4,
        ),
      );
    }

    if (controller.cardioLogs.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(controller, isDark),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = controller.cardioLogs[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildCardioLogCard(item, isDark),
          );
        },
        childCount: controller.cardioLogs.length,
      ),
    );
  }

  // ── Cardio Log Card ────────────────────────────────────────────────
  Widget _buildCardioLogCard(CardioLogItem item, bool isDark) {
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111111);
    final metricBg = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF7F8F9);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_run_rounded,
                    color: AppColors.primaryColor,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12.sp,
                          color: isDark
                              ? const Color(0xFF888888)
                              : const Color(0xFF777777),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          item.formattedDate,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? const Color(0xFF888888)
                                : const Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF222222)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '#${item.workout}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFAAAAAA)
                        : const Color(0xFF555555),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Metrics Grid (4 chips)
          Row(
            children: [
              Expanded(
                child: _buildMetricPill(
                  icon: Icons.timer_outlined,
                  label: 'Time',
                  value: item.timeLabel,
                  bg: metricBg,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMetricPill(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: item.distanceLabel,
                  bg: metricBg,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMetricPill(
                  icon: Icons.speed_rounded,
                  label: 'Speed',
                  value: item.speedLabel,
                  bg: metricBg,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMetricPill(
                  icon: Icons.trending_up_rounded,
                  label: 'Incline',
                  value: item.inclineLabel,
                  bg: metricBg,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color bg,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: isDark ? const Color(0xFF777777) : const Color(0xFF888888),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Skeleton Loader ────────────────────────────────────────────────
  Widget _buildSkeletonCard(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ShimmerBox(width: 40.r, height: 40.r, radius: 12.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 130.w, height: 16.h, radius: 4.r),
                      SizedBox(height: 6.h),
                      ShimmerBox(width: 80.w, height: 12.h, radius: 4.r),
                    ],
                  ),
                ),
                ShimmerBox(width: 36.w, height: 20.h, radius: 8.r),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 3 ? 0 : 8.w),
                    child: ShimmerBox(
                      height: 52.h,
                      radius: 10.r,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────
  Widget _buildEmptyState(MainLogginController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_run_outlined,
              size: 36.sp,
              color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Cardio Logs Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start your first running or cardio session to track your distance, speed, and time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? const Color(0xFF888888) : const Color(0xFF777777),
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoute.loggingScreen),
            icon: const Icon(Icons.add_rounded, color: Color(0xFF111111)),
            label: const Text(
              'Start Workout',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────
  Widget _buildErrorState(
    BuildContext context,
    MainLogginController controller,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: Colors.redAccent,
            ),
            SizedBox(height: 12.h),
            Text(
              'Failed to Load Logs',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? const Color(0xFF888888) : const Color(0xFF777777),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => controller.fetchCardioLogs(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
