import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
        child: Column(
          children: [
            // User Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_rounded, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Obx(() => Text(
                    controller.userName.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    controller.userEmail.value,
                    style: theme.textTheme.bodyMedium,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Settings Menu
            _buildMenuItem(
              context,
              icon: Icons.edit_rounded,
              title: 'Edit Profile',
              onTap: () => Get.toNamed(Routes.editProfile),
            ),
            _buildMenuItem(
              context,
              icon: Icons.history_rounded,
              title: 'Reading History',
              onTap: () => Get.toNamed(Routes.history),
            ),
            _buildMenuItem(
              context,
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              onTap: () => Get.toNamed(Routes.changePassword),
            ),
            _buildMenuItem(
              context,
              icon: Icons.brightness_6_outlined,
              title: 'Dark Mode',
              trailing: Obx(() => Switch(
                value: controller.isDarkMode.value,
                activeColor: theme.primaryColor,
                onChanged: (val) => controller.toggleTheme(),
              )),
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About NewsFlow',
              onTap: () {
                Get.toNamed('/about');
              },
            ),
            const SizedBox(height: 32),
            _buildMenuItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Logout',
              titleColor: const Color(0xFFEB5757),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF2B354E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (Get.isRegistered<AuthController>()) {
                Get.find<AuthController>().logout();
              } else {
                Get.put(AuthController()).logout();
              }
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFFEB5757), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? const Color(0xFF2B354E) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            icon, 
            color: titleColor ?? (isDark ? const Color(0xFFABB0C4) : const Color(0xFF7C82A1)),
            size: 22,
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: titleColor ?? theme.colorScheme.onSurface,
            ),
          ),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}
