import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:pulse/features/crypto/domain/entities/crypto_coin.dart';

class TopMoverCard extends StatelessWidget {
  final CryptoCoin coin;
  const TopMoverCard({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final isNegative = coin.priceChangePercentage24h < 0;
    
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNegative
            ? Colors.redAccent.withValues(alpha: 0.1)
            : Colors.greenAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isNegative
              ? Colors.redAccent.withValues(alpha: 0.3)
              : Colors.greenAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CachedNetworkImage(
                imageUrl: coin.imageUrl,
                width: 36,
                height: 36,
                placeholder: (context, url) =>
                    const SpinKitDoubleBounce(color: Colors.grey, size: 20),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    coin.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            currencyFormatter.format(coin.currentPrice),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isNegative ? Icons.trending_down : Icons.trending_up,
                color: isNegative ? Colors.redAccent : Colors.green,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${coin.priceChangePercentage24h.abs().toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isNegative ? Colors.redAccent : Colors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
