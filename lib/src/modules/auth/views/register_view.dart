import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

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
              'Create Account',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Sign up to get the latest news first and stay updated.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(theme, 'First Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.regFirstNameController,
                        decoration: const InputDecoration(
                          hintText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(theme, 'Last Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.regLastNameController,
                        decoration: const InputDecoration(
                          hintText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Email Field
            _buildFieldLabel(theme, 'Email Address'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.regEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // DOB Field
            _buildFieldLabel(theme, 'Date of Birth'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.regDobController,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: theme.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  controller.regDobController.text = formattedDate;
                }
              },
              decoration: const InputDecoration(
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            _buildFieldLabel(theme, 'Password'),
            const SizedBox(height: 8),
            Obx(() => TextField(
              controller: controller.regPasswordController,
              obscureText: !controller.isPasswordVisible.value,
              decoration: InputDecoration(
                hintText: 'Create a password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(controller.isPasswordVisible.value 
                    ? Icons.visibility 
                    : Icons.visibility_off),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
            )),
            const SizedBox(height: 20),

            // Confirm Password Field
            _buildFieldLabel(theme, 'Confirm Password'),
            const SizedBox(height: 8),
            Obx(() => TextField(
              controller: controller.regConfirmPasswordController,
              obscureText: !controller.isConfirmPasswordVisible.value,
              decoration: InputDecoration(
                hintText: 'Repeat your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(controller.isConfirmPasswordVisible.value 
                    ? Icons.visibility 
                    : Icons.visibility_off),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
              ),
            )),
            const SizedBox(height: 40),

            // Register Button
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.register(),
              child: controller.isLoading.value 
                ? const SizedBox(
                    width: 25, 
                    height: 25, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Sign Up'),
            )),
            
            const SizedBox(height: 40),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ", 
                  style: theme.textTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text(
                    'Login', 
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
    );
  }

  Widget _buildFieldLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.bodySmall,
    );
  }
}
