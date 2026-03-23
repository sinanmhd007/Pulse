import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getLiveNews();
  Future<List<NewsModel>> searchNews(String query);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;
  // TODO: Add your NewsAPI Key here
  final String apiKey = 'YOUR_API_KEY_HERE'; 

  NewsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NewsModel>> getLiveNews() async {
    try {
      final response = await dio.get(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey',
      );
      final List<dynamic> articlesJson = response.data['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<NewsModel>> searchNews(String query) async {
    try {
      final response = await dio.get(
        'https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey',
      );
      final List<dynamic> articlesJson = response.data['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException();
    }
  }
}
