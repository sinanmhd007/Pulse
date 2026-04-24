import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/crypto_coin.dart';
import '../repositories/crypto_repository.dart';

class GetLiveCryptoPrices implements UseCase<List<CryptoCoin>, NoParams> {
  final CryptoRepository repository;

  GetLiveCryptoPrices(this.repository);

  @override
  Future<Either<Failure, List<CryptoCoin>>> call(NoParams params) {
    return repository.getLiveCryptoPrices();
  }
}
