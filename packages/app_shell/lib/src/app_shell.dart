import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'models/models.dart';
import 'navigation/navigation.dart';
import 'routing/dynamic_router.dart';
import 'shells/shells.dart';
import 'widgets/widgets.dart';

/// Main app shell that provides the complete navigation and layout structure
class AppShell extends ConsumerStatefulWidget {
  final User? user;
  final Building? currentBuilding;
  final List<Building> availableBuildings;

  const AppShell({
    super.key,
    this.user,
    this.currentBuilding,
    this.availableBuildings = const [],
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Building? _lastInitializedBuilding;
  bool _hasSetupStreams = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(dynamicRouterProvider);

    // Initialize/reinitialize navigation state when building changes
    if (_lastInitializedBuilding?.id != widget.currentBuilding?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeNavigationState();
        _lastInitializedBuilding = widget.currentBuilding;
        
        // Set up streams only once
        if (!_hasSetupStreams) {
          _setupCapabilityStreams();
          _hasSetupStreams = true;
        }
      });
    }

    return Router.withConfig(
      config: router,
    );
  }

  void _initializeNavigationState() {
    final navigationNotifier = ref.read(navigationProvider.notifier);

    // Set user role based on user data
    UserRole userRole = UserRole.resident;
    if (widget.user != null) {
      if (widget.user!.isAdmin) {
        userRole = UserRole.admin;
      } else if (widget.availableBuildings.length > 1) {
        // If user has access to multiple buildings but is not admin, they're likely a building manager
        userRole = UserRole.buildingManager;
      } else {
        // Default to resident for single building users
        userRole = UserRole.resident;
      }
    }
    navigationNotifier.setUserRole(userRole);

    // Set current building
    if (widget.currentBuilding != null) {
      navigationNotifier.setCurrentBuilding(widget.currentBuilding);
    }

    // Set available buildings
    print('DEBUG: AppShell initializing with ${widget.availableBuildings.length} buildings');
    if (widget.availableBuildings.isNotEmpty) {
      navigationNotifier.setBuildingList(widget.availableBuildings);
      print('DEBUG: Set ${widget.availableBuildings.length} buildings in navigation provider');
    }

    // Load capabilities for the current building
    _loadBuildingCapabilities();
  }

  void _setupCapabilityStreams() {
    final navigationNotifier = ref.read(navigationProvider.notifier);
    final authService = AuthService.instance;

    // Listen to building capabilities changes
    authService.buildingCapabilitiesStream.listen((buildingCapabilities) {
      if (!mounted) return;
      
      if (buildingCapabilities != null) {
        print('DEBUG: Received building capabilities with ${buildingCapabilities.enabled.length} enabled');
        navigationNotifier.setBuildingCapabilities(buildingCapabilities);
      } else {
        // Fallback to default capabilities if API fails
        final userRole = navigationNotifier.state.userRole;
        print('DEBUG: No building capabilities, using default for role: $userRole');
        navigationNotifier.setAvailableCapabilities(userRole.defaultCapabilities);
      }
    });
  }

  void _loadBuildingCapabilities() {
    final navigationNotifier = ref.read(navigationProvider.notifier);
    
    if (widget.currentBuilding == null) {
      // No building selected, use default capabilities
      final userRole = navigationNotifier.state.userRole;
      navigationNotifier.setAvailableCapabilities(userRole.defaultCapabilities);
      return;
    }

    final authService = AuthService.instance;
    authService.getBuildingCapabilities().then((buildingCapabilities) {
      if (!mounted) return;
        
      if (buildingCapabilities != null) {
        print('DEBUG: Immediately loaded ${buildingCapabilities.enabled.length} enabled capabilities');
        navigationNotifier.setBuildingCapabilities(buildingCapabilities);
      } else {
        // Fallback to default capabilities if API fails
        final userRole = navigationNotifier.state.userRole;
        print('DEBUG: No building capabilities from API, using default for role: $userRole');
        navigationNotifier.setAvailableCapabilities(userRole.defaultCapabilities);
      }
    }).catchError((e) {
      if (!mounted) return;
      
      print('DEBUG: Failed to load capabilities: $e');
      final userRole = navigationNotifier.state.userRole;
      navigationNotifier.setAvailableCapabilities(userRole.defaultCapabilities);
    });
  }
}

/// Wrapper that provides accessibility enhancements
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;

  const AccessibilityWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Building Manager Application',
      child: Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);
          
          // Ensure minimum text scaling for accessibility
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                (mediaQuery.textScaler.scale(1.0)).clamp(1.0, 1.3),
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// App shell factory for different user types
class AppShellFactory {
  static Widget createForAdmin({
    required User user,
    Building? currentBuilding,
    List<Building> availableBuildings = const [],
  }) {
    return ProviderScope(
      overrides: [
        userRoleProvider.overrideWith((ref) => UserRole.admin),
        currentBuildingProvider.overrideWith((ref) => currentBuilding),
        buildingListProvider.overrideWith((ref) => availableBuildings),
        availableCapabilitiesProvider.overrideWith((ref) => 
            // TODO: Update to use BuildingCapabilitiesResponse with enabled/available arrays
            // Temporarily removing isEnabled check since Capability model no longer has this field
            currentBuilding?.capabilities
                // ?.where((cap) => cap.isEnabled) // Temporarily commented out
                ?.map((cap) => cap.key)
                .toList() ?? UserRole.admin.defaultCapabilities),
      ],
      child: AppShell(
        user: user,
        currentBuilding: currentBuilding,
        availableBuildings: availableBuildings,
      ),
    );
  }

  static Widget createForBuildingManager({
    required User user,
    Building? currentBuilding,
    List<Building> availableBuildings = const [],
  }) {
    // TODO: Update to use BuildingCapabilitiesResponse with enabled/available arrays
    // Temporarily removing isEnabled check since Capability model no longer has this field
    final capabilities = currentBuilding?.capabilities
            // ?.where((cap) => cap.isEnabled) // Temporarily commented out
            ?.map((cap) => cap.key)
            .toList() ??
        UserRole.buildingManager.defaultCapabilities;

    return ProviderScope(
      overrides: [
        userRoleProvider.overrideWith((ref) => UserRole.buildingManager),
        currentBuildingProvider.overrideWith((ref) => currentBuilding),
        buildingListProvider.overrideWith((ref) => availableBuildings),
        availableCapabilitiesProvider.overrideWith((ref) => capabilities),
      ],
      child: AppShell(
        user: user,
        currentBuilding: currentBuilding,
        availableBuildings: availableBuildings,
      ),
    );
  }

  static Widget createForResident({
    required User user,
    required Building building,
  }) {
    // TODO: Update to use BuildingCapabilitiesResponse with enabled/available arrays
    // Temporarily removing isEnabled check since Capability model no longer has this field
    final capabilities = building.capabilities
            // ?.where((cap) => cap.isEnabled) // Temporarily commented out
            ?.map((cap) => cap.key)
            .toList() ??
        UserRole.resident.defaultCapabilities;

    return ProviderScope(
      overrides: [
        userRoleProvider.overrideWith((ref) => UserRole.resident),
        currentBuildingProvider.overrideWith((ref) => building),
        buildingListProvider.overrideWith((ref) => [building]),
        availableCapabilitiesProvider.overrideWith((ref) => capabilities),
      ],
      child: AppShell(
        user: user,
        currentBuilding: building,
        availableBuildings: [building],
      ),
    );
  }

  static Widget createForDefectUser({
    required User user,
    Building? building,
  }) {
    return ProviderScope(
      overrides: [
        userRoleProvider.overrideWith((ref) => UserRole.defectUser),
        currentBuildingProvider.overrideWith((ref) => building),
        buildingListProvider.overrideWith((ref) => building != null ? [building] : []),
        availableCapabilitiesProvider.overrideWith((ref) => ['defects']),
      ],
      child: AppShell(
        user: user,
        currentBuilding: building,
        availableBuildings: building != null ? [building] : [],
      ),
    );
  }

  static Widget createForStaff({
    required User user,
    Building? building,
  }) {
    final capabilities = UserRole.staff.defaultCapabilities;

    return ProviderScope(
      overrides: [
        userRoleProvider.overrideWith((ref) => UserRole.staff),
        currentBuildingProvider.overrideWith((ref) => building),
        buildingListProvider.overrideWith((ref) => building != null ? [building] : []),
        availableCapabilitiesProvider.overrideWith((ref) => capabilities),
      ],
      child: AppShell(
        user: user,
        currentBuilding: building,
        availableBuildings: building != null ? [building] : [],
      ),
    );
  }
}

/// Extension methods for easier navigation
extension AppShellNavigation on WidgetRef {
  /// Switch to a different building (if user has permission)
  bool switchBuilding(Building building) {
    return read(navigationProvider.notifier).switchBuilding(building);
  }

  /// Navigate to a specific route
  void navigateTo(String route) {
    read(navigationProvider.notifier).navigateTo(route);
  }

  /// Get current navigation state
  NavigationState get navigationState => read(navigationProvider);

  /// Check if user can access a specific capability
  bool canAccess(String capability) {
    final state = read(navigationProvider);
    return state.availableCapabilities.contains(capability);
  }

  /// Check if user has a specific role
  bool hasRole(UserRole role) {
    return read(navigationProvider).userRole == role;
  }

  /// Check if user can manage buildings
  bool canManageBuildings() {
    return read(navigationProvider).userRole.canManageBuildings;
  }

  /// Check if user can access multiple buildings
  bool canAccessMultipleBuildings() {
    return read(navigationProvider).userRole.canAccessMultipleBuildings;
  }
}

/// Utility functions for app shell
class AppShellUtils {
  AppShellUtils._();

  /// Determine user role from user data
  static UserRole getUserRoleFromData(User user, {Building? building}) {
    // This would be implemented based on your user data structure
    // For now, returning default role
    return UserRole.resident;
  }

  /// Get building-specific capabilities
  static List<String> getBuildingCapabilities(Building? building) {
    if (building?.capabilities == null) return [];
    
    // TODO: Update to use BuildingCapabilitiesResponse with enabled/available arrays
    // Temporarily removing isEnabled check since Capability model no longer has this field
    return building!.capabilities!
        // .where((cap) => cap.isEnabled) // Temporarily commented out
        .map((cap) => cap.key)
        .toList();
  }

  /// Validate if user can access building
  static bool canUserAccessBuilding(User user, Building building) {
    // Implement your business logic for building access
    // For now, allowing all access
    return true;
  }

  /// Get appropriate default route for user role
  static String getDefaultRoute(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.buildingManager:
      case UserRole.resident:
      case UserRole.staff:
        return '/dashboard';
      case UserRole.defectUser:
        return '/defects';
    }
  }

  /// Check if feature is enabled for building
  static bool isFeatureEnabled(Building? building, String feature) {
    if (building == null) return false;
    return building.hasCapability(feature);
  }
}