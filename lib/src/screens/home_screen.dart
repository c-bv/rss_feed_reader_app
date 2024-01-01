import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/providers/feed_provider.dart';
import 'package:rss_feed_reader_app/src/widgets/app_bar.dart';
import 'package:rss_feed_reader_app/src/widgets/article_card.dart';
import 'package:rss_feed_reader_app/src/widgets/nav_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _lastFeedId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        String appBarTitle = feedProvider.selectedFeedTitle ?? 'All Articles';
        List<Article> articles = feedProvider.filteredArticles;

        if (_lastFeedId != feedProvider.selectedFeedId) {
          _lastFeedId = feedProvider.selectedFeedId;
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }

        return Scaffold(
          appBar: AppBarWidget(title: appBarTitle),
          drawer: const NavDrawer(),
          body: articles.isEmpty
              ? const Center(child: Text('No articles found.'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    var article = articles[index];
                    return ArticleCard(
                      article: article,
                      onMarkAsRead: (article) {
                        feedProvider.toggleArticleReadStatus(article);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
