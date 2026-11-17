import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/browse_workouts_controller.dart';
import 'package:hawiisaac/features/home/model/browse_workout_item.dart';
import 'package:hawiisaac/features/home/presentation/widgets/browse_workouts_widgets.dart';
import 'package:hawiisaac/features/scan/presentation/screens/exercise_detail_view.dart';

class BrowseWorkoutsScreen extends StatelessWidget {
  const BrowseWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BrowseWorkoutsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.blackColor,
            size: 21.r,
          ),
          onPressed: Get.back,
        ),
        centerTitle: true,
        title: Text(
          'Browse Workouts',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.blackColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.h),
          BrowseWorkoutsFilterBar(controller: controller),
          SizedBox(height: 6.h),
          Expanded(
            child: BrowseWorkoutsList(
              controller: controller,
              onWorkoutTap: _openWorkout,
            ),
          ),
        ],
      ),
    );
  }

  void _openWorkout(BrowseWorkoutItem workout) {
    Get.to(
      () => const ExerciseDetailView(),
      arguments: workout.detailArguments,
    );
  }
}
