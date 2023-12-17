import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/services/feeds_service.dart';
import 'package:rss_feed_reader_app/src/widgets/app_bar.dart';
import 'package:rss_feed_reader_app/src/widgets/nav_drawer.dart';

class HomeScreen extends StatelessWidget {
  final FeedsService _feedsService = FeedsService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'All Feeds'),
      drawer: const NavDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _feedsService.getUserFeeds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>>? feeds = snapshot.data;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: feeds?.length ?? 0,
              itemBuilder: (context, index) {
                String feedUrl = feeds?[index]['url'] ?? '';

                return FutureBuilder<List<Article>>(
                  future: _feedsService.getArticlesFromFeed(feedUrl),
                  builder: (context, articleSnapshot) {
                    if (articleSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (articleSnapshot.hasError) {
                      return Text('Error: ${articleSnapshot.error}');
                    } else {
                      List<Article>? articles = articleSnapshot.data;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // To prevent nested scrolling issues
                        itemCount: articles?.length ?? 0,
                        itemBuilder: (context, articleIndex) {
                          Article? article = articles?[articleIndex];
                          return Card(
                            child: ListTile(
                              leading: article?.imageUrl != null
                                  ? Image.network(article!.imageUrl)
                                  : null,
                              title: Text(article?.title ?? ''),
                              
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
