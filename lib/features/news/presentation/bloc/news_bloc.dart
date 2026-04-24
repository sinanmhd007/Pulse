import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_live_news.dart';
import '../../domain/usecases/search_news.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetLiveNews getLiveNews;
  final SearchNews searchNews;

  NewsBloc({
    required this.getLiveNews,
    required this.searchNews,
  }) : super(NewsInitial()) {
    on<FetchLiveNews>(_onFetchLiveNews);
    on<SearchLiveNews>(_onSearchLiveNews);
  }

  Future<void> _onFetchLiveNews(FetchLiveNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    final result = await getLiveNews(NoParams());
    result.fold(
      (failure) => emit(NewsError(failure.message)),
      (articles) => emit(NewsLoaded(articles)),
    );
  }

  Future<void> _onSearchLiveNews(SearchLiveNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    final result = await searchNews(SearchNewsParams(query: event.query));
    result.fold(
      (failure) => emit(NewsError(failure.message)),
      (articles) => emit(NewsLoaded(articles)),
    );
  }
}
