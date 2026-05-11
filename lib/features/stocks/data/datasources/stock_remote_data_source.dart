import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/web_request_helper.dart';
import '../models/stock_model.dart';

abstract class StockRemoteDataSource {
  Future<List<StockModel>> getLiveStocks();
  Future<List<StockModel>> searchStocks(String query);
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final Dio dio;
  final String? apiKey = dotenv.env['FINNHUB_API_KEY'];

  static const List<String> _defaultSymbols = [
    'AAPL',
    'MSFT',
    'NVDA',
    'AMZN',
    'GOOGL',
    'META',
    'TSLA',
    'NFLX',
    'AMD',
    'INTC',
  ];

  StockRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StockModel>> getLiveStocks() async {
    final key = apiKey;
    if (key == null || key.isEmpty) {
      throw ServerException('Missing FINNHUB_API_KEY in .env');
    }

    try {
      return _fetchStocksBySymbols(_defaultSymbols, key);
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<List<StockModel>> searchStocks(String query) async {
    final key = apiKey;
    if (key == null || key.isEmpty) {
      throw ServerException('Missing FINNHUB_API_KEY in .env');
    }

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return getLiveStocks();
    }

    try {
      final encodedQuery = Uri.encodeQueryComponent(trimmedQuery);
      final searchResponse = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url:
            'https://finnhub.io/api/v1/search?q=$encodedQuery&exchange=US&token=$key',
      );

      final List<dynamic> result = (searchResponse.data['result'] as List?) ?? [];
      final symbols = result
          .map((item) => (item as Map<String, dynamic>)['symbol']?.toString())
          .whereType<String>()
          .where((symbol) => symbol.isNotEmpty)
          .take(10)
          .toList();

      if (symbols.isEmpty) {
        return [];
      }

      return _fetchStocksBySymbols(symbols, key);
    } catch (_) {
      throw ServerException();
    }
  }

  Future<List<StockModel>> _fetchStocksBySymbols(
    List<String> symbols,
    String key,
  ) async {
    final futures = symbols.map((symbol) async {
      final quoteFuture = WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url: 'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$key',
      );
      final profileFuture = WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url: 'https://finnhub.io/api/v1/stock/profile2?symbol=$symbol&token=$key',
      );

      final responses = await Future.wait([quoteFuture, profileFuture]);
      final quote = responses[0].data as Map<String, dynamic>;
      final profile = responses[1].data as Map<String, dynamic>;

      return StockModel.fromFinnhub(
        symbol: symbol,
        quoteJson: quote,
        profileJson: profile,
      );
    });

    final stocks = await Future.wait(futures);
    stocks.sort((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
    return stocks;
  }
}
