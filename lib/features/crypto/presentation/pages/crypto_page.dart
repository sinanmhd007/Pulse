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
    if (query.trim().isNotEmpty) {
      context.read<CryptoBloc>().add(SearchLiveCrypto(query.trim()));
    } else {
      context.read<CryptoBloc>().add(FetchLiveCrypto());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {
          if (state is CryptoLoading) {
            return const Center(child: SpinKitPulse(color: Colors.greenAccent, size: 60));
          } else if (state is CryptoLoaded) {
            final List<CryptoCoin> allCoins = state.coins;
            // Let's create a 'Top Movers' simple logic if not searching
            final isSearching = _searchController.text.isNotEmpty;
            List<CryptoCoin> topMovers = [];
            
            if (!isSearching && allCoins.length >= 3) {
               topMovers = List.from(allCoins)
                ..sort((a, b) => b.priceChangePercentage24h.abs().compareTo(a.priceChangePercentage24h.abs()));
               topMovers = topMovers.take(5).toList();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _searchController.clear();
                context.read<CryptoBloc>().add(FetchLiveCrypto());
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120.0,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      title: Text(
                        'Market',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search coins...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.green),
                            suffixIcon: isSearching ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                FocusScope.of(context).unfocus();
                              },
                            ) : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isSearching && topMovers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Top Movers',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: topMovers.length,
                          itemBuilder: (context, index) {
                            return _buildTopMoverCard(context, topMovers[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSearching ? 'Search Results' : 'Top Assets',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  allCoins.isEmpty 
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Text('No coins found for "${_searchController.text}"', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                        ),
                      ),
                    )
                  : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                          child: _buildCryptoCard(context, allCoins[index], index + 1),
                        );
                      },
                      childCount: allCoins.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            );
          } else if (state is CryptoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Unable to retrieve markets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => context.read<CryptoBloc>().add(FetchLiveCrypto()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTopMoverCard(BuildContext context, CryptoCoin coin) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isNegative = coin.priceChangePercentage24h < 0;

    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNegative ? Colors.redAccent.withValues(alpha: 0.1) : Colors.greenAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isNegative ? Colors.redAccent.withValues(alpha: 0.3) : Colors.greenAccent.withValues(alpha: 0.3),
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
                placeholder: (context, url) => const SpinKitDoubleBounce(color: Colors.grey, size: 20),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  coin.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildCryptoCard(BuildContext context, CryptoCoin coin, int rank) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isNegative = coin.priceChangePercentage24h < 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 12),
          CachedNetworkImage(
            imageUrl: coin.imageUrl,
            width: 44,
            height: 44,
            placeholder: (context, url) => const SpinKitDoubleBounce(color: Colors.grey, size: 20),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coin.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  coin.symbol.toUpperCase(),
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormatter.format(coin.currentPrice),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNegative ? Colors.redAccent.withValues(alpha: 0.1) : Colors.greenAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNegative ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                      color: isNegative ? Colors.redAccent : Colors.green,
                      size: 16,
                    ),
                    Text(
                      '${coin.priceChangePercentage24h.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isNegative ? Colors.redAccent : Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
