import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_quote.dart';
import '../repositories/stock_repository.dart';

class GetLiveStocks implements UseCase<List<StockQuote>, NoParams> {
  final StockRepository repository;

  GetLiveStocks(this.repository);

  @override
  Future<Either<Failure, List<StockQuote>>> call(NoParams params) {
    return repository.getLiveStocks();
  }
}
