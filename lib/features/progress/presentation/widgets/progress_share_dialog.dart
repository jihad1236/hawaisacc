import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/profile/services/current_user_service.dart';
import 'package:hawiisaac/features/progress/controller/progress_controller.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:share_plus/share_plus.dart';

class ProgressShareDialog extends StatefulWidget {
  const ProgressShareDialog({super.key, required this.controller});

  final ProgressController controller;

  static Future<void> show(
    BuildContext context,
    ProgressController controller,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => ProgressShareDialog(controller: controller),
    );
  }

  @override
  State<ProgressShareDialog> createState() => _ProgressShareDialogState();
}

class _ProgressShareDialogState extends State<ProgressShareDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  // final GlobalKey _shareButtonKey = GlobalKey();
  final bool _isSharing = false;
  bool _isSaving = false;
  String _userHandle = '';

  @override
  void initState() {
    super.initState();
    _loadUserHandle();
  }

  Future<void> _loadUserHandle() async {
    // 1. Check cached StorageService username
    if (StorageService.username.isNotEmpty) {
      if (mounted) setState(() => _userHandle = StorageService.username);
      return;
    }

    // 2. Fetch from CurrentUserService
    try {
      final user = await CurrentUserService().getProfile();
      final name = user.username.isNotEmpty ? user.username : user.displayName;
      if (name.isNotEmpty) {
        await StorageService.saveUsername(name);
        if (mounted) setState(() => _userHandle = name);
        return;
      }
    } catch (_) {}

    // Fallback if unavailable
    if (mounted && _userHandle.isEmpty) {
      setState(() => _userHandle = 'user');
    }
  }

  String get _formattedHandle {
    if (_userHandle.isEmpty) return '@user';
    final clean = _userHandle.trim();
    return clean.startsWith('@') ? clean : '@$clean';
  }

  String get _monthYear {
    final range = widget.controller.dateRange.value.trim();
    if (range.isNotEmpty) {
      return range;
    }
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  String _getStatValue(String label, String fallback) {
    for (final card in widget.controller.statCards) {
      if (card['label'] == label && (card['value']?.isNotEmpty ?? false)) {
        return card['value']!;
      }
    }
    return fallback;
  }

  Map<String, String> _getStatData(String label) {
    for (final card in widget.controller.statCards) {
      if (card['label'] == label) return card;
    }
    return {};
  }

  /// Compact volume formatting (e.g., 48,200kg -> 48.2k kg)
  String _formatCompactVolume(String rawVolume, String unit) {
    final clean = rawVolume
        .replaceAll(',', '')
        .replaceAll(unit, '')
        .replaceAll('kg', '')
        .replaceAll('lbs', '')
        .trim();

    final num? val = num.tryParse(clean);
    if (val == null) {
      return rawVolume.endsWith(unit) ? rawVolume : '$rawVolume$unit';
    }

    if (val >= 1000000) {
      final formatted = (val / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return '${formatted}M $unit';
    } else if (val >= 1000) {
      final formatted = (val / 1000).toStringAsFixed(1).replaceAll('.0', '');
      return '${formatted}k $unit';
    } else {
      return '${val.toInt()} $unit';
    }
  }

  /// Formats trend labels cleanly without repeating arrows
  Widget _buildTrendLabel(String rawChange, String trendDirection) {
    var clean = rawChange.trim();
    if (clean.isEmpty) return const SizedBox.shrink();

    // Remove existing arrows / signs to prevent double arrows like "↑ → Stable"
    clean = clean
        .replaceAll('↑', '')
        .replaceAll('↓', '')
        .replaceAll('→', '')
        .replaceAll('+', '')
        .trim();

    final isStable =
        trendDirection.toLowerCase() == 'stable' ||
        clean.toLowerCase().contains('stable');
    final isDown =
        trendDirection.toLowerCase() == 'down' || clean.startsWith('-');

    final String displayText;
    final Color textColor;
    final Color glowColor;

    if (isStable) {
      displayText = '→ Stable';
      textColor = const Color(0xFFB0B0B0);
      glowColor = Colors.transparent;
    } else if (isDown) {
      final val = clean.replaceAll('-', '').trim();
      displayText = '↓ $val';
      textColor = const Color(0xFFFF5252);
      glowColor = const Color(0xFFFF5252).withValues(alpha: 0.3);
    } else {
      displayText = '↑ $clean';
      textColor = const Color(0xFF00FF44);
      glowColor = const Color(0xFF00FF44).withValues(alpha: 0.35);
    }

    return Text(
      displayText,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.2,
        shadows: [
          if (glowColor != Colors.transparent)
            Shadow(color: glowColor, blurRadius: 8),
          Shadow(
            color: Colors.black.withValues(alpha: 0.8),
            offset: const Offset(0, 1.5),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _capturePngBytes() async {
    try {
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not locate render boundary.');
      }

      // 3.5x pixelRatio ensures crisp, high-resolution transparent output
      final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to generate PNG image data.');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing progress PNG: $e');
      rethrow;
    }
  }

  /// Request permissions cleanly on both Android & iOS
  Future<bool> _requestStorageAndPhotoPermissions() async {
    try {
      if (Platform.isIOS) {
        // Gal owns the Photos permission flow on iOS. This is important for
        // saving into the HYKX album and avoids relying on optional
        // permission_handler photo macros in the host app.
        var hasAccess = await Gal.hasAccess(toAlbum: true);
        if (!hasAccess) {
          hasAccess = await Gal.requestAccess(toAlbum: true);
        }
        if (hasAccess) return true;

        if (mounted) {
          _showSettingsDialog('Photo Library');
        }
        return false;
      } else if (Platform.isAndroid) {
        // Modern Android (API 33+) does not need WRITE_EXTERNAL_STORAGE for MediaStore/Gal.
        // For older Android versions (API <= 32), check storage permission:
        var status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
        if (status.isGranted) return true;

        // Check photos permission (Android 13+)
        var photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          photosStatus = await Permission.photos.request();
        }
        if (photosStatus.isGranted) return true;

        // If permanently denied on older android:
        if (status.isPermanentlyDenied && photosStatus.isPermanentlyDenied) {
          _showSettingsDialog('Storage');
          return false;
        }

        return true;
      }
    } catch (e) {
      debugPrint('Permission check error: $e');
    }
    return true;
  }

  void _showSettingsDialog(String permissionName) {
    if (!mounted) return;
    Get.defaultDialog(
      title: '$permissionName Permission Needed',
      titleStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E1E24),
      middleText:
          'Please grant $permissionName permission in app settings to save progress cards.',
      middleTextStyle: TextStyle(fontSize: 13.sp, color: Colors.white70),
      textConfirm: 'Open Settings',
      textCancel: 'Cancel',
      confirmTextColor: Colors.black,
      cancelTextColor: Colors.white70,
      buttonColor: AppColors.primaryColor,
      onConfirm: () {
        Get.back();
        openAppSettings();
      },
    );
  }

  /// Stores a permanent copy in the device's internal storage (both Android and iOS)
  Future<File?> _saveToInternalStorage(Uint8List bytes) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final internalHykxDir = Directory('${appDocDir.path}/HYKX');
      if (!internalHykxDir.existsSync()) {
        await internalHykxDir.create(recursive: true);
      }
      final filename =
          'hykx_progress_${DateTime.now().millisecondsSinceEpoch}.png';
      final internalFile = File('${internalHykxDir.path}/$filename');
      await internalFile.writeAsBytes(bytes);
      debugPrint('Saved to internal app storage: ${internalFile.path}');

      // On Android, also attempt saving directly into public Pictures/HYKX
      if (Platform.isAndroid) {
        try {
          final publicPicturesDir = Directory(
            '/storage/emulated/0/Pictures/HYKX',
          );
          if (!publicPicturesDir.existsSync()) {
            await publicPicturesDir.create(recursive: true);
          }
          final publicFile = File('${publicPicturesDir.path}/$filename');
          await publicFile.writeAsBytes(bytes);
          debugPrint('Saved to public Pictures directory: ${publicFile.path}');
        } catch (e) {
          debugPrint('Could not write to public Pictures directly: $e');
        }
      }

      return internalFile;
    } catch (e) {
      debugPrint('Error saving to internal storage: $e');
      return null;
    }
  }

  // Future<void> _shareTransparentImage() async {
  //   if (_isSharing || _isSaving) return;

  //   setState(() => _isSharing = true);

  //   try {
  //     final bytes = await _capturePngBytes();
  //     if (bytes == null || !mounted) return;

  //     final tempDir = await getTemporaryDirectory();
  //     final tempFile = File(
  //       '${tempDir.path}/hykx_progress_${DateTime.now().millisecondsSinceEpoch}.png',
  //     );
  //     await tempFile.writeAsBytes(bytes);

  //     if (!mounted) return;

  //     final shareButton =
  //         _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
  //     final sharePositionOrigin = shareButton != null && shareButton.hasSize
  //         ? shareButton.localToGlobal(Offset.zero) & shareButton.size
  //         : null;

  //     await Share.shareXFiles(
  //       [
  //         XFile(
  //           tempFile.path,
  //           mimeType: 'image/png',
  //           name: 'progress_card.png',
  //         ),
  //       ],
  //       text: 'My HYKX Workout Progress',
  //       sharePositionOrigin: sharePositionOrigin,
  //     );
  //   } catch (e) {
  //     debugPrint('Error sharing transparent progress image: $e');
  //     AppLoadingService.showError('Share Error', 'Could not export image: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isSharing = false);
  //     }
  //   }
  // }

  Future<void> _saveToGallery() async {
    if (_isSharing || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // 1. Check and request OS permissions
      final hasPerm = await _requestStorageAndPhotoPermissions();
      if (!hasPerm) return;

      // 2. Capture high-res transparent PNG bytes
      final bytes = await _capturePngBytes();
      if (bytes == null || !mounted) return;

      // 3. Save to phone internal storage (always guaranteed)
      final internalFile = await _saveToInternalStorage(bytes);

      // 4. Save to System Gallery / Photos via Gal
      bool savedToGallery = false;
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/hykx_progress_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await tempFile.writeAsBytes(bytes);

        // Gal permission check
        try {
          final galAccess = await Gal.hasAccess(toAlbum: true);
          if (!galAccess) {
            await Gal.requestAccess(toAlbum: true);
          }
        } catch (_) {}

        await Gal.putImage(tempFile.path, album: 'HYKX');
        savedToGallery = true;
      } on MissingPluginException {
        debugPrint(
          'Gal plugin platform channel missing; saved to internal storage.',
        );
      } on GalException catch (e) {
        debugPrint('GalException saving to gallery: ${e.type.message}');
      } catch (e) {
        debugPrint('Gal export error: $e');
      }

      if (!mounted) return;

      if (savedToGallery) {
        AppLoadingService.showSuccess(
          'Saved to Gallery',
          'Progress image saved to your phone Gallery and internal storage!',
        );
      } else if (internalFile != null) {
        AppLoadingService.showSuccess(
          'Saved to Storage',
          'Progress image saved to phone storage: HYKX',
        );
      } else {
        AppLoadingService.showError(
          'Save Failed',
          'Could not save image to phone storage.',
        );
      }
    } catch (e) {
      debugPrint('Error saving progress image: $e');
      AppLoadingService.showError('Save Failed', 'Could not save image: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460.w,
          maxHeight: MediaQuery.sizeOf(context).height - 48.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131316),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFF2A2A30), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 35,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.insights_rounded,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Progress Card',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Transparent PNG • High Resolution',
                              style: TextStyle(
                                color: const Color(0xFF8E8E93),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFF232328), height: 1),

              // Keep the action row visible while allowing the preview to scroll
              // on compact iPhone screens.
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 26.h,
                        horizontal: 22.w,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0C0C0E), Color(0xFF141418)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: const Color(0xFF26262D),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        // RepaintBoundary captures the full card, even when
                        // the preview is scrolled inside the dialog.
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: Container(
                            color: Colors.transparent,
                            child: _buildProgressContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Action Buttons: Save to Gallery & Share
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                child: Row(
                  children: [
                    // Save to Gallery Button
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: OutlinedButton.icon(
                          onPressed: (_isSharing || _isSaving)
                              ? null
                              : _saveToGallery,
                          icon: _isSaving
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.file_download_outlined,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save to Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF33333D),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            backgroundColor: const Color(0xFF1B1B20),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    // Share Button
                    // Expanded(
                    //   child: SizedBox(
                    //     key: _shareButtonKey,
                    //     height: 50.h,
                    //     child: ElevatedButton.icon(
                    //       onPressed: (_isSharing || _isSaving)
                    //           ? null
                    //           : _shareTransparentImage,
                    //       icon: _isSharing
                    //           ? SizedBox(
                    //               width: 18.w,
                    //               height: 18.w,
                    //               child: const CircularProgressIndicator(
                    //                 strokeWidth: 2,
                    //                 color: Colors.black,
                    //               ),
                    //             )
                    //           : Icon(
                    //               Icons.ios_share_rounded,
                    //               size: 20.sp,
                    //               color: Colors.black,
                    //             ),
                    //       label: Text(
                    //         _isSharing ? 'Sharing...' : 'Share',
                    //         style: TextStyle(
                    //           color: Colors.black,
                    //           fontSize: 14.sp,
                    //           fontWeight: FontWeight.w700,
                    //         ),
                    //       ),
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: AppColors.primaryColor,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(14.r),
                    //         ),
                    //         elevation: 0,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the high-contrast progress card matching the reference design
  Widget _buildProgressContent() {
    final workoutsCount = _getStatValue('Workout', '0');

    final durationData = _getStatData('Avg Duration');
    final durationVal = durationData['value'] ?? '0m';
    final durationChange = durationData['change'] ?? '';
    final durationTrend = durationData['trendDirection'] ?? 'stable';

    final rawVolume = widget.controller.totalVolume.value.isNotEmpty
        ? widget.controller.totalVolume.value
        : '0';
    final volumeUnit = widget.controller.volumeUnit.value.isNotEmpty
        ? widget.controller.volumeUnit.value
        : 'kg';
    final compactVolume = _formatCompactVolume(rawVolume, volumeUnit);

    final rawVolumeDelta = widget.controller.volumeDeltaDisplay.value;
    final volumeTrend = widget.controller.volumeTrendDirection.value;

    final setsCount = _getStatValue('Total Sets', '0');

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 340.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range / Month
          _outlinedText(
            text: _monthYear,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            strokeWidth: 2.6,
          ),
          SizedBox(height: 2.h),

          // Big Workouts Title
          _outlinedText(
            text: 'Workouts',
            fontSize: 42.sp,
            fontWeight: FontWeight.w900,
            strokeWidth: 4.0,
            letterSpacing: -1.0,
          ),
          SizedBox(height: 24.h),

          // Row 1: Workouts & Duration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workouts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _outlinedText(
                      text: 'Workouts',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 2.2,
                    ),
                    _outlinedText(
                      text: workoutsCount,
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 3.5,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _outlinedText(
                      text: 'Duration',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 2.2,
                    ),
                    _outlinedText(
                      text: durationVal,
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 3.0,
                    ),
                    _buildTrendLabel(durationChange, durationTrend),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 22.h),

          // Row 2: Volume & Sets
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Volume
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _outlinedText(
                      text: 'Volume',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 2.2,
                    ),
                    _outlinedText(
                      text: compactVolume,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 3.2,
                    ),
                    _buildTrendLabel(rawVolumeDelta, volumeTrend),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Sets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _outlinedText(
                      text: 'Sets',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 2.2,
                    ),
                    _outlinedText(
                      text: setsCount,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w900,
                      strokeWidth: 3.5,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 28.h),

          // Footer: HYKX Logo on left & Real Username on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HYKX Logo
              Image.asset(
                'assets/icons/hykx_logo.png',
                height: 26.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _outlinedText(
                  text: 'HYKX',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  strokeWidth: 3.0,
                ),
              ),

              // Current logged-in user handle
              _outlinedText(
                text: _formattedHandle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                strokeWidth: 2.2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Outlined text generator: white inside with crisp dark outline and soft shadow
  Widget _outlinedText({
    required String text,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w900,
    double strokeWidth = 3.0,
    double letterSpacing = -0.5,
  }) {
    return Stack(
      children: [
        // Dark Outline / Stroke
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = const Color(0xFF1E1E22),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: const Offset(0, 3),
                blurRadius: 4.5,
              ),
            ],
          ),
        ),
        // Solid White Text Fill
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
