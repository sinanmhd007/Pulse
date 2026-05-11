import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/stock_quote.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_data_source.dart';
import '../datasources/stock_remote_data_source.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;
  final StockLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  StockRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<StockQuote>>> getLiveStocks() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteStocks = await remoteDataSource.getLiveStocks();
        await localDataSource.cacheLiveStocks(remoteStocks);
        return Right(remoteStocks);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (_) {
        return const Left(ServerFailure());
      }
    }

    try {
      final cachedStocks = await localDataSource.getLastLiveStocks();
      return Right(cachedStocks);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StockQuote>>> searchStocks(String query) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final remoteStocks = await remoteDataSource.searchStocks(query);
      return Right(remoteStocks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
