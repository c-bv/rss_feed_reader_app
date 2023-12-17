import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/widgets/main_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      body: Text('Settings'),
    );
  }
}
