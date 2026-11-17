import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';
import 'package:hawiisaac/features/home/services/content_api_service.dart';

class ContentDetailsController extends GetxController {
  final ContentApiService _contentApiService = ContentApiService();

  final Rxn<DashboardExpertTip> expertTip = Rxn<DashboardExpertTip>();
  final Rxn<ContentItem> content = Rxn<ContentItem>();
  final RxBool isLoading = false.obs;
  final RxBool isBookmarking = false.obs;
  final RxBool isBookmarked = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is DashboardExpertTip) {
      final bookmarked = StorageService.isExpertTipBookmarked(args.id);
      expertTip.value = args.copyWith(isBookmarked: bookmarked);
      isBookmarked.value = bookmarked;
      fetchExpertTipDetail(args.id);
      return;
    }

    if (args is ContentItem) {
      content.value = args;
      isBookmarked.value = args.isBookmarked;
      fetchContentDetail(args.id);
      return;
    }

    if (args is int && args > 0) {
      final bookmarked = StorageService.isExpertTipBookmarked(args);
      isBookmarked.value = bookmarked;
      fetchExpertTipDetail(args);
      return;
    }

    if (args is Map) {
      if (args['tip'] is DashboardExpertTip) {
        final tip = args['tip'] as DashboardExpertTip;
        final bookmarked = StorageService.isExpertTipBookmarked(tip.id);
        expertTip.value = tip.copyWith(isBookmarked: bookmarked);
        isBookmarked.value = bookmarked;
        fetchExpertTipDetail(tip.id);
        return;
      }
      final id = int.tryParse(args['id']?.toString() ?? '') ?? 0;
      if (id > 0) {
        final bookmarked = StorageService.isExpertTipBookmarked(id);
        isBookmarked.value = bookmarked;
        fetchExpertTipDetail(id);
        return;
      }
    }
  }

  Future<void> fetchExpertTipDetail(int id) async {
    if (expertTip.value == null) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final tip = await _contentApiService.getExpertTipById(id);
      final bookmarked = StorageService.isExpertTipBookmarked(id);
      expertTip.value = tip.copyWith(isBookmarked: bookmarked);
      isBookmarked.value = bookmarked;
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      if (expertTip.value == null) {
        AppLoadingService.showError('Expert Tip Error', error.message);
      }
    } catch (e) {
      debugPrint('[ContentDetailsController] Error fetching expert tip: $e');
      if (expertTip.value == null) {
        errorMessage.value = 'Failed to load expert tip details.';
        AppLoadingService.showError('Expert Tip Error', errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchContentDetail(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final item = await _contentApiService.getContentById(id);
      content.value = item;
      isBookmarked.value = item.isBookmarked;
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      AppLoadingService.showError('Content Failed', error.message);
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      AppLoadingService.showError('Content Failed', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onBookmarkTap() async {
    if (isBookmarking.value) return;

    final tip = expertTip.value;
    if (tip != null) {
      isBookmarking.value = true;
      try {
        final newBookmarkedState =
            await StorageService.toggleExpertTipBookmark(tip.id);
        isBookmarked.value = newBookmarkedState;
        expertTip.value = tip.copyWith(isBookmarked: newBookmarkedState);

        AppLoadingService.showSuccess(
          newBookmarkedState ? 'Saved' : 'Removed',
          newBookmarkedState
              ? 'Expert tip added to bookmarks'
              : 'Expert tip removed from bookmarks',
        );
      } catch (e) {
        debugPrint('[ContentDetailsController] Bookmark toggle error: $e');
        AppLoadingService.showError('Bookmark Error', 'Failed to update bookmark.');
      } finally {
        isBookmarking.value = false;
      }
      return;
    }

    final item = content.value;
    if (item == null) return;

    isBookmarking.value = true;
    try {
      final result = item.isBookmarked
          ? await _contentApiService.removeBookmark(item.id)
          : await _contentApiService.addBookmark(item.id);

      content.value = item.copyWith(
        isBookmarked: result.isBookmarked,
        bookmarkCount: result.bookmarkCount,
        myReaction: result.myReaction,
      );
      isBookmarked.value = result.isBookmarked;

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().applyBookmarkResult(result);
      }

      AppLoadingService.showSuccess(
        result.isBookmarked ? 'Saved' : 'Removed',
        result.isBookmarked
            ? 'Content added to bookmarks'
            : 'Content removed from bookmarks',
      );
    } on AuthException catch (error) {
      AppLoadingService.showError('Bookmark Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Bookmark Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isBookmarking.value = false;
    }
  }
}
