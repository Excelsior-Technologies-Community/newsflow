import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import '../../../routes/app_pages.dart';
import '../../../core/network/auth_service.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  
  // Login Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  
  // Register Controllers
  final regFirstNameController = TextEditingController();
  final regLastNameController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  final regDobController = TextEditingController();
  final Rx<File?> selectedProfilePhoto = Rx<File?>(null);
  
  // Forgot/Reset Password Controller
  final forgotEmailController = TextEditingController();
  final otpController = TextEditingController();
  final resetNewPasswordController = TextEditingController();
  final resetConfirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (loginEmailController.text.trim().isEmpty || loginPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    
    final result = await AuthService.login(
      loginEmailController.text.trim(),
      loginPasswordController.text,
    );

    if (result['success']) {
      final data = result['data']['data'];
      storage.write('isLoggedIn', true);
      
      if (result['data']['token'] != null) storage.write('token', result['data']['token']);
      
      if (data != null) {
        storage.write('userId', data['id']);
        storage.write('userName', "${data['first_name']} ${data['last_name']}");
        storage.write('userEmail', data['email']);
        storage.write('userDob', data['dob']);
        storage.write('userAvatar', data['profile_photo']);
      } else {
        storage.write('userName', 'User');
        storage.write('userEmail', loginEmailController.text);
      }
      Get.offAllNamed(Routes.dashboard);
    } else {
      Get.snackbar(
        'Login Failed', 
        result['message'] ?? 'An error occurred', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  Future<void> register() async {
    if (regFirstNameController.text.trim().isEmpty || 
        regLastNameController.text.trim().isEmpty || 
        regEmailController.text.trim().isEmpty || 
        regPasswordController.text.isEmpty ||
        regDobController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (regPasswordController.text != regConfirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    
    final result = await AuthService.register(
      firstName: regFirstNameController.text.trim(),
      lastName: regLastNameController.text.trim(),
      email: regEmailController.text.trim(),
      password: regPasswordController.text,
      dob: regDobController.text,
      profilePhoto: selectedProfilePhoto.value,
    );
    
    if (result['success']) {
      Get.snackbar('Success', 'Registration successful! Please login.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } else {
      Get.snackbar('Registration Failed', result['message'] ?? 'An error occurred', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  Future<void> forgotPassword() async {
    if (forgotEmailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    
    final result = await AuthService.forgotPassword(forgotEmailController.text.trim());
    
    if (result['success']) {
      Get.snackbar('Success', result['message'] ?? 'OTP Sent', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
      Get.toNamed(Routes.otpVerify);
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to send OTP.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter OTP', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final result = await AuthService.verifyOtp(
      forgotEmailController.text.trim(), 
      otpController.text.trim()
    );

    if (result['success']) {
      Get.toNamed(Routes.resetPassword);
    } else {
      Get.snackbar('Error', result['message'] ?? 'Invalid OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  Future<void> resendOtp() async {
    isLoading.value = true;
    final result = await AuthService.resendOtp(forgotEmailController.text.trim());

    if (result['success']) {
      Get.snackbar('Success', result['message'] ?? 'OTP Resent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to resend OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  Future<void> submitNewPassword() async {
    if (resetNewPasswordController.text.isEmpty || resetConfirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (resetNewPasswordController.text != resetConfirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (otpController.text.trim().isEmpty) {
      Get.snackbar('Error', 'OTP is missing. Please try again.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final result = await AuthService.resetPassword(
      email: forgotEmailController.text.trim(),
      newPassword: resetNewPasswordController.text,
      confirmPassword: resetConfirmPasswordController.text,
    );

    if (result['success']) {
      Get.snackbar('Success', result['message'] ?? 'Password reset successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.login);
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to reset password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  void logout() {
    storage.erase();
    Get.offAllNamed(Routes.login);
  }

  void clearControllers() {
    loginEmailController.clear();
    loginPasswordController.clear();
    regFirstNameController.clear();
    regLastNameController.clear();
    regEmailController.clear();
    regPasswordController.clear();
    regConfirmPasswordController.clear();
    regDobController.clear();
    forgotEmailController.clear();
    otpController.clear();
    resetNewPasswordController.clear();
    resetConfirmPasswordController.clear();
    isPasswordVisible.value = false;
    selectedProfilePhoto.value = null;
  }
}
