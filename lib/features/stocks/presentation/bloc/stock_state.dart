import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_quote.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockQuote> stocks;

  const StockLoaded(this.stocks);

  @override
  List<Object> get props => [stocks];
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object> get props => [message];
}
