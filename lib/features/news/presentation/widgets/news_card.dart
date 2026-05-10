import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pulse/features/news/domain/entities/news_article.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final Function(String url) onTap;

  const NewsCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final useWebCard = MediaQuery.sizeOf(context).width >= 700;

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
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
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
        onTap: () => onTap(article.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(useWebCard ? 18 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: useWebCard ? 0.08 : 0.05),
                blurRadius: useWebCard ? 18 : 10,
                offset: Offset(0, useWebCard ? 10 : 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: useWebCard ? _buildWebCard(context) : _buildMobileCard(context),
        ),
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _ArticleImage(article: article, width: 100, height: 100, radius: 16),
          const SizedBox(width: 16),
          Expanded(child: _ArticleText(article: article, timeAgo: timeAgo)),
        ],
      ),
    );
  }

  Widget _buildWebCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _ArticleImage(
            article: article,
            width: double.infinity,
            height: double.infinity,
            radius: 0,
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: _ArticleText(
              article: article,
              timeAgo: timeAgo,
              titleMaxLines: 3,
              titleSize: 17,
            ),
          ),
        ),
      ],
    );
  }

  String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 1) return '${diff.inDays} days ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }
}

class _ArticleImage extends StatelessWidget {
  final NewsArticle article;
  final double width;
  final double height;
  final double radius;

  const _ArticleImage({
    required this.article,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: article.url,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: article.imageUrl ?? '',
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const SpinKitPulse(color: Colors.blueAccent, size: 30),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline),
          ),
        ),
      ),
    );
  }
}

class _ArticleText extends StatelessWidget {
  final NewsArticle article;
  final String Function(DateTime) timeAgo;
  final int titleMaxLines;
  final double titleSize;

  const _ArticleText({
    required this.article,
    required this.timeAgo,
    this.titleMaxLines = 2,
    this.titleSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          article.title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          maxLines: titleMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              timeAgo(article.publishedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                article.sourceName ?? 'Web',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
