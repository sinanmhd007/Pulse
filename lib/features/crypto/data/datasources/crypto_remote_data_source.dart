import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/crypto_model.dart';

abstract class CryptoRemoteDataSource {
  Future<List<CryptoModel>> getLiveCryptoPrices();
  Future<List<CryptoModel>> searchCrypto(String query);
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final http.Client client;

  CryptoRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CryptoModel>> getLiveCryptoPrices() async {
    final response = await client.get(
      Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CryptoModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<CryptoModel>> searchCrypto(String query) async {
    // CoinGecko search endpoint doesn't return full price data directly in the same format.
    // For simplicity of this demo, we'll fetch top markets and filter locally, 
    // or you could use their dedicated search endpoint and map appropriately.
    final allCoins = await getLiveCryptoPrices();
    final lowercaseQuery = query.toLowerCase();
    
    return allCoins.where((coin) {
      return coin.name.toLowerCase().contains(lowercaseQuery) || 
             coin.symbol.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
