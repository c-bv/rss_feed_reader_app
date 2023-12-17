import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/widgets/app_bar.dart';
import 'package:rss_feed_reader_app/src/widgets/nav_drawer.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;

  const MainScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(), drawer: const NavDrawer(), body: body);
  }
}
