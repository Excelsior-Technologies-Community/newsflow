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
                        separatorBuilder: (context, index) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          return _CommentItem(comment: comment);
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

class _CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  const _CommentItem({required this.comment});

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  late final TextEditingController _replyController;
  final isReplying = false.obs;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsDetailController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId = controller.storage.read('userId')?.toString();
    final currentUserName = controller.storage.read('userName')?.toString();
    final commentUserId = widget.comment['user_id']?.toString();
    final commentUserName = widget.comment['user_name']?.toString();

    // MOST RELIABLE CHECK: Compare trimmed strings
    final isMine = (currentUserId != null && commentUserId != null && currentUserId.trim() == commentUserId.trim()) ||
                   (currentUserName != null && commentUserName != null && currentUserName.trim() == commentUserName.trim());
    
    final commentId = widget.comment['id'] as int;

    // EMERGENCY LOGGING - PLEASE SHARE THIS
    print("CRITICAL DEBUG: MyID='$currentUserId', CommentOwnerID='$commentUserId', MyName='$currentUserName', OwnerName='$commentUserName', MATCH=$isMine");

    final isLiked = widget.comment['is_liked'] == 1 || widget.comment['is_liked'] == true;
    final likesCount = widget.comment['likes_count'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: Text(
                (widget.comment['user_name'] ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User', // Hardcoded as requested
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      // Force showing the menu if we suspect it's the user's comment
                      if (isMine)
                        PopupMenuButton(
                          icon: const Icon(Icons.more_horiz, size: 18),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(context, controller, commentId, widget.comment['comment'] ?? '');
                            } else if (value == 'delete') {
                              controller.deleteComment(commentId);
                            }
                          },
                        ),
                    ],
                  ),
                  Text(
                    widget.comment['comment'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  
                  // Actions: Like, Reply
                  Row(
                    children: [
                      Obx(() {
                        // Crucial: Find the current state from the controller's reactive list
                        final currentComment = controller.comments.firstWhere(
                          (c) => c['id'] == commentId, 
                          orElse: () => widget.comment
                        );
                        final isLiked = currentComment['is_liked'] == 1 || currentComment['is_liked'] == true;
                        final likesCount = currentComment['likes_count'] ?? 0;

                        return GestureDetector(
                          onTap: () => controller.likeComment(commentId),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$likesCount',
                                style: TextStyle(fontSize: 12, color: isLiked ? Colors.red : Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => isReplying.toggle(),
                        child: const Text(
                          'Reply',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        _formatTime(widget.comment['created_at']),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  
                  // Reply Input Area
                  Obx(() => isReplying.value 
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Write a reply...',
                                  isDense: true,
                                  fillColor: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_replyController.text.isNotEmpty) {
                                  controller.addReply(commentId, _replyController.text);
                                  _replyController.clear();
                                  isReplying.value = false;
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              icon: Icon(Icons.send_rounded, color: theme.primaryColor, size: 20),
                            ),
                          ],
                        ),
                      ) 
                    : const SizedBox.shrink()
                  ),
                  
                  // Replies List Section
                  _buildRepliesSection(context, controller, commentId),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepliesSection(BuildContext context, NewsDetailController controller, int commentId) {
    return GetBuilder<NewsDetailController>(
      builder: (c) {
        final commentReplies = c.replies[commentId];
        final isLoading = c.loadingReplies[commentId] ?? false;

        if (commentReplies == null && !isLoading) {
          // If has replies count but not loaded, show "View X replies"
          final repliesCount = widget.comment['replies_count'] ?? 0;
          if (repliesCount > 0) {
            return TextButton(
              onPressed: () => c.fetchReplies(commentId),
              child: Text('View $repliesCount replies', style: const TextStyle(fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: commentReplies!.length,
          itemBuilder: (context, index) {
            final reply = commentReplies[index];
            return _ReplyItem(reply: reply, parentCommentId: commentId);
          },
        );
      },
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  void _showEditDialog(BuildContext context, NewsDetailController controller, int commentId, String currentText) {
    final editController = TextEditingController(text: currentText);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.updateComment(commentId, editController.text);
              Get.back();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _ReplyItem extends StatelessWidget {
  final Map<String, dynamic> reply;
  final int parentCommentId;
  const _ReplyItem({required this.reply, required this.parentCommentId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsDetailController>();
    final theme = Theme.of(context);
    final currentUserId = controller.storage.read('userId');
    final isMine = reply['user_id'] == currentUserId;
    
    final isLiked = reply['is_liked'] == 1 || reply['is_liked'] == true;
    final likesCount = reply['likes_count'] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.primaryColor.withOpacity(0.05),
            child: const Text(
              'U', // Hardcoded as requested
              style: TextStyle(color: Color(0xFF1E88E5), fontSize: 10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User', // Hardcoded as requested
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (isMine)
                      GestureDetector(
                        onTap: () => controller.deleteReply(reply['id'], parentCommentId),
                        child: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                      ),
                  ],
                ),
                Text(
                  reply['reply'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Obx(() {
                      final commentReplies = controller.replies[parentCommentId];
                      final currentReply = commentReplies?.firstWhere(
                        (r) => r['id'] == reply['id'],
                        orElse: () => reply,
                      ) ?? reply;

                      final isLiked = currentReply['is_liked'] == 1 || currentReply['is_liked'] == true;
                      final likesCount = currentReply['likes_count'] ?? 0;

                      return GestureDetector(
                        onTap: () => controller.likeReply(reply['id'], parentCommentId),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$likesCount',
                              style: TextStyle(fontSize: 11, color: isLiked ? Colors.red : Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }),
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
