import '../../domain/entities/stock_quote.dart';

class StockModel extends StockQuote {
  const StockModel({
    required super.symbol,
    required super.name,
    required super.logoUrl,
    required super.currentPrice,
    required super.change,
    required super.changePercent,
    required super.highPrice,
    required super.lowPrice,
    required super.openPrice,
    required super.previousClosePrice,
  });

  factory StockModel.fromFinnhub({
    required String symbol,
    required Map<String, dynamic> quoteJson,
    Map<String, dynamic>? profileJson,
  }) {
    final profile = profileJson ?? <String, dynamic>{};
    return StockModel(
      symbol: symbol,
      name: (profile['name'] ?? symbol).toString(),
      logoUrl: profile['logo']?.toString(),
      currentPrice: (quoteJson['c'] as num?)?.toDouble() ?? 0,
      change: (quoteJson['d'] as num?)?.toDouble() ?? 0,
      changePercent: (quoteJson['dp'] as num?)?.toDouble() ?? 0,
      highPrice: (quoteJson['h'] as num?)?.toDouble() ?? 0,
      lowPrice: (quoteJson['l'] as num?)?.toDouble() ?? 0,
      openPrice: (quoteJson['o'] as num?)?.toDouble() ?? 0,
      previousClosePrice: (quoteJson['pc'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'logoUrl': logoUrl,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'openPrice': openPrice,
      'previousClosePrice': previousClosePrice,
    };
  }

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      change: (json['change'] as num?)?.toDouble() ?? 0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0,
      highPrice: (json['highPrice'] as num?)?.toDouble() ?? 0,
      lowPrice: (json['lowPrice'] as num?)?.toDouble() ?? 0,
      openPrice: (json['openPrice'] as num?)?.toDouble() ?? 0,
      previousClosePrice: (json['previousClosePrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
