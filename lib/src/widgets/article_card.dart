import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10.0)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
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
                  article.title ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  article.description ?? 'No Description',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Feed Title and Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                          ? Image.network(article.iconUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.rss_feed,
                              color: Colors.white, size: 14.0),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      article.feedTitle ?? 'Unknown Feed',
                      style: const TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                // Publication Date
                Text(
                  DateFormat('MMM d, y')
                      .format(DateTime.parse(article.pubDate!)),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
