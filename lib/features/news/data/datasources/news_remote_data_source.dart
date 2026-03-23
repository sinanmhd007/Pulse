import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getLiveNews();
  Future<List<NewsModel>> searchNews(String query);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client client;
  // TODO: Add your NewsAPI Key here
  final String apiKey = 'YOUR_API_KEY_HERE'; 

  NewsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<NewsModel>> getLiveNews() async {
    final response = await client.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> articlesJson = jsonResponse['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<NewsModel>> searchNews(String query) async {
    final response = await client.get(
      Uri.parse('https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> articlesJson = jsonResponse['articles'];
      return articlesJson.map((json) => NewsModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }
}
