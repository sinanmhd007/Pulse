import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_quote.dart';

class StockCard extends StatelessWidget {
  final StockQuote stock;

  const StockCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final percentFmt = NumberFormat("+#0.00;-#0.00");
    final changeFmt = NumberFormat("+#0.00;-#0.00");
    final isNegative = stock.changePercent < 0;
    final accent = isNegative ? Colors.redAccent : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Logo(logoUrl: stock.logoUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      stock.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            priceFmt.format(stock.currentPrice),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${changeFmt.format(stock.change)} (${percentFmt.format(stock.changePercent)}%)',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Metric(label: 'Open', value: priceFmt.format(stock.openPrice)),
              _Metric(label: 'High', value: priceFmt.format(stock.highPrice)),
              _Metric(label: 'Low', value: priceFmt.format(stock.lowPrice)),
              _Metric(
                label: 'Prev Close',
                value: priceFmt.format(stock.previousClosePrice),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? logoUrl;

  const _Logo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return const CircleAvatar(
        radius: 20,
        child: Icon(Icons.show_chart_rounded),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const CircleAvatar(
          radius: 20,
          child: Icon(Icons.show_chart_rounded),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
