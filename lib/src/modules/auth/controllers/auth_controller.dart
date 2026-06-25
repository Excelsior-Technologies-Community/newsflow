import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  
  // Login Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  
  // Register Controllers
  final regNameController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  
  // Forgot Password Controller
  final forgotEmailController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (loginEmailController.text.isEmpty || loginPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulate network
    
    // Static Login Logic
    if (loginEmailController.text == 'yash@newsflow.com' && loginPasswordController.text == '123456') {
      storage.write('isLoggedIn', true);
      storage.write('userName', 'Yash Jani');
      Get.offAllNamed(Routes.home);
    } else {
      Get.snackbar('Login Failed', 'Invalid email or password. Use: yash@newsflow.com / 123456', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  Future<void> register() async {
    if (regNameController.text.isEmpty || regEmailController.text.isEmpty || regPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (regPasswordController.text != regConfirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    
    Get.snackbar('Success', 'Registration successful! Please login.', 
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    Get.back(); // Go back to login
    isLoading.value = false;
  }

  Future<void> resetPassword() async {
    if (forgotEmailController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your email', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    
    Get.snackbar('Email Sent', 'Password reset link sent to ${forgotEmailController.text}', 
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
    Get.back();
    isLoading.value = false;
  }

  void logout() {
    storage.remove('isLoggedIn');
    storage.remove('userName');
    Get.offAllNamed(Routes.login);
  }

  void clearControllers() {
    loginEmailController.clear();
    loginPasswordController.clear();
    regNameController.clear();
    regEmailController.clear();
    regPasswordController.clear();
    regConfirmPasswordController.clear();
    forgotEmailController.clear();
    isPasswordVisible.value = false;
  }

  @override
  void onClose() {
    // Note: If using Get.lazyPut in a Binding, GetX handles disposal.
    // However, if the controller is being reused across multiple views 
    // (Login, Register, Forgot), we should NOT dispose the controllers 
    // in onClose if those views are still alive or being rebuilt.
    // Given the "used after disposed" error, we'll let GetX manage the 
    // controller lifecycle via Bindings and only clear text if needed.
    super.onClose();
  }
}
