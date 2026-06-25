import '../../models/news_model.dart';

abstract class BaseNewsService {
  Future<List<NewsModel>> fetchNews({required String category, int page = 1});
  Future<List<String>> fetchAllCategories();
}
