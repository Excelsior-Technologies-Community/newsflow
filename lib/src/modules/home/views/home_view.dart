import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/theme/theme_service.dart';
import '../../../models/news_model.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/base/base_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDarkMode;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => AppBar(
          elevation: controller.appBarElevation.value,
          shadowColor: isDark ? Colors.black45 : Colors.black12,
          surfaceTintColor: Colors.transparent, // Prevents color shifting on scroll
          backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
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
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                if (Get.isRegistered<AuthController>()) {
                  Get.find<AuthController>().logout();
                } else {
                  Get.put(AuthController()).logout();
                }
              },
            ),
            IconButton(
              tooltip: 'Refresh News',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => controller.fetchNews(controller.selectedCategory.value),
            ),
            IconButton(
              icon: const Icon(Icons.brightness_6_rounded),
              onPressed: () => ThemeService().switchTheme(),
            ),
          ],
        )),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Column(
          children: [
            _buildCategoryList(),
            Expanded(
              child: Obx(() {
                switch (controller.state) {
                  case ViewState.loading:
                    return const ShimmerLoading();
                  case ViewState.noInternet:
                    return ErrorStateView(
                      message: 'No Internet Connection',
                      icon: Icons.wifi_off_rounded,
                      onRetry: () => controller.fetchNews(controller.selectedCategory.value),
                    );
                  case ViewState.error:
                    return ErrorStateView(
                      message: 'Something went wrong while fetching news',
                      onRetry: () => controller.fetchNews(controller.selectedCategory.value),
                    );
                  case ViewState.empty:
                    return ErrorStateView(
                      message: 'No news found for this category',
                      icon: Icons.search_off_rounded,
                      onRetry: () => controller.fetchNews(controller.selectedCategory.value),
                    );
                  case ViewState.success:
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchNews(controller.selectedCategory.value, showLoading: false),
                      child: _buildNewsList(),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    bool isDark = Get.isDarkMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Obx(() {
                bool isSelected = controller.selectedCategory.value == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 600 ? 16 : 13,
                        color: isSelected 
                            ? const Color(0xFF244D44) // Match border color
                            : Colors.grey[500]!,      // Match unselected border color
                        fontWeight: FontWeight.bold,  // All text is now bold
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) controller.fetchNews(category);
                    },
                    selectedColor: Colors.transparent, // Transparent like in the photo
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected 
                            ? const Color(0xFF244D44) // Updated green color
                            : Colors.grey[400]!,      // Light grey border for unselected
                        width: 1,
                      ),
                    ),
                    showCheckmark: false, // Cleaner look like the photo
                  ),
                );
              });
            },
          )),
        );
      },
    );
  }

  Widget _buildNewsList() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchNews(controller.selectedCategory.value, showLoading: false),
      child: ListView.separated(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(15),
        itemCount: controller.newsList.length + (controller.hasMore.value ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == controller.newsList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final news = controller.newsList[index];
          return _buildNewsCard(news);
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    bool isDark = Get.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isTablet = screenWidth > 600;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1117) : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Large Image
              if (news.urlToImage.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: news.urlToImage,
                  width: double.infinity,
                  height: isTablet ? 350 : 250,
                  fit: BoxFit.cover,
                  memCacheWidth: 1000,
                  placeholder: (context, url) => Container(
                    height: isTablet ? 350 : 250,
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: isTablet ? 350 : 250,
                    width: double.infinity,
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Image Unavailable",
                          style: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // 2. Source Name (Italic, Light Grey) - Matches "India's Nuclear" in demo
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 12, bottom: 8),
                child: Text(
                  news.source,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ),
              
              const Divider(height: 1, thickness: 0.5),

              Padding(
                padding: EdgeInsets.all(isTablet ? 25 : 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3. Category Badge (Red Dot + Black/White Badge)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD32F2F), // Muted professional red
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 4. Headline - Large, Ultra Bold
                    Text(
                      news.title,
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: isDark ? Colors.white : const Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. Description - Clean, Spaced
                    Obx(() => AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Text(
                        news.description,
                        maxLines: news.isExpanded.value ? null : 3,
                        overflow: news.isExpanded.value ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 17 : 15,
                          height: 1.6,
                          color: isDark ? Colors.grey[300] : const Color(0xFF444444),
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),

                    // 6. Read More Toggle (Only shown when text is actually truncated)
                    LayoutBuilder(
                      builder: (context, lConstraints) {
                        // Create a TextPainter to check if the text will actually overflow 3 lines
                        final textSpan = TextSpan(
                          text: news.description,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 17 : 15,
                            height: 1.6,
                          ),
                        );
                        
                        final tp = TextPainter(
                          text: textSpan,
                          maxLines: 3,
                          textDirection: TextDirection.ltr,
                        );
                        
                        tp.layout(maxWidth: lConstraints.maxWidth);
                        
                        // didExceedMaxLines is true only if text is physically cut off
                        bool isTruncated = tp.didExceedMaxLines;
                        
                        if (!isTruncated) return const SizedBox(height: 20);

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => news.isExpanded.toggle(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Obx(() => Text(
                              news.isExpanded.value ? "Read Less" : "Read More",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 15 : 14,
                                color: Colors.blueAccent,
                              ),
                            )),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // 7. Footer (Date + Options)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          news.publishedAt,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[500] : const Color(0xFF777777),
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
              const Divider(height: 40, thickness: 8, color: Color(0x08000000)), // Subtle section break
            ],
          ),
        );
      },
    );
  }
}
