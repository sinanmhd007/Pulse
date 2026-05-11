import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../bloc/stock_bloc.dart';
import '../../bloc/stock_event.dart';
import '../../bloc/stock_state.dart';
import '../../widgets/stock_page_content.dart';

class StockPageMobile extends StatefulWidget {
  const StockPageMobile({super.key});

  @override
  State<StockPageMobile> createState() => _StockPageMobileState();
}

class _StockPageMobileState extends State<StockPageMobile> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);

    _debounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  void _onSearchTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        final q = query.trim();

        if (q.isEmpty) {
          context.read<StockBloc>().add(
                FetchLiveStocks(),
              );
        } else {
          context.read<StockBloc>().add(
                SearchLiveStocks(q),
              );
        }
      },
    );
  }

  void _onClearSearch() {
    _debounce?.cancel();

    _searchController.clear();

    context.read<StockBloc>().add(
          FetchLiveStocks(),
        );

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          /// Loading
          if (state is StockLoading) {
            return const Center(
              child: SpinKitPulse(
                color: Colors.greenAccent,
                size: 60,
              ),
            );
          }

          /// Success
          if (state is StockLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _debounce?.cancel();

                _searchController.clear();

                context.read<StockBloc>().add(
                      FetchLiveStocks(),
                    );
              },

              child: StockPageContent(
                isSearching:
                    _searchController.text.trim().isNotEmpty,

                stocks: state.stocks,

                searchController: _searchController,

                onSearchChanged: _onSearchChanged,

                onClearSearch: _onClearSearch,
              ),
            );
          }

          /// Error
          if (state is StockError) {
            return _ErrorView(
              message: state.message,

              onRetry: () {
                context.read<StockBloc>().add(
                      FetchLiveStocks(),
                    );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.currency_exchange,
              size: 80,
              color: Colors.grey[400],
            ),

            const SizedBox(height: 14),

            const Text(
              'Unable to load currency market data',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh),

              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}