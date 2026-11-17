import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';

class HomeTodayProgress extends StatelessWidget {
  const HomeTodayProgress({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isTodayProgressLoading.value) {
        return const _TodayProgressSkeleton();
      }

      if (!controller.hasTodayProgress) {
        return const _TodayProgressEmptyState();
      }

      final progress = controller.todayProgress.value!;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final metrics = [
        _TodayMetric(
          value: progress.totalWorkouts.toString(),
          label: 'Workouts',
          icon: Icons.directions_run_outlined,
          color: const Color(0xFF6C5CE7),
          backgroundColor: const Color(0xFFECE9FF),
          darkBackgroundColor: const Color(0xFF28234A),
        ),
        _TodayMetric(
          value: _formatDuration(progress.avgDuration),
          label: 'Minutes',
          icon: Icons.timer_outlined,
          color: const Color(0xFF1683E8),
          backgroundColor: const Color(0xFFE5F2FF),
          darkBackgroundColor: const Color(0xFF173754),
        ),
        _TodayMetric(
          value: progress.totalSets.toString(),
          label: 'Sets',
          icon: Icons.layers_outlined,
          color: const Color(0xFF00A878),
          backgroundColor: const Color(0xFFE2F8F0),
          darkBackgroundColor: const Color(0xFF143E38),
        ),
      ];

      return AnimatedSize(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: _TodayProgressCard(metrics: metrics, isDark: isDark),
      );
    });
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0
        ? '${hours}h'
        : '${hours}h ${remainingMinutes}m';
  }
}

class _TodayProgressEmptyState extends StatelessWidget {
  const _TodayProgressEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B62E8), Color(0xFF3C8FEA)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF536FE5).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make today count',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Complete a workout to see your progress here.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: const Color(0xFFFFE58A),
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayProgressSkeleton extends StatelessWidget {
  const _TodayProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF171B28)
        : const Color(0xFFF3F6FB);
    final borderColor = isDark
        ? const Color(0xFF29344A)
        : const Color(0xFFE3EBF7);
    final placeholderColor = isDark
        ? const Color(0xFF2B3447)
        : const Color(0xFFDCE5F1);

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: borderColor),
      ),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 112.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 7.w),
                    child: Container(
                      height: 75.h,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
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
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({required this.metrics, required this.isDark});

  final List<_TodayMetric> metrics;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF171D2D), Color(0xFF111827)]
              : const [Color(0xFFF8FAFF), Color(0xFFEFF4FF)],
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3B5B) : const Color(0xFFDCEBFF),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF5B8DEF,
            ).withValues(alpha: isDark ? 0.2 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's progress",
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFF3F7FF)
                          : const Color(0xFF13244A),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'A quick look at your activity',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9DAFCE)
                          : const Color(0xFF7890B4),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: isDark
                      ? const Color(0xFF72A7FF)
                      : const Color(0xFF3986E8),
                  size: 15.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (var index = 0; index < metrics.length; index++) ...[
                Expanded(
                  child: _TodayMetricTile(
                    metric: metrics[index],
                    isDark: isDark,
                  ),
                ),
                if (index < metrics.length - 1) SizedBox(width: 7.w),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayMetricTile extends StatelessWidget {
  const _TodayMetricTile({required this.metric, required this.isDark});

  final _TodayMetric metric;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) {
        return Opacity(
          opacity: animation.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - animation)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 7.h),
            decoration: BoxDecoration(
              color:
                  (isDark ? metric.darkBackgroundColor : metric.backgroundColor)
                      .withValues(alpha: isDark ? 0.96 : 0.82),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(metric.icon, color: metric.color, size: 16.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF4F7FF)
                        : const Color(0xFF12244B),
                    fontSize: metric.value.length > 5 ? 12.sp : 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  metric.label,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFA8B8D2)
                        : const Color(0xFF667898),
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMetric {
  const _TodayMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.darkBackgroundColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color darkBackgroundColor;
}
