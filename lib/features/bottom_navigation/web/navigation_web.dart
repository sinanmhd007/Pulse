import 'package:flutter/material.dart';

class NavigationWeb extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<Widget> pages;

  const NavigationWeb({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onTabSelected,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.article),
                label: Text('News'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.currency_bitcoin),
                label: Text('Crypto'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: pages[currentIndex],
          ),
        ],
      ),
    );
  }
}
