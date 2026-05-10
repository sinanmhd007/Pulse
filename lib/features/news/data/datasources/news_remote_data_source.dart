import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/web_request_helper.dart';
import '../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getLiveNews();
  Future<List<NewsModel>> searchNews(String query);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;
  final String? apiKey = dotenv.env['NEWS_API_KEY'];

  NewsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NewsModel>> getLiveNews() async {
    final resolvedApiKey = apiKey;
    if (resolvedApiKey == null || resolvedApiKey.isEmpty) {
      throw ServerException('Missing NEWS_API_KEY in .env');
    }

    try {
      final response = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url: 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$resolvedApiKey',
      );
      final List<dynamic> articlesJson = response.data['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<NewsModel>> searchNews(String query) async {
    final resolvedApiKey = apiKey;
    if (resolvedApiKey == null || resolvedApiKey.isEmpty) {
      throw ServerException('Missing NEWS_API_KEY in .env');
    }

    try {
      final response = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url: 'https://newsapi.org/v2/everything?q=$query&apiKey=$resolvedApiKey',
      );
      final List<dynamic> articlesJson = response.data['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException();
    }
  }
}
