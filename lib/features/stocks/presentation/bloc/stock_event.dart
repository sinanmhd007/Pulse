import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class FetchLiveStocks extends StockEvent {}

class SearchLiveStocks extends StockEvent {
  final String query;

  const SearchLiveStocks(this.query);

  @override
  List<Object> get props => [query];
}
