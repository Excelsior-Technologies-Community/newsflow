import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/network/api_service.dart';
import '../../../models/source_icon_model.dart';

class SourcesController extends GetxController with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final storage = GetStorage();
  
  final sources = <SourceIconModel>[].obs;
  final isLoading = false.obs;
  
  // Search and Filtering
  final searchQuery = ''.obs;
  final filteredSources = <SourceIconModel>[].obs;
  final followedSources = <SourceIconModel>[].obs;
  
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchSources();
    
    // Setup dynamic filtering
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchSources() async {
    isLoading.value = true;
    try {
      final token = storage.read('token');
      if (token == null) return;
      
      // 1. Fetch Master List from /api/news-sources
      print("SourcesController: Fetching master list...");
      final allSources = await _apiService.fetchSourceIcons(token);
      print("SourcesController: Fetched ${allSources.length} sources");
      
      // 2. Fetch User Followed List from /api/follow-sources
      print("SourcesController: Fetching user subscriptions...");
      final followedIds = await _apiService.fetchFollowedSourceIds(token);
      print("SourcesController: Subscribed IDs: $followedIds");

      // 3. Sync status: Ensure IDs are correctly matched
      for (var source in allSources) {
        source.isFollowed.value = followedIds.contains(source.id);
      }

      sources.assignAll(allSources);
      _applyFilters();
    } catch (e) {
      print("SourcesController FATAL ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    final query = searchQuery.value.toLowerCase();
    
    // Filter for "All" tab
    if (query.isEmpty) {
      filteredSources.assignAll(sources);
    } else {
      filteredSources.assignAll(sources.where((s) => 
        s.name.toLowerCase().contains(query)
      ).toList());
    }
    
    // Filter for "Following" tab
    followedSources.assignAll(sources.where((s) => s.isFollowed.value).toList());
    if (query.isNotEmpty) {
      followedSources.assignAll(followedSources.where((s) => 
        s.name.toLowerCase().contains(query)
      ).toList());
    }
  }

  Future<void> toggleFollow(SourceIconModel source) async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Auth Required', 'Please login to follow sources');
      return;
    }

    final previousState = source.isFollowed.value;
    source.isFollowed.value = !previousState;
    _applyFilters(); // Update following list immediately

    bool success;
    if (source.isFollowed.value) {
      success = await _apiService.followSource(source.id, source.name, token);
    } else {
      success = await _apiService.unfollowSource(source.id, source.name, token);
    }

    if (!success) {
      source.isFollowed.value = previousState;
      _applyFilters();
      Get.snackbar('Error', 'Failed to update follow status');
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
