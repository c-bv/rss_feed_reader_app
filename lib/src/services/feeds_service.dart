import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/models/feed_search_result.dart';
import 'package:rss_feed_reader_app/src/services/auth_service.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:convert';

class FeedsService {
  final _firestore = FirebaseFirestore.instance;

 

  Future<List<Map<String, dynamic>>> getUserFeeds() async {
    try {
      String? userId = AuthService().userId;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      List<Map<String, dynamic>> feeds = [];
      if (userDoc.exists) {
        feeds = List<Map<String, dynamic>>.from(userDoc['feeds']);
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
            imageUrl = 'https://via.placeholder.com/150?text=No+Image+Found';
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

  List<FeedSearchResult> parseSearchResults(String responseBody) {
    final parsed = (jsonDecode(responseBody)['results'] as List)
        .cast<Map<String, dynamic>>();
    return parsed
        .map<FeedSearchResult>((json) => FeedSearchResult.fromJson(json))
        .toList();
  }

  Future<List<FeedSearchResult>> searchFeeds(String query) async {
    try {
      final response = await http.get(Uri.parse(
          'https://cloud.feedly.com/v3/search/feeds?query=$query&count=20'));
      return parseSearchResults(response.body);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addFeed(FeedSearchResult feedSearchResult) async {
    try {
      String? userId = AuthService().userId;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
     
      final userFeeds = userDoc.reference.collection('feeds');

      final feed = await http.get(Uri.parse(feedSearchResult.feedUrl));
      final rssFeed = RssFeed.parse(feed.body);

      await userFeeds.add({
        'title': rssFeed.title,
        'iconUrl': feedSearchResult.iconUrl,
        'feedUrl': feedSearchResult.feedUrl,
        'items': rssFeed.items!.map((item) {
          return {
            'title': item.title,
            'link': item.link,
            'value': item.content?.value ?? '',
            'imageUrl': item.content?.images.first ?? '',
            'published': item.pubDate?.toIso8601String() ?? '',
            'read': false,
          };
        }).toList(),
      });

    } catch (e) {
      rethrow;
    }
  }

}