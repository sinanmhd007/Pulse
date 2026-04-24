import 'package:equatable/equatable.dart';

class NewsArticle extends Equatable {
  final String title;
  final String description;
  final String url;
  final String? sourceName;
  final String? imageUrl;
  final DateTime publishedAt;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.sourceName,
    this.imageUrl,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [title, description, url, sourceName, imageUrl, publishedAt];
}
