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
      throw ServerException('Failed to Load News');
    }

    try {
      final response = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url:
             'https://newsdata.io/api/1/news?apikey=$resolvedApiKey&country=us&language=en',
      );
      
      final List<dynamic> articlesJson = response.data['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to Load News');
    }
  }

  @override
  Future<List<NewsModel>> searchNews(String query) async {
    final resolvedApiKey = apiKey;
    if (resolvedApiKey == null || resolvedApiKey.isEmpty) {
      throw ServerException('Failed to Load News');
    }

    try {
      final response = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url:
            'https://newsdata.io/api/1/news?apikey=$resolvedApiKey&q=$query&language=en',
      );
      final List<dynamic> articlesJson = response.data['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to Load News');
    }
  }
}
