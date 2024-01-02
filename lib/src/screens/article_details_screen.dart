import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:rss_feed_reader_app/src/providers/feed_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  FeedProvider get feedProvider =>
      Provider.of<FeedProvider>(context, listen: false);

  void _markArticleAsRead(Article article) async {
    await feedProvider.toggleArticleReadStatus(article);
  }

  void _launchURL(String? urlString) async {
    if (urlString == null) return;

    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $urlString');
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.article.read!) {
      _markArticleAsRead(widget.article);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.feedTitle!),
        titleSpacing: 0.0,
        actions: <Widget>[
          Tooltip(
            message: 'Open in browser',
            child: IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () {
                _launchURL(widget.article.link);
              },
            ),
          ),
          PopupMenuButton(
            tooltip: 'More',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Save article'),
                ),
              ),
              const PopupMenuItem(
                value: 'markAsUnread',
                child: ListTile(
                  leading: Icon(Icons.visibility_off),
                  title: Text('Mark as Unread'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'share':
                  Share.share(widget.article.link!);
                  break;
                case 'save':
                  // bookmark article
                  break;
                case 'markAsUnread':
                  _markArticleAsRead(widget.article);
                  break;
                default:
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.article.title!,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      feedProvider.selectFeed(widget.article.feedUrl);
                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.article.feedTitle!,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.article.author != null
                        ? 'by ${widget.article.author}, ${DateFormat('EEEE, MMMM d, y H:mm').format(DateTime.parse(widget.article.pubDate!))}'
                        : DateFormat('EEEE, MMMM d, y H:mm')
                            .format(DateTime.parse(widget.article.pubDate!)),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Html(
                    data: widget.article.content ?? widget.article.description,
                    onLinkTap: (url, _, __) {
                      _launchURL(url);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
