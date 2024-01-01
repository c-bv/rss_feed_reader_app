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
  final List<Feed> feeds = [];
  final List<Article> articles = [];

  // Fetch feeds and articles from Firestore
  Future<void> fetchFeedsAndArticles() async {
    feeds.clear();
    articles.clear();

    var userFeeds =
        _firestore.collection('users').doc(_userId).collection('feeds');
    var feedsSnapshot =
        await userFeeds.get(const GetOptions(source: Source.cache));

    if (feedsSnapshot.docs.isEmpty) {
      feedsSnapshot = await userFeeds.get();
    }

    for (var feedSnapshot in feedsSnapshot.docs) {
      var feedArticles = feedSnapshot['items'].map<Article>((article) {
        return Article(
          title: article['title'],
          feedTitle: feedSnapshot['title'],
          feedUrl: feedSnapshot['link'],
          link: article['link'],
          description: article['description'],
          content: article['content'],
          author: article['author'],
          imageUrl: article['imageUrl'],
          iconUrl: feedSnapshot['iconUrl'],
          pubDate: article['pubDate'],
          read: article['read'],
        );
      }).toList();

      Feed feed = Feed(
        link: feedSnapshot['link'],
        title: feedSnapshot['title'],
        items: feedArticles,
        iconUrl: feedSnapshot['iconUrl'],
      );

      feeds.add(feed);
      articles.addAll(feedArticles);
    }
  }

  // Filter articles by feed
  Future<List<Article>> getArticlesByFeed(String? feedUrl) async {
    if (feeds.isEmpty) {
      await fetchFeedsAndArticles();
    }
    if (feedUrl == null) {
      return articles;
    } else {
      return feeds.firstWhere((feed) => feed.link == feedUrl).items!;
    }
  }

  // Filter articles by read/unread
  Future<List<Article>> getFilteredArticles(
      String? feedUrl, String? filterOption) async {
    List<Article> articles = await getArticlesByFeed(feedUrl);
    articles.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));
    switch (filterOption) {
      case 'all':
        return articles;
      case 'read':
        return articles.where((article) => article.read!).toList();
      case 'unread':
        return articles.where((article) => !article.read!).toList();
      default:
        return articles;
    }
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
      print('XML Parsing Error: $e');
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

      http.Response response;
      try {
        response = await http.get(Uri.parse(feedSearchResult.link!));
      } catch (e) {
        print(e);
        throw Exception(
            'Network error: Unable to fetch feed. Please try again when online.');
      }

      String decodedBody = utf8.decode(response.bodyBytes);
      final feedType = await detectFeedType(decodedBody);

      List<Map<String, dynamic>> items;

      if (feedType == 'RSS') {
        print('RSS');
        var rssFeed = RssFeed.parse(decodedBody);
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
        print('Atom');
        var atomFeed = AtomFeed.parse(decodedBody);
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

  Future<void> markArticleReadStatus(Article article, bool readStatus) async {
    try {
      var userFeeds =
          _firestore.collection('users').doc(_userId).collection('feeds');
      var feedSnapshot =
          await userFeeds.where('link', isEqualTo: article.feedUrl).get();

      if (feedSnapshot.docs.isEmpty) {
        throw Exception('Feed not found');
      }

      var feedDoc = feedSnapshot.docs.first;
      var items = feedDoc['items'];

      var articleIndex =
          items.indexWhere((item) => item['link'] == article.link);
      if (articleIndex != -1) {
        items[articleIndex]['read'] = readStatus;
        await feedDoc.reference.update({'items': items});
      }
    } catch (e) {
      rethrow;
    }
  }
}
