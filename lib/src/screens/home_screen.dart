import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/widgets/app_bar.dart';
import 'package:rss_feed_reader_app/src/widgets/nav_drawer.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(title: 'All Feeds'),
      drawer: NavDrawer(),
      body: Text('Home Screen'),
    );
  }
}