import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget webLayout;
  final Widget? tabletLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.webLayout,
    this.tabletLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          // Web / Desktop
          return webLayout;
        } else if (constraints.maxWidth >= 600) {
          // Tablet
          return tabletLayout ?? webLayout;
        } else {
          // Mobile
          return mobileLayout;
        }
      },
    );
  }
}
