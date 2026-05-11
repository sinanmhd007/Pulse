import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';

import '../../domain/entities/stock_quote.dart';
import '../../domain/repositories/stock_repository.dart';

import '../datasources/stock_remote_data_source.dart';

class StockRepositoryImpl
    implements StockRepository {
  final StockRemoteDataSource
      remoteDataSource;

  final StockLocalDataSource
      localDataSource;

  final NetworkInfo networkInfo;

  StockRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// ===============================
  /// GET LIVE CURRENCY MARKET
  /// ===============================

  @override
  Future<Either<Failure,
      List<StockQuote>>> getLiveStocks() async {
    /// ONLINE
    if (await networkInfo.isConnected) {
      try {
        final remoteStocks =
            await remoteDataSource
                .getLiveStocks();

        /// Save locally
        await localDataSource
            .cacheLiveStocks(
          remoteStocks,
        );

        return Right(remoteStocks);
      }

      on ServerException catch (e) {
        /// Try cached fallback
        try {
          final cachedStocks =
              await localDataSource
                  .getLastLiveStocks();

          return Right(cachedStocks);
        } catch (_) {
          return Left(
            ServerFailure(e.message),
          );
        }
      }

      catch (_) {
        return const Left(
          ServerFailure(),
        );
      }
    }

    /// OFFLINE MODE
    try {
      final cachedStocks =
          await localDataSource
              .getLastLiveStocks();

      return Right(cachedStocks);
    }

    on CacheException catch (e) {
      return Left(
        CacheFailure(e.message),
      );
    }

    catch (_) {
      return const Left(
        CacheFailure(),
      );
    }
  }

  /// ===============================
  /// SEARCH CURRENCIES
  /// ===============================

  @override
  Future<Either<Failure,
      List<StockQuote>>> searchStocks(
    String query,
  ) async {
    try {
      /// Uses memory cache
      final result =
          await remoteDataSource
              .searchStocks(query);

      return Right(result);
    }

    on ServerException catch (e) {
      return Left(
        ServerFailure(e.message),
      );
    }

    catch (_) {
      return const Left(
        ServerFailure(),
      );
    }
  }
}