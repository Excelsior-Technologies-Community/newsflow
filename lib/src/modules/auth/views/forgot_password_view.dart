import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forgot Password',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your email address and we will send you a reset link to your email.',
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
              controller: controller.forgotEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 40),

            // Reset Button
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.forgotPassword(),
              child: controller.isLoading.value 
                ? const SizedBox(
                    width: 25, 
                    height: 25, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Send Reset Link'),
            )),
          ],
        ),
      ),
    );
  }
}
