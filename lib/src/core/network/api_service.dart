import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/news_model.dart';
import '../../models/source_icon_model.dart';
import 'base_news_service.dart';

class ApiService implements BaseNewsService {
  static const String baseUrl = "https://mushy-chop-entrap.ngrok-free.dev";

  @override
  Future<List<NewsModel>> fetchNews({required String category, int page = 1}) async {
    try {
      final categoryPath = category == 'Top News' ? '' : category;
      final response = await http.get(
        Uri.parse("$baseUrl/api/news?category=$categoryPath&page=$page"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        return results.map((json) => NewsModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Fetch News Error: $e");
      return [];
    }
  }

  @override
  Future<List<NewsModel>> searchNews(String query, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/news?search=$query&page=$page"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        return results.map((json) => NewsModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Search News Error: $e");
      return [];
    }
  }

  @override
  Future<List<NewsModel>> performNewsSync() async {
    try {
      print("ApiService: Syncing news from $baseUrl/api/news/sync");
      final response = await http.get(
        Uri.parse("$baseUrl/api/news/sync"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        return results.map((json) => NewsModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Sync News Error: $e");
      return [];
    }
  }

  @override
  Future<NewsModel?> fetchNewsDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/news/$id"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> item = data['data'] ?? {};
        if (item.isNotEmpty) {
          return NewsModel.fromJson(item);
        }
      }
      return null;
    } catch (e) {
      print("Detail Fetch Error: $e");
      return null;
    }
  }

  @override
  Future<List<String>> fetchAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/news?limit=300"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        final Set<String> categorySet = {};
        for (var item in results) {
          final cat = item['category']?.toString().trim() ?? '';
          if (cat.isNotEmpty) categorySet.add(cat);
        }
        final categories = categorySet.toList();
        categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        return categories;
      }
      return [];
    } catch (e) {
      print("Category Discovery Error: $e");
      return [];
    }
  }

  // --- Bookmarks (Saved News) ---

  @override
  Future<bool> saveNews(int newsId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/news/save"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({"news_id": newsId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Save Bookmark Success: $newsId");
        return true;
      } else {
        final data = json.decode(response.body);
        final message = data['message']?.toString() ?? '';
        print("Save Bookmark Failed: ${response.statusCode} - $message");
        
        // Handle "Duplicate entry" as success (it's already saved)
        if (message.contains('Duplicate entry') || response.statusCode == 409) {
          print("Save Bookmark: Item already exists. Treating as success.");
          return true;
        }

        return false;
      }
    } catch (e) {
      print("Save Bookmark Exception: $e");
      return false;
    }
  }

  @override
  Future<List<NewsModel>> fetchSavedNews(String token, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/users/news/saved?page=$page"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        return results.map((json) => NewsModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<NewsModel?> fetchSavedNewsById(int newsId, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/users/news/saved/$newsId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> item = data['data'] ?? {};
        if (item.isNotEmpty) {
          return NewsModel.fromJson(item);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> removeSavedNews(int newsId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/users/news/saved/$newsId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Remove Bookmark Success: $newsId");
        return true;
      } else {
        print("Remove Bookmark Failed: ${response.statusCode}");
        // If not found, it's already removed, so treat as success
        if (response.statusCode == 404) {
          return true;
        }
        return false;
      }
    } catch (e) {
      print("Remove Bookmark Exception: $e");
      return false;
    }
  }

  // --- Reading History ---

  @override
  Future<bool> addToHistory(int newsId, String token, {int duration = 0, double percentage = 0}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/reading-history"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({
          "news_id": newsId,
          "read_duration": duration,
          "read_percentage": percentage,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistory(String token, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/reading-history?page=$page"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        return results.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchHistoryById(int historyId, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/reading-history/$historyId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateHistoryProgress(int historyId, String token, {int duration = 0, double percentage = 0}) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/api/reading-history/$historyId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({
          "read_duration": duration,
          "read_percentage": percentage,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteHistoryItem(int historyId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/reading-history/$historyId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearHistory(String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/reading-history"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Comments ---

  @override
  Future<List<Map<String, dynamic>>> fetchComments(int newsId, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/comments?news_id=$newsId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        return results.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> addComment(int newsId, String comment, String token) async {
    try {
      final url = Uri.parse("$baseUrl/api/comments");
      print("ApiService: Adding Comment to News ID: $newsId");
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({
          'news_id': newsId,
          'comment': comment,
        }),
      ).timeout(const Duration(seconds: 15));

      print("ApiService: Add Comment Response Status: ${response.statusCode}");
      print("ApiService: Add Comment Response Body: ${response.body}");

      // Handle 200 or 201 as success
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("ApiService: Add Comment Exception: $e");
      return false;
    }
  }

  @override
  Future<bool> likeComment(int commentId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/comments/like"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({"comment_id": commentId}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateComment(int commentId, String text, String token) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/api/comments/$commentId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({'comment': text}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteComment(int commentId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/comments/$commentId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Replies ---

  @override
  Future<List<Map<String, dynamic>>> fetchReplies(int commentId, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/comments/$commentId/replies"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        return results.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> addReply(int commentId, String reply, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/comment-replies/reply"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({
          'comment_id': commentId,
          'reply': reply,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> likeReply(int replyId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/comments/replies/like"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({"reply_id": replyId}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteReply(int replyId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/comments/replies/$replyId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Sharing ---

  @override
  Future<bool> shareNews(int newsId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/news/$newsId/share"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Share News Success: $newsId");
        return true;
      } else {
        print("Share News Failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Share News Exception: $e");
      return false;
    }
  }

  // --- Source Icons (Now News Sources) ---

  @override
  Future<List<SourceIconModel>> fetchSourceIcons(String token) async {
    try {
      print("ApiService: Fetching news sources from $baseUrl/api/news-sources");
      final response = await http.get(
        Uri.parse("$baseUrl/api/news-sources"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 15));

      print("ApiService: Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("ApiService: Raw Response Body: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Handle different possible response structures
        final List results = data['data'] is List 
            ? data['data'] 
            : (data['newsSources'] is List ? data['newsSources'] : (data['results'] is List ? data['results'] : []));
        
        if (results.isNotEmpty) {
          print("ApiService: First source item JSON: ${results.first}");
        }
        
        print("ApiService: Found ${results.length} items in master list");
        return results.map((json) => SourceIconModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Fetch News Sources Error: $e");
      return [];
    }
  }

  // --- Follow Sources ---

  @override
  Future<List<int>> fetchFollowedSourceIds(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/follow-sources"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['data'] ?? [];
        // Assuming data is a list of objects that have source_id or id
        return results.map((item) => (item['source_id'] ?? item['id']) as int).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> followSource(int sourceId, String sourceName, String token) async {
    try {
      final url = Uri.parse("$baseUrl/api/follow-sources");
      print("ApiService: Following - ID: $sourceId, Name: '$sourceName'");
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({
          "source_id": sourceId,
          "source_name": sourceName.trim(), 
        }),
      ).timeout(const Duration(seconds: 15));

      print("ApiService: Follow Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 500) {
        print("ApiService: Retrying with 'news_source_id' key...");
        final retryResponse = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
            "ngrok-skip-browser-warning": "true",
          },
          body: json.encode({
            "news_source_id": sourceId,
            "source_name": sourceName.trim(),
          }),
        ).timeout(const Duration(seconds: 15));
        print("ApiService: Retry Response: ${retryResponse.statusCode} - ${retryResponse.body}");
        return retryResponse.statusCode == 200 || retryResponse.statusCode == 201;
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ApiService: Follow Exception: $e");
      return false;
    }
  }

  @override
  Future<bool> unfollowSource(int sourceId, String sourceName, String token) async {
    try {
      final url = Uri.parse("$baseUrl/api/follow-sources/unfollow");
      print("ApiService: Unfollowing - ID: $sourceId, Name: $sourceName");

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({
          "source_id": sourceId,
          "source_name": sourceName, // Match Follow payload for consistency
        }),
      ).timeout(const Duration(seconds: 15));

      print("ApiService: Unfollow Response: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService: Unfollow Exception: $e");
      return false;
    }
  }
}
