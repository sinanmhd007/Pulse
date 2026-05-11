import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_live_stocks.dart';
import '../../domain/usecases/search_stocks.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final GetLiveStocks getLiveStocks;
  final SearchStocks searchStocks;

  StockBloc({
    required this.getLiveStocks,
    required this.searchStocks,
  }) : super(StockInitial()) {
    on<FetchLiveStocks>(_onFetchLiveStocks);
    on<SearchLiveStocks>(_onSearchLiveStocks);
  }

  Future<void> _onFetchLiveStocks(
    FetchLiveStocks event,
    Emitter<StockState> emit,
  ) async {
    emit(StockLoading());
    final result = await getLiveStocks(NoParams());
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (stocks) => emit(StockLoaded(stocks)),
    );
  }

  Future<void> _onSearchLiveStocks(
    SearchLiveStocks event,
    Emitter<StockState> emit,
  ) async {
    emit(StockLoading());
    final result = await searchStocks(SearchStocksParams(query: event.query));
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (stocks) => emit(StockLoaded(stocks)),
    );
  }
}
