import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/network/auth_service.dart';
import '../../../core/network/api_service.dart';
import '../../../models/user_model.dart';

class ProfileController extends GetxController {
  final storage = GetStorage();
  final ApiService _apiService = ApiService();
  
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userDob = ''.obs;
  final isDarkMode = false.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // History state
  final historyList = <Map<String, dynamic>>[].obs;
  final isHistoryLoading = false.obs;

  // Edit Profile Controllers
  final editFirstNameController = TextEditingController();
  final editLastNameController = TextEditingController();
  final editDobController = TextEditingController();

  // Change Password Controllers (Renamed to match Swagger exactly)
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    userName.value = storage.read('userName') ?? 'User';
    userEmail.value = storage.read('userEmail') ?? 'user@newsflow.com';
    userDob.value = storage.read('userDob') ?? '';
    isDarkMode.value = ThemeService().isDarkMode;
    
    // Fetch fresh profile on init
    getProfile();
  }

  void toggleTheme() {
    ThemeService().switchTheme();
    isDarkMode.value = ThemeService().isDarkMode;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> getProfile() async {
    final token = storage.read('token');
    if (token == null) return;

    final result = await AuthService.getProfile(token);
    if (result['success']) {
      final data = result['data']['data']; 
      if (data != null) {
        final user = UserModel.fromJson(data);
        userName.value = user.name;
        userEmail.value = user.email;
        userDob.value = user.dob ?? '';
        
        storage.write('userName', user.name);
        storage.write('userEmail', user.email);
        storage.write('userDob', user.dob);
        storage.write('userAvatar', user.profilePhoto);
      }
    }
  }

  Future<void> fetchReadingHistory() async {
    final token = storage.read('token');
    if (token == null) return;

    isHistoryLoading.value = true;
    try {
      final results = await _apiService.fetchHistory(token);
      historyList.assignAll(results);
    } catch (e) {
      print("History error: $e");
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> deleteHistoryItem(int historyId) async {
    final token = storage.read('token');
    if (token == null) return;

    bool success = await _apiService.deleteHistoryItem(historyId, token);
    if (success) {
      historyList.removeWhere((item) => item['id'] == historyId);
      Get.snackbar('Success', 'History item removed');
    } else {
      Get.snackbar('Error', 'Failed to remove history item');
    }
  }

  Future<void> clearReadingHistory() async {
    final token = storage.read('token');
    if (token == null) return;

    bool success = await _apiService.clearHistory(token);
    if (success) {
      historyList.clear();
      Get.snackbar('Success', 'History cleared successfully');
    }
  }

  Future<void> updateProfile() async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Error', 'Unauthorized', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (editFirstNameController.text.trim().isEmpty || 
        editLastNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name fields cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final result = await AuthService.updateProfile(
      token: token,
      firstName: editFirstNameController.text.trim(),
      lastName: editLastNameController.text.trim(),
      dob: editDobController.text,
    );

    if (result['success']) {
      userName.value = "${editFirstNameController.text.trim()} ${editLastNameController.text.trim()}";
      userDob.value = editDobController.text;
      storage.write('userName', userName.value);
      storage.write('userDob', userDob.value);

      Get.snackbar('Success', result['message'] ?? 'Profile updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back(); 
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  Future<void> changePassword() async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Error', 'Unauthorized. Please login again.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (currentPasswordController.text.isEmpty || 
        newPasswordController.text.isEmpty || 
        confirmNewPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all password fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      Get.snackbar('Error', 'New passwords do not match', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    
    // Call API with exactly what the Swagger image shows
    final result = await AuthService.changePassword(
      token: token,
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmNewPasswordController.text,
    );

    if (result['success']) {
      Get.snackbar('Success', result['message'] ?? 'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
      Get.back();
    } else {
      // Backend returned the "usermodel.getuserbyid" error here
      Get.snackbar('Change Password Failed', result['message'] ?? 'Check your current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
    isLoading.value = false;
  }
}
