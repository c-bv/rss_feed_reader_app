import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final GlobalKey menuKey = GlobalKey();
    final GlobalKey menuKey2 = GlobalKey();
    final GlobalKey menuKey3 = GlobalKey();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), titleSpacing: 0.0),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        children: [
          _SingleSection(
            title: 'General',
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(settingsProvider.themeOption.displayTitle,
                    style: const TextStyle(fontSize: 12)),
                leading: const Icon(Icons.color_lens),
                onTap: () {
                  dynamic state = menuKey.currentState;
                  state.showButtonMenu();
                },
              ),
              PopupMenuButton<ThemeOption>(
                key: menuKey,
                onSelected: (ThemeOption newValue) {
                  settingsProvider.setThemeOption(newValue);
                },
                itemBuilder: (BuildContext context) => ThemeOption.values
                    .map((ThemeOption option) => PopupMenuItem<ThemeOption>(
                          value: option,
                          child: Text(
                            option.displayTitle,
                            style: TextStyle(
                                color: option == settingsProvider.themeOption
                                    ? Theme.of(context).colorScheme.primary
                                    : null),
                          ),
                        ))
                    .toList(),
                child: Container(),
              ),
            ],
          ),
          const Divider(),
          _SingleSection(
            title: 'Feeds',
            children: [
              ListTile(
                title: const Text('Show unread count'),
                leading: const Icon(Icons.onetwothree),
                trailing: Switch(
                  value: settingsProvider.showUnreadCount,
                  onChanged: (value) {
                    settingsProvider.setShowUnreadCount(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Sort by'),
                subtitle: Text(settingsProvider.sortOption.displayTitle,
                    style: const TextStyle(fontSize: 12)),
                leading: const Icon(Icons.sort),
                onTap: () {
                  dynamic state = menuKey3.currentState;
                  state.showButtonMenu();
                },
              ),
              PopupMenuButton<SortOption>(
                key: menuKey3,
                onSelected: (value) {
                  settingsProvider.setSortOption(value.index);
                },
                itemBuilder: (BuildContext context) => SortOption.values
                    .map((SortOption option) => PopupMenuItem<SortOption>(
                          value: option,
                          child: Text(
                            option.displayTitle,
                            style: TextStyle(
                                color: option == settingsProvider.sortOption
                                    ? Theme.of(context).colorScheme.primary
                                    : null),
                          ),
                        ))
                    .toList(),
                child: Container(),
              ),
            ],
          ),
          const Divider(),
          _SingleSection(
            title: 'Sync',
            children: [
              ListTile(
                title: const Text('Look for new articles'),
                subtitle: Text(settingsProvider.syncFrequency.displayTitle,
                    style: const TextStyle(fontSize: 12)),
                leading: const Icon(Icons.sync),
                onTap: () {
                  dynamic state = menuKey2.currentState;
                  state.showButtonMenu();
                },
              ),
              PopupMenuButton<SyncFrequency>(
                key: menuKey2,
                onSelected: (value) {
                  settingsProvider.setSyncFrequency(value.index);
                },
                itemBuilder: (BuildContext context) => SyncFrequency.values
                    .map((SyncFrequency option) => PopupMenuItem<SyncFrequency>(
                          value: option,
                          child: Text(
                            option.displayTitle,
                            style: TextStyle(
                                color: option == settingsProvider.syncFrequency
                                    ? Theme.of(context).colorScheme.primary
                                    : null),
                          ),
                        ))
                    .toList(),
                child: Container(),
              ),
              ListTile(
                title: const Text('Sync on app start'),
                leading: const Icon(Icons.sync),
                trailing: Switch(
                  value: settingsProvider.syncOnAppStart,
                  onChanged: (value) {
                    settingsProvider.setSyncOnAppStart(value);
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          const _SingleSection(
            title: 'About',
            children: [
              ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
                leading: Icon(Icons.info),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SingleSection({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: children,
        ),
      ],
    );
  }
}
