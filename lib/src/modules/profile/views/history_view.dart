import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../models/news_model.dart';

class HistoryView extends GetView<ProfileController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Fetch history when view is built
    controller.fetchReadingHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearDialog(context),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isHistoryLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 80, color: theme.disabledColor.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No reading history found', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Articles you read will appear here', style: theme.textTheme.bodySmall),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: controller.historyList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = controller.historyList[index];
            
            // NewsModel.fromJson handles internal 'news' key nesting automatically.
            // We only show placeholder if the item seems completely empty of news content.
            final news = NewsModel.fromJson(item);
            
            bool isInvalid = news.title.isEmpty && (item['news'] == null || item['news'].isEmpty);

            if (isInvalid) {
              return _buildBlankItemPlaceholder(theme, isDark, item['id']);
            }
            
            return Dismissible(
              key: Key(item['id'].toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                controller.deleteHistoryItem(item['id']);
              },
              child: GestureDetector(
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
                      if (news.urlToImage.isNotEmpty)
                        Image.network(
                          news.urlToImage,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.source.toUpperCase(),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                news.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (item['read_percentage'] != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: (double.tryParse(item['read_percentage'].toString()) ?? 0.0) / 100,
                                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showClearDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear your entire reading history?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.clearReadingHistory();
              Get.back();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlankItemPlaceholder(ThemeData theme, bool isDark, dynamic id) {
    return Dismissible(
      key: Key('blank_$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (id is int) controller.deleteHistoryItem(id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B354E).withOpacity(0.5) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Icon(Icons.article_outlined, color: theme.disabledColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Original article is no longer available',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
            Icon(Icons.swipe_left_rounded, size: 16, color: theme.disabledColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
