import '../../domain/entities/crypto_coin.dart';

class CryptoModel extends CryptoCoin {
  const CryptoModel({
    required super.id,
    required super.symbol,
    required super.name,
    required super.imageUrl,
    required super.currentPrice,
    required super.priceChangePercentage24h,
  });

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(
      id: json['id'] ?? '',
      symbol: json['symbol']?.toString().toUpperCase() ?? '',
      name: json['name'] ?? 'Unknown Coin',
      imageUrl: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': imageUrl,
      'current_price': currentPrice,
      'price_change_percentage_24h': priceChangePercentage24h,
    };
  }
}
