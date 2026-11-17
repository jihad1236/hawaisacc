import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/workout_profile_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class WorkoutProfileSetupView extends StatelessWidget {
  const WorkoutProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkoutProfileController());
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDarkMode),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildSectionTitle('Fitness Goal', 'What is your primary training target?', isDarkMode),
                    SizedBox(height: 12.h),
                    _buildGoalList(controller, isDarkMode),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Experience Level', 'Select your current fitness level', isDarkMode),
                    SizedBox(height: 12.h),
                    _buildLevelRow(controller, isDarkMode),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Workout Location', 'Where do you plan to train most?', isDarkMode),
                    SizedBox(height: 12.h),
                    _buildLocationRow(controller, isDarkMode),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Workout Days / Week', 'Target active workout days per week', isDarkMode),
                    SizedBox(height: 12.h),
                    _buildDaysStepper(controller, isDarkMode),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Session Duration', 'Typical duration for each session', isDarkMode),
                    SizedBox(height: 12.h),
                    _buildDurationChips(controller, isDarkMode),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Profile',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF111111),
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Step 2 of 2',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Divider(
          color: isDarkMode ? const Color(0xFF262626) : const Color(0xFFEEEEEE),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : const Color(0xFF111111),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: isDarkMode ? Colors.white60 : const Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalList(WorkoutProfileController controller, bool isDarkMode) {
    final cardBg = isDarkMode ? const Color(0xFF151515) : const Color(0xFFF9F9F9);
    final cardBorder = isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);

    return Column(
      children: WorkoutProfileController.goalOptions.map((opt) {
        return Obx(() {
          final isSelected = controller.selectedGoal.value == opt['value'];

          return GestureDetector(
            onTap: () => controller.setGoal(opt['value']!),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.12) : cardBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : cardBorder,
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt['label']!,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode ? Colors.white70 : const Color(0xFF333333)),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          opt['desc']!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDarkMode ? Colors.white54 : const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : (isDarkMode ? Colors.white38 : const Color(0xFFCCCCCC)),
                        width: 1.8,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 14.r, color: Colors.black)
                        : null,
                  ),
                ],
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildLevelRow(WorkoutProfileController controller, bool isDarkMode) {
    return Row(
      children: WorkoutProfileController.levelOptions.map((opt) {
        final isFirst = opt == WorkoutProfileController.levelOptions.first;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isFirst ? 0 : 8.w),
            child: Obx(() {
              final isSelected = controller.selectedLevel.value == opt['value'];
              return _buildSelectablePill(
                label: opt['label']!,
                isSelected: isSelected,
                isDarkMode: isDarkMode,
                onTap: () => controller.setLevel(opt['value']!),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationRow(WorkoutProfileController controller, bool isDarkMode) {
    return Row(
      children: WorkoutProfileController.locationOptions.map((opt) {
        final isFirst = opt == WorkoutProfileController.locationOptions.first;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isFirst ? 0 : 8.w),
            child: Obx(() {
              final isSelected = controller.selectedLocation.value == opt['value'];
              return _buildSelectablePill(
                label: opt['label']!,
                icon: opt['value'] == 'gym' ? Icons.fitness_center_rounded : Icons.home_rounded,
                isSelected: isSelected,
                isDarkMode: isDarkMode,
                onTap: () => controller.setLocation(opt['value']!),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectablePill({
    required String label,
    IconData? icon,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final unselectedBg = isDarkMode ? const Color(0xFF151515) : const Color(0xFFF9F9F9);
    final unselectedBorder = isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
    final unselectedTextColor = isDarkMode ? Colors.white70 : const Color(0xFF333333);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : unselectedBg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : unselectedBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18.r, color: isSelected ? Colors.black : unselectedTextColor),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.black : unselectedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysStepper(WorkoutProfileController controller, bool isDarkMode) {
    final cardBg = isDarkMode ? const Color(0xFF151515) : const Color(0xFFF9F9F9);
    final cardBorder = isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 22.r, color: AppColors.primaryColor),
              SizedBox(width: 12.w),
              Obx(
                () => Text(
                  '${controller.workoutDays.value} ${controller.workoutDays.value == 1 ? "day" : "days"} / week',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF111111),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                isDarkMode: isDarkMode,
                onTap: () {
                  if (controller.workoutDays.value > 1) {
                    controller.setWorkoutDays(controller.workoutDays.value - 1);
                  }
                },
              ),
              SizedBox(width: 10.w),
              _buildStepperButton(
                icon: Icons.add,
                isDarkMode: isDarkMode,
                onTap: () {
                  if (controller.workoutDays.value < 7) {
                    controller.setWorkoutDays(controller.workoutDays.value + 1);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF222222) : const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20.r, color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildDurationChips(WorkoutProfileController controller, bool isDarkMode) {
    return Row(
      children: WorkoutProfileController.durationOptions.map((mins) {
        final isFirst = mins == WorkoutProfileController.durationOptions.first;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isFirst ? 0 : 6.w),
            child: Obx(() {
              final isSelected = controller.sessionDuration.value == mins;
              return _buildSelectablePill(
                label: '$mins m',
                isSelected: isSelected,
                isDarkMode: isDarkMode,
                onTap: () => controller.setSessionDuration(mins),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(WorkoutProfileController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: 'Finish Setup',
        onTap: controller.submitProfile,
        isLoading: controller.isLoading.value,
        borderRadius: 12,
        margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      ),
    );
  }
}
