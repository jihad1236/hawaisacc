import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/authentication/controller/auth_options_controller.dart';

class AuthOptionsView extends StatelessWidget {
  const AuthOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthOptionsController controller = Get.put<AuthOptionsController>(
      AuthOptionsController(),
    );
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.black,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            // Dark mode gym background with dark overlay
            if (isDarkMode) ...[
              Positioned.fill(
                child: Image.asset(
                  'assets/images/start.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.55),
                ),
              ),
            ],

            // Content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            if (isDarkMode)
                              _buildDarkModeHeader(context, controller)
                            else
                              _buildLightModeHeader(context, controller),
                            const Spacer(),
                            _buildAuthButtons(context, controller, isDarkMode),
                            SizedBox(height: 24.h),
                            _buildFooter(context, controller, isDarkMode),
                            SizedBox(height: 28.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Light Mode Header:
  /// Centered HYKX logo and two-line bold black title
  Widget _buildLightModeHeader(
    BuildContext context,
    AuthOptionsController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 120.h),
          _buildLogo(width: 187.w, height: 58.h, isDarkMode: false),
          SizedBox(height: 32.h),
          Obx(
            () => Text(
              controller.tagline.value.contains('\n')
                  ? controller.tagline.value
                  : controller.tagline.value.replaceFirst('Train. ', 'Train.\n'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dark Mode Header:
  /// Compact logo at top with single-line cyan tagline, leaving athlete image visible
  Widget _buildDarkModeHeader(
    BuildContext context,
    AuthOptionsController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 36.h),
          _buildLogo(width: 145.w, height: 45.h, isDarkMode: true),
          SizedBox(height: 12.h),
          Obx(
            () => Text(
              controller.tagline.value.replaceAll('\n', ' '),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1DE8FF),
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Logo builder with fallback support
  Widget _buildLogo({
    required double width,
    required double height,
    required bool isDarkMode,
  }) {
    return Image.asset(
      'assets/icons/hykx_logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/icons/app_icon.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Text(
            'HYKX',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? Colors.white : Colors.black,
              letterSpacing: 2,
            ),
          ),
        );
      },
    );
  }

  /// Auth Buttons section with 16w horizontal padding matching Figma
  Widget _buildAuthButtons(
    BuildContext context,
    AuthOptionsController controller,
    bool isDarkMode,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildAppleButton(context, controller, isDarkMode),
          SizedBox(height: 16.h),
          _buildGoogleButton(context, controller, isDarkMode),
          SizedBox(height: 16.h),
          _buildEmailButton(context, controller, isDarkMode),
        ],
      ),
    );
  }

  /// Generic button container adhering strictly to Figma specifications:
  /// - Light mode: #121212 background, 8px radius, 48px height, white text
  /// - Dark mode: #FFFFFF background, 8px radius, 48px height, 0px 4px 2px rgba(0,0,0,0.25) shadow, #111111 text
  Widget _buttonContainer(
    BuildContext context, {
    required Widget child,
    required VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isDarkMode
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    offset: Offset(0, 4),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildAppleButton(
    BuildContext context,
    AuthOptionsController controller,
    bool isDarkMode,
  ) {
    final Color textColor =
        isDarkMode ? const Color(0xFF111111) : Colors.white;

    return Obx(
      () => _buttonContainer(
        context,
        isDarkMode: isDarkMode,
        onTap: controller.isAppleLoading.value
            ? null
            : controller.onAppleSignUpTapped,
        child: controller.isAppleLoading.value
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2.2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    size: 22.r,
                    color: textColor,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    controller.appleButtonText.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleButton(
    BuildContext context,
    AuthOptionsController controller,
    bool isDarkMode,
  ) {
    final Color textColor =
        isDarkMode ? const Color(0xFF111111) : Colors.white;

    return Obx(
      () => _buttonContainer(
        context,
        isDarkMode: isDarkMode,
        onTap: controller.isGoogleLoading.value
            ? null
            : controller.onGoogleSignUpTapped,
        child: controller.isGoogleLoading.value
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2.2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/google.png',
                    width: 20.r,
                    height: 20.r,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.g_mobiledata_rounded,
                      size: 22.r,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    controller.googleButtonText.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmailButton(
    BuildContext context,
    AuthOptionsController controller,
    bool isDarkMode,
  ) {
    final Color textColor =
        isDarkMode ? const Color(0xFF111111) : Colors.white;

    return Obx(
      () => _buttonContainer(
        context,
        isDarkMode: isDarkMode,
        onTap: controller.isEmailLoading.value
            ? null
            : controller.onEmailSignUpTapped,
        child: controller.isEmailLoading.value
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2.2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/mail-01.svg',
                    width: 20.r,
                    height: 20.r,
                    colorFilter: ColorFilter.mode(
                      textColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    controller.emailButtonText.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Footer: "Already have an account? Log in"
  Widget _buildFooter(
    BuildContext context,
    AuthOptionsController controller,
    bool isDarkMode,
  ) {
    final Color footerTextColor =
        isDarkMode ? Colors.white : const Color(0xFF0C0C0C);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(
          () => Text(
            controller.footerText.value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: footerTextColor,
            ),
          ),
        ),
        SizedBox(width: 5.w),
        GestureDetector(
          onTap: controller.onLogInTapped,
          behavior: HitTestBehavior.opaque,
          child: Obx(
            () => Text(
              controller.loginLinkText.value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00E5FF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

