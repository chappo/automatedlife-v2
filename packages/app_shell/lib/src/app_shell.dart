import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'models/models.dart';
import 'navigation/navigation.dart';
import 'routing/routing.dart';
import 'shells/shells.dart';
import 'widgets/widgets.dart';

/// Main app shell that provides the complete navigation and layout structure
class AppShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize navigation state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNavigationState(ref);
    });

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Building Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        return AccessibilityWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  void _initializeNavigationState(WidgetRef ref) {
    final navigationNotifier = ref.read(navigationProvider.notifier);

    // Set user role based on user data or default to resident
    UserRole userRole = UserRole.resident;
    if (user != null) {
      // This would be determined from user data in a real implementation
      // For now, we'll use resident as default
      userRole = UserRole.resident;
    }
    navigationNotifier.setUserRole(userRole);

    // Set current building
    if (currentBuilding != null) {
      navigationNotifier.setCurrentBuilding(currentBuilding);
    }

    // Set available buildings
    if (availableBuildings.isNotEmpty) {
      navigationNotifier.setBuildingList(availableBuildings);
    }

    // Set capabilities based on current building
    List<String> capabilities = [];
    if (currentBuilding?.capabilities != null) {
      capabilities = currentBuilding!.capabilities!
          .where((cap) => cap.isEnabled)
          .map((cap) => cap.key)
          .toList();
    } else {
      // Set default capabilities based on user role
      capabilities = userRole.defaultCapabilities;
    }
    navigationNotifier.setAvailableCapabilities(capabilities);
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
            currentBuilding?.capabilities
                ?.where((cap) => cap.isEnabled)
                .map((cap) => cap.key)
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
    final capabilities = currentBuilding?.capabilities
            ?.where((cap) => cap.isEnabled)
            .map((cap) => cap.key)
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
    final capabilities = building.capabilities
            ?.where((cap) => cap.isEnabled)
            .map((cap) => cap.key)
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
    
    return building!.capabilities!
        .where((cap) => cap.isEnabled)
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
    return RouteUtils.getDefaultRouteForRole(role);
  }

  /// Check if feature is enabled for building
  static bool isFeatureEnabled(Building? building, String feature) {
    if (building == null) return false;
    return building.hasCapability(feature);
  }
}