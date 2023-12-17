import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/services/auth_service.dart';
import 'package:webfeed/webfeed.dart';

class FeedsService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> postFeed({required String name, required String url}) async {
    try {
      DocumentReference feedDocRef = _firestore.collection('feeds').doc();
      await feedDocRef.set({
        'name': name,
        'url': url,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserFeeds() async {
    try {
      String? userId = AuthService().userId;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      List<DocumentReference> userFeedsRefs = List.from(userDoc['feeds']);
      List<Map<String, dynamic>> feeds = [];

      for (DocumentReference feedRef in userFeedsRefs) {
        DocumentSnapshot feedDoc = await feedRef.get();
        feeds.add(feedDoc.data() as Map<String, dynamic>);
      }

      return feeds;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getArticlesFromFeed(String feedUrl) async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      final rssFeed = RssFeed.parse(response.body);

      return rssFeed.items!.map((rssItem) {
        String imageUrl = '';

        if (rssItem.enclosure != null &&
            rssItem.enclosure!.type?.startsWith('image/') == true) {
          imageUrl = rssItem.enclosure!.url ?? '';
        } else {
          // Parse the content for the first image
          var document = rssItem.content?.value != null
              ? html_parser.parse(rssItem.content!.value)
              : null;
          var elements = document?.getElementsByTagName('img');
          if (elements != null && elements.isNotEmpty) {
            imageUrl = elements.first.attributes['src'] ?? '';
          } else {
            // Use placeholder if no image is found
            imageUrl =
                'https://via.placeholder.com/150?text=No+Image+Found';
          }
        }
        return Article(
          title: rssItem.title ?? 'No Title',
          link: rssItem.link ?? '#',
          description: rssItem.description ?? 'No Description',
          imageUrl: imageUrl,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
