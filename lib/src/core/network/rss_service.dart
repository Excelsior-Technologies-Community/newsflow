import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../models/news_model.dart';
import 'base_news_service.dart';

class RssService implements BaseNewsService {
  final Map<String, String> _categoryFeeds = {
    'Top News': 'https://news.google.com/rss?hl=en-IN&gl=IN&ceid=IN:en',
    'Business': 'https://news.google.com/rss/headlines/section/topic/BUSINESS?hl=en-IN&gl=IN&ceid=IN:en',
    'Tech News': 'https://news.google.com/rss/headlines/section/topic/TECHNOLOGY?hl=en-IN&gl=IN&ceid=IN:en',
    'Health News': 'https://news.google.com/rss/headlines/section/topic/HEALTH?hl=en-IN&gl=IN&ceid=IN:en',
    'Cricket': 'https://news.google.com/rss/search?q=cricket&hl=en-IN&gl=IN&ceid=IN:en',
    'Football': 'https://news.google.com/rss/search?q=football&hl=en-IN&gl=IN&ceid=IN:en',
    'Stock Market': 'https://news.google.com/rss/search?q=stock%20market&hl=en-IN&gl=IN&ceid=IN:en',
    'National': 'https://news.google.com/rss/headlines/section/topic/NATION?hl=en-IN&gl=IN&ceid=IN:en',
    'International': 'https://news.google.com/rss/headlines/section/topic/WORLD?hl=en-IN&gl=IN&ceid=IN:en',
    'New Invention': 'https://news.google.com/rss/search?q=new%20invention&hl=en-IN&gl=IN&ceid=IN:en',
  };

  @override
  Future<List<NewsModel>> fetchNews({required String category, int page = 1}) async {
    final url = _categoryFeeds[category] ?? _categoryFeeds['Top News']!;
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        // Manual pagination simulation: RSS usually returns 50+ items at once.
        // We'll increase the items per page to provide more content.
        const int itemsPerPage = 20; 
        final start = (page - 1) * itemsPerPage;
        final end = start + itemsPerPage;
        
        final pagedItems = items.length > start 
            ? items.toList().sublist(start, items.length > end ? end : items.length)
            : <XmlElement>[];

        return pagedItems.map((node) {
          final title = node.findElements('title').single.innerText;
          final description = node.findElements('description').isNotEmpty 
              ? node.findElements('description').single.innerText 
              : '';
          final pubDate = node.findElements('pubDate').isNotEmpty 
              ? node.findElements('pubDate').single.innerText 
              : '';
          final source = node.findElements('source').isNotEmpty 
              ? node.findElements('source').single.innerText 
              : 'Google News';
          
          // Better Image Extraction: Check description HTML and potential media tags
          String imageUrl = '';
          
          // 1. Try to find img src in description
          final imgRegex = RegExp(r'src="([^"]+)"');
          final match = imgRegex.firstMatch(description);
          if (match != null) {
            imageUrl = match.group(1) ?? '';
            // Handle relative URLs or protocol-relative
            if (imageUrl.startsWith('//')) imageUrl = 'https:$imageUrl';
          }

          // 2. Fallback: Check for enclosure or media:content tags
          if (imageUrl.isEmpty) {
            final enclosure = node.findElements('enclosure');
            if (enclosure.isNotEmpty) {
              imageUrl = enclosure.first.getAttribute('url') ?? '';
            }
          }

          /* Removed Smart Image Generation to use only direct API images as requested */

          // Strip HTML tags from description to get clean text
          final cleanDescription = description
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .replaceAll('&nbsp;', ' ')
              .trim();

          return NewsModel(
            title: title,
            description: cleanDescription,
            urlToImage: imageUrl,
            publishedAt: pubDate,
            source: source,
          );
        }).toList();
      } else {
        throw Exception('Failed to load RSS feed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
