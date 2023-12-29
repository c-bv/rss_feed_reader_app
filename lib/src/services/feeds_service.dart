import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/models/feed.dart';
import 'package:rss_feed_reader_app/src/services/auth_service.dart';
import 'package:webfeed/webfeed.dart';
import 'package:xml/xml.dart' as xml;

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
          'title': feed['title'],
          'iconUrl': feed['iconUrl'],
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
      var feedArticles = feed['items'].map<Article>((article) {
        return Article(
          title: article['title'],
          feedTitle: feed['title'],
          link: article['link'],
          description: article['description'],
          content: article['content'],
          author: article['author'],
          imageUrl: article['imageUrl'],
          iconUrl: feed['iconUrl'],
          pubDate: article['pubDate'],
          read: article['read'],
        );
      }).toList();
      allArticles.addAll(feedArticles);
    }
    return allArticles;
  }

  List<Feed> parseSearchResults(String responseBody) {
    final parsed = (jsonDecode(responseBody)['results'] as List)
        .cast<Map<String, dynamic>>();
    return parsed.map<Feed>((json) => Feed.fromJson(json)).toList();
  }

  Future<List<Feed>> searchFeeds(String query) async {
    try {
      final response = await http.get(Uri.parse(
          'https://cloud.feedly.com/v3/search/feeds?query=$query&count=20'));
      return parseSearchResults(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> detectFeedType(String xmlString) async {
    try {
      var document = xml.XmlDocument.parse(xmlString);
      var root = document.rootElement;

      if (root.name.local == 'rss') {
        return 'RSS';
      } else if (root.name.local == 'feed') {
        return 'Atom';
      } else {
        throw Exception('Unknown feed type');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFeed(Feed feedSearchResult) async {
    try {
      var userFeeds =
          _firestore.collection('users').doc(_userId).collection('feeds');

      var existingFeed =
          await userFeeds.where('link', isEqualTo: feedSearchResult.link).get();

      if (existingFeed.docs.isNotEmpty) {
        throw Exception('You have already subscribed to this feed');
      }

      http.Response feedResponse;
      try {
        feedResponse = await http.get(Uri.parse(feedSearchResult.link!));
      } catch (e) {
        throw Exception(
            'Network error: Unable to fetch feed. Please try again when online.');
      }

      final feedType = await detectFeedType(feedResponse.body);

      List<Map<String, dynamic>> items;

      if (feedType == 'RSS') {
        var rssFeed = RssFeed.parse(feedResponse.body);
        items = rssFeed.items!.map((item) {
          return {
            'title': item.title,
            'description': item.description,
            'content': item.content?.value,
            'author': item.dc?.creator,
            'link': item.link,
            'imageUrl': item.content?.images.first,
            'pubDate': item.pubDate?.toIso8601String(),
            'read': false,
          };
        }).toList();
      } else if (feedType == 'Atom') {
        var atomFeed = AtomFeed.parse(feedResponse.body);
        items = atomFeed.items!.map((item) {
          return {
            'title': item.title,
            'description': item.summary,
            'content': item.content,
            'author': item.authors?.map((a) => a.name).join(', '),
            'link': item.links?.first.href,
            'imageUrl':
                item.links?.firstWhere((l) => l.rel == 'enclosure').href,
            'pubDate': item.updated?.toIso8601String(),
            'read': false,
          };
        }).toList();
      } else {
        throw Exception('Unsupported feed type');
      }
      await userFeeds.add({
        'title': feedSearchResult.title,
        'iconUrl': feedSearchResult.iconUrl,
        'link': feedSearchResult.link,
        'items': items,
      });
    } catch (e) {
      rethrow;
    }
  }
}
