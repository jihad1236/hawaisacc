import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/bookmarks_controller.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';
import 'package:hawiisaac/features/home/presentation/widgets/workout_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookmarksController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.blackColor;
    final dividerColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE7E7E7);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: textColor,
            ),
            onPressed: controller.onBackTap,
          ),
          title: Text(
            'Bookmarks',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Divider(height: 1.h, thickness: 1.h, color: dividerColor),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.bookmarks.isEmpty) {
          return _buildLoadingList();
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.bookmarks.isEmpty) {
          return _buildErrorState(controller, isDark);
        }

        if (controller.bookmarks.isEmpty) {
          return _buildEmptyState(controller, isDark);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshBookmarks,
          color: AppColors.primaryColor,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: controller.bookmarks.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final workout = controller.bookmarks[index];
              return Obx(() {
                final isRemoving = controller.isRemovingBookmark(workout.id);
                return WorkoutCard(
                  workout: workout,
                  isDark: isDark,
                  isBookmarked: true,
                  isBookmarkLoading: isRemoving,
                  width: double.infinity,
                  height: 240,
                  onTap: () => controller.onContentTap(workout),
                  onBookmarkTap: () =>
                      _showRemoveOption(context, workout, controller, isDark),
                );
              });
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return ShimmerBox(
          width: double.infinity,
          height: 240.h,
          radius: 8.r,
        );
      },
    );
  }

  Widget _buildErrorState(BookmarksController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 54.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load bookmarks',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.blackColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => controller.fetchBookmarks(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BookmarksController controller, bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshBookmarks,
      color: AppColors.primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(height: 140.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/bookmark-01.svg',
                      width: 36.w,
                      height: 36.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'No bookmarks yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    'Save your favorite workouts and exercises from Home to access them here quickly.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? const Color(0xFFA0A0A0)
                          : const Color(0xFF757575),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRemoveOption(
    BuildContext context,
    DashboardWorkoutItem item,
    BookmarksController controller,
    bool isDark,
  ) {
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final itemBg = isDark
        ? const Color(0xFF2C2C2E)
        : Colors.red.withValues(alpha: 0.05);

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
                SizedBox(height: 18.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Material(
                    color: itemBg,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      leading: Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade500,
                          size: 22.sp,
                        ),
                      ),
                      title: Text(
                        'Remove bookmark',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.blackColor,
                        ),
                      ),
                      subtitle: Text(
                        'This will remove "${item.title}" from your bookmarks list.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      onTap: () {
                        Get.back();
                        controller.removeBookmark(item);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
