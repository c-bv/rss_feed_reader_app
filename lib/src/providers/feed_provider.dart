import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/models/feed.dart';
import 'package:rss_feed_reader_app/src/services/feeds_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedProvider with ChangeNotifier {
  final FeedsService _feedsService = FeedsService();

  String? _selectedFeedId;
  String _filterOption = 'unread';

  List<Feed> get feeds => _feedsService.feeds;
  List<Article> get articles => _feedsService.articles;

  String? get selectedFeedId => _selectedFeedId;
  String? get selectedFeedTitle {
    if (_selectedFeedId == null) return null;
    return feeds.firstWhere((feed) => feed.link == _selectedFeedId).title;
  }

  String get filterOption => _filterOption;

  FeedProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFeedId = prefs.getString('selectedFeedId');
    _filterOption = prefs.getString('filterOption') ?? _filterOption;
    notifyListeners();
  }

  Future<void> fetchFeeds() async {
    await _feedsService.fetchFeedsAndArticles();
    notifyListeners();
  }

  Future<void> selectFeed(String? feedId) async {
    _selectedFeedId = feedId;
    await _updatePreference('selectedFeedId', feedId);
    notifyListeners();
  }

  Future<void> setFilterOption(String option) async {
    print('setFilterOption: $option');
    print('setFilterOption: $selectedFeedTitle');
    _filterOption = option;
    await _updatePreference('filterOption', option);
    notifyListeners();
  }

  Future<String?> getStoredFilterOption() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('filterOption');
  }

  Future<List<Article>> getFilteredArticles() async {
    return await _feedsService.getFilteredArticles(
        _selectedFeedId, _filterOption);
  }

  Future<void> toggleArticleReadStatus(Article article) async {
    bool newReadStatus = !article.read!;
    await _feedsService.markArticleReadStatus(article, newReadStatus);

    var localArticle = articles.firstWhere(
      (a) => a.link == article.link,
      orElse: () => article,
    );
    localArticle.read = newReadStatus;

    notifyListeners();
  }

  Future<void> _updatePreference(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null && value.isNotEmpty) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }
}
