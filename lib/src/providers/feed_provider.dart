import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/models/feed.dart';
import 'package:rss_feed_reader_app/src/services/feeds_service.dart';

class FeedProvider with ChangeNotifier {
  final FeedsService _feedsService = FeedsService();

  String? _selectedFeedId;
  String _filterOption = 'unread';

  // Constructor
  FeedProvider() {
    fetchFeeds();
  }

  // Getters
  List<Feed> get feeds => _feedsService.feeds;
  List<Article> get articles => _feedsService.articles;

  String? get selectedFeedId => _selectedFeedId;
  String get filterOption => _filterOption;

  String? get selectedFeedTitle => _selectedFeedId == null
      ? null
      : feeds.firstWhere((feed) => feed.link == _selectedFeedId).title;

  List<Article> get filteredArticles {
    List<Article> filtered = _filterOption == 'all'
        ? articles
        : articles
            .where((article) => article.read == (_filterOption == 'read'))
            .toList();

    if (_selectedFeedId != null) {
      filtered = filtered
          .where((article) => article.feedUrl == _selectedFeedId)
          .toList();
    }
    return filtered;
  }

  // Fetches feeds and articles
  Future<void> fetchFeeds() async {
    await _feedsService.fetchFeedsAndArticles();
    notifyListeners();
  }

  // Selects a feed
  void selectFeed(String? feedId) {
    _selectedFeedId = feedId;
    notifyListeners();
  }

  // Sets the filter option
  void setFilterOption(String option) {
    _filterOption = option;
    notifyListeners();
  }

  // Toggles the read status of an article
  Future<void> toggleArticleReadStatus(Article article) async {
    var localArticle = articles.firstWhere((a) => a.link == article.link);
    bool newReadStatus = !localArticle.read!;
    localArticle.read = newReadStatus;

    await _feedsService.markArticleReadStatus(article, newReadStatus);
    notifyListeners();
  }
}
