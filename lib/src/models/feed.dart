import 'package:rss_feed_reader_app/src/models/article.dart';

class Feed {
  final String? iconUrl;
  final String? title;
  final String? description;
  final String? link;
  final String? author;
  final List<Article>? items;
  final String? image;
  final String? cloud;
  final List<String>? categories;
  final List<int>? skipDays;
  final List<int>? skipHours;
  final DateTime? lastBuildDate;
  final String? language;
  final String? generator;
  final String? copyright;
  final String? docs;
  final String? managingEditor;
  final String? rating;
  final String? webMaster;
  final int? ttl;
  final Map<String, dynamic>? dc;

  Feed({
    this.iconUrl,
    this.title,
    this.description,
    this.link,
    this.author,
    this.items,
    this.image,
    this.cloud,
    this.categories,
    this.skipDays,
    this.skipHours,
    this.lastBuildDate,
    this.language,
    this.generator,
    this.copyright,
    this.docs,
    this.managingEditor,
    this.rating,
    this.webMaster,
    this.ttl,
    this.dc,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    String processedFeedUrl = json['id'];
    if (processedFeedUrl.startsWith('feed/')) {
      processedFeedUrl = processedFeedUrl.replaceFirst('feed/', '');
    }
    return Feed(
      iconUrl: json['iconUrl'],
      title: json['title'],
      description: json['description'],
      link: processedFeedUrl,
    );
  }
}
