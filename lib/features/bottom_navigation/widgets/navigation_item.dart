import 'package:flutter/material.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

const navigationItems = [
  NavigationItem(
    label: 'Stocks',
    icon: Icons.show_chart_outlined,
    selectedIcon: Icons.show_chart_rounded,
  ),
  NavigationItem(
    label: 'Crypto',
    icon: Icons.currency_bitcoin_outlined,
    selectedIcon: Icons.currency_bitcoin_rounded,
  ),
];
