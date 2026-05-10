import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/responsive_layout.dart';
import 'mobile/crypto_page_mobile.dart';
import 'web/crypto_page_web.dart';

class CryptoPage extends StatelessWidget {
  const CryptoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileLayout: CryptoPageMobile(),
      webLayout: CryptoPageWeb(),
    );
  }
}
