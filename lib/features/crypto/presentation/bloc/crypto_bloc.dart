import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_live_crypto_prices.dart';
import '../../domain/usecases/search_crypto.dart';
import 'crypto_event.dart';
import 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final GetLiveCryptoPrices getLiveCryptoPrices;
  final SearchCrypto searchCrypto;
  int _requestToken = 0;

  CryptoBloc({
    required this.getLiveCryptoPrices,
    required this.searchCrypto,
  }) : super(CryptoInitial()) {
    on<FetchLiveCrypto>(_onFetchLiveCrypto);
    on<SearchLiveCrypto>(_onSearchLiveCrypto);
  }

  Future<void> _onFetchLiveCrypto(FetchLiveCrypto event, Emitter<CryptoState> emit) async {
    final token = ++_requestToken;
    emit(CryptoLoading());
    final result = await getLiveCryptoPrices(NoParams());
    if (token != _requestToken) {
      return;
    }

    result.fold(
      (failure) => emit(CryptoError(failure.message)),
      (coins) => emit(CryptoLoaded(coins)),
    );
  }

  Future<void> _onSearchLiveCrypto(SearchLiveCrypto event, Emitter<CryptoState> emit) async {
    final token = ++_requestToken;
    final result = await searchCrypto(SearchCryptoParams(query: event.query));
    if (token != _requestToken) {
      return;
    }

    result.fold(
      (failure) => emit(CryptoError(failure.message)),
      (coins) => emit(CryptoLoaded(coins)),
    );
  }
}
