import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/models/feed.dart';
import 'package:rss_feed_reader_app/src/providers/feed_provider.dart';
import 'package:rss_feed_reader_app/src/providers/settings_provider.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  FeedProvider get feedProvider => Provider.of<FeedProvider>(context);
  SettingsProvider get settingsProvider =>
      Provider.of<SettingsProvider>(context);

  int _getUnreadCount(Feed feed) {
    return feed.items!.where((article) => !article.read!).length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        return NavigationDrawer(
          children: <Widget>[
            ListTile(
              title: const Text('All feeds'),
              onTap: () {
                feedProvider.selectFeed(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Saved articles'),
              leading: const Icon(Icons.bookmark),
              onTap: () => {},
            ),
            const Divider(),
            ...feedProvider.feeds.map((feed) {
              int unreadCount = _getUnreadCount(feed);
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
                    if (settingsProvider.showUnreadCount)
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
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
                onTap: () {
                  feedProvider.selectFeed(feed.link);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
