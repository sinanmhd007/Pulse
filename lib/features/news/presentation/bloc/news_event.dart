import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class FetchLiveNews extends NewsEvent {}

class SearchLiveNews extends NewsEvent {
  final String query;

  const SearchLiveNews(this.query);

  @override
  List<Object> get props => [query];
}
