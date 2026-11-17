import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/profile/controller/profile_controller.dart';
import 'package:hawiisaac/features/profile/model/current_user.dart';
import 'package:hawiisaac/features/profile/services/current_user_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final CurrentUserService _currentUserService = CurrentUserService();

  final RxString name = ''.obs;
  final RxString username = ''.obs;
  final RxString bio = ''.obs;
  final RxString sex = ''.obs;
  final RxString birthday = ''.obs;
  final Rxn<DateTime> selectedDob = Rxn<DateTime>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<CurrentUser> currentUser = Rxn<CurrentUser>();

  final RxString profileImagePath = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String _initialName = '';
  String _initialUsername = '';
  String _initialBio = '';
  String _initialSex = '';
  DateTime? _initialDob;

  final RxBool hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(checkForChanges);
    usernameController.addListener(checkForChanges);
    bioController.addListener(checkForChanges);
    fetchCurrentUser();
  }

  @override
  void onClose() {
    nameController.removeListener(checkForChanges);
    usernameController.removeListener(checkForChanges);
    bioController.removeListener(checkForChanges);
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  void _setInitialData(CurrentUser user) {
    _initialName = user.name.isNotEmpty ? user.name : user.displayName;
    _initialUsername = user.username;
    _initialBio = user.bio;
    _initialSex = _capitalize(user.gender);
    _initialDob = user.dob;

    name.value = _initialName;
    username.value = _initialUsername;
    bio.value = _initialBio;
    sex.value = _initialSex;
    selectedDob.value = _initialDob;
    birthday.value = _formatDate(_initialDob);
    profileImageUrl.value = user.effectivePhoto;
    profileImagePath.value = '';

    nameController.text = _initialName;
    usernameController.text = _initialUsername;
    bioController.text = _initialBio;

    hasChanges.value = false;
  }

  void checkForChanges() {
    if (isLoading.value) {
      hasChanges.value = false;
      return;
    }

    final hasNameChanged = nameController.text.trim() != _initialName.trim();
    final hasUsernameChanged =
        usernameController.text.trim() != _initialUsername.trim();
    final hasBioChanged = bioController.text.trim() != _initialBio.trim();
    final hasSexChanged =
        sex.value.trim().toLowerCase() != _initialSex.trim().toLowerCase();
    final hasDobChanged = !_isSameDate(selectedDob.value, _initialDob);
    final hasImageChanged = profileImagePath.value.isNotEmpty;

    hasChanges.value = hasNameChanged ||
        hasUsernameChanged ||
        hasBioChanged ||
        hasSexChanged ||
        hasDobChanged ||
        hasImageChanged;
  }

  bool _isSameDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> fetchCurrentUser() async {
    isLoading.value = true;

    try {
      final user = await _currentUserService.getProfile();
      currentUser.value = user;
      _setInitialData(user);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
      checkForChanges();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        profileImagePath.value = image.path;
        checkForChanges();
      }
    } catch (e) {
      AppLoadingService.showError('Error', 'Failed to pick image: $e');
    }
  }

  void onChangePicture() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void onSexTap() {
    final current = sex.value.trim().toLowerCase();
    final next = current == 'female' ? 'Male' : 'Female';
    sex.value = next;
    checkForChanges();
  }

  Future<void> onDone() async {
    if (isSaving.value) return;

    final nextName = nameController.text.trim();
    final nextUsername = usernameController.text.trim();
    final nextBio = bioController.text.trim();
    final nextGender = sex.value.trim().toLowerCase();

    if (nextUsername.isEmpty) {
      _showError('Username is required.');
      return;
    }

    isSaving.value = true;
    try {
      await _currentUserService.updateProfile(
        username: nextUsername,
        name: nextName,
        bio: nextBio,
        gender: nextGender,
        dob: selectedDob.value,
        photoPath: profileImagePath.value,
      );

      final freshUser = await _currentUserService.getProfile();

      currentUser.value = freshUser;
      _setInitialData(freshUser);

      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().fetchCurrentUser();
      }

      AppLoadingService.showSuccess(
        'Profile Updated',
        'Profile updated successfully',
      );
      Get.back();
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isSaving.value = false;
      checkForChanges();
    }
  }

  Future<void> onBirthdayTap(BuildContext context) async {
    final now = DateTime.now();
    final initialDate =
        selectedDob.value ??
        DateTime(now.year - 18, now.month, now.day > 28 ? 28 : now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate == null) return;

    selectedDob.value = pickedDate;
    birthday.value = _formatDate(pickedDate);
    checkForChanges();
  }

  void onBack() {
    Get.back();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';

    final monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${value.day} ${monthNames[value.month - 1]}, ${value.year}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return '';

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  void _showError(String message) {
    AppLoadingService.showError('Profile Failed', message);
  }
}
