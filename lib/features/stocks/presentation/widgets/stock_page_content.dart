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
        SliverAppBar(
          expandedHeight: 132,
          pinned: true,
          floating: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            title: Text(
              isSearching ? 'Stock Search' : 'Stock Market',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search symbols (AAPL, TSLA, MSFT...)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: isSearching
                      ? IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
        if (stocks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Text(
                  isSearching
                      ? 'No stocks found for "${searchController.text}".'
                      : 'No stock data available.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final count = width > 1100
                    ? 3
                    : width > 700
                        ? 2
                        : 1;

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => StockCard(stock: stocks[index]),
                    childCount: stocks.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: count == 1 ? 1.75 : 1.35,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
