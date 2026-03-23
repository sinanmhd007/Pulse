import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/crypto_model.dart';

abstract class CryptoLocalDataSource {
  Future<List<CryptoModel>> getLastLiveCrypto();
  Future<void> cacheLiveCrypto(List<CryptoModel> cryptoToCache);
}

const CACHED_LIVE_CRYPTO = 'CACHED_LIVE_CRYPTO';

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  final SharedPreferences sharedPreferences;

  CryptoLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheLiveCrypto(List<CryptoModel> cryptoToCache) {
    return sharedPreferences.setString(
      CACHED_LIVE_CRYPTO,
      json.encode(cryptoToCache.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<CryptoModel>> getLastLiveCrypto() {
    final jsonString = sharedPreferences.getString(CACHED_LIVE_CRYPTO);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((json) => CryptoModel.fromJson(json)).toList());
    } else {
      throw CacheException();
    }
  }
}
