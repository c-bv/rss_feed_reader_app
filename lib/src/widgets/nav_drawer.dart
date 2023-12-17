import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/providers/nav_provider.dart';
import 'package:rss_feed_reader_app/src/screens/home_screen.dart';
import 'package:rss_feed_reader_app/src/screens/register_screen.dart';
import 'package:rss_feed_reader_app/src/screens/settings_screen.dart';

class Destination {
  const Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<Destination> destinations = <Destination>[
  Destination('Home', Icon(Icons.home_outlined), Icon(Icons.home)),
  Destination(
      'Saved', Icon(Icons.bookmark_border_outlined), Icon(Icons.bookmark)),
  Destination('Settings', Icon(Icons.settings_outlined), Icon(Icons.settings)),
];

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  int screenIndex = 0;
  late bool showNavigationDrawer;

  void handleScreenChanged(int selectedScreen, NavProvider provider) {
    provider.setScreenIndex(selectedScreen);
    Navigator.pop(context); // Close the drawer after selecting a destination

    switch (selectedScreen) {
      case 0:
        // Navigate to the HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        // Navigate to the RegisterScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
        break;
      case 2:
        // Navigate to the SettingsScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      // Add more cases for additional screens if needed
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
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text(
                'Header',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
              padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
              child: Divider(),
            ),
          ],
        );
      },
    );
  }
}
