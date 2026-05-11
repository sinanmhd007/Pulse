import 'package:equatable/equatable.dart';

class StockQuote extends Equatable {
  final String symbol;
  final String name;
  final String? logoUrl;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double highPrice;
  final double lowPrice;
  final double openPrice;
  final double previousClosePrice;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.logoUrl,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.openPrice,
    required this.previousClosePrice,
  });

  @override
  List<Object?> get props => [
        symbol,
        name,
        logoUrl,
        currentPrice,
        change,
        changePercent,
        highPrice,
        lowPrice,
        openPrice,
        previousClosePrice,
      ];
}
