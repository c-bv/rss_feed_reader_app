class Article {
  final String title;
  final String link;
  final String value;
  final String? imageUrl;
  final String pubDate;
  final bool read;

  Article(
      {required this.title,
      required this.link,
      required this.value,
      this.imageUrl,
      required this.pubDate,
      required this.read});
}
