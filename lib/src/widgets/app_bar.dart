// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/providers/feed_provider.dart';
import 'package:rss_feed_reader_app/src/screens/add_feed_screen.dart';
import 'package:rss_feed_reader_app/src/screens/settings_screen.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWidget({super.key, required this.title});

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWidgetState extends State<AppBarWidget> {
  String? selectedFilter;

  Future<void> _loadStoredFilterOption() async {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final filterOption = feedProvider.filterOption;
    setState(() {
      selectedFilter = filterOption;
    });
  }

  List<PopupMenuEntry<String>> _buildFilterMenuItems() {
    return [
      PopupMenuItem<String>(
        value: 'all',
        child: RadioListTile<String>(
          title: const Text('All'),
          value: 'all',
          groupValue: selectedFilter,
          onChanged: (value) => _handleFilterMenuSelection(value),
        ),
      ),
      PopupMenuItem<String>(
        value: 'unread',
        child: RadioListTile<String>(
          title: const Text('Unread'),
          value: 'unread',
          groupValue: selectedFilter,
          onChanged: (value) => _handleFilterMenuSelection(value),
        ),
      ),
      PopupMenuItem<String>(
        value: 'read',
        child: RadioListTile<String>(
          title: const Text('Read'),
          value: 'read',
          groupValue: selectedFilter,
          onChanged: (value) => _handleFilterMenuSelection(value),
        ),
      ),
    ];
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    return [
      const PopupMenuItem<String>(
        value: 'settings',
        child: ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ),
      const PopupMenuItem<String>(
        value: 'profile',
        child: ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
        ),
      ),
      const PopupMenuItem<String>(
        value: 'add_feed',
        child: ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Feed'),
        ),
      ),
    ];
  }

  void _handleFilterMenuSelection(String? value) {
    setState(() {
      selectedFilter = value!;
      Provider.of<FeedProvider>(context, listen: false).setFilterOption(value);
    });
    Navigator.pop(context);
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'profile':
        break;
      case 'add_feed':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddFeedScreen(),
          ),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStoredFilterOption();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      titleSpacing: 0.0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Filter',
          icon: const Icon(Icons.filter_list_outlined),
          onSelected: _handleFilterMenuSelection,
          itemBuilder: (context) => _buildFilterMenuItems(),
        ),
        PopupMenuButton<String>(
          tooltip: 'More',
          icon: const Icon(Icons.more_vert_outlined),
          onSelected: (value) => _handleMenuSelection(context, value),
          itemBuilder: (context) => _buildMenuItems(),
        ),
      ],
    );
  }
}
