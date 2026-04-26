import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pulse/features/news/domain/entities/news_article.dart';
import 'package:pulse/features/news/presentation/widgets/news_slidable_item.dart';

class NewsPageContent extends StatelessWidget {
  final bool isSearching;
  final bool isCurrentlySearching;

  final List<NewsArticle> breakingNews;
  final List<NewsArticle> todaysNews;
  final List<NewsArticle> articles;

  final TextEditingController searchController;

  final Function(String) onSearchChanged;
  final VoidCallback toggleSearch;
  final Function(String) launchUrl;

  final Widget Function(BuildContext, NewsArticle) buildSlidableNewsCard;

  const NewsPageContent({
    super.key,
    required this.isSearching,
    required this.isCurrentlySearching,
    required this.breakingNews,
    required this.todaysNews,
    required this.articles,
    required this.searchController,
    required this.onSearchChanged,
    required this.toggleSearch,
    required this.launchUrl,
    required this.buildSlidableNewsCard,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: isSearching ? 130.0 : 80.0,
          floating: true,
          pinned: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            title: !isSearching
                ? Text(
                    'Discover',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                  )
                : null,
            background: isSearching
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Container(
                        height: 50,
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
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search the news...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: toggleSearch,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          actions: !isSearching
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(
                        0,
                        0,
                        0,
                        0,
                      ).withValues(alpha: 1),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: toggleSearch,
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
                  'No news found for "${searchController.text}"',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

        /// Breaking News Section
        if (!isCurrentlySearching && breakingNews.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                'Breaking News',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              ),
              itemBuilder: (context, index, realIdx) {
                final article = breakingNews[index];
                return NewsSlidableItem(article: article, onTap: launchUrl);
              },
            ),
          ),
        ],

        /// Section Title
        if (todaysNews.isNotEmpty || isCurrentlySearching)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text(
                isCurrentlySearching ? 'Search Results' : 'Today\'s News',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        /// News List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final listToUse = isCurrentlySearching ? articles : todaysNews;

              if (index >= listToUse.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: buildSlidableNewsCard(context, listToUse[index]),
              );
            },
            childCount: isCurrentlySearching
                ? articles.length
                : todaysNews.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}
