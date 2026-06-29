import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/news_detail_controller.dart';

class NewsDetailView extends GetView<NewsDetailController> {
  const NewsDetailView({super.key});

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM d, y, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final commentController = TextEditingController();

    return Scaffold(
      body: Obx(() {
        final news = controller.news.value;
        if (news == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Collapsing Image Header with Sticky Title
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              centerTitle: true,
              title: LayoutBuilder(
                builder: (context, constraints) {
                  // We can use a different approach here to detect scroll state
                  // But title property of SliverAppBar is only shown when collapsed if we use flexibleSpace properly
                  return const SizedBox.shrink();
                },
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new, 
                    size: 18, 
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.share_outlined, 
                      size: 20, 
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => controller.shareNews(),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero, // We'll handle padding inside the title widget
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final topPadding = MediaQuery.of(context).padding.top;
                    final collapsedHeight = kToolbarHeight + topPadding;
                    final currentHeight = constraints.biggest.height;
                    
                    // Only show the title when the bar is significantly collapsed
                    // This prevents the title from appearing over the image
                    final isCollapsed = currentHeight <= collapsedHeight + 20;

                    if (isCollapsed) {
                      return Container(
                        height: kToolbarHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        alignment: Alignment.center,
                        child: Text(
                          news.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                background: Hero(
                  tag: 'news_image_${news.id}',
                  child: news.urlToImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: news.urlToImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: theme.colorScheme.surface),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                        )
                      : Container(
                          color: theme.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.newspaper, size: 80, color: theme.primaryColor.withOpacity(0.2)),
                        ),
                ),
              ),
            ),

            // 2. Article Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sub-header (Source, Category, Time)
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
                        Flexible(
                          child: Text(
                            news.source.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        if (news.category.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                news.category.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(news.publishedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (news.author.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        "By ${news.author}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // The Full Title (Non-sticky, below image)
                    Text(
                      news.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 12),
                    Obx(() {
                      final currentNews = controller.news.value;
                      if (currentNews == null || currentNews.shareCount <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Row(
                        children: [
                          Icon(Icons.share_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            "${currentNews.shareCount} Shares",
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),

                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      String displayContent = news.content.isNotEmpty 
                          ? news.content 
                          : news.description;

                      return Text(
                        displayContent,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.9,
                          fontSize: 17,
                          letterSpacing: 0.2,
                          color: isDark ? const Color(0xFFABB0C4) : const Color(0xFF333647),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // --- Comments Section ---
                    Text(
                      'Comments',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Comment Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              fillColor: isDark ? const Color(0xFF2B354E) : const Color(0xFFF3F4F6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            if (commentController.text.isNotEmpty) {
                              controller.addComment(commentController.text);
                              commentController.clear();
                              FocusScope.of(context).unfocus();
                            }
                          },
                          icon: Icon(Icons.send_rounded, color: theme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Comments List
                    Obx(() {
                      if (controller.isCommentsLoading.value && controller.comments.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (controller.comments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No comments yet. Be the first to share your thoughts!',
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.comments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: theme.primaryColor.withOpacity(0.1),
                                child: Text(
                                  (comment['user_name'] ?? 'U').substring(0, 1).toUpperCase(),
                                  style: TextStyle(color: theme.primaryColor, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['user_name'] ?? 'User',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['comment'] ?? '',
                                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        final news = controller.news.value;
        if (news == null) return const SizedBox.shrink();
        
        return FloatingActionButton(
          onPressed: () => controller.toggleBookmark(),
          backgroundColor: theme.primaryColor,
          elevation: 4,
          child: Icon(
            news.isBookmarked.value ? Icons.bookmark : Icons.bookmark_outline,
            color: Colors.white,
          ),
        );
      }),
    );
  }
}
