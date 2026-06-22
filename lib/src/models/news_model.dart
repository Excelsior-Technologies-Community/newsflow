import 'package:get/get.dart';

class NewsModel {
  final String title;
  final String description;
  final String urlToImage;
  final String publishedAt;
  final String source;
  final RxBool isExpanded = false.obs; // Add reactive expanded state

  NewsModel({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Robust source parsing
    String sourceName = '';
    if (json['source'] != null) {
      if (json['source'] is Map) {
        sourceName = json['source']['name'] ?? '';
      } else {
        sourceName = json['source'].toString();
      }
    }

    return NewsModel(
      title: json['title'] ?? json['headline'] ?? '',
      description: json['description'] ?? json['content'] ?? '',
      urlToImage: json['urlToImage'] ?? json['image_url'] ?? '',
      publishedAt: json['publishedAt'] ?? json['date'] ?? '',
      source: sourceName,
    );
  }
}
