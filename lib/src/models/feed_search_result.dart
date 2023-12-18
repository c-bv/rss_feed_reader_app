class FeedSearchResult {
  final String title;
  final String feedUrl;
  final String? description;
  final String? iconUrl;

  FeedSearchResult({
    required this.title,
    required this.feedUrl,
    this.description,
    this.iconUrl,
  });

  factory FeedSearchResult.fromJson(Map<String, dynamic> json) {
    String processedFeedUrl = json['feedId'];
    if (processedFeedUrl.startsWith('feed/')) {
      processedFeedUrl = processedFeedUrl.replaceFirst('feed/', '');
    }
    return FeedSearchResult(
      title: json['title'],
      feedUrl: processedFeedUrl,
      description: json['description'],
      iconUrl: json['iconUrl'],
    );
  }
}
