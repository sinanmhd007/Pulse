import 'package:flutter/material.dart';
import '../../core/presentation/widgets/responsive_layout.dart';
import '../stocks/presentation/pages/stock_page.dart';
import '../crypto/presentation/pages/crypto_page.dart';
import 'mobile/navigation_mobile.dart';
import 'web/navigation_web.dart';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    StockPage(),
    CryptoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: NavigationMobile(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        pages: _pages,
      ),
      webLayout: NavigationWeb(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        pages: _pages,
      ),
    );
  }
}
