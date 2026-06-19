import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/news_model.dart';

class ApiService {
  // TODO: Replace with your actual backend URL provided by your team
  static const String baseUrl = "https://newsapi.org/v2"; 
  static const String apiKey = "YOUR_API_KEY_HERE"; // Placeholder

  Future<List<NewsModel>> fetchNews(String category) async {
    try {
      // Note: This is a placeholder structure. 
      // Replace with your team's endpoint and parameter structure.
      final response = await http.get(
        Uri.parse("$baseUrl/top-headlines?category=$category&apiKey=$apiKey"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['articles'];
        return results.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      // For now, return an empty list or rethrow
      return [];
    }
  }
}
