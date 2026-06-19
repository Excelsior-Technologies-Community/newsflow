import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/theme_service.dart';
import '../../../models/news_model.dart';
import '../../../core/widgets/app_logo.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 30, showText: false),
            SizedBox(width: 10),
            Text(
              'NewsFlow',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_rounded),
            onPressed: () => ThemeService().switchTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector
          _buildCategoryList(),
          
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.newsList.isEmpty) {
                return const Center(child: Text("No news found."));
              }

              return RefreshIndicator(
                onRefresh: () async => controller.fetchNews(controller.selectedCategory.value),
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: controller.newsList.length + 1, // +1 for Top News section
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildTopNewsSection();
                    }
                    final news = controller.newsList[index - 1];
                    return _buildNewsCard(news);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    bool isDark = Get.isDarkMode;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            bool isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) controller.fetchNews(category);
                },
                selectedColor: isDark ? Colors.teal.withAlpha((0.2 * 255).toInt()) : Colors.deepPurple,
                backgroundColor: isDark ? const Color(0xFF161B22) : Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? (isDark ? Colors.tealAccent : Colors.deepPurple)
                        : (isDark ? Colors.grey[700]! : Colors.transparent),
                    width: 1.5,
                  ),
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.tealAccent : Colors.white)
                      : (isDark ? Colors.grey[400] : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildTopNewsSection() {
    return const SizedBox.shrink(); // Removing the old slider for the new vertical list structure
  }

  Widget _buildNewsCard(NewsModel news) {
    bool isDark = Get.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Large Image
          if (news.urlToImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: news.urlToImage,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: isDark ? Colors.grey[900] : Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
            ),

          // 2. Source/Category in Italic
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 12, bottom: 8),
            child: Text(
              news.source,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. Black Badge Category
                Row(
                  children: [
                    if (news.source.contains("INDIA"))
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        news.source.toUpperCase(),
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Bold Title
                Text(
                  news.title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: isDark ? Colors.white : const Color(0xFF000000), // Pure black in light mode
                  ),
                ),
                const SizedBox(height: 15),

                // 5. Description
                Text(
                  news.description,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : const Color(0xFF444444), // Dark grey for description
                  ),
                ),
                const SizedBox(height: 15),

                // 6. Read More
                Text(
                  "Read More",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : const Color(0xFF222222), // Almost black for read more
                  ),
                ),
                const SizedBox(height: 20),

                // 7. Footer: Date and Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      news.publishedAt,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[500] : const Color(0xFF777777), // Medium grey for date
                      ),
                    ),
                    Icon(
                      Icons.more_horiz,
                      color: isDark ? Colors.grey[500] : const Color(0xFF777777),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 20, thickness: 1),
        ],
      ),
    );
  }
}
