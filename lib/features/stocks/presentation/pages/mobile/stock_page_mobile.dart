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
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = query.trim();
      if (q.isEmpty) {
        context.read<StockBloc>().add(FetchLiveStocks());
      } else {
        context.read<StockBloc>().add(SearchLiveStocks(q));
      }
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<StockBloc>().add(FetchLiveStocks());
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(
              child: SpinKitPulse(color: Colors.greenAccent, size: 60),
            );
          }

          if (state is StockLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _searchController.clear();
                context.read<StockBloc>().add(FetchLiveStocks());
              },
              child: StockPageContent(
                isSearching: _searchController.text.trim().isNotEmpty,
                stocks: state.stocks,
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onClearSearch: _onClearSearch,
              ),
            );
          }

          if (state is StockError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<StockBloc>().add(FetchLiveStocks()),
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

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Unable to load stock market data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
