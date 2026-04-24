import 'package:equatable/equatable.dart';

abstract class CryptoEvent extends Equatable {
  const CryptoEvent();

  @override
  List<Object> get props => [];
}

class FetchLiveCrypto extends CryptoEvent {}

class SearchLiveCrypto extends CryptoEvent {
  final String query;

  const SearchLiveCrypto(this.query);

  @override
  List<Object> get props => [query];
}
