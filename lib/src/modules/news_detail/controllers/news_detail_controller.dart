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
      news.value!.isBookmarked.value = bookmarksController.isBookmarked(news.value!.id!);
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
      comments.assignAll(results);
    } catch (e) {
      print("Comments error: $e");
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment(String text) async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Auth Required', 'Please login to comment');
      return;
    }

    if (news.value?.id == null || text.trim().isEmpty) return;

    bool success = await _apiService.addComment(news.value!.id!, text, token);
    if (success) {
      fetchComments(); // Refresh list
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
