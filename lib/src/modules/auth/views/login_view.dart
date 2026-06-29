import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/app_logo.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Center(child: AppLogo(size: 70, showText: true)),
              const SizedBox(height: 50),
              
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'I am happy to see you again. You can continue where you left off by logging in.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
  
              // Email Field
              Text(
                'Email Address',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.loginEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
  
              // Password Field
              Text(
                'Password',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.loginPasswordController,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(controller.isPasswordVisible.value 
                      ? Icons.visibility 
                      : Icons.visibility_off),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              )),
  
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.forgotPassword),
                  child: Text(
                    'Forgot Password?', 
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
  
              // Login Button
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.login(),
                child: controller.isLoading.value 
                  ? const SizedBox(
                      width: 25, 
                      height: 25, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Login'),
              )),
              
              const SizedBox(height: 40),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ", 
                    style: theme.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.register),
                    child: Text(
                      'Register', 
                      style: TextStyle(
                        color: theme.primaryColor, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
