import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/notifications_controller.dart';
import 'package:hawiisaac/features/home/model/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF7F8FA);
    final unreadCardColor = isDark
        ? const Color(0xFF15262B)
        : const Color(0xFFF0F9FB);
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF6B7280);
    final timeTextColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF8F9CAE);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 18.h),

            // ─── Screen Header ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SizedBox(
                height: 44.h,
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24.r),
                      onTap: Get.back,
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 22.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      if (!controller.hasUnread) {
                        return SizedBox(width: 34.w);
                      }
                      return TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 4.h,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: controller.markAllAsRead,
                        icon: Icon(
                          Icons.done_all_rounded,
                          size: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                        label: Text(
                          'Mark read',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: isDark ? const Color(0xFF262626) : const Color(0xFFEEEEEE),
            ),

            // ─── Body: Loading / Empty State / Notification List ─────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.notifications.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                final items = controller.notifications;

                // When list is empty or on error: show empty state widget
                if (items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: controller.refreshNotifications,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 140.h),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 76.r,
                                height: 76.r,
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  size: 38.sp,
                                  color: secondaryTextColor,
                                ),
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                'No notifications yet',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.w),
                                child: Text(
                                  'You will see notifications about offers, workouts, and updates here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: secondaryTextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF333333)
                                        : const Color(0xFFD6D6D6),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18.w,
                                    vertical: 8.h,
                                  ),
                                ),
                                onPressed: controller.refreshNotifications,
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  size: 16.sp,
                                  color: secondaryTextColor,
                                ),
                                label: Text(
                                  'Refresh',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Notification list
                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: controller.refreshNotifications,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _notificationCard(
                        context: context,
                        item: item,
                        controller: controller,
                        cardColor: cardColor,
                        unreadCardColor: unreadCardColor,
                        secondaryTextColor: secondaryTextColor,
                        timeTextColor: timeTextColor,
                        isDark: isDark,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard({
    required BuildContext context,
    required NotificationItem item,
    required NotificationsController controller,
    required Color cardColor,
    required Color unreadCardColor,
    required Color secondaryTextColor,
    required Color timeTextColor,
    required bool isDark,
  }) {
    final isUnread = !item.isRead;

    return Dismissible(
      key: Key('notif_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      onDismissed: (_) {
        controller.deleteNotification(item.id);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          controller.markAsRead(item);
        },
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isUnread ? unreadCardColor : cardColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isUnread
                  ? AppColors.primaryColor.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header: Title on Left, Timestamp on Right
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          SizedBox(width: 6.w),
                          Container(
                            width: 7.r,
                            height: 7.r,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    item.timeDisplay,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: timeTextColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Message Body
              Text(
                item.message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
