import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/warm_up_details_controller.dart';
import 'package:hawiisaac/features/home/model/plan_detail_model.dart';

class WarmUpDetailsScreen extends StatelessWidget {
  const WarmUpDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WarmUpDetailsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.appBarTitle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111111),
              height: 1.2,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFEAEAEA),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _loadingSkeleton(context, isDark);
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.planDetail.value == null) {
            return _errorView(context, controller, isDark);
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Title, Location & Subtitle
                      _titleSection(controller, isDark),
                      SizedBox(height: 16.h),

                      // 3 Stat Cards (Cal Burn, Duration/Exercises, Level)
                      _statsRow(controller, isDark),
                      SizedBox(height: 20.h),

                      // 4-Day Cycle Selector (Push, Pull, Legs, Rest)
                      if (controller.hasSchedule) ...[
                        _scheduleDaySelector(controller, isDark),
                        SizedBox(height: 16.h),
                      ],

                      // Focus / Split Target Banner
                      if (controller.hasSchedule &&
                          controller.currentScheduleDay?.focus.isNotEmpty == true)
                        _dayFocusBanner(controller, isDark),

                      // Exercises list OR Rest Day View
                      if (controller.isCurrentDayRest)
                        _restDayView(controller, isDark)
                      else
                        _todayExerciseSection(controller, isDark),

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              _bottomButton(controller, isDark),
            ],
          );
        }),
      ),
    );
  }

  // ─── Title & Subtitle ─────────────────────────────────────────────

  Widget _titleSection(WarmUpDetailsController controller, bool isDark) {
    final location = controller.planDetail.value?.location.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (location.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Text(
              location.toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Text(
          controller.planTitle,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111111),
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          controller.planSubtitle,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF848484),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ─── Stats Row: 3 Cards ───────────────────────────────────────────

  Widget _statsRow(WarmUpDetailsController controller, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            value: controller.calBurn,
            label: 'CAL BURN',
            isDark: isDark,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _statCard(
            value: controller.exercisesCount,
            label: 'EXERCISES',
            isDark: isDark,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _statCard(
            value: controller.levelText,
            label: 'LEVEL',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFEAEAEA),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111111),
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF848484),
              height: 1.3,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4-Day Cycle Selector ─────────────────────────────────────────

  Widget _scheduleDaySelector(
    WarmUpDetailsController controller,
    bool isDark,
  ) {
    final days = controller.scheduleDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Program Schedule',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(days.length, (index) {
              final day = days[index];
              final isSelected = controller.selectedDayIndex.value == index;

              final title = day.splitName.isNotEmpty
                  ? '${day.dayName}: ${day.splitName}'
                  : day.title;

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: InkWell(
                  onTap: () => controller.selectDay(index),
                  borderRadius: BorderRadius.circular(20.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : (isDark
                              ? const Color(0xFF1A1A1E)
                              : const Color(0xFFF0F0F3)),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : (isDark
                                ? const Color(0xFF2E2E36)
                                : const Color(0xFFDDDDDF)),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (day.isRestDay)
                          Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: Icon(
                              Icons.spa_rounded,
                              size: 14.sp,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark
                                      ? const Color(0xFF90E0EF)
                                      : const Color(0xFF0077B6)),
                            ),
                          ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.black
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF222222)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── Focus / Split Target Banner ──────────────────────────────────

  Widget _dayFocusBanner(
    WarmUpDetailsController controller,
    bool isDark,
  ) {
    final focus = controller.currentScheduleDay?.focus ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161A) : const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? const Color(0xFF282830) : const Color(0xFFE4E4E8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 16.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Focus: $focus',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD0D0D5) : const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Rest Day View ────────────────────────────────────────────────

  Widget _restDayView(
    WarmUpDetailsController controller,
    bool isDark,
  ) {
    final restNote = controller.currentScheduleDay?.restNote.isNotEmpty == true
        ? controller.currentScheduleDay!.restNote
        : 'Recovery is essential for muscle hypertrophy and strength adaptation. Rest, stretch, hydrate, and prepare for the next training cycle.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF15191E) : const Color(0xFFF2F6FA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF26323D) : const Color(0xFFD6E3EF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hotel_rounded,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rest & Active Recovery',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111111),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Day 4 of 4-Day Cycle',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? const Color(0xFFA0A0A0) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            restNote,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16.h),
          _recoveryTipItem(
            icon: Icons.water_drop_outlined,
            title: 'Optimal Hydration',
            desc: 'Aim for 2.5 - 3.5 liters of water to support joint health.',
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _recoveryTipItem(
            icon: Icons.bedtime_outlined,
            title: '7-9 Hours Sleep',
            desc: 'Human Growth Hormone peaks during deep sleep cycles.',
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _recoveryTipItem(
            icon: Icons.directions_walk_rounded,
            title: 'Light Mobility',
            desc: 'Gentle 20-30 min walk or stretching to promote blood flow.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _recoveryTipItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primaryColor),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.5.sp,
                color: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF555555),
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Today's Exercise Section ─────────────────────────────────────

  Widget _todayExerciseSection(
    WarmUpDetailsController controller,
    bool isDark,
  ) {
    final exercises = controller.exercises;
    final dayTitle = controller.currentScheduleDay?.title ?? "Today's Exercise";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111111),
            height: 1.2,
          ),
        ),
        SizedBox(height: 14.h),
        if (exercises.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'No exercises listed for this day.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? const Color(0xFFA0A0A0) : Colors.grey,
                ),
              ),
            ),
          )
        else
          ...exercises.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final exercise = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _exerciseCard(
                exercise: exercise,
                order: exercise.order > 0 ? exercise.order : index,
                isDark: isDark,
              ),
            );
          }),
      ],
    );
  }

  // ─── Exercise Card ────────────────────────────────────────────────

  Widget _exerciseCard({
    required PlanExerciseItem exercise,
    required int order,
    required bool isDark,
  }) {
    final timeStr = exercise.timeDisplay.isNotEmpty
        ? exercise.timeDisplay
        : (exercise.timeSeconds > 0 ? '${exercise.timeSeconds}s' : '45s');

    final match = RegExp(r'^(\d+)(.*)$').firstMatch(timeStr.trim());
    final numberPart = match?.group(1) ?? timeStr;
    final unitPart = match?.group(2) ?? '';

    final subtitleText = exercise.subtitle.isNotEmpty
        ? exercise.subtitle.replaceAll('•', '.')
        : (exercise.targetMuscles.isNotEmpty
            ? exercise.targetMuscles.join(' . ')
            : (exercise.muscleGroup ?? 'Upper Body'));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF222224) : const Color(0xFFE8E8E8),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$order',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFFA0A0A0)
                        : const Color(0xFF848484),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                numberPart,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.primaryColor
                      : const Color(0xFF00464F),
                  height: 1.2,
                ),
              ),
              if (unitPart.isNotEmpty)
                Text(
                  unitPart,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.primaryColor
                        : const Color(0xFF00464F),
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Bottom Button ────────────────────────────────────────────────

  Widget _bottomButton(WarmUpDetailsController controller, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFEAEAEA),
            width: 1.0,
          ),
        ),
      ),
      child: Obx(() {
        final isRest = controller.isCurrentDayRest;
        final activeDay = controller.currentScheduleDay;

        final buttonLabel = isRest
            ? 'Rest Day (Recovery Mode)'
            : (activeDay != null
                ? 'Start ${activeDay.title}'
                : 'Start Exercise');

        return SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: (controller.isStartingExercise.value || isRest)
                ? (isRest ? () => controller.onStartExercise() : null)
                : controller.onStartExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: isRest
                  ? (isDark ? const Color(0xFF1E242B) : const Color(0xFFE2E8F0))
                  : AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: controller.isStartingExercise.value
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: isRest ? Colors.white : Colors.black,
                    ),
                  )
                : Text(
                    buttonLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isRest
                          ? (isDark ? const Color(0xFF90E0EF) : const Color(0xFF0077B6))
                          : const Color(0xFF0A0A0A),
                    ),
                  ),
          ),
        );
      }),
    );
  }

  // ─── Loading Skeleton ─────────────────────────────────────────────

  Widget _loadingSkeleton(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 220.w, height: 32.h, radius: 6.r),
          SizedBox(height: 8.h),
          ShimmerBox(width: 280.w, height: 16.h, radius: 4.r),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 64.h, radius: 8.r)),
              SizedBox(width: 8.w),
              Expanded(child: ShimmerBox(height: 64.h, radius: 8.r)),
              SizedBox(width: 8.w),
              Expanded(child: ShimmerBox(height: 64.h, radius: 8.r)),
            ],
          ),
          SizedBox(height: 20.h),
          ShimmerBox(width: 140.w, height: 20.h, radius: 4.r),
          SizedBox(height: 16.h),
          ...List.generate(
            5,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ShimmerBox(height: 60.h, radius: 16.r),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error View ───────────────────────────────────────────────────

  Widget _errorView(
    BuildContext context,
    WarmUpDetailsController controller,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: Colors.redAccent,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load plan details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? const Color(0xFFA0A0A0) : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                final id = int.tryParse(controller.workout.value?['id'] ?? '');
                if (id != null && id > 0) {
                  controller.fetchPlanDetail(id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: const Color(0xFF0A0A0A),
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.sp),
              label: Text(
                'Try Again',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
