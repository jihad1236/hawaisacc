import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/content_details_controller.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';
import 'package:intl/intl.dart';

class ContentDetailsScreen extends StatelessWidget {
  const ContentDetailsScreen({super.key});

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  String _formatImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return trimmed.replaceFirst('http://', 'https://');
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContentDetailsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.blackColor;
    final dividerColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE7E7E7);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: textColor,
            ),
          ),
          centerTitle: true,
          title: Obx(() {
            final tip = controller.expertTip.value;
            final content = controller.content.value;
            final title = tip != null
                ? (tip.contentType.isNotEmpty
                    ? '${tip.contentType[0].toUpperCase()}${tip.contentType.substring(1)}'
                    : 'Expert Tip')
                : (content?.feedLabel ?? 'Guide');

            return Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            );
          }),
          actions: [
            Obx(() {
              final isBookmarked = controller.isBookmarked.value;
              final isBookmarking = controller.isBookmarking.value;

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  onPressed: isBookmarking ? null : controller.onBookmarkTap,
                  icon: isBookmarking
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.white : AppColors.blackColor,
                          ),
                        )
                      : Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked
                              ? AppColors.primaryColor
                              : textColor,
                          size: 24.sp,
                        ),
                ),
              );
            }),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Divider(height: 1.h, thickness: 1.h, color: dividerColor),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final tip = controller.expertTip.value;
          final content = controller.content.value;

          if (controller.isLoading.value && tip == null && content == null) {
            return _loadingSkeleton(context, isDark);
          }

          if (tip != null) {
            return _buildExpertTipBody(context, tip, isDark, textColor);
          }

          if (content != null) {
            return _buildContentItemBody(context, content, isDark, textColor);
          }

          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48.sp,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    controller.errorMessage.value.isEmpty
                        ? 'Guide or tip not found'
                        : controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      final args = Get.arguments;
                      if (args is int) {
                        controller.fetchExpertTipDetail(args);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: const Color(0xFF111111),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
          child: Obx(() {
            final isBookmarked = controller.isBookmarked.value;
            final isBookmarking = controller.isBookmarking.value;
            final hasData =
                controller.expertTip.value != null || controller.content.value != null;

            return SizedBox(
              height: 54.h,
              child: ElevatedButton.icon(
                onPressed: hasData && !isBookmarking
                    ? controller.onBookmarkTap
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBookmarked
                      ? (isDark ? const Color(0xFF242426) : const Color(0xFF111111))
                      : AppColors.primaryColor,
                  foregroundColor: isBookmarked ? Colors.white : const Color(0xFF111111),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    side: isBookmarked && isDark
                        ? BorderSide(
                            color: AppColors.primaryColor.withValues(alpha: 0.5),
                            width: 1.2,
                          )
                        : BorderSide.none,
                  ),
                ),
                icon: isBookmarking
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isBookmarked ? Colors.white : const Color(0xFF111111),
                        ),
                      )
                    : Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 20.sp,
                        color: isBookmarked
                            ? AppColors.primaryColor
                            : const Color(0xFF111111),
                      ),
                label: Text(
                  isBookmarking
                      ? 'Updating...'
                      : (isBookmarked ? 'Bookmarked' : 'Bookmark Guide'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Expert Tip Body ───────────────────────────────────────────────

  Widget _buildExpertTipBody(
    BuildContext context,
    DashboardExpertTip tip,
    bool isDark,
    Color textColor,
  ) {
    final effectiveImage = (tip.image != null && tip.image!.trim().isNotEmpty)
        ? tip.image
        : (tip.equipmentDetails.isNotEmpty
            ? tip.equipmentDetails.first.image
            : null);
    final formattedDate = _formatDate(tip.createdAt);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Image / Banner
          _buildHeroImage(context, effectiveImage, tip, isDark),
          SizedBox(height: 18.h),

          // 2. Metadata Tags Row
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Content Type Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2638)
                      : AppColors.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _contentTypeIcon(tip.contentType),
                      size: 14.sp,
                      color: isDark ? AppColors.primaryColor : const Color(0xFF1A1A1A),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      tip.contentType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: isDark ? AppColors.primaryColor : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              // Date Chip if available
              if (formattedDate.isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Verified Pro Tip Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A2E1E)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13.sp,
                      color: Colors.green.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Verified Guide',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 3. Title
          Text(
            tip.title,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: textColor,
            ),
          ),
          SizedBox(height: 20.h),

          // 4. Description / Guide Content
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF161618)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF28282A)
                    : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Expert Instruction',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  tip.description.isNotEmpty
                      ? tip.description
                      : 'No description provided.',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.6,
                    color: isDark
                        ? const Color(0xFFD1D5DB)
                        : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 5. Equipment Details Section
          if (tip.equipmentDetails.isNotEmpty) ...[
            Text(
              'Equipment Required',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: 12.h),
            ...tip.equipmentDetails.map((equip) {
              return _buildEquipmentCard(context, equip, isDark, textColor);
            }),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  // ─── Equipment Card ────────────────────────────────────────────────

  Widget _buildEquipmentCard(
    BuildContext context,
    DashboardEquipmentDetail equip,
    bool isDark,
    Color textColor,
  ) {
    final hasImage = equip.image != null && equip.image!.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262628) : const Color(0xFFEAEAEA),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Equipment Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 58.w,
              height: 58.w,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: _formatImageUrl(equip.image!),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => AppShimmer(
                        child: Container(
                          color: isDark
                              ? const Color(0xFF222222)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark
                            ? const Color(0xFF242426)
                            : const Color(0xFFF3F4F6),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.grey.shade400,
                          size: 26.sp,
                        ),
                      ),
                    )
                  : Container(
                      color: isDark
                          ? const Color(0xFF242426)
                          : const Color(0xFFF3F4F6),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: Colors.grey.shade400,
                        size: 26.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 14.w),

          // Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equip.title.isNotEmpty ? equip.title : equip.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Standard Gym Equipment',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? const Color(0xFFA0A0A0)
                        : const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),

          // Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Equipment',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryColor : const Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Image Widget ─────────────────────────────────────────────

  Widget _buildHeroImage(
    BuildContext context,
    String? imageUrl,
    DashboardExpertTip tip,
    bool isDark,
  ) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: _formatImageUrl(imageUrl),
                fit: BoxFit.cover,
                placeholder: (context, url) => AppShimmer(
                  child: Container(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _tipPlaceholder(tip, isDark),
              )
            else
              _tipPlaceholder(tip, isDark),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),

            // Floating Pill for Content Type
            Positioned(
              top: 14.h,
              left: 14.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
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
          ],
        ),
      ),
    );
  }

  Widget _tipPlaceholder(DashboardExpertTip tip, bool isDark) {
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
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  IconData _contentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'guide':
        return Icons.menu_book_rounded;
      case 'safety':
        return Icons.health_and_safety_outlined;
      case 'article':
        return Icons.article_outlined;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  // ─── Backward-compatible ContentItem Body ──────────────────────────

  Widget _buildContentItemBody(
    BuildContext context,
    ContentItem item,
    bool isDark,
    Color textColor,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey.shade500,
                    size: 42.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          if (item.summary.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              item.summary,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          if (item.body.trim().isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              item.body,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.55,
                color: textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Loading Skeleton ──────────────────────────────────────────────

  Widget _loadingSkeleton(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 210.h, radius: 16),
          SizedBox(height: 18.h),
          const ShimmerBox(width: 120, height: 28, radius: 20),
          SizedBox(height: 16.h),
          const ShimmerBox(width: double.infinity, height: 32, radius: 8),
          SizedBox(height: 8.h),
          const ShimmerBox(width: 240, height: 32, radius: 8),
          SizedBox(height: 18.h),
          const ShimmerBox(width: double.infinity, height: 110, radius: 14),
          SizedBox(height: 20.h),
          const ShimmerBox(width: 160, height: 24, radius: 8),
          SizedBox(height: 12.h),
          const ShimmerBox(width: double.infinity, height: 80, radius: 14),
        ],
      ),
    );
  }
}
