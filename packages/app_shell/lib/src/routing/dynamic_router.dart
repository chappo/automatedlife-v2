import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigation/navigation_provider.dart';
import '../widgets/building_switcher.dart';
import '../screens/settings_screen.dart';
import '../utils/icon_mapper.dart';

/// Provider for dynamic router that adapts to building capabilities
final dynamicRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: DynamicRouterRefreshStream(ref),
    redirect: (context, state) {
      return _handleRedirect(ref, state);
    },
    routes: _buildDynamicRoutes(ref),
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Route Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Build routes dynamically based on building capabilities
List<RouteBase> _buildDynamicRoutes(ProviderRef ref) {
  final navigationState = ref.watch(navigationProvider);
  
  return [
    ShellRoute(
      builder: (context, state, child) {
        return _buildAppShell(context, ref, state, child);
      },
      routes: [
        // Always include dashboard
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        
        // Dynamically add capability routes
        ..._buildCapabilityRoutes(navigationState.availableCapabilities),
        
        // Always include settings
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ];
}

/// Build routes for each enabled capability from API
List<GoRoute> _buildCapabilityRoutes(List<String> capabilities) {
  final routes = <GoRoute>[];
  
  // Get the navigation state to access actual capability data
  for (final capabilityKey in capabilities) {
    routes.add(GoRoute(
      path: '/$capabilityKey',
      name: capabilityKey,
      builder: (context, state) {
        // This will be dynamically determined by the capability type from API
        return DynamicCapabilityPage(capabilityKey: capabilityKey);
      },
    ));
  }
  
  return routes;
}

/// Handle route redirects and access control
String? _handleRedirect(ProviderRef ref, GoRouterState state) {
  final navigationState = ref.read(navigationProvider);
  final location = state.matchedLocation;
  
  // Always allow access to dashboard and settings
  if (location == '/dashboard' || location == '/settings') {
    return null;
  }
  
  // Check if user has access to capability-based routes
  final capability = _extractCapabilityFromPath(location);
  if (capability != null && !navigationState.availableCapabilities.contains(capability)) {
    // Redirect to dashboard if user doesn't have access to this capability
    return '/dashboard';
  }
  
  return null;
}

/// Extract capability name from route path
String? _extractCapabilityFromPath(String path) {
  if (path.startsWith('/')) {
    final segments = path.substring(1).split('/');
    if (segments.isNotEmpty) {
      final firstSegment = segments.first;
      // Map route names to capability keys
      switch (firstSegment) {
        case 'defects': return 'defects';
        case 'messaging': return 'messaging';
        case 'documents': return 'documents';
        case 'calendar': return 'calendar';
        case 'intercom': return '2n_intercom';
        case 'wiser': return 'clipsal_wiser';
        default: return firstSegment;
      }
    }
  }
  return null;
}

/// Build the app shell around the routed content
Widget _buildAppShell(BuildContext context, ProviderRef ref, GoRouterState state, Widget child) {
  final navigationState = ref.watch(navigationProvider);
  
  // Use drawer for navigation if there are too many capabilities
  final useSideNavigation = navigationState.availableCapabilities.length > 4;
  
  return Scaffold(
    appBar: AppBar(
      title: Text(navigationState.currentBuilding?.name ?? 'Building Manager'),
      actions: [
        // Always show building switcher if there are multiple buildings
        if (navigationState.availableBuildings.length > 1)
          BuildingSwitcherButton(
            currentBuilding: navigationState.currentBuilding,
            onBuildingSelected: (building) async {
              // Switch building using AuthService (this will fetch new capabilities)
              final authService = AuthService.instance;
              await authService.selectBuilding(building);
              
              // Update navigation state
              ref.read(navigationProvider.notifier).setCurrentBuilding(building);
              
              // Don't invalidate the router here - the capability stream will handle updates
            },
          ),
      ],
    ),
    drawer: useSideNavigation ? _buildNavigationDrawer(context, navigationState) : null,
    body: child,
    bottomNavigationBar: !useSideNavigation ? _buildBottomNavigation(context, navigationState) : null,
  );
}

/// Build bottom navigation based on available capabilities
Widget? _buildBottomNavigation(BuildContext context, NavigationState navigationState) {
  final items = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
  ];
  
  // Add navigation items for each capability
  for (final capability in navigationState.availableCapabilities.take(4)) { // Limit to 4 for bottom nav
    final icon = _getCapabilityIcon(capability, navigationState);
    final label = _getCapabilityLabel(capability, navigationState);
    
    items.add(BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    ));
  }
  
  // Add settings
  items.add(const BottomNavigationBarItem(
    icon: Icon(Icons.settings),
    label: 'Settings',
  ));
  
  if (items.length < 2) return null; // Don't show if only dashboard
  
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    items: items,
    currentIndex: _getCurrentNavigationIndex(context, navigationState),
    onTap: (index) {
      if (index == 0) {
        context.go('/dashboard');
      } else if (index == items.length - 1) {
        context.go('/settings');
      } else {
        final capability = navigationState.availableCapabilities[index - 1];
        context.go('/$capability');
      }
    },
  );
}

/// Build navigation drawer for when there are many capabilities
Widget _buildNavigationDrawer(BuildContext context, NavigationState navigationState) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Building Manager',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              if (navigationState.currentBuilding != null)
                Text(
                  navigationState.currentBuilding!.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
        
        // Dashboard
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          selected: _isCurrentRoute(context, '/dashboard'),
          onTap: () {
            Navigator.pop(context);
            context.go('/dashboard');
          },
        ),
        
        const Divider(),
        
        // Capabilities
        ...navigationState.availableCapabilities.map((capability) {
          final icon = _getCapabilityIcon(capability, navigationState);
          final label = _getCapabilityLabel(capability, navigationState);
          final route = '/$capability';
          
          return ListTile(
            leading: Icon(icon),
            title: Text(label),
            selected: _isCurrentRoute(context, route),
            onTap: () {
              Navigator.pop(context);
              context.go(route);
            },
          );
        }).toList(),
        
        const Divider(),
        
        // Settings
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          selected: _isCurrentRoute(context, '/settings'),
          onTap: () {
            Navigator.pop(context);
            context.go('/settings');
          },
        ),
      ],
    ),
  );
}

/// Get current navigation index for bottom navigation
int _getCurrentNavigationIndex(BuildContext context, NavigationState navigationState) {
  final currentRoute = ModalRoute.of(context)?.settings.name ?? '/dashboard';
  
  if (currentRoute.startsWith('/dashboard')) return 0;
  if (currentRoute.startsWith('/settings')) {
    return navigationState.availableCapabilities.take(4).length + 1;
  }
  
  // Find capability index
  for (int i = 0; i < navigationState.availableCapabilities.take(4).length; i++) {
    final capability = navigationState.availableCapabilities[i];
    if (currentRoute.startsWith('/$capability')) {
      return i + 1;
    }
  }
  
  return 0; // Default to dashboard
}

/// Check if current route matches
bool _isCurrentRoute(BuildContext context, String route) {
  final currentRoute = ModalRoute.of(context)?.settings.name ?? '/dashboard';
  return currentRoute.startsWith(route);
}

/// Get icon for capability using API data if available, fallback to hardcoded mapping
IconData _getCapabilityIcon(String capabilityKey, NavigationState navigationState) {
  // Try to get icon from API data first
  if (navigationState.buildingCapabilities != null) {
    final enabledCapability = navigationState.buildingCapabilities!.enabled
        .where((cap) => cap.key == capabilityKey)
        .firstOrNull;
    
    if (enabledCapability != null && enabledCapability.icon != null) {
      return IconMapper.getIconFromApiData(enabledCapability.icon);
    }
  }
  
  // Fallback to IconMapper's built-in mapping
  return IconMapper.getIcon(capabilityKey);
}

/// Get label for capability using API data if available, fallback to formatted key
String _getCapabilityLabel(String capabilityKey, NavigationState navigationState) {
  // Try to get name from API data first
  if (navigationState.buildingCapabilities != null) {
    final enabledCapability = navigationState.buildingCapabilities!.enabled
        .where((cap) => cap.key == capabilityKey)
        .firstOrNull;
    
    if (enabledCapability != null) {
      return enabledCapability.name;
    }
  }
  
  // Fallback to formatted capability key
  switch (capabilityKey) {
    case 'defects': return 'Defects';
    case 'messaging': return 'Messaging';
    case 'documents': return 'Documents';
    case 'calendar': return 'Calendar';
    case '2n_intercom': return '2N Intercom';
    case 'clipsal_wiser': return 'Clipsal Wiser';
    default: return capabilityKey.replaceAll('_', ' ').split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

/// Stream wrapper for router refresh when capabilities change
class DynamicRouterRefreshStream extends ChangeNotifier {
  DynamicRouterRefreshStream(ProviderRef ref) {
    ref.listen(navigationProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// Dynamic page that renders based on API capability data and handles external links
class DynamicCapabilityPage extends ConsumerWidget {
  final String capabilityKey;
  
  const DynamicCapabilityPage({
    super.key,
    required this.capabilityKey,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    
    // Find the capability from the navigation state
    final enabledCapability = navigationState.buildingCapabilities?.enabled
        .where((cap) => cap.key == capabilityKey)
        .firstOrNull;
    
    if (enabledCapability == null) {
      return _buildErrorPage(context, 'Capability not found');
    }
    
    // Check if this is an external capability that should launch immediately
    if (_shouldLaunchExternally(enabledCapability)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchExternalCapability(context, enabledCapability);
      });
      return _buildLaunchingPage(context, enabledCapability);
    }
    
    // For internal capabilities or when external launch fails, show the tile interface
    return _buildCapabilityTile(context, enabledCapability, navigationState);
  }
  
  bool _shouldLaunchExternally(EnabledCapability capability) {
    return capability.type == 'external_app' || 
           capability.type == 'web_link' || 
           capability.type == 'hybrid';
  }
  
  Future<void> _launchExternalCapability(BuildContext context, EnabledCapability capability) async {
    final apps = capability.apps;
    if (apps == null) {
      _showError(context, 'No app configuration found');
      return;
    }
    
    String? urlToLaunch;
    
    // Determine which URL to use based on platform
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      urlToLaunch = apps['ios'] as String?;
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      urlToLaunch = apps['android'] as String?;
    }
    
    // Fallback to web URL if platform-specific URL not available
    urlToLaunch ??= apps['web'] as String?;
    
    if (urlToLaunch == null || urlToLaunch.isEmpty) {
      _showError(context, 'No URL configured for this platform');
      return;
    }
    
    try {
      final uri = Uri.parse(urlToLaunch);
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        await launchUrl(
          uri,
          mode: capability.type == 'external_app' 
              ? LaunchMode.externalApplication 
              : LaunchMode.externalApplication,
        );
        
        // Navigate back after launching external app
        if (context.mounted) {
          context.go('/dashboard');
        }
      } else {
        _showError(context, 'Cannot launch: $urlToLaunch');
      }
    } catch (e) {
      _showError(context, 'Failed to launch: $e');
    }
  }
  
  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Back',
            textColor: Colors.white,
            onPressed: () => context.go('/dashboard'),
          ),
        ),
      );
    }
  }
  
  Widget _buildLaunchingPage(BuildContext context, EnabledCapability capability) {
    final icon = IconMapper.getIconFromApiData(capability.icon);
    final iconColor = IconMapper.getIconColor(capability.icon) ?? Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(capability.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Launching ${capability.name}...',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (capability.description != null) ...[
              Text(
                capability.description!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCapabilityTile(BuildContext context, EnabledCapability capability, NavigationState navigationState) {
    final icon = IconMapper.getIconFromApiData(capability.icon);
    final iconColor = IconMapper.getIconColor(capability.icon) ?? Theme.of(context).primaryColor;
    final backgroundColor = IconMapper.getBackgroundColor(capability.icon);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(capability.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main capability tile
            Card(
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: iconColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capability.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (capability.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              capability.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dynamic data badges
            if (capability.data != null && capability.data!.isNotEmpty) ...[
              Text(
                'Current Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: capability.data!.entries.map((entry) {
                  return Chip(
                    label: Text('${_formatDataKey(entry.key)}: ${entry.value}'),
                    backgroundColor: iconColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            
            // Actions
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            if (capability.apps != null) ...[
              _buildLaunchButton(context, capability),
              const SizedBox(height: 8),
            ],
            
            _buildDashboardButton(context),
            
            const Spacer(),
            
            // Debug info (can be removed in production)
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capability Info',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${capability.type}'),
                    Text('Key: ${capability.key}'),
                    if (capability.category != null) Text('Category: ${capability.category}'),
                    Text('Sort Order: ${capability.sortOrder}'),
                    if (capability.linkId != null) Text('Link ID: ${capability.linkId}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLaunchButton(BuildContext context, EnabledCapability capability) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchExternalCapability(context, capability),
        icon: Icon(
          capability.type == 'external_app' 
              ? Icons.launch 
              : Icons.open_in_new,
        ),
        label: Text(
          capability.type == 'external_app' 
              ? 'Open ${capability.name} App'
              : 'Open ${capability.name} Website',
        ),
      ),
    );
  }
  
  Widget _buildDashboardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.go('/dashboard'),
        icon: const Icon(Icons.dashboard),
        label: const Text('Back to Dashboard'),
      ),
    );
  }
  
  Widget _buildErrorPage(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDataKey(String key) {
    return key
        .replaceAll(RegExp(r'([A-Z])'), ' \$1')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ')
        .trim();
  }
}

/// Simple dashboard page
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 64),
            SizedBox(height: 16),
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Welcome to Building Manager'),
          ],
        ),
      ),
    );
  }
}

// Settings page now imported from main app