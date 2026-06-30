import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/news_model.dart';
import '../../../core/network/api_service.dart';
import '../../news_detail/controllers/news_detail_controller.dart';

class BookmarksController extends GetxController {
  final ApiService _apiService = ApiService();
  final storage = GetStorage();
  
  // The primary source of truth for UI icons
  final savedNewsIds = <int>{}.obs;
  
  // Track if we have completed at least one sync with the server
  final hasLoadedOnce = false.obs;
  
  // The list of news items for the Bookmarks screen
  final bookmarks = <NewsModel>[].obs;
  
  final isLoading = false.obs;
  final _togglingIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final token = storage.read('token');
    if (token == null) return;

    isLoading.value = true;
    try {
      final remoteBookmarks = await _apiService.fetchSavedNews(token);
      
      final Set<int> newIds = {};
      final List<NewsModel> validBookmarks = [];
      
      for (var b in remoteBookmarks) {
        if (b.id != null) {
          newIds.add(b.id!);
          b.isBookmarked.value = true;
          validBookmarks.add(b);
        }
      }
      
      savedNewsIds.assignAll(newIds);
      bookmarks.assignAll(validBookmarks);
      
      // Sync other screens
      for (var id in newIds) {
        _updateGlobalNewsState(id, true);
      }
    } catch (e) {
      print("Error loading bookmarks: $e");
    } finally {
      isLoading.value = false;
      hasLoadedOnce.value = true;
    }
  }

  Future<void> toggleBookmark(NewsModel news) async {
    final newsId = news.id;
    if (newsId == null) {
      Get.snackbar('Error', 'News ID missing. Cannot save.');
      return;
    }

    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Auth Required', 'Please login to save news');
      return;
    }

    // --- OPTIMISTIC UPDATE ---
    bool isCurrentlySaved = savedNewsIds.contains(newsId);
    bool newState = !isCurrentlySaved;

    // 1. Update internal Set (Truth)
    if (newState) {
      savedNewsIds.add(newsId);
      // Add to bookmarks list if not already there
      if (!bookmarks.any((item) => item.id == newsId)) {
        bookmarks.insert(0, news);
      }
    } else {
      savedNewsIds.remove(newsId);
      bookmarks.removeWhere((item) => item.id == newsId);
    }

    // 2. Update the model instance passed in
    news.isBookmarked.value = newState;

    // 3. Sync other screens immediately
    _updateGlobalNewsState(newsId, newState);

    if (_togglingIds.contains(newsId)) return;
    _togglingIds.add(newsId);

    try {
      if (isCurrentlySaved) {
        // --- ACTION: REMOVE ---
        bool success = await _apiService.removeSavedNews(newsId, token);
        if (!success) {
          // Revert on failure
          _revertBookmarkState(news, newsId, true);
          Get.snackbar('Error', 'Server failed to remove bookmark');
        }
      } else {
        // --- ACTION: ADD ---
        bool success = await _apiService.saveNews(newsId, token);
        if (!success) {
          // Revert on failure
          _revertBookmarkState(news, newsId, false);
          Get.snackbar('Error', 'Server failed to save bookmark');
        }
      }
    } catch (e) {
      print("Bookmark toggle exception for ID $newsId: $e");
      // Revert on exception
      _revertBookmarkState(news, newsId, isCurrentlySaved);
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      _togglingIds.remove(newsId);
    }
  }

  void _revertBookmarkState(NewsModel news, int newsId, bool originalState) {
    if (originalState) {
      savedNewsIds.add(newsId);
      if (!bookmarks.any((item) => item.id == newsId)) {
        bookmarks.insert(0, news);
      }
    } else {
      savedNewsIds.remove(newsId);
      bookmarks.removeWhere((item) => item.id == newsId);
    }
    news.isBookmarked.value = originalState;
    _updateGlobalNewsState(newsId, originalState);
  }

  void _updateGlobalNewsState(int newsId, bool isSaved) {
    // Sync with Home if it exists
    try {
      final dynamic home = Get.find(); 
      // Duck typing to see if it's likely HomeController
      if (home != null) {
        // Try to access newsList if it exists on the object
        final List<NewsModel>? newsList = home.newsList;
        if (newsList != null) {
          for (var item in newsList) {
            if (item.id == newsId) {
              item.isBookmarked.value = isSaved;
            }
          }
        }
      }
    } catch (_) {
      // HomeController not registered/active, ignore
    }

    if (Get.isRegistered<NewsDetailController>()) {
      final detailController = Get.find<NewsDetailController>();
      if (detailController.news.value?.id == newsId) {
        detailController.news.value?.isBookmarked.value = isSaved;
      }
    }

    // Also update instances within the bookmarks list itself to keep UI consistent
    for (var item in bookmarks) {
      if (item.id == newsId) {
        item.isBookmarked.value = isSaved;
      }
    }
  }

  bool isBookmarked(int newsId) {
    return savedNewsIds.contains(newsId);
  }
}
