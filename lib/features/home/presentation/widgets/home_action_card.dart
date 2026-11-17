import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Image-backed action card used for the three primary home actions.
class HomeActionCard extends StatefulWidget {
  const HomeActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageAsset,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String imageAsset;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  State<HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<HomeActionCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24.r);

    return AnimatedScale(
      scale: _isPressed ? 0.975 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: AspectRatio(
        // All three background assets are 720 x 288 (2.5:1).
        // Keeping this ratio prevents the artwork from being cropped.
        aspectRatio: 2.5,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              borderRadius: borderRadius,
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // The assets contain a small transparent edge. A subtle
                  // scale removes that edge without changing the artwork.
                  Transform.scale(
                    scale: 1.06,
                    child: Image.asset(widget.imageAsset, fit: BoxFit.fill),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.15,
                            shadows: const [
                              Shadow(color: Colors.black26, blurRadius: 8),
                            ],
                          ),
                        ),
                        SizedBox(height: 3.h),
                        SizedBox(
                          width: 170.w,
                          child: Text(
                            widget.subtitle,
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 13.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  width: 1.1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.icon,
                                    color: const Color(0xFF17202A),
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    widget.title == 'Scan Equipment'
                                        ? 'Start Scanning'
                                        : 'View Now',
                                    style: TextStyle(
                                      color: const Color(0xFF17202A),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: const Color(0xFF17202A),
                                    size: 15.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
