import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline_rounded, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    Text('Welcome Back', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    Text('Please sign in to continue', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 50),
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
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
                          const SizedBox(height: 30),
                          Obx(() => SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value ? null : controller.login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF764ba2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: controller.isLoading.value ? const CircularProgressIndicator() : Text('LOGIN', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: GoogleFonts.poppins(color: Colors.white70)),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.REGISTER),
                          child: Text('Sign Up', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
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
