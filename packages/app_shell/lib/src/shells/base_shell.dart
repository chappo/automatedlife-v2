import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/navigation_item.dart';
import '../navigation/adaptive_navigation.dart';
import '../navigation/navigation_provider.dart';

/// Base shell that provides common layout and navigation structure
class BaseShell extends ConsumerWidget {
  final Widget child;
  final String currentRoute;
  final PreferredSizeWidget? appBar;
  final List<NavigationItem> navigationItems;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const BaseShell({
    super.key,
    required this.child,
    required this.currentRoute,
    this.appBar,
    required this.navigationItems,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        if (isMobile) {
          return _buildMobileLayout(context, ref);
        } else {
          return _buildDesktopLayout(context, ref);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: child,
      bottomNavigationBar: navigationItems.isNotEmpty
          ? AdaptiveNavigation(
              navigationItems: navigationItems,
              currentRoute: currentRoute,
              onNavigationChanged: (item) {
                ref.read(navigationProvider.notifier).navigateTo(item.route);
              },
            )
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBar,
      endDrawer: endDrawer,
      body: Row(
        children: [
          if (navigationItems.isNotEmpty)
            AdaptiveNavigation(
              navigationItems: navigationItems,
              currentRoute: currentRoute,
              onNavigationChanged: (item) {
                ref.read(navigationProvider.notifier).navigateTo(item.route);
              },
            ),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// Responsive shell that adapts layout based on screen size
class ResponsiveShell extends ConsumerWidget {
  final Widget child;
  final String currentRoute;
  final String title;
  final List<NavigationItem> navigationItems;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBuildingSwitcher;

  const ResponsiveShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
    required this.navigationItems,
    this.actions,
    this.floatingActionButton,
    this.showBuildingSwitcher = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildCompactLayout(context, ref);
        } else if (constraints.maxWidth < 1200) {
          return _buildMediumLayout(context, ref);
        } else {
          return _buildExpandedLayout(context, ref);
        }
      },
    );
  }

  Widget _buildCompactLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: _buildNavigationDrawer(context, ref),
      body: child,
      bottomNavigationBar: navigationItems.length <= 5
          ? AdaptiveNavigation(
              navigationItems: navigationItems.take(5).toList(),
              currentRoute: currentRoute,
              onNavigationChanged: (item) {
                ref.read(navigationProvider.notifier).navigateTo(item.route);
              },
            )
          : null,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildMediumLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          AdaptiveNavigation(
            navigationItems: navigationItems,
            currentRoute: currentRoute,
            onNavigationChanged: (item) {
              ref.read(navigationProvider.notifier).navigateTo(item.route);
            },
          ),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildExpandedLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          ExtendedNavigationRail(
            navigationItems: navigationItems,
            currentRoute: currentRoute,
            onNavigationChanged: (item) {
              ref.read(navigationProvider.notifier).navigateTo(item.route);
            },
            isExtended: true,
          ),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildNavigationDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          ...navigationItems.map((item) => ListTile(
            leading: Icon(item.icon),
            title: Text(item.label),
            selected: currentRoute == item.route,
            onTap: () {
              Navigator.pop(context);
              ref.read(navigationProvider.notifier).navigateTo(item.route);
            },
          )),
        ],
      ),
    );
  }
}