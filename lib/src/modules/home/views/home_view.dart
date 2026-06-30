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
        child: Obx(() {
          if (controller.isSearching.value) {
            return AppBar(
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                onPressed: () => controller.toggleSearch(),
              ),
              titleSpacing: 0,
              title: Container(
                height: 42,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B354E) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for articles...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded, 
                      size: 20, 
                      color: isDark ? Colors.grey[500] : Colors.grey[600]
                    ),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, size: 18),
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchQuery.value = '';
                          },
                        )
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) => controller.searchQuery.value = value,
                ),
              ),
            );
          }

          return AppBar(
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
                icon: const Icon(Icons.search),
                onPressed: () => controller.toggleSearch(),
              ),
              const SizedBox(width: 8),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Obx(() => controller.isSearching.value 
            ? const SizedBox.shrink() 
            : _buildCategoryList()
          ),
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
                    onRefresh: () async {
                      if (controller.isSearching.value && controller.searchQuery.value.isNotEmpty) {
                        await controller.performSearch(controller.searchQuery.value);
                      } else {
                        await controller.fetchNews(controller.selectedCategory.value, showLoading: true);
                      }
                    },
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

  Widget _buildNewsList() {
    return ListView.separated(
      controller: controller.scrollController,
      padding: EdgeInsets.zero, // Remove side padding for full-width feel
      itemCount: controller.newsList.length + (controller.hasMore.value ? 1 : 0),
      separatorBuilder: (context, index) => Container(
        height: 8,
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.black12 
            : Colors.grey.shade100,
      ),
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
        return _buildNewsItem(context, news);
      },
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsModel news) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarkController = Get.find<BookmarksController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Full-width Image
        if (news.urlToImage.isNotEmpty)
          GestureDetector(
            onTap: () => Get.toNamed(Routes.newsDetail, arguments: news),
            child: CachedNetworkImage(
              imageUrl: news.urlToImage,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 240,
                color: theme.colorScheme.surface,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 240,
                color: theme.colorScheme.surface,
                child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
              ),
            ),
          ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Source Badge (Modern style)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD32F2F),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          news.source.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Bold Title
              GestureDetector(
                onTap: () => Get.toNamed(Routes.newsDetail, arguments: news),
                child: Text(
                  news.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.25,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Description Snippet
              Text(
                news.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFFABB0C4) : const Color(0xFF4B5563),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // 5. Read More Link
              InkWell(
                onTap: () => Get.toNamed(Routes.newsDetail, arguments: news),
                child: Text(
                  'Read More',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 6. Footer (Date and Actions)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(news.publishedAt),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (value) {
                      if (value == 'share') {
                        Share.share('${news.title}\n\nRead more at: ${news.link}');
                      } else if (value == 'save') {
                        bookmarkController.toggleBookmark(news);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Share'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'save',
                        child: Obx(() => Row(
                          children: [
                            Icon(
                              news.isBookmarked.value ? Icons.bookmark : Icons.bookmark_outline,
                              size: 18,
                              color: news.isBookmarked.value ? theme.primaryColor : null,
                            ),
                            const SizedBox(width: 12),
                            Text(news.isBookmarked.value ? 'Saved' : 'Save'),
                          ],
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
