import 'package:flutter/material.dart';

class NavigationMobile extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<Widget> pages;

  const NavigationMobile({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Crypto',
          ),
        ],
      ),
    );
  }
}
