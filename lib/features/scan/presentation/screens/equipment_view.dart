import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/scan/controller/equipment_controller.dart';

class EquipmentView extends StatelessWidget {
  const EquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EquipmentController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton(context);
        }

        if (controller.allEquipments.isEmpty &&
            controller.errorMessage.isNotEmpty) {
          return _buildErrorState(context, controller);
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildSearchBar(context, controller),
                    SizedBox(height: 16.h),
                    _buildCategoryChips(context, controller),
                    SizedBox(height: 16.h),
                    _buildEquipmentGrid(context, controller),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            _buildContinueButton(context, controller),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: AppBar
  // ─────────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    EquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.blackColor;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: titleColor,
          size: 22.r,
        ),
        onPressed: controller.onBackTapped,
      ),
      centerTitle: true,
      title: Obx(
        () => Text(
          controller.appBarTitle.value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Search Bar
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context, EquipmentController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? Theme.of(context).cardColor : const Color(0xFFF5F5F5);
    final borderColor = isDark ? Colors.transparent : const Color(0xFFEAEAEA);

    return SizedBox(
      height: 50.h,
      child: Obx(
        () => TextFormField(
          controller: controller.searchController,
          style: TextStyle(
            fontSize: 16.sp,
            color: isDark ? Colors.white : AppColors.blackColor,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: controller.searchHint.value,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF848484),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 10.w),
              child: Icon(
                Icons.search_rounded,
                size: 22.r,
                color: const Color(0xFF848484),
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 46.w),
            suffixIcon: controller.searchQuery.value.trim().isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.r,
                      color: const Color(0xFF848484),
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                    },
                  )
                : null,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            filled: true,
            fillColor: fillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: borderColor, width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide:
                  BorderSide(color: AppColors.primaryColor, width: 1.5.w),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Category Chips
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryChips(
    BuildContext context,
    EquipmentController controller,
  ) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            controller.categories.length,
            (index) => Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: _buildCategoryChip(context, controller, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    EquipmentController controller,
    int index,
  ) {
    final bool isSelected = controller.selectedCategoryIndex.value == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg =
        isDark ? Theme.of(context).cardColor : const Color(0xFFF5F5F5);
    final unselectedTextColor = isDark ? Colors.white : AppColors.blackColor;

    return GestureDetector(
      onTap: () => controller.onCategorySelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : unselectedBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          controller.categories[index],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.blackColor : unselectedTextColor,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Equipment Grid
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEquipmentGrid(
    BuildContext context,
    EquipmentController controller,
  ) {
    return Obx(() {
      final items = controller.filteredEquipments;

      if (items.isEmpty) {
        return _buildEmptyState(context, controller);
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 11.w,
          mainAxisSpacing: 11.h,
          childAspectRatio: 1.05,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildEquipmentCard(context, controller, index);
        },
      );
    });
  }

  Widget _buildEmptyState(
    BuildContext context,
    EquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSearchActive = controller.searchQuery.value.trim().isNotEmpty;
    final isCategoryFiltered = controller.selectedCategoryIndex.value > 0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearchActive
                    ? Icons.search_off_rounded
                    : Icons.fitness_center_rounded,
                size: 30.r,
                color: const Color(0xFF848484),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              isSearchActive
                  ? 'No matching equipment'
                  : 'No equipment found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.blackColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              isSearchActive
                  ? 'No equipment matches "${controller.searchQuery.value.trim()}". Try another name or keyword.'
                  : 'There is no equipment available in this category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF848484),
                height: 1.4,
              ),
            ),
            if (isSearchActive || isCategoryFiltered) ...[
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  controller.searchController.clear();
                  controller.selectedCategoryIndex.value = 0;
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Reset filters',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    EquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 32.r,
                color: const Color(0xFF848484),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Unable to load equipment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF848484),
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: controller.fetchEquipments,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 18.r,
                      color: AppColors.blackColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER: Equipment Card
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEquipmentCard(
    BuildContext context,
    EquipmentController controller,
    int index,
  ) {
    return Obx(() {
      final items = controller.filteredEquipments;
      if (index >= items.length) return const SizedBox.shrink();

      final equipment = items[index];
      final bool isSelected = controller.selectedEquipmentIndex.value == index;
      final image = equipment['image']?.toString() ?? '';
      final name = equipment['title']?.toString().isNotEmpty == true
          ? equipment['title']?.toString() ?? ''
          : equipment['name']?.toString() ?? '';
      final linkedExercises = equipment['linkedExercises'] ??
          (equipment['recommendedExercises'] as List?)?.length ??
          0;

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final unselectedCardBg =
          isDark ? Theme.of(context).cardColor : const Color(0xFFF5F5F5);
      final selectedCardBg =
          isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white;

      final iconBoxBg = isSelected
          ? const Color(0xFFD9FBFF)
          : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEAEAEA));

      final titleColor = isDark ? Colors.white : AppColors.blackColor;

      return GestureDetector(
        onTap: () => controller.onEquipmentSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: isSelected ? selectedCardBg : unselectedCardBg,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 1.5.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon Box ─────────────────────────────────────────────
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: iconBoxBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.network(
                            image.startsWith('http://')
                                ? image.replaceFirst('http://', 'https://')
                                : image,
                            width: 38.r,
                            height: 38.r,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.fitness_center_rounded,
                              size: 26.r,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : (isDark ? Colors.white70 : const Color(0xFF111111)),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fitness_center_rounded,
                          size: 26.r,
                          color: isSelected
                              ? AppColors.primaryColor
                              : (isDark ? Colors.white70 : const Color(0xFF111111)),
                        ),
                ),
              ),
              const Spacer(),
              // ── Equipment Title ───────────────────────────────────────
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 3.h),
              // ── Linked Exercises Subtitle ────────────────────────────
              Text(
                '$linkedExercises exercises',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF848484),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Continue Button
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildContinueButton(
    BuildContext context,
    EquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final btnTextColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Obx(
      () => CustomPrimaryButton(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        text: controller.isDetailLoading.value
            ? 'Loading...'
            : controller.buttonText.value,
        onTap: controller.onContinueTapped,
        isLoading: controller.isDetailLoading.value,
        backgroundColor: btnBg,
        textColor: btnTextColor,
        height: 52.h,
        borderRadius: 12,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Loading Skeleton
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 50.h, radius: 8),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: ShimmerBox(width: 80.w, height: 36.h, radius: 8),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 11.w,
              mainAxisSpacing: 11.h,
              childAspectRatio: 1.05,
            ),
            itemCount: 6,
            itemBuilder: (context, index) =>
                ShimmerBox(width: double.infinity, height: 155.h, radius: 8),
          ),
        ],
      ),
    );
  }
}
