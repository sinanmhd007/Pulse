import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/crypto_coin.dart';
import '../repositories/crypto_repository.dart';

class SearchCrypto implements UseCase<List<CryptoCoin>, SearchCryptoParams> {
  final CryptoRepository repository;

  SearchCrypto(this.repository);

  @override
  Future<Either<Failure, List<CryptoCoin>>> call(SearchCryptoParams params) {
    return repository.searchCrypto(params.query);
  }
}

class SearchCryptoParams extends Equatable {
  final String query;

  const SearchCryptoParams({required this.query});

  @override
  List<Object> get props => [query];
}
