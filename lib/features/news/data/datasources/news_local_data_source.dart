import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/news_model.dart';

abstract class NewsLocalDataSource {
  Future<List<NewsModel>> getLastLiveNews();
  Future<void> cacheLiveNews(List<NewsModel> newsToCache);
}

const CACHED_LIVE_NEWS = 'CACHED_LIVE_NEWS';

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final SharedPreferences sharedPreferences;

  NewsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheLiveNews(List<NewsModel> newsToCache) {
    return sharedPreferences.setString(
      CACHED_LIVE_NEWS,
      json.encode(newsToCache.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<NewsModel>> getLastLiveNews() {
    final jsonString = sharedPreferences.getString(CACHED_LIVE_NEWS);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((json) => NewsModel.fromJson(json)).toList());
    } else {
      throw CacheException();
    }
  }
}
