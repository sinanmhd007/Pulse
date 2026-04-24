import '../../domain/entities/news_article.dart';

class NewsModel extends NewsArticle {
  const NewsModel({
    required super.title,
    required super.description,
    required super.url,
    super.sourceName,
    super.imageUrl,
    required super.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      sourceName: json['source']?['name'],
      imageUrl: json['urlToImage'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'source': {'name': sourceName},
      'urlToImage': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}
