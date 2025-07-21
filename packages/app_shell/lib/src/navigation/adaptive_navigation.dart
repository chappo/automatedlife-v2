import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/navigation_item.dart';

/// Breakpoint for determining mobile vs tablet layout
const double _mobileBreakpoint = 768.0;

/// Adaptive navigation that switches between bottom nav and nav rail
class AdaptiveNavigation extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final String currentRoute;
  final ValueChanged<NavigationItem> onNavigationChanged;
  final Widget? leading;
  final List<Widget>? trailing;

  const AdaptiveNavigation({
    super.key,
    required this.navigationItems,
    required this.currentRoute,
    required this.onNavigationChanged,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _mobileBreakpoint) {
          return _buildBottomNavigation(context);
        } else {
          return _buildNavigationRail(context);
        }
      },
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Limit to 5 items for bottom navigation
    final items = navigationItems.take(5).toList();
    final currentIndex = _getCurrentIndex(items);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index < items.length) {
          onNavigationChanged(items[index]);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      elevation: 8,
      items: items.map((item) => _buildBottomNavigationBarItem(item)).toList(),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentIndex = _getCurrentIndex(navigationItems);

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index < navigationItems.length) {
          onNavigationChanged(navigationItems[index]);
        }
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: colorScheme.surface,
      elevation: 1,
      leading: leading,
      trailing: trailing != null 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: trailing!,
            )
          : null,
      destinations: navigationItems
          .map((item) => _buildNavigationRailDestination(item))
          .toList(),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(NavigationItem item) {
    return BottomNavigationBarItem(
      icon: _buildNavigationIcon(item, false),
      activeIcon: _buildNavigationIcon(item, true),
      label: item.label,
      tooltip: item.label,
    );
  }

  NavigationRailDestination _buildNavigationRailDestination(NavigationItem item) {
    return NavigationRailDestination(
      icon: _buildNavigationIcon(item, false),
      selectedIcon: _buildNavigationIcon(item, true),
      label: Text(item.label),
    );
  }

  Widget _buildNavigationIcon(NavigationItem item, bool isSelected) {
    final icon = isSelected && item.selectedIcon != null 
        ? item.selectedIcon! 
        : item.icon;

    Widget iconWidget = Icon(icon);

    // Add badge if present
    if (item.badge != null && item.badge! > 0) {
      iconWidget = Badge(
        label: Text(item.badge.toString()),
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  int _getCurrentIndex(List<NavigationItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == currentRoute) {
        return i;
      }
    }
    return 0;
  }
}

/// Extended navigation rail for larger screens with additional features
class ExtendedNavigationRail extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final String currentRoute;
  final ValueChanged<NavigationItem> onNavigationChanged;
  final Widget? header;
  final Widget? footer;
  final bool isExtended;

  const ExtendedNavigationRail({
    super.key,
    required this.navigationItems,
    required this.currentRoute,
    required this.onNavigationChanged,
    this.header,
    this.footer,
    this.isExtended = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentIndex = _getCurrentIndex();

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index < navigationItems.length) {
          onNavigationChanged(navigationItems[index]);
        }
      },
      extended: isExtended,
      labelType: isExtended 
          ? NavigationRailLabelType.none 
          : NavigationRailLabelType.all,
      backgroundColor: colorScheme.surface,
      elevation: 1,
      leading: header,
      trailing: footer,
      destinations: navigationItems
          .map((item) => _buildDestination(item))
          .toList(),
    );
  }

  NavigationRailDestination _buildDestination(NavigationItem item) {
    return NavigationRailDestination(
      icon: _buildIcon(item, false),
      selectedIcon: _buildIcon(item, true),
      label: Text(item.label),
    );
  }

  Widget _buildIcon(NavigationItem item, bool isSelected) {
    final icon = isSelected && item.selectedIcon != null 
        ? item.selectedIcon! 
        : item.icon;

    Widget iconWidget = Icon(icon);

    if (item.badge != null && item.badge! > 0) {
      iconWidget = Badge(
        label: Text(item.badge.toString()),
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  int _getCurrentIndex() {
    for (int i = 0; i < navigationItems.length; i++) {
      if (navigationItems[i].route == currentRoute) {
        return i;
      }
    }
    return 0;
  }
}