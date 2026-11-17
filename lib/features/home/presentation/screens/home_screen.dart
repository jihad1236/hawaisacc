import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';
import 'package:hawiisaac/features/home/presentation/widgets/workout_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70.h,
        titleSpacing: 0,
        title: _topBar(context, controller, isDark),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => controller.fetchDashboard(isRefresh: true),
          child: Obx(() {
            final hasError =
                controller.errorMessage.value.isNotEmpty &&
                controller.forYouPlans.isEmpty &&
                controller.browsePlans.isEmpty &&
                controller.expertTips.isEmpty &&
                controller.trendingPlans.isEmpty &&
                !controller.isLoading.value;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      _workoutsHeader(context, isDark),
                      SizedBox(height: 16.h),
                      _workoutTabs(controller, isDark),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
                if (hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _errorView(context, controller, isDark),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 120.h),
                      child: _contentBody(context, controller, isDark),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ─── Top Bar (Figma Node 1:2261) ──────────────────────────────────

  Widget _topBar(BuildContext context, HomeController controller, bool isDark) {
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
            _avatar(controller, isDark),
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

  Widget _avatar(HomeController controller, bool isDark) {
    final profileImg = controller.profileImage.value;
    final hasImage = profileImg != null && profileImg.trim().isNotEmpty;

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(26.5.r),
        child: CachedNetworkImage(
          imageUrl: _formatImageUrl(profileImg),
          width: 53.w,
          height: 53.w,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              ShimmerBox(width: 53.w, height: 53.w, shape: BoxShape.circle),
          errorWidget: (context, url, error) =>
              _initialsAvatar(controller.userInitials.value, isDark),
        ),
      );
    }

    return _initialsAvatar(controller.userInitials.value, isDark);
  }

  Widget _initialsAvatar(String initials, bool isDark) {
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

  // ─── Workouts Header (Figma Node 1:2190) ──────────────────────────

  Widget _workoutsHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        'Workouts',
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF111111),
          height: 1.2,
        ),
      ),
    );
  }

  // ─── Tabs (Figma Node 1:2192) ─────────────────────────────────────

  Widget _workoutTabs(HomeController controller, bool isDark) {
    final borderColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFEAEAEA);
    final activeColor = isDark ? Colors.white : const Color(0xFF111111);
    final inactiveColor = isDark
        ? const Color(0xFFA0A0A0)
        : const Color(0xFF848484);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: controller.tabs.asMap().entries.map((entry) {
              final isSelected = entry.key == controller.selectedTabIndex.value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.onTabSelected(entry.key),
                child: Padding(
                  padding: EdgeInsets.only(right: 24.w),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected ? activeColor : inactiveColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.h,
                        width: isSelected ? 48.w : 0,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── Content Body ─────────────────────────────────────────────────

  Widget _contentBody(
    BuildContext context,
    HomeController controller,
    bool isDark,
  ) {
    if (controller.isLoading.value) {
      if (controller.selectedTabIndex.value == 0) {
        return Column(
          children: [
            _workoutGroupSkeleton(context, isDark),
            SizedBox(height: 24.h),
            _workoutGroupSkeleton(context, isDark),
          ],
        );
      }
      return _verticalListSkeleton(context, isDark);
    }

    final currentTab = controller.selectedTab.toLowerCase();

    // ── Tab: Browse ─────────────────────────────────────────────────
    if (currentTab == 'browse') {
      if (controller.browsePlans.isEmpty) {
        return _emptyTabWidget(
          icon: Icons.explore_outlined,
          title: 'No workout plans found',
          subtitle: 'Browse workout plans will appear here once available.',
          isDark: isDark,
          onRefresh: () => controller.fetchDashboard(isRefresh: true),
        );
      }

      return _verticalWorkoutList(
        context,
        title: 'Browse Workouts',
        workouts: controller.browsePlans,
        controller: controller,
        isDark: isDark,
      );
    }

    // ── Tab: Expert Tips ────────────────────────────────────────────
    if (currentTab.contains('expert') || currentTab.contains('tip')) {
      if (controller.expertTips.isEmpty) {
        return _emptyTabWidget(
          icon: Icons.lightbulb_outline_rounded,
          title: 'No expert tips found',
          subtitle: 'Expert training tips and guides will show up here.',
          isDark: isDark,
          onRefresh: () => controller.fetchDashboard(isRefresh: true),
        );
      }

      return _verticalExpertTipsList(
        context,
        title: 'Expert Tips',
        tips: controller.expertTips,
        controller: controller,
        isDark: isDark,
      );
    }

    // ── Tab: Trending ───────────────────────────────────────────────
    if (currentTab.contains('trend')) {
      if (controller.trendingPlans.isEmpty) {
        return _emptyTabWidget(
          icon: Icons.local_fire_department_outlined,
          title: 'No trending plans found',
          subtitle: 'Trending workout plans will appear here once available.',
          isDark: isDark,
          onRefresh: () => controller.fetchDashboard(isRefresh: true),
        );
      }

      return _verticalWorkoutList(
        context,
        title: 'Trending Workouts',
        workouts: controller.trendingPlans,
        controller: controller,
        isDark: isDark,
      );
    }

    // ── Default Tab: For You (Figma Node 1:2201) ────────────────────
    if (controller.forYouPlans.isEmpty) {
      return _emptyTabWidget(
        icon: Icons.fitness_center_outlined,
        title: 'No plans found for you',
        subtitle: 'Pull down to refresh or check back later for your plans.',
        isDark: isDark,
        onRefresh: () => controller.fetchDashboard(isRefresh: true),
      );
    }

    // Split for_you_plans into "Warm-Up Workouts" & "Perfect For Home" as in Figma
    final allPlans = controller.forYouPlans;
    final warmUpList = <DashboardWorkoutItem>[];
    final perfectList = <DashboardWorkoutItem>[];

    final hasWarmUpCategory = allPlans.any(
      (p) => (p.categoryName ?? '').toLowerCase().contains('warm'),
    );

    if (hasWarmUpCategory) {
      for (final plan in allPlans) {
        if ((plan.categoryName ?? '').toLowerCase().contains('warm')) {
          warmUpList.add(plan);
        } else {
          perfectList.add(plan);
        }
      }
    } else {
      final half = (allPlans.length / 2).ceil();
      warmUpList.addAll(allPlans.take(half));
      perfectList.addAll(allPlans.skip(half));
    }

    return Column(
      children: [
        if (warmUpList.isNotEmpty)
          _workoutGroup(
            context,
            title: 'Warm-Up Workouts',
            workouts: warmUpList,
            controller: controller,
            isDark: isDark,
          ),
        if (warmUpList.isNotEmpty && perfectList.isNotEmpty)
          SizedBox(height: 24.h),
        if (perfectList.isNotEmpty)
          _workoutGroup(
            context,
            title: 'Perfect For Home',
            workouts: perfectList,
            controller: controller,
            isDark: isDark,
          ),
      ],
    );
  }

  // ─── Workout Group (Figma Node 1:2202) ────────────────────────────

  Widget _workoutGroup(
    BuildContext context, {
    required String title,
    required List<DashboardWorkoutItem> workouts,
    required HomeController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111111),
              height: 1.2,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 280.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: workouts.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) => _workoutCard(
              context,
              workout: workouts[index],
              controller: controller,
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Workout Card (Figma Node 1:2205 - 250px x 280px) ─────────────

  Widget _workoutCard(
    BuildContext context, {
    required DashboardWorkoutItem workout,
    required HomeController controller,
    required bool isDark,
  }) {
    return Obx(() {
      final isBookmarked = controller.isWorkoutBookmarked(workout.id);
      return WorkoutCard(
        workout: workout,
        isDark: isDark,
        isBookmarked: isBookmarked,
        width: 250,
        height: 280,
        onTap: () => controller.onWorkoutTap(workout),
        onBookmarkTap: () => controller.toggleWorkoutBookmark(workout),
      );
    });
  }

  // ─── Vertical Workout List (Single Item Per Row) ─────────────────

  Widget _verticalWorkoutList(
    BuildContext context, {
    required String title,
    required List<DashboardWorkoutItem> workouts,
    required HomeController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111111),
              height: 1.2,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: workouts.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return Obx(() {
              final isBookmarked = controller.isWorkoutBookmarked(workout.id);
              return WorkoutCard(
                workout: workout,
                isDark: isDark,
                isBookmarked: isBookmarked,
                width: double.infinity,
                height: 240,
                onTap: () => controller.onWorkoutTap(workout),
                onBookmarkTap: () => controller.toggleWorkoutBookmark(workout),
              );
            });
          },
        ),
      ],
    );
  }

  // ─── Vertical Expert Tips List (Single Item Per Row) ─────────────

  Widget _verticalExpertTipsList(
    BuildContext context, {
    required String title,
    required List<DashboardExpertTip> tips,
    required HomeController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111111),
              height: 1.2,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: tips.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) => _expertTipFigmaCard(
            context,
            tip: tips[index],
            controller: controller,
            isDark: isDark,
            width: double.infinity,
            height: 240,
          ),
        ),
      ],
    );
  }


  Widget _expertTipFigmaCard(
    BuildContext context, {
    required DashboardExpertTip tip,
    required HomeController controller,
    required bool isDark,
    double? width = 250,
    double? height = 280,
  }) {
    final hasTipImage = tip.image != null && tip.image!.trim().isNotEmpty;
    final hasEquipImage =
        tip.equipmentDetails.isNotEmpty &&
        tip.equipmentDetails.first.image != null &&
        tip.equipmentDetails.first.image!.trim().isNotEmpty;
    final effectiveImage = hasTipImage
        ? tip.image!
        : (hasEquipImage ? tip.equipmentDetails.first.image! : null);
    final equipName = tip.equipmentDetails.isNotEmpty
        ? tip.equipmentDetails.first.name
        : '';
    final cardWidth = width == double.infinity ? double.infinity : width?.w;
    final cardHeight = height?.h;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.onExpertTipTap(tip),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (effectiveImage != null && effectiveImage.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: _formatImageUrl(effectiveImage),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => AppShimmer(
                    child: Container(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      _tipCardPlaceholder(tip, isDark),
                )
              else
                _tipCardPlaceholder(tip, isDark),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),

              // Top Badge: Content Type pill
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    tip.contentType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Bottom Details
              Positioned(
                bottom: 14.h,
                left: 12.w,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tip.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      equipName.isNotEmpty ? equipName : 'Expert Guide',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Image Fallback Placeholders ──────────────────────────────────

  Widget _tipCardPlaceholder(DashboardExpertTip tip, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2638), Color(0xFF10141E)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lightbulb_outline_rounded,
          size: 48.sp,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  // ─── Skeleton Loading (Figma Aligned) ─────────────────────────────

  Widget _workoutGroupSkeleton(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ShimmerBox(width: 180.w, height: 20.h, radius: 6.r),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 280.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 2,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) =>
                ShimmerBox(width: 250.w, height: 280.h, radius: 8.r),
          ),
        ),
      ],
    );
  }

  Widget _verticalListSkeleton(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 180.w, height: 20.h, radius: 6.r),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) =>
                ShimmerBox(width: double.infinity, height: 240.h, radius: 8.r),
          ),
        ],
      ),
    );
  }

  // ─── Modern Empty State ───────────────────────────────────────────

  Widget _emptyTabWidget({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onRefresh,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF2F4F7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E2E2E)
                      : const Color(0xFFE4E7EC),
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                size: 30.sp,
                color: isDark
                    ? const Color(0xFF777777)
                    : const Color(0xFF98A2B3),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? const Color(0xFFA0A0A0)
                    : const Color(0xFF667085),
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? Colors.white
                    : const Color(0xFF111111),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF333333)
                      : const Color(0xFFD0D5DD),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 16.sp),
              label: Text(
                'Refresh',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Modern Error View ────────────────────────────────────────────

  Widget _errorView(
    BuildContext context,
    HomeController controller,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? const Color(0xFF3B1D1D) : const Color(0xFFFFECEC),
                    isDark ? const Color(0xFF261212) : const Color(0xFFFFDADA),
                  ],
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.redAccent.withValues(alpha: 0.3)
                      : Colors.red.shade200,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 38.sp,
                  color: isDark
                      ? Colors.redAccent.shade100
                      : Colors.red.shade600,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Failed to load dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Unable to connect to the server. Please check your internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? const Color(0xFFA0A0A0)
                    : const Color(0xFF666666),
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => controller.fetchDashboard(),
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
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  String _formatImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return trimmed.replaceFirst('http://', 'https://');
    }
    return trimmed;
  }
}
