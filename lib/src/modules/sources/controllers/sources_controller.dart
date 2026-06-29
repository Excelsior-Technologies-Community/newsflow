import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/network/api_service.dart';
import '../../../models/source_icon_model.dart';

class SourcesController extends GetxController {
  final ApiService _apiService = ApiService();
  final storage = GetStorage();
  
  final sources = <SourceIconModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSources();
  }

  Future<void> fetchSources() async {
    isLoading.value = true;
    try {
      final token = storage.read('token');
      
      // 1. Fetch all sources
      final allSources = await _apiService.fetchSourceIcons();
      
      // 2. Fetch followed sources if logged in
      List<int> followedIds = [];
      if (token != null) {
        followedIds = await _apiService.fetchFollowedSourceIds(token);
      }

      // 3. Sync status
      for (var source in allSources) {
        source.isFollowed.value = followedIds.contains(source.id);
      }

      sources.assignAll(allSources);
    } catch (e) {
      print("Sources controller error: $e");
    } finally {
      isLoading.value = false;
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

    bool success;
    if (source.isFollowed.value) {
      success = await _apiService.followSource(source.id, token);
    } else {
      success = await _apiService.unfollowSource(source.id, token);
    }

    if (!success) {
      // Revert if failed
      source.isFollowed.value = previousState;
      Get.snackbar('Error', 'Failed to update follow status');
    }
  }
}
