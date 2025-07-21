import 'package:flutter/material.dart';
import 'user_role.dart';

/// Represents a navigation item in the app shell
class NavigationItem {
  final String key;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String route;
  final List<String> requiredCapabilities;
  final List<UserRole> allowedRoles;
  final int? badge;
  final bool isEnabled;
  final List<NavigationItem> children;

  const NavigationItem({
    required this.key,
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.route,
    this.requiredCapabilities = const [],
    this.allowedRoles = const [],
    this.badge,
    this.isEnabled = true,
    this.children = const [],
  });

  /// Whether this navigation item should be shown for the given role and capabilities
  bool shouldShow({
    required UserRole userRole,
    required List<String> availableCapabilities,
  }) {
    // Check if role is allowed (empty list means all roles allowed)
    if (allowedRoles.isNotEmpty && !allowedRoles.contains(userRole)) {
      return false;
    }

    // Check if required capabilities are available
    if (requiredCapabilities.isNotEmpty) {
      // Check if all required capabilities are available
      for (final capability in requiredCapabilities) {
        if (!availableCapabilities.contains(capability)) {
          return false;
        }
      }
    }

    return isEnabled;
  }

  /// Create a copy with updated properties
  NavigationItem copyWith({
    String? key,
    String? label,
    IconData? icon,
    IconData? selectedIcon,
    String? route,
    List<String>? requiredCapabilities,
    List<UserRole>? allowedRoles,
    int? badge,
    bool? isEnabled,
    List<NavigationItem>? children,
  }) {
    return NavigationItem(
      key: key ?? this.key,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      route: route ?? this.route,
      requiredCapabilities: requiredCapabilities ?? this.requiredCapabilities,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      badge: badge ?? this.badge,
      isEnabled: isEnabled ?? this.isEnabled,
      children: children ?? this.children,
    );
  }

  @override
  String toString() {
    return 'NavigationItem(key: $key, label: $label, route: $route)';
  }
}