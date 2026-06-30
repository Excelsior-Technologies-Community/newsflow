import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/news_model.dart';
import '../../../core/network/api_service.dart';
import '../../bookmarks/controllers/bookmarks_controller.dart';

class NewsDetailController extends GetxController {
  final ApiService _apiService = ApiService();
  final storage = GetStorage();
  
  final news = Rxn<NewsModel>();
  final isLoading = false.obs;
  
  final comments = <Map<String, dynamic>>[].obs;
  final isCommentsLoading = false.obs;
  
  // Nested replies: Map of commentId -> List of replies
  final replies = <int, List<Map<String, dynamic>>>{}.obs;
  final loadingReplies = <int, bool>{}.obs;

  // History tracking
  int _historyId = 0;
  DateTime? _startTime;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is NewsModel) {
      news.value = Get.arguments;
      _syncBookmarkState();
      fetchFullContent();
      _addToHistory();
      fetchComments();
      _startTime = DateTime.now();
    }
  }

  @override
  void onClose() {
    _updateFinalProgress();
    super.onClose();
  }

  void _syncBookmarkState() {
    if (news.value?.id != null) {
      final bookmarksController = Get.find<BookmarksController>();
      
      // Only overwrite if BookmarksController has at least loaded once from server
      // to avoid defaulting to "false" while it's still fetching.
      if (bookmarksController.hasLoadedOnce.value) {
        news.value!.isBookmarked.value = bookmarksController.isBookmarked(news.value!.id!);
      } else {
        // If not loaded once, we can still check the set, but don't force a 'false' 
        // if it's not there yet. Wait for reactive updates from BookmarksController.
        final isSaved = bookmarksController.isBookmarked(news.value!.id!);
        if (isSaved) {
          news.value!.isBookmarked.value = true;
        }
      }
    }
  }

  Future<void> fetchFullContent() async {
    if (news.value?.id == null) return;
    
    isLoading.value = true;
    try {
      final detailedNews = await _apiService.fetchNewsDetail(news.value!.id!);
      if (detailedNews != null && detailedNews.content.isNotEmpty) {
        // Update content if we got better data
        news.value = NewsModel(
          id: detailedNews.id,
          title: detailedNews.title,
          description: detailedNews.description,
          urlToImage: detailedNews.urlToImage,
          publishedAt: detailedNews.publishedAt,
          source: detailedNews.source,
          link: detailedNews.link,
          content: detailedNews.content,
          author: detailedNews.author,
          category: detailedNews.category,
          shareCount: detailedNews.shareCount,
        );
        _syncBookmarkState();
      }
    } catch (e) {
      print("Full content error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addToHistory() async {
    final token = storage.read('token');
    if (token == null || news.value?.id == null) return;
    
    // In a real app, addToHistory might return the history entry ID
    // For now, we'll assume we can update by news_id if the API supports it,
    // or just call add. Since the user wants ALL endpoints from Swagger:
    await _apiService.addToHistory(news.value!.id!, token);
  }

  Future<void> _updateFinalProgress() async {
    final token = storage.read('token');
    if (token == null || news.value?.id == null || _startTime == null) return;

    final duration = DateTime.now().difference(_startTime!).inSeconds;
    // Simple heuristic for percentage (e.g., 100% after 60 seconds)
    final percentage = (duration / 60.0 * 100).clamp(0.0, 100.0);

    // If we had _historyId, we'd use updateHistoryProgress(_historyId, ...)
    // Since addToHistory is "Add or Update", we'll call it again with progress
    await _apiService.addToHistory(
      news.value!.id!, 
      token, 
      duration: duration, 
      percentage: percentage,
    );
  }

  Future<void> fetchComments() async {
    if (news.value?.id == null) return;
    
    isCommentsLoading.value = true;
    try {
      final token = storage.read('token') ?? '';
      final results = await _apiService.fetchComments(news.value!.id!, token);
      
      // Initialize isLiked for each comment if available in data
      comments.assignAll(results);
    } catch (e) {
      print("Comments error: $e");
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> fetchReplies(int commentId) async {
    loadingReplies[commentId] = true;
    update(); // Notify UI
    try {
      final token = storage.read('token') ?? '';
      final results = await _apiService.fetchReplies(commentId, token);
      replies[commentId] = results;
    } catch (e) {
      print("Replies error: $e");
    } finally {
      loadingReplies[commentId] = false;
      update();
    }
  }

  Future<void> addComment(String text) async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Auth Required', 'Please login to comment');
      return;
    }

    if (news.value?.id == null || text.trim().isEmpty) return;

    print("NewsDetailController: Adding top-level comment: $text");
    bool success = await _apiService.addComment(news.value!.id!, text, token);
    if (success) {
      print("NewsDetailController: Comment added successfully. Refreshing list...");
      await fetchComments();
      comments.refresh();
    } else {
      print("NewsDetailController: FAILED to add comment.");
      Get.snackbar(
        'Comment Exists', 
        'You have already commented on this news. Tap the menu on your comment to Edit it.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addReply(int commentId, String text) async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Auth Required', 'Please login to reply');
      return;
    }

    if (text.trim().isEmpty) return;

    print("NewsDetailController: Adding reply to comment $commentId: $text");
    bool success = await _apiService.addReply(commentId, text, token);
    if (success) {
      print("NewsDetailController: Reply added successfully. Refreshing replies...");
      await fetchReplies(commentId);
      replies.refresh(); // Ensure UI observers trigger
    } else {
      print("NewsDetailController: FAILED to add reply.");
      Get.snackbar('Error', 'Failed to add reply.');
    }
  }

  Future<void> likeComment(int commentId) async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Auth Required', 'Please login to like');
      return;
    }

    // 1. Optimistic Update (UI reacts instantly)
    final index = comments.indexWhere((c) => c['id'] == commentId);
    if (index != -1) {
      final comment = Map<String, dynamic>.from(comments[index]);
      final wasLiked = comment['is_liked'] == 1 || comment['is_liked'] == true;
      
      comment['is_liked'] = !wasLiked ? 1 : 0;
      comment['likes_count'] = (comment['likes_count'] ?? 0) + (!wasLiked ? 1 : -1);
      
      comments[index] = comment;
      comments.refresh(); // Force UI Update
      print("NewsDetailController: Optimistic like updated for comment $commentId. New state: ${!wasLiked}");
    }

    // 2. Network Call
    print("NewsDetailController: Sending like request to API for comment $commentId");
    bool success = await _apiService.likeComment(commentId, token);
    
    if (!success) {
      print("NewsDetailController: Like API FAILED. Reverting state.");
      // 3. Revert if failed
      if (index != -1) {
        final comment = Map<String, dynamic>.from(comments[index]);
        final isNowLiked = comment['is_liked'] == 1 || comment['is_liked'] == true;
        comment['is_liked'] = !isNowLiked ? 1 : 0;
        comment['likes_count'] = (comment['likes_count'] ?? 0) + (!isNowLiked ? 1 : -1);
        comments[index] = comment;
        comments.refresh();
      }
      Get.snackbar('Error', 'Action failed. Please try again.');
    }
  }

  Future<void> likeReply(int replyId, int parentCommentId) async {
    final token = storage.read('token');
    if (token == null) return;

    bool success = await _apiService.likeReply(replyId, token);
    if (success) {
      // Find reply and toggle state
      final commentReplies = replies[parentCommentId];
      if (commentReplies != null) {
        final index = commentReplies.indexWhere((r) => r['id'] == replyId);
        if (index != -1) {
          final reply = Map<String, dynamic>.from(commentReplies[index]);
          final currentlyLiked = reply['is_liked'] == 1 || reply['is_liked'] == true;
          
          reply['is_liked'] = currentlyLiked ? 0 : 1;
          reply['likes_count'] = (reply['likes_count'] ?? 0) + (currentlyLiked ? -1 : 1);
          
          commentReplies[index] = reply;
          replies[parentCommentId] = List<Map<String, dynamic>>.from(commentReplies);
          replies.refresh();
        }
      }
    }
  }

  Future<void> updateComment(int commentId, String newText) async {
    final token = storage.read('token');
    if (token == null || newText.trim().isEmpty) return;

    bool success = await _apiService.updateComment(commentId, newText, token);
    if (success) {
      fetchComments();
    }
  }

  Future<void> deleteComment(int commentId) async {
    final token = storage.read('token');
    if (token == null) return;

    bool success = await _apiService.deleteComment(commentId, token);
    if (success) {
      comments.removeWhere((c) => c['id'] == commentId);
      replies.remove(commentId);
      Get.snackbar('Success', 'Comment deleted');
    }
  }

  Future<void> deleteReply(int replyId, int parentCommentId) async {
    final token = storage.read('token');
    if (token == null) return;

    bool success = await _apiService.deleteReply(replyId, token);
    if (success) {
      replies[parentCommentId]?.removeWhere((r) => r['id'] == replyId);
      replies.refresh();
      Get.snackbar('Success', 'Reply deleted');
    }
  }

  void toggleBookmark() {
    if (news.value != null) {
      Get.find<BookmarksController>().toggleBookmark(news.value!);
    }
  }

  Future<void> shareNews() async {
    final currentNews = news.value;
    if (currentNews == null) return;

    // Trigger System Share
    Share.share('${currentNews.title}\n\nRead more at: ${currentNews.link}');

    // Track share on backend if logged in
    final token = storage.read('token');
    if (token != null && currentNews.id != null) {
      final success = await _apiService.shareNews(currentNews.id!, token);
      if (success) {
        // Increment local share count for immediate feedback
        news.value = NewsModel(
          id: currentNews.id,
          title: currentNews.title,
          description: currentNews.description,
          urlToImage: currentNews.urlToImage,
          publishedAt: currentNews.publishedAt,
          source: currentNews.source,
          link: currentNews.link,
          content: currentNews.content,
          author: currentNews.author,
          category: currentNews.category,
          shareCount: currentNews.shareCount + 1,
        );
        _syncBookmarkState();
      }
    }
  }
}
