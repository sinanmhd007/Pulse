import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pulse/features/news/presentation/widgets/build_slidable_news_card.dart';
import 'package:pulse/features/news/presentation/widgets/news_page_content.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      debugPrint('Could not launch $url');
    }
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer if typing continues
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Wait 500ms after user stops typing
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        context.read<NewsBloc>().add(SearchLiveNews(query.trim()));
      } else {
        context.read<NewsBloc>().add(FetchLiveNews());
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _onSearchChanged('');
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is NewsLoading) {
            return const Center(
              child: SpinKitPulse(color: Colors.blueAccent, size: 60),
            );
          } else if (state is NewsLoaded) {
            final articles = state.articles
                .where((a) => a.imageUrl != null && a.imageUrl!.isNotEmpty)
                .toList();

            final breakingNews = articles.take(5).toList();
            final todaysNews = articles.skip(5).toList();

            final isCurrentlySearching = _searchController.text
                .trim()
                .isNotEmpty;

            return RefreshIndicator(
              onRefresh: () async {
                _searchController.clear();
                _isSearching = false;
                setState(() {});
                context.read<NewsBloc>().add(FetchLiveNews());
              },
              child: NewsPageContent(
                isSearching: _isSearching, 
                isCurrentlySearching: isCurrentlySearching, 
                breakingNews: breakingNews, 
                todaysNews: todaysNews, 
                articles: articles, 
                searchController: _searchController, 
                onSearchChanged: _onSearchChanged, 
                toggleSearch: _toggleSearch, 
                launchUrl: _launchUrl, 
                buildSlidableNewsCard: (context, article) => SlidableNewsCard(
                  article: article,
                  onTap: _launchUrl,
                
                ),
              ),
            );

          } else if (state is NewsError) {
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
                    'Oops, looks like you\'re offline!',
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
                        context.read<NewsBloc>().add(FetchLiveNews()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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
    );
  }



 
}
