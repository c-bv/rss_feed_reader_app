import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/providers/feed_provider.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String? selectedFeedId;

  late bool showNavigationDrawer;

  @override
  void initState() {
    super.initState();
  }

  void onFeedSelected(String feedUrl) {
    Provider.of<FeedProvider>(context, listen: false).selectFeed(feedUrl);
    setState(() {
      selectedFeedId = feedUrl;
    });
    Navigator.pop(context);
  }

  void onAllFeedsSelected() {
    Provider.of<FeedProvider>(context, listen: false).selectFeed(null);
    setState(() {
      selectedFeedId = null;
    });
    Navigator.pop(context);
  }

  void openDrawer() {
    setState(() {
      showNavigationDrawer = true;
    });
  }

  int _getUnreadCount(String feedId) {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final articles = feedProvider.feeds
        .firstWhere((feed) => feed.link == feedId)
        .items!
        .where((article) => !article.read!);
    return articles.length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        return NavigationDrawer(
          children: <Widget>[
            ListTile(
              title: const Text('All feeds'),
              onTap: () => onAllFeedsSelected(),
            ),
             ListTile(
              title: const Text('Saved articles'),
              leading: const Icon(Icons.bookmark),
              onTap: () => onAllFeedsSelected(),
              
            ),
            const Divider(),
            ...feedProvider.feeds.map((feed) {
              int unreadCount = _getUnreadCount(feed.link!);
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        feed.title!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 10.0,
                  child: feed.iconUrl != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: feed.iconUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.rss_feed,
                                color: Colors.white,
                                size: 14.0),
                          ),
                        )
                      : const Icon(Icons.rss_feed,
                          color: Colors.white, size: 14.0),
                ),
                onTap: () => onFeedSelected(
                  feed.link!,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
