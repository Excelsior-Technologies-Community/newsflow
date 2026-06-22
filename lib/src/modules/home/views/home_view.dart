import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/home_controller.dart';
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
    // Controller is already put in GetMaterialApp or initialized elsewhere, 
    // but ensuring it's available here.
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => AppBar(
          elevation: controller.appBarElevation.value,
          shadowColor: Colors.black26,
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
                    return _buildNewsList();
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
          child: ListView.builder(
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
                      ),
                    ),
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
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.urlToImage.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: news.urlToImage,
                  width: double.infinity,
                  height: isTablet ? 350 : 220,
                  fit: BoxFit.cover,
                  memCacheWidth: 1000,
                  placeholder: (context, url) => Container(
                    height: isTablet ? 350 : 220,
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
                    height: isTablet ? 350 : 220,
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

              Padding(
                padding: EdgeInsets.all(isTablet ? 25 : 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          news.publishedAt.split(' ').take(4).join(' '),
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      news.title,
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() => AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Text(
                        news.description,
                        maxLines: news.isExpanded.value ? null : 3,
                        overflow: news.isExpanded.value ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 16 : 14,
                          height: 1.5,
                          color: isDark ? Colors.grey[400] : const Color(0xFF4A4A4A),
                        ),
                      ),
                    )),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            // Only allow expansion if description is long enough (approx > 3 lines)
                            bool canExpand = news.description.length > 130;
                            
                            return GestureDetector(
                              onTap: canExpand ? () => news.isExpanded.toggle() : null,
                              child: Obx(() => Text(
                                news.isExpanded.value ? "Read Less" : "Read Full Story",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 15 : 13,
                                  color: canExpand 
                                      ? Colors.blueAccent 
                                      : (isDark ? Colors.grey[700] : Colors.grey[400]),
                                ),
                              )),
                            );
                          },
                        ),
                        Icon(
                          Icons.more_horiz,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
