import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pulse/features/crypto/presentation/widgets/market_screen.dart';
import 'dart:async';

import '../../bloc/crypto_bloc.dart';
import '../../bloc/crypto_event.dart';
import '../../bloc/crypto_state.dart';
import '../../../domain/entities/crypto_coin.dart';

class CryptoPageWeb extends StatefulWidget {
  const CryptoPageWeb({super.key});

  @override
  State<CryptoPageWeb> createState() => _CryptoPageWebState();
}

class _CryptoPageWebState extends State<CryptoPageWeb> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final trimmed = query.trim();
      if (trimmed.isNotEmpty) {
        context.read<CryptoBloc>().add(SearchLiveCrypto(trimmed));
      } else {
        context.read<CryptoBloc>().add(FetchLiveCrypto());
      }
    });
  }

  void _onClearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<CryptoBloc>().add(FetchLiveCrypto());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: BlocBuilder<CryptoBloc, CryptoState>(
            builder: (context, state) {
              if (state is CryptoLoading) {
                return const Center(
                  child: SpinKitPulse(color: Colors.greenAccent, size: 60),
                );
              } else if (state is CryptoLoaded) {
                final List<CryptoCoin> allCoins = state.coins;
                final isSearching = _searchController.text.isNotEmpty;
                List<CryptoCoin> topMovers = [];

                if (!isSearching && allCoins.length >= 3) {
                  topMovers = List.from(allCoins)
                    ..sort(
                      (a, b) => b.priceChangePercentage24h.abs().compareTo(
                        a.priceChangePercentage24h.abs(),
                      ),
                    );
                  topMovers = topMovers.take(5).toList();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _debounce?.cancel();
                    _searchController.clear();
                    context.read<CryptoBloc>().add(FetchLiveCrypto());
                  },
                  child: MarketScreen(
                    isSearching: isSearching,
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onClearSearch: _onClearSearch,
                    topMovers: topMovers,
                    allCoins: allCoins,
                    useWideLayout: true,
                  ),
                );
              } else if (state is CryptoError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Unable to retrieve markets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<CryptoBloc>().add(FetchLiveCrypto()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Try Again',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
