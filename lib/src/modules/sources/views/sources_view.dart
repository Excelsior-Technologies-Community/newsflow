import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/api_service.dart';
import '../controllers/sources_controller.dart';
import '../../../models/source_icon_model.dart';

class SourcesView extends GetView<SourcesController> {
  const SourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('News Sources'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        bottom: PreferredSizeWidgetWrapper(
          child: Column(
            children: [
              // 1. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search news sources...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2B354E) : const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // 2. Tab Bar
              Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return TabBar(
                    controller: controller.tabController,
                    indicatorColor: theme.primaryColor,
                    indicatorWeight: 3,
                    labelColor: theme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'All Sources'),
                      Tab(text: 'Following'),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          controller: controller,
        ),
      ),
      body: Obx(() => controller.searchQuery.value.isNotEmpty 
        ? _buildSourceGrid(context, controller.filteredSources)
        : TabBarView(
            controller: controller.tabController,
            children: [
              _buildSourceGrid(context, controller.filteredSources),
              _buildSourceGrid(context, controller.followedSources),
            ],
          ),
      ),
    );
  }

  Widget _buildSourceGrid(BuildContext context, RxList<SourceIconModel> sourceList) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value && sourceList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (sourceList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.source_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.isEmpty ? 'No sources found' : 'No results for "${controller.searchQuery}"',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchSources(),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 0.73,
          ),
          itemCount: sourceList.length,
          itemBuilder: (context, index) {
            final source = sourceList[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: source.iconUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: source.iconUrl.startsWith('http') 
                                    ? source.iconUrl 
                                    : "${ApiService.baseUrl}${source.iconUrl.startsWith('/') ? '' : '/'}${source.iconUrl}",
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.business, color: theme.primaryColor.withOpacity(0.5), size: 40),
                              )
                            : Icon(Icons.business, color: theme.primaryColor.withOpacity(0.5), size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    source.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => controller.toggleFollow(source),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: source.isFollowed.value 
                          ? theme.primaryColor.withOpacity(0.1) 
                          : theme.primaryColor,
                      foregroundColor: source.isFollowed.value 
                          ? theme.primaryColor 
                          : Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: theme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      source.isFollowed.value ? 'Following' : 'Follow',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
              ],
            );
          },
        ),
      );
    });
  }
}

// Custom wrapper to handle dynamic PreferredSize with Obx
class PreferredSizeWidgetWrapper extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final SourcesController controller;

  const PreferredSizeWidgetWrapper({
    super.key, 
    required this.child, 
    required this.controller
  });

  @override
  Widget build(BuildContext context) => child;

  @override
  Size get preferredSize => Size.fromHeight(controller.searchQuery.value.isEmpty ? 110 : 60);
}
