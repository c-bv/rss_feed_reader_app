import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/models/feed_search_result.dart';
import 'package:rss_feed_reader_app/src/services/auth_service.dart';
import 'package:webfeed/webfeed.dart';

class FeedsService {
  final _firestore = FirebaseFirestore.instance;
  final _userId = AuthService().userId;

  Future<List<Map<String, dynamic>>> getUserFeeds() async {
    try {
      var userFeeds =
          _firestore.collection('users').doc(_userId).collection('feeds');

      var feeds = await userFeeds.get(const GetOptions(source: Source.cache));

      if (feeds.docs.isEmpty) {
        feeds = await userFeeds.get();
      }

      return feeds.docs.map((feed) {
        return {
          'id': feed.id,
          'title': feed['title'],
          'iconUrl': feed['iconUrl'],
          'feedUrl': feed['feedUrl'],
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getAllArticles() async {
    var userFeeds =
        _firestore.collection('users').doc(_userId).collection('feeds');
    var feeds = await userFeeds.get();
    List<Article> allArticles = [];

    for (var feed in feeds.docs) {
      var articles = await getArticlesFromFeed(feed['feedUrl']);
      allArticles.addAll(articles);
    }

    return allArticles;
  }

  Future<List<Article>> getArticlesFromFeed(String feedUrl) async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      final rssFeed = RssFeed.parse(response.body);

      return rssFeed.items!.map((rssItem) {
        String? imageUrl;

        if (rssItem.enclosure != null &&
            rssItem.enclosure!.type?.startsWith('image/') == true) {
          imageUrl = rssItem.enclosure!.url ?? '';
        } else {
          var document = rssItem.content?.value != null
              ? html_parser.parse(rssItem.content!.value)
              : null;
          var elements = document?.getElementsByTagName('img');
          if (elements != null && elements.isNotEmpty) {
            imageUrl = elements.first.attributes['src'] ?? '';
          } else {
            imageUrl = null;
          }
        }
        return Article(
          title: rssItem.title ?? 'No Title',
          link: rssItem.link ?? '#',
          value: rssItem.description ?? 'No Description',
          imageUrl: imageUrl,
          pubDate: rssItem.pubDate?.toIso8601String() ?? '',
          read: false,
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
      var userFeeds =
          _firestore.collection('users').doc(_userId).collection('feeds');

      var existingFeed = await userFeeds
          .where('feedUrl', isEqualTo: feedSearchResult.feedUrl)
          .get();

      if (existingFeed.docs.isNotEmpty) {
        throw Exception('You have already subscribed to this feed');
      }

      http.Response feedResponse;
      try {
        feedResponse = await http.get(Uri.parse(feedSearchResult.feedUrl));
      } catch (e) {
        throw Exception(
            'Network error: Unable to fetch feed. Please try again when online.');
      }
      final rssFeed = RssFeed.parse(feedResponse.body);

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
            'pubDate': item.pubDate?.toIso8601String() ?? '',
            'read': false,
          };
        }).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
