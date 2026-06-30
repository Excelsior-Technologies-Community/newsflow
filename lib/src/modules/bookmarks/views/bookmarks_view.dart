import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/bookmarks_controller.dart';
import '../../../routes/app_pages.dart';

class BookmarksView extends GetView<BookmarksController> {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved News'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasLoadedOnce.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline_rounded, 
                  size: 80, 
                  color: isDark ? const Color(0xFF2B354E) : Colors.grey[200]
                ),
                const SizedBox(height: 24),
                Text(
                  'No saved news yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your bookmarked articles will appear here',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: controller.bookmarks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final news = controller.bookmarks[index];
            return GestureDetector(
              onTap: () => Get.toNamed(Routes.newsDetail, arguments: news),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B354E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    ClipRRect(
                      child: news.urlToImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: news.urlToImage,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 110, 
                              height: 110, 
                              color: theme.colorScheme.surface,
                              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.source.toUpperCase(),
                              style: TextStyle(
                                color: theme.primaryColor, 
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              news.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_remove_outlined, size: 22, color: Colors.redAccent),
                      onPressed: () => controller.toggleBookmark(news),
                      tooltip: 'Remove Bookmark',
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
