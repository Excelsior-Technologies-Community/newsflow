import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/rss_service.dart';
import '../../../models/news_model.dart';
import '../../../core/base/base_controller.dart';

class HomeController extends BaseController {
  final RssService _newsService = RssService();
  
  final newsList = <NewsModel>[].obs;
  final selectedCategory = 'Top News'.obs;
  final currentPage = 1.obs;
  final isFetchingMore = false.obs;
  final hasMore = true.obs;

  final ScrollController scrollController = ScrollController();
  final appBarElevation = 0.0.obs;

  final List<String> categories = [
    'Top News',
    'Stock Market',
    'National',
    'International',
    'Business',
    'Tech News',
    'Health News',
    'New Invention',
    'Cricket',
    'Football'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchNews(selectedCategory.value);
    
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
        newsList.assignAll(results);
        state = ViewState.success;
      }
    } catch (e) {
      errorMessage = e.toString();
      // Detect connection errors manually if connectivity check missed it
      if (e.toString().contains("SocketException") || e.toString().contains("Connection failed")) {
        state = ViewState.noInternet;
      } else {
        state = ViewState.error;
        Get.snackbar('Error', 'Failed to fetch news', snackPosition: SnackPosition.BOTTOM);
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
        newsList.addAll(results);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load more news', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingMore.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
