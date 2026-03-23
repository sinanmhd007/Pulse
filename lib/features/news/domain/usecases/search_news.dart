import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

class SearchNews implements UseCase<List<NewsArticle>, SearchNewsParams> {
  final NewsRepository repository;

  SearchNews(this.repository);

  @override
  Future<Either<Failure, List<NewsArticle>>> call(SearchNewsParams params) {
    return repository.searchNews(params.query);
  }
}

class SearchNewsParams extends Equatable {
  final String query;

  const SearchNewsParams({required this.query});

  @override
  List<Object> get props => [query];
}
