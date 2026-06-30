import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_service.dart';
import '../../../models/news_model.dart';
import '../../../core/base/base_controller.dart';
import '../../bookmarks/controllers/bookmarks_controller.dart';

class HomeController extends BaseController {
  final _newsService = ApiService();
  
  final newsList = <NewsModel>[].obs;
  final selectedCategory = 'Top News'.obs;
  final currentPage = 1.obs;
  final isFetchingMore = false.obs;
  final hasMore = true.obs;

  final ScrollController scrollController = ScrollController();
  final appBarElevation = 0.0.obs;

  final categories = <String>['Top News', 'India', 'World', 'Business', 'Sports', 'AI'].obs;

  // Search Implementation
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    discoverCategories();
    fetchNews(selectedCategory.value);
    _startSyncTimer();
    
    // Debounce search input
    debounce(searchQuery, (query) {
      if (query.isNotEmpty) {
        performSearch(query);
      } else if (isSearching.value) {
        // If query cleared while in search mode, go back to category
        fetchNews(selectedCategory.value);
      }
    }, time: const Duration(milliseconds: 500));

    scrollController.addListener(() {
      // Handle App Bar Elevation
      appBarElevation.value = scrollController.offset > 10 ? 2.0 : 0.0;

      // Handle Pagination: Trigger earlier (300px from bottom)
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300) {
        if (!isFetchingMore.value && hasMore.value && state == ViewState.success) {
          fetchMoreNews();
        }
      }
    });
  }

  Future<void> fetchNews(String category, {bool showLoading = true}) async {
    // Reset search if we are switching categories manually
    if (!isSearching.value) {
      searchQuery.value = '';
      searchController.clear();
    }

    if (showLoading) {
      state = ViewState.loading;
      newsList.clear(); 
    }
    selectedCategory.value = category;
    currentPage.value = 1;
    hasMore.value = true;

    if (!await checkConnectivity()) return;

    try {
      final results = await _newsService.fetchNews(category: category, page: 1);
      if (results.isEmpty) {
        state = ViewState.empty;
      } else {
        // Sync bookmark state for newly fetched news
        if (Get.isRegistered<BookmarksController>()) {
          final bookmarksController = Get.find<BookmarksController>();
          for (var item in results) {
            if (item.id != null) {
              _syncItemBookmark(item, bookmarksController);
            }
          }
        }
        newsList.assignAll(results);
        state = ViewState.success;
      }
    } catch (e) {
      errorMessage = e.toString().contains("SocketException") 
          ? "Cannot connect to backend server. Is ngrok running?" 
          : "Server error or parsing failure: $e";
          
      // Detect connection errors manually if connectivity check missed it
      if (e.toString().contains("SocketException") || e.toString().contains("Connection failed")) {
        state = ViewState.noInternet;
      } else {
        state = ViewState.error;
        Get.snackbar('Build Error', errorMessage, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
      }
    }
  }

  Future<void> fetchMoreNews() async {
    isFetchingMore.value = true;
    currentPage.value++;

    try {
      final List<NewsModel> results;
      if (isSearching.value && searchQuery.value.isNotEmpty) {
        results = await (_newsService as dynamic).searchNews(
          searchQuery.value, 
          page: currentPage.value
        );
      } else {
        results = await _newsService.fetchNews(
          category: selectedCategory.value, 
          page: currentPage.value
        );
      }
      
      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        // Sync bookmark state for newly fetched news
        if (Get.isRegistered<BookmarksController>()) {
          final bookmarksController = Get.find<BookmarksController>();
          for (var item in results) {
            if (item.id != null) {
              _syncItemBookmark(item, bookmarksController);
            }
          }
        }
        newsList.addAll(results);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load more news', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingMore.value = false;
    }
  }

  Future<void> discoverCategories() async {
    try {
      final discovered = await _newsService.fetchAllCategories();
      if (discovered.isNotEmpty) {
        // Keep 'Top News' as the first item, then add discovered categories
        categories.assignAll(['Top News', ...discovered]);
      }
    } catch (e) {
      print("Failed to discover categories: $e");
    }
  }

  void _startSyncTimer() {
    // Sync every 30 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (selectedCategory.value == 'Top News') {
        performBackgroundSync();
      }
    });
  }

  Future<void> performBackgroundSync() async {
    try {
      print("HomeController: Starting background sync for category: ${selectedCategory.value}");
      final List<NewsModel> results = await _newsService.performNewsSync();
      
      if (results.isNotEmpty) {
        // Sync bookmark state for new items
        if (Get.isRegistered<BookmarksController>()) {
          final bookmarksController = Get.find<BookmarksController>();
          for (var item in results) {
            if (item.id != null) {
              _syncItemBookmark(item, bookmarksController);
            }
          }
        }

        // Add only new unique items to the top
        final currentIds = newsList.map((e) => e.id).toSet();
        final newItems = results.where((item) => !currentIds.contains(item.id)).toList();

        if (newItems.isNotEmpty) {
          newsList.insertAll(0, newItems);
          Get.snackbar(
            'New Updates', 
            'Added ${newItems.length} new news items',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blueAccent.withAlpha(204), // Approx 0.8 opacity
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print("Background sync failed: $e");
    }
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
      searchController.clear();
      fetchNews(selectedCategory.value);
    }
  }

  Future<void> performSearch(String query) async {
    state = ViewState.loading;
    newsList.clear();
    currentPage.value = 1;
    hasMore.value = true;

    if (!await checkConnectivity()) return;

    try {
      final results = await (_newsService as dynamic).searchNews(query, page: 1);
      if (results.isEmpty) {
        state = ViewState.empty;
      } else {
        if (Get.isRegistered<BookmarksController>()) {
          final bookmarksController = Get.find<BookmarksController>();
          for (var item in results) {
            if (item.id != null) {
              _syncItemBookmark(item, bookmarksController);
            }
          }
        }
        newsList.assignAll(results);
        state = ViewState.success;
      }
    } catch (e) {
      state = ViewState.error;
    }
  }

  void _syncItemBookmark(NewsModel item, BookmarksController bookmarksController) {
    if (bookmarksController.hasLoadedOnce.value) {
      item.isBookmarked.value = bookmarksController.isBookmarked(item.id!);
    } else {
      if (bookmarksController.isBookmarked(item.id!)) {
        item.isBookmarked.value = true;
      }
    }
  }
}
