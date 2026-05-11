import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/responsive_layout.dart';
import 'mobile/stock_page_mobile.dart';
import 'web/stock_page_web.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileLayout: StockPageMobile(),
      webLayout: StockPageWeb(),
    );
  }
}
