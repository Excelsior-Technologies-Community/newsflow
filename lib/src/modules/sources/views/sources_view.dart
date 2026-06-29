import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/sources_controller.dart';

class SourcesView extends GetView<SourcesController> {
  const SourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Sources'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.sources.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sources.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.source_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No sources available',
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.fetchSources(),
                  child: const Text('Retry'),
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
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65, // Taller ratio to prevent overflow
            ),
            itemCount: controller.sources.length,
            itemBuilder: (context, index) {
              final source = controller.sources[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: source.iconUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: source.iconUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.business, color: theme.primaryColor.withOpacity(0.5), size: 30),
                              )
                            : Icon(Icons.business, color: theme.primaryColor.withOpacity(0.5), size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          source.name.isNotEmpty ? source.name : "Source ${source.id}",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 26,
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
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(
                                  color: theme.primaryColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              source.isFollowed.value ? 'Following' : 'Follow',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
