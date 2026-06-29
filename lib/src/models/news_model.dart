import 'package:get/get.dart';

class NewsModel {
  final int? id;
  final String title;
  final String description;
  final String urlToImage;
  final String publishedAt;
  final String source;
  final String link;
  final String content;
  final String author;
  final String category;
  final int shareCount;
  
  // Reactive states
  final RxBool isExpanded = false.obs;
  final RxBool isBookmarked = false.obs;

  NewsModel({
    this.id,
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
    required this.link,
    this.content = '',
    this.author = '',
    this.category = '',
    this.shareCount = 0,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // 1. Identify the news data container
    // Some endpoints wrap the news object (e.g., History/Bookmarks)
    final Map<String, dynamic> data = json['news'] != null 
        ? Map<String, dynamic>.from(json['news']) 
        : json;

    // 2. Extract ID with strict priority
    // news_id is our primary cross-table identifier.
    // If news_id exists anywhere (top level or data object), use it.
    // Otherwise fall back to 'id'.
    var rawId = json['news_id'] ?? data['news_id'] ?? data['id'] ?? json['id'];
    int? parsedId = rawId != null ? int.tryParse(rawId.toString()) : null;

    return NewsModel(
      id: parsedId,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      urlToImage: data['image_url']?.toString() ?? data['urlToImage']?.toString() ?? '',
      publishedAt: data['published_at']?.toString() ?? data['publishedAt']?.toString() ?? '',
      source: data['source']?.toString() ?? 'NewsFlow',
      link: data['link']?.toString() ?? '',
      content: data['full_content']?.toString() ?? data['content']?.toString() ?? data['body']?.toString() ?? '',
      author: data['author']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      shareCount: int.tryParse(data['share_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'news_id': id, // Ensure news_id is preserved in serialization
      'title': title,
      'description': description,
      'image_url': urlToImage,
      'published_at': publishedAt,
      'source': source,
      'link': link,
      'content': content,
      'author': author,
      'category': category,
      'share_count': shareCount,
    };
  }
}
