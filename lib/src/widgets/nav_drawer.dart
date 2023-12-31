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

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        return NavigationDrawer(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            ),
            ListTile(
              title: const Text('All feeds'),
              leading: const Icon(Icons.home_outlined),
              onTap: () => onAllFeedsSelected(),
            ),
            ...feedProvider.feeds.map((feed) {
              return ListTile(
                title: Text(
                  feed.title!,
                  overflow: TextOverflow.ellipsis,
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
