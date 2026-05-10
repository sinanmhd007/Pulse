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
    label: 'News',
    icon: Icons.article_outlined,
    selectedIcon: Icons.article_rounded,
  ),
  NavigationItem(
    label: 'Crypto',
    icon: Icons.currency_bitcoin_outlined,
    selectedIcon: Icons.currency_bitcoin_rounded,
  ),
];
