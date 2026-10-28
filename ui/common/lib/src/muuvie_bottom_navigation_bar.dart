import 'package:flutter/material.dart';

class MuuvieBottomNavigationBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const MuuvieBottomNavigationBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class MuuvieBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<MuuvieBottomNavigationBarItem> items;
  final MuuvieBottomNavigationBarItem? centerItem;
  final VoidCallback? onCenterTap;

  const MuuvieBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.centerItem,
    this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCenter = centerItem != null;

    if (!hasCenter) {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon ?? item.icon),
                label: item.label,
              ),
            )
            .toList(),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final centerIndex = items.length ~/ 2;
    final mappedIndex = currentIndex >= centerIndex
        ? currentIndex + 1
        : currentIndex;

    final destinations = <NavigationDestination>[];
    for (var i = 0; i < items.length; i++) {
      if (i == centerIndex) {
        destinations.add(
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(centerItem!.icon, color: colorScheme.onSecondary),
            ),
            label: centerItem!.label,
          ),
        );
      }
      final item = items[i];
      destinations.add(
        NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        NavigationBar(
          selectedIndex: mappedIndex,
          onDestinationSelected: (index) {
            if (index == centerIndex) {
              onCenterTap?.call();
              return;
            }
            onTap(index > centerIndex ? index - 1 : index);
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: destinations,
        ),
        Positioned(
          top: 8,
          child: FloatingActionButton(
            onPressed: onCenterTap,
            tooltip: centerItem!.label,
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            child: Icon(centerItem!.icon, semanticLabel: ''),
          ),
        ),
      ],
    );
  }
}
