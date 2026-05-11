import 'package:flutter/material.dart';
import '../../domain/entities/stock_quote.dart';
import 'stock_card.dart';

class StockPageContent extends StatelessWidget {
  final bool isSearching;
  final List<StockQuote> stocks;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const StockPageContent({
    super.key,
    required this.isSearching,
    required this.stocks,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        /// App Bar
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          floating: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),

            title: Text(
              isSearching
                  ? 'Currency Search'
                  : 'Currency Market',

              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        /// Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),

            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,

                decoration: InputDecoration(
                  hintText: 'Search currency (INR, EUR, GBP...)',

                  prefixIcon: const Icon(Icons.search),

                  suffixIcon: isSearching
                      ? IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(Icons.close),
                        )
                      : null,

                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        /// Empty State
        if (stocks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),

              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      size: 70,
                      color: Colors.grey[400],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      isSearching
                          ? 'No currency found for "${searchController.text}"'
                          : 'No currency market data available',

                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),

                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )

        /// Grid
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),

            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;

                final count = width > 1200
                    ? 4
                    : width > 900
                        ? 3
                        : width > 650
                            ? 2
                            : 1;

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return StockCard(
                        stock: stocks[index],
                      );
                    },
                    childCount: stocks.length,
                  ),

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,

                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,

                    childAspectRatio: count == 1
                        ? 1.65
                        : count == 2
                            ? 1.25
                            : 1.1,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}