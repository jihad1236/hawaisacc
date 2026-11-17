import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/bottom_navigation/controllers/bottom_navigation_controller.dart';
import 'package:hawiisaac/features/home/presentation/widgets/home_action_card.dart';
import 'package:hawiisaac/features/home/presentation/screens/browse_workouts_screen.dart';
import 'package:hawiisaac/features/progress/presentation/screens/progress_screen.dart';
import 'package:hawiisaac/features/scan/presentation/screens/scan_equipment_view.dart';

/// Renders the 3 colorful action buttons: Scan Equipment, Browse Workouts, and My Progress
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Scan Equipment (Vibrant Emerald Green)
        HomeActionCard(
          title: 'Scan Equipment',
          subtitle: 'Use AI to suggest workouts',
          icon: Icons.camera_alt_outlined,
          imageAsset: 'assets/images/img_scan.webp',
          gradientColors: const [Color(0xFF00C853), Color(0xFF009624)],
          shadowColor: const Color(0xFF00C853),
          onTap: _navigateToScanner,
        ),

        SizedBox(height: 16.h),

        // 2. Browse Workouts (Vibrant Royal Blue)
        HomeActionCard(
          title: 'Browse Workouts',
          subtitle: 'Select manually',
          icon: Icons.fitness_center_outlined,
          imageAsset: 'assets/images/img_workout.webp',
          gradientColors: const [Color(0xFF2979FF), Color(0xFF1565C0)],
          shadowColor: const Color(0xFF2979FF),
          onTap: _navigateToWorkouts,
        ),

        SizedBox(height: 16.h),

        // 3. My Progress (Vibrant Purple/Violet)
        HomeActionCard(
          title: 'My Progress',
          subtitle: 'Track & improve',
          icon: Icons.show_chart_outlined,
          imageAsset: 'assets/images/img_progress.webp',
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          shadowColor: const Color(0xFF8B5CF6),
          onTap: _navigateToProgress,
        ),
      ],
    );
  }

  void _navigateToScanner() {
    if (Get.isRegistered<BottomNavigationController>()) {
      Get.find<BottomNavigationController>().changeTab(1);
    } else {
      Get.to(() => const ScanEquipmentView());
    }
  }

  void _navigateToWorkouts() {
    Get.to(() => const BrowseWorkoutsScreen());
  }

  void _navigateToProgress() {
    if (Get.isRegistered<BottomNavigationController>()) {
      Get.find<BottomNavigationController>().changeTab(3);
    } else {
      Get.to(() => const ProgressView());
    }
  }
}
