import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/responsive_layout.dart';
import 'mobile/signup_page_mobile.dart';
import 'web/signup_page_web.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileLayout: SignupPageMobile(),
      webLayout: SignupPageWeb(),
    );
  }
}
