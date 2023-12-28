import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:rss_feed_reader_app/src/models/article.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

void _launchURL(String? urlString) async {
  if (urlString == null) return; // Exit if URL is null

  final Uri url = Uri.parse(urlString);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    print('Could not launch $urlString');
  }
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.feedTitle!),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                ),
              ),
              const PopupMenuItem(
                value: 'bookmark',
                child: ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Bookmark'),
                ),
              ),
              const PopupMenuItem(
                value: 'markAsRead',
                child: ListTile(
                  leading: Icon(Icons.markunread),
                  title: Text('Mark as Unread'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'share':
                  // share article
                  break;
                case 'bookmark':
                  // bookmark article
                  break;
                case 'markAsRead':
                  // mark article as read
                  break;
                default:
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
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
                      // Navigator.pushNamed(context, '/feed', arguments: {
                      //   'title': widget.article.feedTitle,
                      //   'iconUrl': widget.article.iconUrl,
                      // });
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
                    'by ${widget.article.author}, ${DateFormat('EEEE, MMMM d, y H:mm').format(DateTime.parse(widget.article.pubDate!))}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Html(
                    data: widget.article.content!,
                    onLinkTap: (url, _, __) {
                      _launchURL(url);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
