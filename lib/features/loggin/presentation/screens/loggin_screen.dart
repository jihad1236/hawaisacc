import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_secondary_button.dart';
import 'package:hawiisaac/features/bottom_navigation/controllers/bottom_navigation_controller.dart';
import 'package:hawiisaac/features/loggin/controller/logging_controller.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class LoggingView extends StatefulWidget {
  const LoggingView({super.key});

  @override
  State<LoggingView> createState() => _LoggingViewState();
}

class _LoggingViewState extends State<LoggingView> {
  late final LoggingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoggingController>()
        ? Get.find<LoggingController>()
        : Get.put(LoggingController());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      appBar: _buildAppBar(context, controller, isDark),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton(isDark);
        }

        if (!controller.hasActiveSession.value ||
            controller.exercises.isEmpty) {
          return _buildEmptyState(context, controller, isDark);
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          onRefresh: () => controller.loadActiveSession(showLoading: false),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 130.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  ...controller.exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: _buildDynamicExerciseCard(
                        context,
                        controller,
                        exercise,
                        exerciseIndex: index,
                        isDark: isDark,
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                  _finishWorkoutButton(controller),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Loading Skeleton ─────────────────────────────────────────────

  Widget _buildLoadingSkeleton(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 18.h,
        bottom: 130.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _loggingSkeletonCard(isDark, showDuration: true),
          SizedBox(height: 24.h),
          _loggingSkeletonCard(isDark),
          SizedBox(height: 24.h),
          _loggingSkeletonCard(isDark),
        ],
      ),
    );
  }

  Widget _loggingSkeletonCard(bool isDark, {bool showDuration = false}) {
    final cardColor = isDark ? const Color(0xFF141414) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF242424)
        : const Color(0xFFEAEAEA);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 180.w, height: 22.h, radius: 6.r),
          SizedBox(height: 8.h),
          ShimmerBox(width: 128.w, height: 14.h, radius: 5.r),
          SizedBox(height: 18.h),
          if (showDuration) ...[
            ShimmerBox(width: double.infinity, height: 164.h, radius: 14.r),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(height: 46.h, radius: 12.r),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ShimmerBox(height: 46.h, radius: 12.r),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                ShimmerBox(width: 42.w, height: 14.h, radius: 4.r),
                SizedBox(width: 20.w),
                Expanded(
                  child: ShimmerBox(height: 14.h, radius: 4.r),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: ShimmerBox(height: 14.h, radius: 4.r),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 10.h),
                child: Row(
                  children: [
                    ShimmerBox(width: 34.w, height: 34.w, radius: 17.r),
                    SizedBox(width: 18.w),
                    Expanded(
                      child: ShimmerBox(height: 42.h, radius: 10.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ShimmerBox(height: 42.h, radius: 10.r),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            ShimmerBox(width: double.infinity, height: 46.h, radius: 12.r),
          ],
          SizedBox(height: 14.h),
          ShimmerBox(width: double.infinity, height: 72.h, radius: 12.r),
        ],
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────

  Widget _buildEmptyState(
    BuildContext context,
    LoggingController controller,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF111111);

    return RefreshIndicator(
      color: AppColors.primaryColor,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      onRefresh: () => controller.loadActiveSession(showLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        children: [
          SizedBox(height: 60.h),
          Center(
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 44.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            controller.emptyMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.3,
            ),
          ),
          SizedBox(height: 36.h),
          CustomPrimaryButton(
            text: 'Scan Equipment',
            onTap: () {
              if (Get.isRegistered<BottomNavigationController>()) {
                Get.find<BottomNavigationController>().changeTab(1);
              } else {
                Get.toNamed(AppRoute.getEquipmentView());
              }
            },
            borderRadius: 16,
            height: 52.h,
          ),
          SizedBox(height: 14.h),
          CustomSecondaryButton(
            text: 'Refresh Session',
            onTap: () => controller.loadActiveSession(),
            borderRadius: 16,
            height: 52.h,
          ),
        ],
      ),
    );
  }

  // ─── Fixed Top AppBar (Figma Node 25:7221) ─────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    LoggingController controller,
    bool isDark,
  ) {
    final canPop = Navigator.canPop(context);
    final iconColor = isDark ? Colors.white : const Color(0xFF111111);
    final titleColor = isDark ? Colors.white : const Color(0xFF111111);
    final borderColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFEAEAEA);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 56.h,
      leading: IconButton(
        onPressed: () {
          if (canPop) {
            Get.back();
          } else if (Get.isRegistered<BottomNavigationController>()) {
            Get.find<BottomNavigationController>().changeTab(0);
          }
        },
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.sp,
          color: iconColor,
        ),
      ),
      title: Text(
        'Logging',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Center(child: _timerBadge(controller, isDark)),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: borderColor, height: 1.0),
      ),
    );
  }

  Widget _timerBadge(LoggingController controller, bool isDark) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primaryColor.withValues(alpha: 0.16)
              : const Color(0xFFDDFCFF),
          borderRadius: BorderRadius.circular(80.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14.sp,
              color: isDark ? AppColors.primaryColor : const Color(0xFF01555E),
            ),
            SizedBox(width: 6.w),
            Text(
              controller.formattedTime,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.primaryColor
                    : const Color(0xFF01555E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dynamic Exercise Card Dispatcher ──────────────────────────────

  Widget _buildDynamicExerciseCard(
    BuildContext context,
    LoggingController controller,
    ActiveExerciseState exercise, {
    required int exerciseIndex,
    required bool isDark,
  }) {
    switch (exercise.logType) {
      case 'strength':
        return _buildStrengthCard(context, controller, exercise, isDark);
      case 'bodyweight':
        return _buildBodyweightCard(context, controller, exercise, isDark);
      case 'cardio':
        return _buildCardioCard(context, controller, exercise, isDark);
      case 'duration':
        return _buildDurationCard(context, controller, exercise, isDark);
      default:
        return _buildStrengthCard(context, controller, exercise, isDark);
    }
  }

  // ─── 1. Strength Exercise Card ──────────────────────────────────────

  Widget _buildStrengthCard(
    BuildContext context,
    LoggingController controller,
    ActiveExerciseState exercise,
    bool isDark,
  ) {
    final titleColor = isDark ? Colors.white : AppColors.blackColor;
    final subtextColor = isDark
        ? const Color(0xFF888888)
        : Colors.grey.shade500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        if (exercise.muscles.isNotEmpty ||
            exercise.categoryName.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            [
              if (exercise.categoryName.isNotEmpty) exercise.categoryName,
              ...exercise.muscles,
            ].join(' • '),
            style: TextStyle(fontSize: 12.sp, color: subtextColor),
          ),
        ],
        SizedBox(height: 18.h),
        _setTableHeader(showKg: true),
        SizedBox(height: 10.h),
        _setList(context, controller, exercise, showKg: true),
        SizedBox(height: 14.h),
        CustomSecondaryButton(
          text: 'Add set',
          onTap: () => controller.addSet(exercise),
          height: 52.h,
          borderRadius: 12,
        ),
        SizedBox(height: 16.h),
        _noteField(exercise, controller, isDark),
      ],
    );
  }

  // ─── 2. Bodyweight Exercise Card ───────────────────────────────────

  Widget _buildBodyweightCard(
    BuildContext context,
    LoggingController controller,
    ActiveExerciseState exercise,
    bool isDark,
  ) {
    final titleColor = isDark ? Colors.white : AppColors.blackColor;
    final subtextColor = isDark
        ? const Color(0xFF888888)
        : Colors.grey.shade500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        if (exercise.muscles.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            exercise.muscles.join(' • '),
            style: TextStyle(fontSize: 12.sp, color: subtextColor),
          ),
        ],
        SizedBox(height: 18.h),
        _setTableHeader(showKg: false),
        SizedBox(height: 10.h),
        _setList(context, controller, exercise, showKg: false),
        SizedBox(height: 14.h),
        CustomSecondaryButton(
          text: 'Add set',
          onTap: () => controller.addSet(exercise),
          height: 52.h,
          borderRadius: 12,
        ),
        SizedBox(height: 16.h),
        _noteField(exercise, controller, isDark),
      ],
    );
  }

  // ─── 3. Cardio Exercise Card ───────────────────────────────────────

  Widget _buildCardioCard(
    BuildContext context,
    LoggingController controller,
    ActiveExerciseState exercise,
    bool isDark,
  ) {
    final titleColor = isDark ? Colors.white : AppColors.blackColor;
    final subtextColor = isDark
        ? const Color(0xFF888888)
        : Colors.grey.shade500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        if (exercise.muscles.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            exercise.muscles.join(' • '),
            style: TextStyle(fontSize: 12.sp, color: subtextColor),
          ),
        ],
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: _cardioField(
                context,
                label: 'Time',
                icon: Icons.timer_outlined,
                controller: exercise.timeController,
                hintText: '10 min',
                isDark: isDark,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _cardioField(
                context,
                label: 'Distance',
                icon: Icons.place_outlined,
                controller: exercise.distanceController,
                hintText: '4 km',
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _cardioField(
                context,
                label: 'Speed',
                icon: Icons.speed_outlined,
                controller: exercise.speedController,
                hintText: '24 km/h',
                isDark: isDark,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(child: _inclineField(context, exercise, isDark)),
          ],
        ),
        SizedBox(height: 14.h),
        Obx(
          () => CustomSecondaryButton(
            text: exercise.isCardioSaving.value ? 'Saving...' : 'Add set',
            onTap: () => controller.saveCardioMetrics(exercise),
            height: 52.h,
            borderRadius: 12,
          ),
        ),
        SizedBox(height: 16.h),
        _noteField(exercise, controller, isDark),
      ],
    );
  }

  // ─── 4. Duration Exercise Card (Stopwatch / Hold) ───────────────────

  Widget _buildDurationCard(
    BuildContext context,
    LoggingController controller,
    ActiveExerciseState exercise,
    bool isDark,
  ) {
    final titleColor = isDark ? Colors.white : AppColors.blackColor;
    final cardBg = isDark ? const Color(0xFF161616) : const Color(0xFFF7F8F9);
    final borderColor = isDark ? const Color(0xFF262626) : Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Obx(
                () => Icon(
                  exercise.isDone.value
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_bottom_rounded,
                  size: 36.sp,
                  color: exercise.isDone.value
                      ? Colors.greenAccent
                      : AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Text(
                  exercise.isDone.value
                      ? 'Completed'
                      : _formatDuration(exercise.durationSeconds.value),
                  style: TextStyle(
                    fontSize: exercise.isDone.value ? 26.sp : 32.sp,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Text(
                  exercise.isDone.value
                      ? 'Great work — hold completed'
                      : 'Target: ${_formatDuration(exercise.targetDurationSeconds)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: exercise.isDone.value
                      ? null
                      : () {
                          if (exercise.isTimerRunning.value) {
                            controller.pauseDuration(exercise);
                          } else {
                            controller.startDuration(exercise);
                          }
                        },
                  icon: Icon(
                    exercise.isTimerRunning.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 18.sp,
                  ),
                  label: Text(
                    exercise.isTimerRunning.value ? 'Pause' : 'Start',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.black,
                    minimumSize: Size.fromHeight(46.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: exercise.isDone.value
                      ? null
                      : () => controller.resetDuration(exercise),
                  icon: Icon(Icons.restart_alt_rounded, size: 18.sp),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white
                        : AppColors.blackColor,
                    minimumSize: Size(0, 46.h),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _noteField(exercise, controller, isDark),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ─── Set Table Header ──────────────────────────────────────────────

  Widget _setTableHeader({required bool showKg}) {
    return Row(
      children: [
        SizedBox(
          width: 44.w,
          child: Text('SET', style: _headerStyle()),
        ),
        SizedBox(width: 12.w),
        if (showKg) ...[
          Expanded(
            child: Center(child: Text('KG', style: _headerStyle())),
          ),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Center(child: Text('REPS', style: _headerStyle())),
        ),
        SizedBox(width: 36.w),
      ],
    );
  }

  TextStyle _headerStyle() => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF111111),
    letterSpacing: 0.5,
  );

  // ─── Set List ──────────────────────────────────────────────────────

  Widget _setList(
    BuildContext context,
    LoggingController controller,
    ActiveExerciseState exercise, {
    required bool showKg,
  }) {
    return Obx(
      () => Column(
        children: exercise.sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _setRow(
              index: index,
              set: set,
              exercise: exercise,
              context: context,
              controller: controller,
              showKg: showKg,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Set Row ───────────────────────────────────────────────────────

  Widget _setRow({
    required int index,
    required WorkoutSetState set,
    required ActiveExerciseState exercise,
    required BuildContext context,
    required LoggingController controller,
    required bool showKg,
  }) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _setNumberBadge(
            context,
            number: set.setNumber.value,
            isCompleted: set.isCompleted.value,
          ),
          SizedBox(width: 12.w),
          if (showKg) ...[
            Expanded(
              child: _stepper(
                context: context,
                valueText: set.kg.value % 1 == 0
                    ? '${set.kg.value.toInt()}'
                    : '${set.kg.value}',
                isEnabled: !set.isCompleted.value,
                onDecrement: () => controller.decrementKg(exercise, index),
                onIncrement: () => controller.incrementKg(exercise, index),
              ),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: _stepper(
              context: context,
              valueText: '${set.reps.value}',
              isEnabled: !set.isCompleted.value,
              onDecrement: () => controller.decrementReps(exercise, index),
              onIncrement: () => controller.incrementReps(exercise, index),
            ),
          ),
          SizedBox(width: 12.w),
          _completedCheckbox(
            exercise: exercise,
            index: index,
            isCompleted: set.isCompleted.value,
            onTap: () => controller.toggleSetCompleted(exercise, index),
          ),
        ],
      ),
    );
  }

  // ─── Stepper ───────────────────────────────────────────────────────

  Widget _stepper({
    required BuildContext context,
    required String valueText,
    required bool isEnabled,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepperButton(
          context: context,
          icon: Icons.remove,
          onTap: isEnabled ? onDecrement : null,
          isEnabled: isEnabled,
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 36.w,
          child: Text(
            valueText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isEnabled
                  ? (isDark ? Colors.white : AppColors.blackColor)
                  : (isDark ? Colors.white38 : Colors.grey.shade400),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        _stepperButton(
          context: context,
          icon: Icons.add,
          onTap: isEnabled ? onIncrement : null,
          isEnabled: isEnabled,
        ),
      ],
    );
  }

  Widget _stepperButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isEnabled
        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
        : (isDark ? const Color(0xFF141414) : Colors.grey.shade100);
    final borderColor = isEnabled
        ? (isDark ? Colors.white24 : Colors.grey.shade300)
        : (isDark ? Colors.white10 : Colors.grey.shade200);
    final iconColor = isEnabled
        ? (isDark ? Colors.white : AppColors.blackColor)
        : (isDark ? Colors.white30 : Colors.grey.shade400);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor, width: 1.2),
          color: backgroundColor,
        ),
        child: Icon(icon, size: 14.sp, color: iconColor),
      ),
    );
  }

  // ─── Set Number Badge ──────────────────────────────────────────────

  Widget _setNumberBadge(
    BuildContext context, {
    required int number,
    required bool isCompleted,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.primaryColor
            : (isDark ? const Color(0xFF262626) : const Color(0xFFEAEAEA)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: isCompleted
              ? AppColors.blackColor
              : (isDark ? Colors.white : const Color(0xFF111111)),
        ),
      ),
    );
  }

  // ─── Completed Checkbox ────────────────────────────────────────────

  Widget _completedCheckbox({
    required ActiveExerciseState exercise,
    required int index,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final isLoading = exercise.savingSetIndexes.contains(index);

      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.r),
            color: isCompleted ? AppColors.primaryColor : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.all(5.w),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? AppColors.blackColor
                          : AppColors.primaryColor,
                    ),
                  ),
                )
              : isCompleted
              ? Icon(
                  Icons.check_rounded,
                  size: 18.sp,
                  color: AppColors.blackColor,
                )
              : null,
        ),
      );
    });
  }

  // ─── Cardio Fields ─────────────────────────────────────────────────

  Widget _cardioField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
  }) {
    final labelColor = isDark ? Colors.white : AppColors.blackColor;
    final hintColor = isDark ? Colors.white38 : const Color(0xFF848484);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: labelColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isDark ? const Color(0xFF262626) : const Color(0xFFEAEAEA),
              width: 1.0,
            ),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 15.sp, color: hintColor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inclineField(
    BuildContext context,
    ActiveExerciseState exercise,
    bool isDark,
  ) {
    final labelColor = isDark ? Colors.white : AppColors.blackColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up_rounded, size: 16.sp, color: labelColor),
            SizedBox(width: 6.w),
            Text(
              'Incline',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isDark ? const Color(0xFF262626) : const Color(0xFFEAEAEA),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              _stepperButton(
                context: context,
                icon: Icons.remove,
                onTap: () {
                  if (exercise.inclineValue.value > 0) {
                    exercise.inclineValue.value--;
                  }
                },
                isEnabled: true,
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    '${exercise.inclineValue.value}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                ),
              ),
              _stepperButton(
                context: context,
                icon: Icons.add,
                onTap: () => exercise.inclineValue.value++,
                isEnabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Note Field ────────────────────────────────────────────────────

  Widget _noteField(
    ActiveExerciseState exercise,
    LoggingController controller,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF848484);
    final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFEAEAEA);

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          controller.saveExerciseNote(exercise);
        }
      },
      child: Container(
        height: 89.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: TextField(
          controller: exercise.noteController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(fontSize: 14.sp, color: textColor),
          onSubmitted: (_) => controller.saveExerciseNote(exercise),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Add a note about this exercise...',
            hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
            border: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  // ─── Finish Workout Button ─────────────────────────────────────────

  Widget _finishWorkoutButton(LoggingController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: controller.isSaving.value ? 'Finishing...' : 'Finish workout',
        onTap: controller.onFinishWorkout,
        isLoading: controller.isSaving.value,
        borderRadius: 12,
        height: 52.h,
      ),
    );
  }
}
