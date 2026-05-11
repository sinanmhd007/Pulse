import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/stock_model.dart';

/// ===============================
/// REMOTE DATASOURCE
/// ===============================

abstract class StockRemoteDataSource {
  Future<List<StockModel>> getLiveStocks();

  Future<List<StockModel>> searchStocks(
    String query,
  );
}

class StockRemoteDataSourceImpl
    implements StockRemoteDataSource {
  final Dio dio;

  static const String apiKey =
      '00d958f046b4fac53e47ce7d';

  static const List<String> _currencies = [
    'INR',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'AED',
    'SAR',
    'CNY',
    'SGD',
    'CHF',
    'NZD',
  ];

  /// In-memory search cache
  List<StockModel> _cachedCurrencies = [];

  StockRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<List<StockModel>>
      getLiveStocks() async {
    try {
      final response = await dio.get(
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/USD',
      );

      final rates =
          response.data['conversion_rates'];

      final data = _currencies.map((currency) {
        final rate =
            (rates[currency] ?? 0).toDouble();

        return StockModel(
          symbol: currency,

          name: 'USD/$currency',

          logoUrl: null,

          currentPrice: rate,

          change: 0,

          changePercent: 0,

          highPrice: rate,

          lowPrice: rate,

          openPrice: rate,

          previousClosePrice: rate,
        );
      }).toList();

      /// Save in memory
      _cachedCurrencies = data;

      return data;
    } catch (e) {
      throw ServerException(
        'Failed to load currency market data',
      );
    }
  }

  @override
  Future<List<StockModel>> searchStocks(
    String query,
  ) async {
    final q = query
        .trim()
        .toUpperCase();

    /// Fetch once if empty
    if (_cachedCurrencies.isEmpty) {
      await getLiveStocks();
    }

    /// Return all
    if (q.isEmpty) {
      return _cachedCurrencies;
    }

    /// Local filtering
    return _cachedCurrencies.where((item) {
      return item.symbol
              .toUpperCase()
              .contains(q) ||
          item.name
              .toUpperCase()
              .contains(q);
    }).toList();
  }
}

/// ===============================
/// LOCAL DATASOURCE
/// ===============================

abstract class StockLocalDataSource {
  Future<List<StockModel>>
      getLastLiveStocks();

  Future<void> cacheLiveStocks(
    List<StockModel> stocksToCache,
  );
}

const cachedLiveStocks =
    'CACHED_LIVE_STOCKS';

class StockLocalDataSourceImpl
    implements StockLocalDataSource {
  final SharedPreferences
      sharedPreferences;

  StockLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheLiveStocks(
    List<StockModel> stocksToCache,
  ) {
    return sharedPreferences.setString(
      cachedLiveStocks,

      json.encode(
        stocksToCache
            .map((e) => e.toJson())
            .toList(),
      ),
    );
  }

  @override
  Future<List<StockModel>>
      getLastLiveStocks() {
    final jsonString =
        sharedPreferences.getString(
      cachedLiveStocks,
    );

    if (jsonString == null) {
      throw CacheException();
    }

    final List<dynamic> jsonList =
        json.decode(jsonString)
            as List<dynamic>;

    return Future.value(
      jsonList
          .map(
            (json) =>
                StockModel.fromJson(
              json
                  as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}