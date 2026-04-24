import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/crypto_coin.dart';

abstract class CryptoRepository {
  Future<Either<Failure, List<CryptoCoin>>> getLiveCryptoPrices();
  Future<Either<Failure, List<CryptoCoin>>> searchCrypto(String query);
}
