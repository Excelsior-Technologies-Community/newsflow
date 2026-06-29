import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_logo.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About NewsFlow'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          children: [
            const Center(
              child: AppLogo(size: 100),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoCard(
              context,
              title: 'Our Mission',
              description: 'NewsFlow is dedicated to delivering the most relevant and up-to-date news from around the world. We believe in high-quality journalism and provide a seamless reading experience tailored to your interests.',
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              title: 'Features',
              description: '• Real-time news updates\n• Personalized categories\n• Reading history tracking\n• Bookmark articles for later\n• Community comments and interaction',
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            _buildLinkItem(
              context,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildLinkItem(
              context,
              title: 'Terms of Service',
              onTap: () {},
            ),
            _buildLinkItem(
              context,
              title: 'Contact Us',
              onTap: () {},
            ),
            const SizedBox(height: 60),
            Text(
              '© 2026 NewsFlow. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String description}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B354E) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark ? const Color(0xFFABB0C4) : const Color(0xFF333647),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, {required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
