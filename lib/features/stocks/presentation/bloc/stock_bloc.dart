import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_live_stocks.dart';
import '../../domain/usecases/search_stocks.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final GetLiveStocks getLiveStocks;
  final SearchStocks searchStocks;
  int _requestToken = 0;

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
    final token = ++_requestToken;
    emit(StockLoading());
    final result = await getLiveStocks(NoParams());
    if (token != _requestToken) {
      return;
    }

    result.fold(
      (failure) => emit(StockError(failure.message)),
      (stocks) => emit(StockLoaded(stocks)),
    );
  }

  Future<void> _onSearchLiveStocks(
    SearchLiveStocks event,
    Emitter<StockState> emit,
  ) async {
    final token = ++_requestToken;
    final result = await searchStocks(SearchStocksParams(query: event.query));
    if (token != _requestToken) {
      return;
    }

    result.fold(
      (failure) => emit(StockError(failure.message)),
      (stocks) => emit(StockLoaded(stocks)),
    );
  }
}
