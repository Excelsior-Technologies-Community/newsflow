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
      // mapping 'Top News' to empty string to fetch all news as default
      final categoryPath = category == 'Top News' ? '' : category;
      
      final response = await http.get(
        Uri.parse("$baseUrl/api/news?category=$categoryPath&page=$page"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection Timeout. Please check your server.'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // The backend wraps news in a "data" field
        final List results = data['data'] ?? [];

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
