import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/profile/controller/premium_controller.dart';

class PremiumView extends StatelessWidget {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PremiumController());

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    _buildHeaderRow(controller),
                    SizedBox(height: 8.h),
                    _buildHeadline(controller),
                    SizedBox(height: 20.h),
                    _buildFeatureList(controller),
                    SizedBox(height: 32.h),
                    _buildPlanCards(controller),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            _buildSubscribeButton(controller),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(PremiumController controller) {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Icon(
          Icons.chevron_left,
          color: AppColors.blackColor,
          size: 28.sp,
        ),
      ),
      title: Text(
        'HYKX Pro',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.blackColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: controller.onRestorePurchases,
          child: Text(
            'Restore',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.secondaryColor.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(PremiumController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          controller.appName,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.blackColor,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Text(
            controller.tagLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline(PremiumController controller) {
    return Text(
      controller.headline,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.blackColor,
      ),
    );
  }

  Widget _buildFeatureList(PremiumController controller) {
    return Column(
      children: controller.features
          .map((feature) => _buildFeatureItem(feature))
          .toList(),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Icon(Icons.check, color: AppColors.primaryColor, size: 20.sp),
          SizedBox(width: 14.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards(PremiumController controller) {
    return Obx(
      () => SizedBox(
        height: 230.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(controller.plans.length * 2 - 1, (slot) {
            if (slot.isOdd) {
              return SizedBox(width: 8.w);
            }

            final index = slot ~/ 2;
            final plan = controller.plans[index];
            final isSelected = controller.selectedPlanIndex.value == index;
            final hasBadge = isSelected && plan['badge']!.isNotEmpty;

            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectPlan(index),
                child: _buildPlanCard(
                  plan: plan,
                  isSelected: isSelected,
                  hasBadge: hasBadge,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required Map<String, String> plan,
    required bool isSelected,
    required bool hasBadge,
  }) {
    final radius = Radius.circular(24.r);
    final shellColor = isSelected ? AppColors.primaryColor : Colors.transparent;
    final borderColor = isSelected
        ? AppColors.primaryColor
        : AppColors.secondaryColor.withValues(alpha: 0.12);

    return AnimatedScale(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      scale: isSelected ? 1 : 0.965,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: shellColor,
          borderRadius: BorderRadius.all(radius),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40.h,
              child: Center(
                child: hasBadge
                    ? Text(
                        plan['badge']!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isSelected ? 24.h : 22.h,
                  horizontal: 18.w,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.all(radius),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 3 : 1.5,
                  ),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        plan['label']!,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(plan['title']!),
                      SizedBox(height: 18.h),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${plan['currency']} ',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                            ),
                            TextSpan(
                              text: plan['price']!,
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        plan['billing']!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryColor.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(PremiumController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => CustomPrimaryButton(
              text: controller.ctaLabel,
              onTap: controller.onSubscribe,
              isLoading: controller.isLoading.value,
              height: 52.h,
              borderRadius: 14,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Payment will be charged to your App Store or Google Play account. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: AppColors.secondaryColor.withValues(alpha: 0.6),
              height: 1.35,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: controller.onRestorePurchases,
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                '  •  ',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.secondaryColor.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '  •  ',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.secondaryColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
