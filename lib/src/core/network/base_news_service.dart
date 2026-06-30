import '../../models/news_model.dart';
import '../../models/source_icon_model.dart';

abstract class BaseNewsService {
  Future<List<NewsModel>> fetchNews({required String category, int page = 1});
  Future<List<NewsModel>> searchNews(String query, {int page = 1});
  // Method to sync latest news
  Future<List<NewsModel>> performNewsSync();
  Future<NewsModel?> fetchNewsDetail(int id);
  Future<List<String>> fetchAllCategories();
  
  // User News Interactions (Bookmarks)
  Future<bool> saveNews(int newsId, String token);
  Future<List<NewsModel>> fetchSavedNews(String token, {int page = 1});
  Future<NewsModel?> fetchSavedNewsById(int newsId, String token);
  Future<bool> removeSavedNews(int newsId, String token);
  
  // Reading History
  Future<bool> addToHistory(int newsId, String token, {int duration = 0, double percentage = 0});
  Future<List<Map<String, dynamic>>> fetchHistory(String token, {int page = 1});
  Future<Map<String, dynamic>?> fetchHistoryById(int historyId, String token);
  Future<bool> updateHistoryProgress(int historyId, String token, {int duration = 0, double percentage = 0});
  Future<bool> deleteHistoryItem(int historyId, String token);
  Future<bool> clearHistory(String token);
  
  // Comments
  Future<List<Map<String, dynamic>>> fetchComments(int newsId, String token);
  Future<bool> addComment(int newsId, String comment, String token);
  Future<bool> likeComment(int commentId, String token);
  Future<bool> updateComment(int commentId, String text, String token);
  Future<bool> deleteComment(int commentId, String token);

  // Replies
  Future<List<Map<String, dynamic>>> fetchReplies(int commentId, String token);
  Future<bool> addReply(int commentId, String reply, String token);
  Future<bool> likeReply(int replyId, String token);
  Future<bool> deleteReply(int replyId, String token);

  // Sharing
  Future<bool> shareNews(int newsId, String token);

  // Source Icons (Now News Sources)
  Future<List<SourceIconModel>> fetchSourceIcons(String token);
  
  // Follow Sources
  Future<List<int>> fetchFollowedSourceIds(String token);
  Future<bool> followSource(int sourceId, String sourceName, String token);
  Future<bool> unfollowSource(int sourceId, String sourceName, String token);
}
