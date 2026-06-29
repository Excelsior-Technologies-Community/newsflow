import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/base_news_service.dart';
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

  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    discoverCategories();
    fetchNews(selectedCategory.value);
    _startSyncTimer();
    
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
    if (showLoading) state = ViewState.loading;
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
              item.isBookmarked.value = bookmarksController.isBookmarked(item.id!);
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
      final results = await _newsService.fetchNews(
        category: selectedCategory.value, 
        page: currentPage.value
      );
      
      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        // Sync bookmark state for newly fetched news
        if (Get.isRegistered<BookmarksController>()) {
          final bookmarksController = Get.find<BookmarksController>();
          for (var item in results) {
            if (item.id != null) {
              item.isBookmarked.value = bookmarksController.isBookmarked(item.id!);
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
              item.isBookmarked.value = bookmarksController.isBookmarked(item.id!);
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
    super.onClose();
  }
}
