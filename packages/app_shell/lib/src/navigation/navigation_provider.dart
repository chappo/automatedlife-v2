import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../models/models.dart';

/// Provider for current user role
final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.resident);

/// Provider for available capabilities based on current building
final availableCapabilitiesProvider = StateProvider<List<String>>((ref) => []);

/// Provider for building capabilities response (includes full capability data with icons)
final buildingCapabilitiesProvider = StateProvider<BuildingCapabilitiesResponse?>((ref) => null);

/// Provider for current navigation route
final currentRouteProvider = StateProvider<String>((ref) => '/dashboard');

/// Provider for current building (admin/manager can switch)
final currentBuildingProvider = StateProvider<Building?>((ref) => null);

/// Provider for navigation items filtered by role and capabilities
final navigationItemsProvider = Provider<List<NavigationItem>>((ref) {
  final userRole = ref.watch(userRoleProvider);
  final capabilities = ref.watch(availableCapabilitiesProvider);
  
  return NavigationConfig.getNavigationItems(
    userRole: userRole,
    availableCapabilities: capabilities,
  );
});

/// Provider for primary navigation items (excluding settings)
final primaryNavigationItemsProvider = Provider<List<NavigationItem>>((ref) {
  final userRole = ref.watch(userRoleProvider);
  final capabilities = ref.watch(availableCapabilitiesProvider);
  
  return NavigationConfig.getPrimaryNavigationItems(
    userRole: userRole,
    availableCapabilities: capabilities,
  );
});

/// Provider for building list (for building switcher)
final buildingListProvider = StateProvider<List<Building>>((ref) => []);

/// Navigation state notifier for complex navigation logic
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setCurrentRoute(String route) {
    state = state.copyWith(currentRoute: route);
  }

  void setUserRole(UserRole role) {
    state = state.copyWith(userRole: role);
  }

  void setAvailableCapabilities(List<String> capabilities) {
    state = state.copyWith(availableCapabilities: capabilities);
  }

  void setCurrentBuilding(Building? building) {
    state = state.copyWith(currentBuilding: building);
  }

  void setBuildingList(List<Building> buildings) {
    state = state.copyWith(availableBuildings: buildings);
  }

  void setBuildingCapabilities(BuildingCapabilitiesResponse? capabilities) {
    if (capabilities != null) {
      // Extract capability keys for backward compatibility
      final capabilityKeys = capabilities.enabled.map((cap) => cap.key).toList();
      state = state.copyWith(
        availableCapabilities: capabilityKeys,
        buildingCapabilities: capabilities,
      );
    }
  }

  /// Navigate to a specific route with optional building context
  void navigateTo(String route, {Building? building}) {
    if (building != null) {
      setCurrentBuilding(building);
    }
    setCurrentRoute(route);
  }

  /// Switch to a different building (admin/manager only)
  bool switchBuilding(Building building) {
    if (!state.userRole.canAccessMultipleBuildings) {
      return false;
    }
    
    setCurrentBuilding(building);
    // Update capabilities based on new building
    if (building.capabilities != null) {
      // TODO: Update to use BuildingCapabilitiesResponse with enabled/available arrays
      // Temporarily removing isEnabled check since Capability model no longer has this field
      final capabilities = building.capabilities!
          // .where((cap) => cap.isEnabled) // Temporarily commented out
          .map((cap) => cap.key)
          .toList();
      setAvailableCapabilities(capabilities);
    }
    
    return true;
  }
}

/// Navigation state
class NavigationState {
  final String currentRoute;
  final UserRole userRole;
  final List<String> availableCapabilities;
  final Building? currentBuilding;
  final List<Building> availableBuildings;
  final BuildingCapabilitiesResponse? buildingCapabilities;

  const NavigationState({
    this.currentRoute = '/dashboard',
    this.userRole = UserRole.resident,
    this.availableCapabilities = const [],
    this.currentBuilding,
    this.availableBuildings = const [],
    this.buildingCapabilities,
  });

  NavigationState copyWith({
    String? currentRoute,
    UserRole? userRole,
    List<String>? availableCapabilities,
    Building? currentBuilding,
    List<Building>? availableBuildings,
    BuildingCapabilitiesResponse? buildingCapabilities,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      userRole: userRole ?? this.userRole,
      availableCapabilities: availableCapabilities ?? this.availableCapabilities,
      currentBuilding: currentBuilding ?? this.currentBuilding,
      availableBuildings: availableBuildings ?? this.availableBuildings,
      buildingCapabilities: buildingCapabilities ?? this.buildingCapabilities,
    );
  }

  /// Get filtered navigation items for current state
  List<NavigationItem> get navigationItems {
    return NavigationConfig.getNavigationItems(
      userRole: userRole,
      availableCapabilities: availableCapabilities,
    );
  }

  /// Get primary navigation items for current state
  List<NavigationItem> get primaryNavigationItems {
    return NavigationConfig.getPrimaryNavigationItems(
      userRole: userRole,
      availableCapabilities: availableCapabilities,
    );
  }

  @override
  String toString() {
    return 'NavigationState(currentRoute: $currentRoute, userRole: $userRole, building: ${currentBuilding?.name})';
  }
}

/// Provider for navigation state notifier
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);