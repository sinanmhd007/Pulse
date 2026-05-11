import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_quote.dart';
import '../repositories/stock_repository.dart';

class SearchStocks implements UseCase<List<StockQuote>, SearchStocksParams> {
  final StockRepository repository;

  SearchStocks(this.repository);

  @override
  Future<Either<Failure, List<StockQuote>>> call(SearchStocksParams params) {
    return repository.searchStocks(params.query);
  }
}

class SearchStocksParams extends Equatable {
  final String query;

  const SearchStocksParams({required this.query});

  @override
  List<Object> get props => [query];
}
