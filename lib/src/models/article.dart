class Article {
  final String? imageUrl;
  final String? iconUrl;
  final String? content;
  final String? feedTitle;
  final String? title;
  final String? description;
  final String? link;
  final List<String>? categories;
  final String? guid;
  final String? pubDate;
  final String? author;
  final String? comments;
  final Map<String, dynamic>? source;
  final Map<String, dynamic>? media;
  final Map<String, dynamic>? enclosure;
  final Map<String, dynamic>? dc;
  final bool? read;

  Article({
    this.imageUrl,
    this.iconUrl,
    this.content,
    this.feedTitle,
    this.title,
    this.description,
    this.link,
    this.categories,
    this.guid,
    this.pubDate,
    this.author,
    this.comments,
    this.source,
    this.media,
    this.enclosure,
    this.dc,
    this.read,
  });
}
