import 'package:get/get.dart';
import '../../../core/network/api_service.dart';
import '../../../models/news_model.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = true.obs;
  var newsList = <NewsModel>[].obs;
  var topNews = <NewsModel>[].obs;
  var selectedCategory = 'General'.obs;

  final List<String> categories = [
    'Top News',
    'Stock Market',
    'National',
    'International',
    'Business',
    'Cricket',
    'Football',
    'Tech News',
    'Health News',
    'New Invention'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchNews('Top News');
  }

  void fetchNews(String category) async {
    isLoading.value = true;
    selectedCategory.value = category;
    
    // Using dummy data for testing the new UI structure
    await Future.delayed(const Duration(milliseconds: 800));
    
    final dummyData = [
      NewsModel(
        title: "India's Nuclear Arsenal Swells To 190: Which Country Has Most Nuke Warheads",
        description: "For the first time, India has kept 12 nuclear warheads deployed during peacetime, breaking with its longstanding practice of storing warheads separately from delivery systems such as ballistic missiles, according to SIPRI.",
        urlToImage: "https://images.unsplash.com/photo-1569003339405-ea396a5a8a90?q=80&w=1000&auto=format&fit=crop", // More reliable Unsplash URL
        publishedAt: "09 June 2026 • 7.49 PM IST",
        source: "INDIA'S NUCLEAR",
      ),
      NewsModel(
        title: "Stock Market Reaches New All-Time High Amid Positive Global Cues",
        description: "Investors are optimistic as the main indices surged to record levels today. Analysts suggest that the trend might continue given the current economic climate and strong corporate earnings reported this quarter.",
        urlToImage: "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?q=80&w=1000&auto=format&fit=crop", // New reliable Stock Market image
        publishedAt: "10 June 2026 • 10:15 AM IST",
        source: "MARKET UPDATE",
      ),
    ];

    newsList.assignAll(dummyData);
    topNews.assignAll(dummyData);
    isLoading.value = false;
  }
}
