import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/screens/article_details_screen.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  String _handleDate(String pubDate) {
    final DateTime now = DateTime.now();
    final DateTime date = DateTime.parse(pubDate);
    final Duration difference = now.difference(date);
    if (difference.inDays > 0) {
      return DateFormat('MMM d, y').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToArticleDetail(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToArticleDetail(context, article),
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10.0)),
                  child: SizedBox(
                    height: 200.0,
                    child: article.imageUrl != null
                        ? Image.network(article.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 64.0,
                              ),
                            ),
                          ),
                  ),
                ),
                // Title and Description
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        article.title!,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        article.description!,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Feed Title and Date
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Icon and Feed Title
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 10.0,
                            child: article.iconUrl != null
                                ? Image.network(article.iconUrl!,
                                    fit: BoxFit.cover)
                                : const Icon(Icons.rss_feed,
                                    color: Colors.white, size: 14.0),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            article.feedTitle!,
                            style: const TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      // Publication Date
                      Text(
                        _handleDate(article.pubDate!),
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (article.read == true)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
