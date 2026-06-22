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
    return NewsModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source'] != null ? json['source']['name'] ?? '' : '',
    );
  }
}
