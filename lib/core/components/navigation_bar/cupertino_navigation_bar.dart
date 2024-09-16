import 'package:flutter/cupertino.dart';

import '../../utils/extension_methods.dart';
import '../scaffold/app_navigation_scaffold.dart';

class CupertinoBottomNavigationBar extends StatelessWidget {
  const CupertinoBottomNavigationBar({
    required this.index,
    required this.items,
    required this.onDestinationSelected,
    super.key,
  });

  final int index;
  final void Function(int index) onDestinationSelected;
  final List<NavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: index,
      onTap: onDestinationSelected,
      items: items.mapList(
        (e) => BottomNavigationBarItem(
          icon: e.icon,
          activeIcon: e.selectedIcon,
          label: e.label,
        ),
      ),
    );
  }
}
