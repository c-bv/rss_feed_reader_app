import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/models/feed.dart';
import 'package:rss_feed_reader_app/src/services/feeds_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedProvider with ChangeNotifier {
  final FeedsService _feedsService = FeedsService();

  String? _selectedFeedId;
  String _filterOption = 'unread';

  String? get selectedFeedId => _selectedFeedId;
  String get filterOption => _filterOption;
  List<Feed> get feeds => _feedsService.feeds;

  FeedProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFeedId = prefs.getString('selectedFeedId');
    if (_selectedFeedId == null || _selectedFeedId!.isEmpty) {
      _selectedFeedId = null;
    }
    _filterOption = prefs.getString('filterOption') ?? 'unread';
    notifyListeners();
  }

  Future<void> fetchFeeds() async {
    await _feedsService.fetchFeedsAndArticles();
    notifyListeners();
  }

  Future<void> selectFeed(String? feedId) async {
    _selectedFeedId = feedId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFeedId', feedId ?? '');
    notifyListeners();
  }

  Future<void> setFilterOption(String filterOption) async {
    _filterOption = filterOption;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filterOption', filterOption);
    notifyListeners();
  }

  Future<List<Article>> getFilteredArticles() async {
    return await _feedsService.getFilteredArticles(
        _selectedFeedId, _filterOption);
  }
}
