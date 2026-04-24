import 'package:equatable/equatable.dart';

class CryptoCoin extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double priceChangePercentage24h;

  const CryptoCoin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.priceChangePercentage24h,
  });

  @override
  List<Object> get props => [
        id,
        symbol,
        name,
        imageUrl,
        currentPrice,
        priceChangePercentage24h,
      ];
}
