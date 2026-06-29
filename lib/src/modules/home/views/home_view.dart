import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/home_controller.dart';
import '../../bookmarks/controllers/bookmarks_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/news_model.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/base/base_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => AppBar(
          elevation: controller.appBarElevation.value,
          shadowColor: isDark ? Colors.black45 : Colors.black12,
          surfaceTintColor: Colors.transparent,
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          title: Row(
            children: [
              const AppLogo(size: 28, showText: false),
              const SizedBox(width: 12),
              Text(
                'NewsFlow',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh News',
              icon: const Icon(Icons.refresh_rounded, size: 24),
              onPressed: () => controller.fetchNews(controller.selectedCategory.value),
            ),
          ],
        )),
      ),
      body: Column(
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
    );
  }

  Widget _buildCategoryList() {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            bool isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected 
                        ? theme.primaryColor 
                        : (isDark ? const Color(0xFFABB0C4) : const Color(0xFF7C82A1)),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) controller.fetchNews(category);
                },
                selectedColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected 
                        ? theme.primaryColor 
                        : (isDark ? const Color(0xFF2B354E) : const Color(0xFFE5E7EB)),
                    width: 1.5,
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          });
        },
      )),
    );
  }

  Widget _buildNewsList() {
    return ListView.separated(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      itemCount: controller.newsList.length + (controller.hasMore.value ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 20),
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
        return GestureDetector(
          onTap: () => Get.toNamed(Routes.newsDetail, arguments: news),
          child: _buildNewsCard(context, news),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      // Use format like "Jun 29, 2024, 4:33 PM"
      return DateFormat('MMM d, y, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildNewsCard(BuildContext context, NewsModel news) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarkController = Get.find<BookmarksController>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B354E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(13), // Approx 0.05 opacity
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
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: theme.colorScheme.surface,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: theme.colorScheme.surface,
                child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        news.source.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(news.publishedAt),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined, size: 20),
                          onPressed: () => Share.share('${news.title}\n\nRead more at: ${news.link}'),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 16),
                        Obx(() => IconButton(
                          icon: Icon(
                            news.isBookmarked.value ? Icons.bookmark : Icons.bookmark_outline,
                            size: 20,
                          ),
                          onPressed: () => bookmarkController.toggleBookmark(news),
                          color: news.isBookmarked.value ? theme.primaryColor : null,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
