import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_quote.dart';

abstract class StockRepository {
  Future<Either<Failure, List<StockQuote>>> getLiveStocks();
  Future<Either<Failure, List<StockQuote>>> searchStocks(String query);
}
