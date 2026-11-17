import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';

/// Greeting Header: "Good morning! / What would you like to do today?"
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.controller,
    required this.isDark,
  });

  final HomeController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final greeting = controller.greeting.value.trim();
          final title = greeting.isNotEmpty ? '$greeting!' : 'Good morning!';

          return Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111111),
              letterSpacing: -0.4,
              height: 1.2,
            ),
          );
        }),
        SizedBox(height: 6.h),
        Text(
          'What would you like to do today?',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B7280),
            letterSpacing: -0.2,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
