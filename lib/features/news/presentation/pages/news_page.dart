import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../../domain/entities/news_article.dart';

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
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: _isSearching ? 130.0 : 80.0,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      title: !_isSearching
                          ? Text(
                              'Discover',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                                letterSpacing: 1.2,
                              ),
                            )
                          : null,
                      background: _isSearching
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  16,
                                ),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _onSearchChanged,
                                    autofocus: true,
                                    style: const TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      hintText: 'Search the news...',
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.blueAccent,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                        ),
                                        onPressed: _toggleSearch,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    actions: !_isSearching
                        ? [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey.withValues(
                                  alpha: 0.1,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: _toggleSearch,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),

                  if (articles.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            'No news found for "${_searchController.text}"',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (!isCurrentlySearching && breakingNews.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Breaking News',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: CarouselSlider.builder(
                        itemCount: breakingNews.length,
                        options: CarouselOptions(
                          height: 240,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                        ),
                        itemBuilder: (context, index, realIdx) {
                          return _buildCarouselItem(
                            context,
                            breakingNews[index],
                          );
                        },
                      ),
                    ),
                  ],

                  if (todaysNews.isNotEmpty || isCurrentlySearching)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.pinkAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCurrentlySearching
                                      ? 'Search Results'
                                      : 'Today\'s News',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (!isCurrentlySearching)
                              Text(
                                'See all',
                                style: TextStyle(
                                  color: Colors.blueAccent.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listToUse = isCurrentlySearching
                            ? articles
                            : todaysNews;
                        if (index >= listToUse.length)
                          return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: _buildSlidableNewsCard(
                            context,
                            listToUse[index],
                          ),
                        );
                      },
                      childCount: isCurrentlySearching
                          ? articles.length
                          : todaysNews.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
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

  Widget _buildCarouselItem(BuildContext context, NewsArticle article) {
    return GestureDetector(
      onTap: () => _launchUrl(article.url),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: article.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const SpinKitDoubleBounce(color: Colors.white30),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.sourceName ?? 'News',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlidableNewsCard(BuildContext context, NewsArticle article) {
    return Slidable(
      key: ValueKey(article.url),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            icon: Icons.bookmark_add_outlined,
            label: 'Save',
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(8),
          ),
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.share_rounded,
            label: 'Share',
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _launchUrl(article.url),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: article.url,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const SpinKitPulse(
                        color: Colors.blueAccent,
                        size: 30,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeAgo(article.publishedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          article.sourceName ?? 'Web',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 1) return '${diff.inDays} days ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }
}
