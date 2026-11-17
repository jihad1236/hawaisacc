import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/selectunit_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class SelectUnitsView extends StatelessWidget {
  const SelectUnitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SelectUnitsController>()
        ? Get.find<SelectUnitsController>()
        : Get.put(SelectUnitsController());
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
                    SizedBox(height: 24.h),
                    _buildSectionCard(
                      context,
                      isDarkMode: isDarkMode,
                      icon: 'assets/icons/weight.png',
                      fallbackIcon: Icons.fitness_center_rounded,
                      title: 'Weight',
                      subtitle: 'Choose preferred unit for workout weight',
                      options: controller.weightOptions,
                      displayLabels: const {'lbs': 'Pounds (lbs)', 'kg': 'Kilograms (kg)'},
                      selectedRx: controller.selectedWeight,
                      onSelect: controller.selectWeight,
                    ),
                    SizedBox(height: 20.h),
                    _buildSectionCard(
                      context,
                      isDarkMode: isDarkMode,
                      icon: 'assets/icons/distance.png',
                      fallbackIcon: Icons.directions_run_rounded,
                      title: 'Distance',
                      subtitle: 'Choose preferred unit for cardio & running',
                      options: controller.distanceOptions,
                      displayLabels: const {'miles': 'Miles (mi)', 'km': 'Kilometers (km)'},
                      selectedRx: controller.selectedDistance,
                      onSelect: controller.selectDistance,
                    ),
                    SizedBox(height: 20.h),
                    _buildSectionCard(
                      context,
                      isDarkMode: isDarkMode,
                      icon: 'assets/icons/body_mesurments.png',
                      fallbackIcon: Icons.straighten_rounded,
                      title: 'Body Measurements',
                      subtitle: 'Choose preferred unit for size tracking',
                      options: controller.bodyMeasurementOptions,
                      displayLabels: const {'in': 'Inches (in)', 'cm': 'Centimeters (cm)'},
                      selectedRx: controller.selectedBodyMeasurement,
                      onSelect: controller.selectBodyMeasurement,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            _buildGetStartedButton(controller),
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
                'Select Units',
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
                  'Step 1 of 2',
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

  Widget _buildSectionCard(
    BuildContext context, {
    required bool isDarkMode,
    required String icon,
    required IconData fallbackIcon,
    required String title,
    required String subtitle,
    required List<String> options,
    required Map<String, String> displayLabels,
    required RxString selectedRx,
    required void Function(String) onSelect,
  }) {
    final cardBg = isDarkMode ? const Color(0xFF151515) : const Color(0xFFF9F9F9);
    final cardBorder = isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF111111);
    final secondaryTextColor = isDarkMode ? Colors.white60 : const Color(0xFF757575);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF222222)
                      : const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  icon,
                  width: 20.r,
                  height: 20.r,
                  color: isDarkMode ? Colors.white : const Color(0xFF111111),
                  errorBuilder: (context, error, stackTrace) => Icon(
                    fallbackIcon,
                    size: 20.r,
                    color: isDarkMode ? Colors.white : const Color(0xFF111111),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(
            () => Row(
              children: options.map((option) {
                final isSelected = selectedRx.value == option;
                final isFirst = option == options.first;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: isFirst ? 0 : 8.w),
                    child: _buildToggleButton(
                      isDarkMode: isDarkMode,
                      label: displayLabels[option] ?? option,
                      unitValue: option,
                      isSelected: isSelected,
                      onTap: () => onSelect(option),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required bool isDarkMode,
    required String label,
    required String unitValue,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final unselectedBg = isDarkMode ? const Color(0xFF1F1F1F) : Colors.white;
    final unselectedBorder =
        isDarkMode ? const Color(0xFF333333) : const Color(0xFFDCDCDC);
    final unselectedTextColor =
        isDarkMode ? Colors.white70 : const Color(0xFF333333);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 50.h,
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : unselectedTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(SelectUnitsController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: 'Continue to Profile',
        onTap: controller.onGetStarted,
        isLoading: controller.isLoading.value,
        borderRadius: 12,
        margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      ),
    );
  }
}

