import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_local_data_source.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<NewsArticle>>> getLiveNews() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteNews = await remoteDataSource.getLiveNews();
        localDataSource.cacheLiveNews(remoteNews);
        return Right(remoteNews);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localNews = await localDataSource.getLastLiveNews();
        return Right(localNews);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<NewsArticle>>> searchNews(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteNews = await remoteDataSource.searchNews(query);
        return Right(remoteNews);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      // For search, we might not have cached results. 
      return const Left(NetworkFailure());
    }
  }
}
