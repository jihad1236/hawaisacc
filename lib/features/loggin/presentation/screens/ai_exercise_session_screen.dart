import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/loggin/controller/ai_exercise_session_controller.dart';

class AiExerciseSessionScreen extends StatelessWidget {
  const AiExerciseSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiExerciseSessionController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Logging',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(child: _timerBadge(controller, isDark)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value && !controller.hasExercises) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (!controller.hasExercises) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  controller.errorMessage.value.isEmpty
                      ? 'No active exercises found.'
                      : controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  children: [
                    // ── Completed exercises (Figma Node 25:6217) ──────
                    if (controller.completedExercises.isNotEmpty) ...[
                      for (final exercise in controller.completedExercises) ...[
                        _completedExerciseTile(
                          context,
                          exercise: exercise,
                          isDark: isDark,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ],

                    // ── Active exercise (Figma Node 25:6067 & 25:6217) ──
                    if (!controller.allExercisesCompleted) ...[
                      Text(
                        controller.currentExercise.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Center(child: _currentExerciseTimer(controller)),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: controller.isAdvancing.value
                              ? null
                              : () => controller.nextExercise(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF1A1A1A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: controller.isAdvancing.value
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  controller.isLastExercise ? 'Done' : 'Next',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // ── Pending upcoming exercises (Figma Node 25:6067) ──
                    for (
                      var index = 0;
                      index < controller.pendingExercises.length;
                      index++
                    ) ...[
                      if (index > 0) SizedBox(height: 16.h),
                      _pendingExerciseTile(
                        context,
                        exercise: controller.pendingExercises[index],
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),

              // ── Bottom Pinned Button "Finish workout" ─────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: controller.isFinishing.value
                        ? null
                        : () => controller.finishWorkout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: const Color(0xFF0A0A0A),
                      disabledBackgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      shadowColor: const Color(0x5E000000),
                    ),
                    child: controller.isFinishing.value
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              color: Color(0xFF0A0A0A),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Finish workout',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0A0A),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Header Timer Pill Badge (Figma Node 25:6139) ───────────────────

  Widget _timerBadge(AiExerciseSessionController controller, bool isDark) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF003840) : const Color(0xFFDDFAFE),
          borderRadius: BorderRadius.circular(80.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 13.sp,
              color: isDark ? AppColors.primaryColor : const Color(0xFF01555E),
            ),
            SizedBox(width: 6.w),
            Text(
              controller.formattedSessionRemainingTime,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryColor : const Color(0xFF01555E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dual Countdown Timer Boxes (Figma Node 25:6074) ────────────────

  Widget _currentExerciseTimer(AiExerciseSessionController controller) {
    return Obx(() {
      final seconds = controller.remainingSeconds.value;
      final left = (seconds ~/ 60).toString().padLeft(2, '0');
      final right = (seconds % 60).toString().padLeft(2, '0');

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeBox(left),
          SizedBox(width: 8.w),
          _timeBox(right),
        ],
      );
    });
  }

  Widget _timeBox(String value) {
    return Container(
      width: 48.w,
      height: 42.h,
      decoration: BoxDecoration(
        color: const Color(0xFF4B4B4B),
        borderRadius: BorderRadius.circular(7.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Completed Exercise Card (Figma Node 25:6221) ───────────────────

  Widget _completedExerciseTile(
    BuildContext context, {
    required AiExerciseSessionItem exercise,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
            alignment: Alignment.center,
            child: Text(
              '${exercise.order}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  exercise.tags,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF848484),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Done',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.primaryColor : const Color(0xFF00464F),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pending Upcoming Exercise Card (Figma Node 25:6079) ────────────

  Widget _pendingExerciseTile(
    BuildContext context, {
    required AiExerciseSessionItem exercise,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
            alignment: Alignment.center,
            child: Text(
              '${exercise.order}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  exercise.tags,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF848484),
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${exercise.seconds > 0 ? exercise.seconds : 45}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.primaryColor
                        : const Color(0xFF00464F),
                  ),
                ),
                TextSpan(
                  text: 's',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.primaryColor
                        : const Color(0xFF00464F),
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
