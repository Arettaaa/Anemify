class ArticleSection {
  final String header;
  final String body;

  const ArticleSection({required this.header, required this.body});
}

class ArticleModel {
  final String id;
  final String number;
  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final List<ArticleSection> sections;
  final String referenceSource;
  final String referenceName;

  const ArticleModel({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.sections,
    required this.referenceSource,
    required this.referenceName,
  });
}
