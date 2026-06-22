import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/news_model.dart';
import 'base_news_service.dart';

class ApiService implements BaseNewsService {
  // Your provided ngrok base URL
  static const String baseUrl = "https://swear-cardboard-treading.ngrok-free.dev";

  @override
  Future<List<NewsModel>> fetchNews({required String category, int page = 1}) async {
    try {
      // mapping 'Top News' to a standard 'general' or empty endpoint if needed
      final categoryPath = category == 'Top News' ? 'general' : category.toLowerCase().replaceAll(' ', '_');
      
      final response = await http.get(
        Uri.parse("$baseUrl/api/news?category=$categoryPath&page=$page"),
        headers: {
          "Content-Type": "application/json",
          // Ngrok sometimes requires this header to skip the warning page
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle both direct list or wrapped results (like 'articles' or 'results')
        List results = [];
        if (data is List) {
          results = data;
        } else if (data is Map) {
          results = data['articles'] ?? data['results'] ?? data['news'] ?? [];
        }

        return results.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        print("Backend Error: ${response.statusCode} - ${response.body}");
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Network/Parsing Error: $e");
      rethrow;
    }
  }
}
