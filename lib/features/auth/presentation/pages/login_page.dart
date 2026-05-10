import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/responsive_layout.dart';
import 'mobile/login_page_mobile.dart';
import 'web/login_page_web.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileLayout: LoginPageMobile(),
      webLayout: LoginPageWeb(),
    );
  }
}
