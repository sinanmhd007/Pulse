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
  static const int _searchResultLimit = 10;
  static const Duration _quoteCacheTtl = Duration(seconds: 45);

  final Map<String, _CachedStock> _stockCache = {};
  final Map<String, List<StockModel>> _searchCache = {};

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

    final trimmedQuery = query.trim().toUpperCase();
    if (trimmedQuery.isEmpty) {
      return getLiveStocks();
    }

    final cachedSearch = _searchCache[trimmedQuery];
    if (cachedSearch != null) {
      return cachedSearch;
    }

    try {
      final encodedQuery = Uri.encodeQueryComponent(trimmedQuery);
      final searchResponse = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url:
            'https://finnhub.io/api/v1/search?q=$encodedQuery&exchange=US&token=$key',
      );

      final List<dynamic> result = (searchResponse.data['result'] as List?) ?? [];
      final symbols = <String>{
        if (_looksLikeTicker(trimmedQuery)) trimmedQuery,
        ...result
            .whereType<Map<String, dynamic>>()
            .where(_isTradableCommonStock)
            .map((item) => item['symbol']?.toString().toUpperCase())
            .whereType<String>()
            .map(_cleanFinnhubSymbol)
            .where((symbol) => symbol.isNotEmpty),
      }
          .take(_searchResultLimit)
          .toList();

      if (symbols.isEmpty) {
        _searchCache[trimmedQuery] = const [];
        return [];
      }

      final stocks = await _fetchStocksBySymbols(symbols, key);
      _searchCache[trimmedQuery] = stocks;
      return stocks;
    } catch (_) {
      throw ServerException();
    }
  }

  Future<List<StockModel>> _fetchStocksBySymbols(
    List<String> symbols,
    String key,
  ) async {
    final futures = symbols.map((symbol) => _fetchStock(symbol, key));
    final stocks = (await Future.wait(futures)).whereType<StockModel>().toList();
    stocks.sort((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
    return stocks;
  }

  Future<StockModel?> _fetchStock(String symbol, String key) async {
    final cachedStock = _freshCachedStock(symbol);
    if (cachedStock != null) {
      return cachedStock;
    }

    try {
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

      final stock = StockModel.fromFinnhub(
        symbol: symbol,
        quoteJson: quote,
        profileJson: profile,
      );

      if (stock.currentPrice <= 0) {
        return null;
      }

      _stockCache[symbol] = _CachedStock(stock, DateTime.now());
      return stock;
    } catch (_) {
      return null;
    }
  }

  StockModel? _freshCachedStock(String symbol) {
    final cached = _stockCache[symbol];
    if (cached == null) {
      return null;
    }

    if (DateTime.now().difference(cached.fetchedAt) > _quoteCacheTtl) {
      return null;
    }

    return cached.stock;
  }

  static bool _isTradableCommonStock(Map<String, dynamic> item) {
    final type = item['type']?.toString().toLowerCase() ?? '';
    final symbol = item['symbol']?.toString() ?? '';
    return type.contains('common stock') && _looksLikeTicker(symbol);
  }

  static bool _looksLikeTicker(String value) {
    return RegExp(r'^[A-Z.]{1,8}$').hasMatch(value.trim().toUpperCase());
  }

  static String _cleanFinnhubSymbol(String symbol) {
    return symbol.trim().toUpperCase().split(' ').first;
  }
}

class _CachedStock {
  final StockModel stock;
  final DateTime fetchedAt;

  const _CachedStock(this.stock, this.fetchedAt);
}
