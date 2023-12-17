import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/services/auth_service.dart';
import 'package:rss_feed_reader_app/src/services/feeds_service.dart';
import 'package:rss_feed_reader_app/src/widgets/app_bar.dart';
import 'package:rss_feed_reader_app/src/widgets/nav_drawer.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final FeedsService _feedsService = FeedsService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      drawer: const NavDrawer(),
      body: Column(
        children: [
          ActionChip(
            onPressed: () {
              _authService.signOut();
            },
            label: const Text('Sign Out'),
          ),
          FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _feedsService.getFeeds(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<QueryDocumentSnapshot>? feeds = snapshot.data;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: feeds?.length ?? 0,
                  itemBuilder: (context, index) {
                    Map<String, dynamic>? feedData =
                        feeds?[index].data() as Map<String, dynamic>?;
                    return ListTile(
                      title: Text(feedData?['title'] ?? ''),
                      subtitle: Text(feedData?['url'] ?? ''),
                    );
                  },
                );
              }
            },
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter RSS Feed URL',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 