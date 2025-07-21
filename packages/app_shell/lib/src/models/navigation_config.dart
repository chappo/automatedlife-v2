import 'package:flutter/material.dart';
import 'navigation_item.dart';
import 'user_role.dart';

/// Configuration for navigation items based on capabilities and roles
class NavigationConfig {
  static const List<NavigationItem> _baseNavigationItems = [
    // Dashboard - Available to all roles
    NavigationItem(
      key: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      route: '/dashboard',
    ),

    // Defects - Available to all roles
    NavigationItem(
      key: 'defects',
      label: 'Defects',
      icon: Icons.report_problem_outlined,
      selectedIcon: Icons.report_problem,
      route: '/defects',
      requiredCapabilities: ['defects'],
    ),

    // Documents - Not available to defect-only users
    NavigationItem(
      key: 'documents',
      label: 'Documents',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      route: '/documents',
      requiredCapabilities: ['documents'],
      allowedRoles: [
        UserRole.admin,
        UserRole.buildingManager,
        UserRole.resident,
        UserRole.staff,
      ],
    ),

    // Messaging - Not available to defect-only users
    NavigationItem(
      key: 'messaging',
      label: 'Messages',
      icon: Icons.message_outlined,
      selectedIcon: Icons.message,
      route: '/messaging',
      requiredCapabilities: ['messaging'],
      allowedRoles: [
        UserRole.admin,
        UserRole.buildingManager,
        UserRole.resident,
        UserRole.staff,
      ],
    ),

    // Intercom - Not available to defect-only users or basic staff
    NavigationItem(
      key: 'intercom',
      label: 'Intercom',
      icon: Icons.doorbell_outlined,
      selectedIcon: Icons.doorbell,
      route: '/intercom',
      requiredCapabilities: ['intercom'],
      allowedRoles: [
        UserRole.admin,
        UserRole.buildingManager,
        UserRole.resident,
      ],
    ),

    // Calendar Booking - Not available to defect-only users or basic staff
    NavigationItem(
      key: 'calendar',
      label: 'Bookings',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      route: '/calendar',
      requiredCapabilities: ['calendar_booking'],
      allowedRoles: [
        UserRole.admin,
        UserRole.buildingManager,
        UserRole.resident,
      ],
    ),


    // Settings - Available to all roles
    NavigationItem(
      key: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      route: '/settings',
    ),
  ];

  /// Get navigation items filtered by user role and available capabilities
  static List<NavigationItem> getNavigationItems({
    required UserRole userRole,
    required List<String> availableCapabilities,
  }) {
    return _baseNavigationItems
        .where((item) => item.shouldShow(
              userRole: userRole,
              availableCapabilities: availableCapabilities,
            ))
        .toList();
  }

  /// Get navigation items for admin role
  static List<NavigationItem> getAdminNavigationItems(
    List<String> availableCapabilities,
  ) {
    return getNavigationItems(
      userRole: UserRole.admin,
      availableCapabilities: availableCapabilities,
    );
  }

  /// Get navigation items for resident role
  static List<NavigationItem> getResidentNavigationItems(
    List<String> availableCapabilities,
  ) {
    return getNavigationItems(
      userRole: UserRole.resident,
      availableCapabilities: availableCapabilities,
    );
  }

  /// Get navigation items for defect user role
  static List<NavigationItem> getDefectUserNavigationItems() {
    return getNavigationItems(
      userRole: UserRole.defectUser,
      availableCapabilities: ['defects'],
    );
  }

  /// Get navigation items for building manager role
  static List<NavigationItem> getBuildingManagerNavigationItems(
    List<String> availableCapabilities,
  ) {
    return getNavigationItems(
      userRole: UserRole.buildingManager,
      availableCapabilities: availableCapabilities,
    );
  }

  /// Get primary navigation items (excluding settings and profile)
  static List<NavigationItem> getPrimaryNavigationItems({
    required UserRole userRole,
    required List<String> availableCapabilities,
  }) {
    return getNavigationItems(
      userRole: userRole,
      availableCapabilities: availableCapabilities,
    ).where((item) => !['settings', 'profile'].contains(item.key)).toList();
  }

  /// Get secondary navigation items (settings, profile, etc.)
  static List<NavigationItem> getSecondaryNavigationItems({
    required UserRole userRole,
    required List<String> availableCapabilities,
  }) {
    return getNavigationItems(
      userRole: userRole,
      availableCapabilities: availableCapabilities,
    ).where((item) => ['settings', 'profile'].contains(item.key)).toList();
  }
}