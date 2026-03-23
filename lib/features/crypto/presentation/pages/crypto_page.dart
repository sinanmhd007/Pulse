import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../bloc/crypto_bloc.dart';
import '../bloc/crypto_event.dart';
import '../bloc/crypto_state.dart';
import '../../domain/entities/crypto_coin.dart';

class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      context.read<CryptoBloc>().add(SearchLiveCrypto(query));
    } else {
      context.read<CryptoBloc>().add(FetchLiveCrypto());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Tracker'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search coins...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {
          if (state is CryptoLoading) {
            return const Center(child: SpinKitPulse(color: Colors.green));
          } else if (state is CryptoLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _searchController.clear();
                context.read<CryptoBloc>().add(FetchLiveCrypto());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.coins.length,
                itemBuilder: (context, index) {
                  return _buildCryptoCard(context, state.coins[index]);
                },
              ),
            );
          } else if (state is CryptoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CryptoBloc>().add(FetchLiveCrypto()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No crypto data available.'));
        },
      ),
    );
  }

  Widget _buildCryptoCard(BuildContext context, CryptoCoin coin) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isNegative = coin.priceChangePercentage24h < 0;
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: coin.imageUrl,
          width: 40,
          height: 40,
          placeholder: (context, url) => const SpinKitDoubleBounce(color: Colors.grey, size: 20),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        title: Text(coin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(coin.symbol),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormatter.format(coin.currentPrice),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNegative ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  color: isNegative ? Colors.red : Colors.green,
                  size: 20,
                ),
                Text(
                  '${coin.priceChangePercentage24h.abs().toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isNegative ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
