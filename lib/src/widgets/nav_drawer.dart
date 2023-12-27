import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/providers/nav_provider.dart';
import 'package:rss_feed_reader_app/src/screens/home_screen.dart';
import 'package:rss_feed_reader_app/src/services/feeds_service.dart';

class Destination {
  const Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<Destination> destinations = <Destination>[
  Destination('All feeds', Icon(Icons.home_outlined), Icon(Icons.home)),
  Destination('Saved articles', Icon(Icons.bookmark_border_outlined),
      Icon(Icons.bookmark)),
];

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  int screenIndex = 0;
  late bool showNavigationDrawer;
  List<Map<String, dynamic>> userFeeds = [];

  @override
  void initState() {
    super.initState();
    _fetchUserFeeds();
  }

  Future<void> _fetchUserFeeds() async {
    try {
      var feeds = await FeedsService().getUserFeeds();
      setState(() {
        userFeeds = feeds;
      });
    } catch (e) {
      // Handle exception or show error message
    }
  }

  void handleScreenChanged(int selectedScreen, NavProvider provider) {
    provider.setScreenIndex(selectedScreen);
    Navigator.pop(context);

    switch (selectedScreen) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
    }
  }

  void openDrawer() {
    setState(() {
      showNavigationDrawer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavProvider>(
      builder: (context, provider, child) {
        return NavigationDrawer(
          onDestinationSelected: (selectedScreen) =>
              handleScreenChanged(selectedScreen, provider),
          selectedIndex: provider.selectedIndex,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            ),
            ...destinations.map(
              (Destination destination) {
                return NavigationDrawerDestination(
                  label: Text(destination.label),
                  icon: destination.icon,
                  selectedIcon: destination.selectedIcon,
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(),
            ),
            ...userFeeds.map(
              (feed) {
                return NavigationDrawerDestination(
                  label: Text(feed['title']),
                  icon: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 10.0,
                    child: feed['iconUrl'] != null
                        ? Image.network(feed['iconUrl'], fit: BoxFit.cover)
                        : const Icon(Icons.rss_feed,
                            color: Colors.white, size: 14.0),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
