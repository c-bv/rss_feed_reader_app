import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/models/feed.dart';
import 'package:rss_feed_reader_app/src/services/feeds_service.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({super.key});

  @override
  State<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  List<Feed> feedSearchResults = [];
  final TextEditingController _controller = TextEditingController();

  void _handleSearchFeed(String query) async {
    if (query.isNotEmpty) {
      try {
        var feeds = await FeedsService().searchFeeds(query);
        setState(() {
          feedSearchResults = feeds;
        });
      } catch (e) {
        setState(() {
          feedSearchResults = [];
        });
      }
    } else {
      setState(() {
        feedSearchResults = [];
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    setState(() {
      feedSearchResults = [];
    });
  }

  void _handleAddFeed(Feed result) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await FeedsService().addFeed(result);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Feed added successfully'),
        ),
      );
    } catch (e) {
      print(e);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Add Feed'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _handleClear(),
                      )
                    : null,
                labelText: 'Search for a feed',
                filled: true,
              ),
              onSubmitted: _handleSearchFeed,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: feedSearchResults.length,
              itemBuilder: (context, index) {
                final result = feedSearchResults[index];
                return Card(
                  child: ListTile(
                    onTap: () => _handleAddFeed(result),
                    leading: SizedBox(
                      width: 25,
                      height: 25,
                      child: result.iconUrl != null
                          ? Image.network(
                              result.iconUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.rss_feed),
                    ),
                    title: Text(result.title!),
                    subtitle: Text(
                      result.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
