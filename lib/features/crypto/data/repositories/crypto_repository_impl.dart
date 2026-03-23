import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/crypto_coin.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasources/crypto_local_data_source.dart';
import '../datasources/crypto_remote_data_source.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoRemoteDataSource remoteDataSource;
  final CryptoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CryptoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CryptoCoin>>> getLiveCryptoPrices() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCrypto = await remoteDataSource.getLiveCryptoPrices();
        localDataSource.cacheLiveCrypto(remoteCrypto);
        return Right(remoteCrypto);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localCrypto = await localDataSource.getLastLiveCrypto();
        return Right(localCrypto);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<CryptoCoin>>> searchCrypto(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCrypto = await remoteDataSource.searchCrypto(query);
        return Right(remoteCrypto);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
