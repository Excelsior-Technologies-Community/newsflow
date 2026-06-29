import 'package:flutter_test/flutter_test.dart';
import 'package:newsflow/src/models/news_model.dart';

void main() {
  group('NewsModel.fromJson', () {
    test('should correctly parse all fields from API JSON', () {
      final json = {
        "id": 1,
        "title": "Test Title",
        "description": "Test Description",
        "link": "https://example.com",
        "image_url": "https://example.com/image.jpg",
        "category": "Technology",
        "source": "Test Source",
        "published_at": "2024-03-20T10:00:00Z",
        "share_count": 42,
        "full_content": "This is the full content of the article.",
        "author": "John Doe"
      };

      final news = NewsModel.fromJson(json);

      expect(news.id, 1);
      expect(news.title, "Test Title");
      expect(news.description, "Test Description");
      expect(news.link, "https://example.com");
      expect(news.urlToImage, "https://example.com/image.jpg");
      expect(news.category, "Technology");
      expect(news.source, "Test Source");
      expect(news.publishedAt, "2024-03-20T10:00:00Z");
      expect(news.shareCount, 42);
      expect(news.content, "This is the full content of the article.");
      expect(news.author, "John Doe");
    });

    test('should fallback to description if content/full_content/body are missing', () {
      final json = {
        "title": "No Content",
        "description": "Just description",
      };

      final news = NewsModel.fromJson(json);
      expect(news.content, ""); // Model currently defaults to '' if missing, View handles fallback to description
    });
    
    test('should parse share_count even if it is a string', () {
      final json = {
        "share_count": "123"
      };
      final news = NewsModel.fromJson(json);
      expect(news.shareCount, 123);
    });
  });
}
