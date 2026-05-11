import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/web_request_helper.dart';
import '../models/crypto_model.dart';

abstract class CryptoRemoteDataSource {
  Future<List<CryptoModel>> getLiveCryptoPrices();
  Future<List<CryptoModel>> searchCrypto(String query);
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final Dio dio;
  static const Duration _cacheTtl = Duration(minutes: 1);
  static const int _searchResultLimit = 15;

  List<CryptoModel>? _marketCache;
  DateTime? _marketCacheTime;
  final Map<String, List<CryptoModel>> _searchCache = {};

  CryptoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CryptoModel>> getLiveCryptoPrices() async {
    final cachedMarkets = _freshMarketCache;
    if (cachedMarkets != null) {
      return cachedMarkets;
    }

    try {
      final response = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url:
            'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false',
      );
      final List<dynamic> jsonList = response.data;
      final coins = jsonList
          .whereType<Map<String, dynamic>>()
          .map(CryptoModel.fromJson)
          .toList();
      _marketCache = coins;
      _marketCacheTime = DateTime.now();
      return coins;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<CryptoModel>> searchCrypto(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return getLiveCryptoPrices();
    }

    final cachedSearch = _searchCache[normalizedQuery];
    if (cachedSearch != null) {
      return cachedSearch;
    }

    try {
      final searchResponse = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url:
            'https://api.coingecko.com/api/v3/search?query=${Uri.encodeQueryComponent(normalizedQuery)}',
      );

      final List<dynamic> rawCoins =
          (searchResponse.data as Map<String, dynamic>)['coins'] as List? ?? [];
      final ids = rawCoins
          .whereType<Map<String, dynamic>>()
          .map((coin) => coin['id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .take(_searchResultLimit)
          .toList();

      if (ids.isEmpty) {
        _searchCache[normalizedQuery] = const [];
        return const [];
      }

      final marketsResponse = await WebRequestHelper.getWithWebCorsFallback(
        dio: dio,
        url:
            'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${Uri.encodeQueryComponent(ids.join(','))}&order=market_cap_desc&sparkline=false&price_change_percentage=24h',
      );

      final List<dynamic> markets = marketsResponse.data as List? ?? [];
      final coins = markets
          .whereType<Map<String, dynamic>>()
          .map(CryptoModel.fromJson)
          .toList();
      _searchCache[normalizedQuery] = coins;
      return coins;
    } catch (_) {
      final fallbackResults = await _searchCachedMarkets(normalizedQuery);
      if (fallbackResults.isNotEmpty) {
        return fallbackResults;
      }
      throw ServerException();
    }
  }

  List<CryptoModel>? get _freshMarketCache {
    final cache = _marketCache;
    final cacheTime = _marketCacheTime;
    if (cache == null || cacheTime == null) {
      return null;
    }

    if (DateTime.now().difference(cacheTime) > _cacheTtl) {
      return null;
    }

    return cache;
  }

  Future<List<CryptoModel>> _searchCachedMarkets(String normalizedQuery) async {
    final cachedMarkets = _marketCache ?? await getLiveCryptoPrices();
    final results = cachedMarkets.where((coin) {
      return coin.name.toLowerCase().contains(normalizedQuery) ||
          coin.symbol.toLowerCase().contains(normalizedQuery);
    }).toList();
    _searchCache[normalizedQuery] = results;
    return results;
  }
}
