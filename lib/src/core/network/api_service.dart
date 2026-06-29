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
        print("Save Bookmark Failed: ${response.statusCode} - ${data['message']}");
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
      final response = await http.post(
        Uri.parse("$baseUrl/api/comments"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({
          'news_id': newsId,
          'comment': comment,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (e) {
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

  // --- Source Icons ---

  @override
  Future<List<SourceIconModel>> fetchSourceIcons() async {
    try {
      print("ApiService: Fetching source icons from $baseUrl/api/source-icons");
      final response = await http.get(
        Uri.parse("$baseUrl/api/source-icons"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 15));

      print("ApiService: Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("ApiService: Data keys: ${data.keys.toList()}");
        
        // Handle different possible response structures
        final List results = data['data'] is List 
            ? data['data'] 
            : (data['sourceIcons'] is List ? data['sourceIcons'] : (data['results'] is List ? data['results'] : []));
        
        print("ApiService: Found ${results.length} items in 'data'");
        return results.map((json) => SourceIconModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Fetch Source Icons Error: $e");
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
  Future<bool> followSource(int sourceId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/follow-sources"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({"source_id": sourceId}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unfollowSource(int sourceId, String token) async {
    try {
      // Based on the user provided image, unfollow is PATCH /api/follow-sources/unfollow
      final response = await http.patch(
        Uri.parse("$baseUrl/api/follow-sources/unfollow"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
        body: json.encode({"source_id": sourceId}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
