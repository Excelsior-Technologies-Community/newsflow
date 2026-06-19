import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RegisterController());

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF764ba2), Color(0xFF667eea)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
                  const SizedBox(height: 20),
                  Text('Create Account', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('Sign up to get started!', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 40),
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: controller.nameController,
                          hint: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (value) => (value?.isEmpty ?? true) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: controller.emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          validator: (value) => GetUtils.isEmail(value ?? '') ? null : 'Enter a valid email',
                        ),
                        const SizedBox(height: 20),
                        Obx(() => _buildTextField(
                              controller: controller.passwordController,
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: !controller.isPasswordVisible.value,
                              onSuffixIconTap: controller.togglePasswordVisibility,
                              validator: (value) => (value?.length ?? 0) < 6 ? 'Password too short' : null,
                            )),
                        const SizedBox(height: 20),
                        Obx(() => _buildTextField(
                              controller: controller.confirmPasswordController,
                              hint: 'Confirm Password',
                              icon: Icons.lock_reset_outlined,
                              isPassword: true,
                              obscureText: !controller.isPasswordVisible.value,
                              onSuffixIconTap: controller.togglePasswordVisibility,
                              validator: (value) => value != controller.passwordController.text ? 'Passwords do not match' : null,
                            )),
                        const SizedBox(height: 40),
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value ? null : controller.register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF667eea),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: controller.isLoading.value ? const CircularProgressIndicator() : Text('SIGN UP', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            )),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool obscureText = false, VoidCallback? onSuffixIconTap, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword ? GestureDetector(onTap: onSuffixIconTap, child: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70)) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
        errorStyle: GoogleFonts.poppins(color: Colors.orangeAccent),
      ),
    );
  }
}
