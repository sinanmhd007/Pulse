import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

class GetLiveNews implements UseCase<List<NewsArticle>, NoParams> {
  final NewsRepository repository;

  GetLiveNews(this.repository);

  @override
  Future<Either<Failure, List<NewsArticle>>> call(NoParams params) {
    return repository.getLiveNews();
  }
}
