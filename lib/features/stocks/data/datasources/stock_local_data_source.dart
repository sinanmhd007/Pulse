import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/stock_model.dart';

abstract class StockLocalDataSource {
  Future<List<StockModel>> getLastLiveStocks();
  Future<void> cacheLiveStocks(List<StockModel> stocksToCache);
}

const cachedLiveStocks = 'CACHED_LIVE_STOCKS';

class StockLocalDataSourceImpl implements StockLocalDataSource {
  final SharedPreferences sharedPreferences;

  StockLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheLiveStocks(List<StockModel> stocksToCache) {
    return sharedPreferences.setString(
      cachedLiveStocks,
      json.encode(stocksToCache.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<StockModel>> getLastLiveStocks() {
    final jsonString = sharedPreferences.getString(cachedLiveStocks);
    if (jsonString == null) {
      throw CacheException();
    }

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return Future.value(
      jsonList
          .map((json) => StockModel.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }
}
