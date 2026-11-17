import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';

/// Top Bar matching home_screen.dart:L22-L30 (Figma Node 1:2261)
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, required this.controller, required this.isDark});

  final HomeController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? Colors.white : const Color(0xFF111111);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Row(
            children: [
              ShimmerBox(width: 53.w, height: 53.w, shape: BoxShape.circle),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 80.w, height: 12.h, radius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 120.w, height: 18.h, radius: 4.r),
                  ],
                ),
              ),
              ShimmerBox(width: 24.w, height: 24.w, radius: 4.r),
              SizedBox(width: 16.w),
              ShimmerBox(width: 24.w, height: 24.w, radius: 4.r),
            ],
          );
        }

        return Row(
          children: [
            _buildAvatar(controller, isDark),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.greeting.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? const Color(0xFFA0A0A0)
                          : const Color(0xFF848484),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    controller.userName.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF111111),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: controller.onBookmarkTap,
              icon: SvgPicture.asset(
                'assets/icons/bookmark-01.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              onPressed: controller.onNotificationTap,
              icon: SvgPicture.asset(
                'assets/icons/notification-01.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAvatar(HomeController controller, bool isDark) {
    final profileImg = controller.profileImage.value;
    final hasImage = profileImg != null && profileImg.trim().isNotEmpty;

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(26.5.r),
        child: CachedNetworkImage(
          imageUrl: _formatImageUrl(profileImg),
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              ShimmerBox(width: 53.w, height: 53.w, shape: BoxShape.circle),
          errorWidget: (context, url, error) =>
              _buildInitialsAvatar(controller.userInitials.value, isDark),
        ),
      );
    }

    return _buildInitialsAvatar(controller.userInitials.value, isDark);
  }

  Widget _buildInitialsAvatar(String initials, bool isDark) {
    return Container(
      width: 53.w,
      height: 53.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF222222) : const Color(0xFFEAEAEA),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  String _formatImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return trimmed.replaceFirst('http://', 'https://');
    }
    return trimmed;
  }
}
