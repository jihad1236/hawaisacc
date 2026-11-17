import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:hawiisaac/features/home/presentation/widgets/home_today_progress.dart';
import 'package:hawiisaac/features/home/presentation/widgets/home_top_bar.dart';

class HomeSimpleScreen extends StatefulWidget {
  const HomeSimpleScreen({super.key});

  @override
  State<HomeSimpleScreen> createState() => _HomeSimpleScreenState();
}

class _HomeSimpleScreenState extends State<HomeSimpleScreen> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    final hadExistingController = Get.isRegistered<HomeController>();
    controller = Get.put(HomeController());

    // A reused GetX controller does not run onInit again when this screen
    // is opened, so explicitly fetch a fresh Today response in that case.
    if (hadExistingController) {
      controller.fetchTodayProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: HomeTopBar(controller: controller, isDark: isDark),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: controller.refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeTodayProgress(controller: controller),
                const HomeQuickActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
