import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/responsive_layout.dart';
import 'mobile/news_page_mobile.dart';
import 'web/news_page_web.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileLayout: NewsPageMobile(),
      webLayout: NewsPageWeb(),
    );
  }
}
