import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/news_model.dart';
import '../../../core/network/api_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../news_detail/controllers/news_detail_controller.dart';

class BookmarksController extends GetxController {
  final ApiService _apiService = ApiService();
  final storage = GetStorage();
  
  // The primary source of truth for UI icons
  final savedNewsIds = <int>{}.obs;
  
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
    }
  }

  Future<void> toggleBookmark(NewsModel news) async {
    final newsId = news.id;
    if (newsId == null) {
      Get.snackbar('Error', 'News ID missing. Cannot save.');
      return;
    }

    if (_togglingIds.contains(newsId)) return;
    _togglingIds.add(newsId);

    try {
      final token = storage.read('token');
      if (token == null) {
        Get.snackbar('Auth Required', 'Please login to save news');
        return;
      }

      // Check against the Set (Truth)
      bool isCurrentlySaved = savedNewsIds.contains(newsId);
      
      if (isCurrentlySaved) {
        // --- ACTION: REMOVE ---
        bool success = await _apiService.removeSavedNews(newsId, token);
        if (success) {
          savedNewsIds.remove(newsId);
          bookmarks.removeWhere((item) => item.id == newsId);
          news.isBookmarked.value = false;
          _updateGlobalNewsState(newsId, false);
        } else {
          Get.snackbar('Error', 'Server failed to remove bookmark');
        }
      } else {
        // --- ACTION: ADD ---
        bool success = await _apiService.saveNews(newsId, token);
        if (success) {
          savedNewsIds.add(newsId);
          news.isBookmarked.value = true;
          
          // Add to bookmarks list if not already there
          if (!bookmarks.any((item) => item.id == newsId)) {
            bookmarks.insert(0, news);
          }
          
          _updateGlobalNewsState(newsId, true);
        } else {
          Get.snackbar('Error', 'Server failed to save bookmark');
        }
      }
    } catch (e) {
      print("Bookmark toggle exception for ID $newsId: $e");
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      _togglingIds.remove(newsId);
    }
  }

  void _updateGlobalNewsState(int newsId, bool isSaved) {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      for (var item in homeController.newsList) {
        if (item.id == newsId) {
          item.isBookmarked.value = isSaved;
        }
      }
    }

    if (Get.isRegistered<NewsDetailController>()) {
      final detailController = Get.find<NewsDetailController>();
      if (detailController.news.value?.id == newsId) {
        detailController.news.value?.isBookmarked.value = isSaved;
      }
    }
  }

  bool isBookmarked(int newsId) {
    return savedNewsIds.contains(newsId);
  }
}
