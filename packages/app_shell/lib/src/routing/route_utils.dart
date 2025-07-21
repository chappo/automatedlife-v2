import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../models/user_role.dart';

/// Utility class for common route operations
class RouteUtils {
  RouteUtils._();

  /// Navigate to dashboard with role-appropriate defaults
  static void goToDashboard(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.buildingManager:
      case UserRole.resident:
      case UserRole.staff:
        context.go('/dashboard');
        break;
      case UserRole.defectUser:
        context.go('/defects');
        break;
    }
  }

  /// Navigate to defect reporting
  static void goToNewDefect(BuildContext context) {
    context.go('/defects/new');
  }

  /// Navigate to specific defect
  static void goToDefect(BuildContext context, String defectId) {
    context.go('/defects/$defectId');
  }

  /// Navigate to documents
  static void goToDocuments(BuildContext context) {
    context.go('/documents');
  }

  /// Navigate to specific document
  static void goToDocument(BuildContext context, String documentId) {
    context.go('/documents/$documentId');
  }

  /// Navigate to messaging
  static void goToMessaging(BuildContext context) {
    context.go('/messaging');
  }

  /// Navigate to compose message
  static void goToComposeMessage(BuildContext context) {
    context.go('/messaging/compose');
  }

  /// Navigate to specific message
  static void goToMessage(BuildContext context, String messageId) {
    context.go('/messaging/$messageId');
  }

  /// Navigate to intercom
  static void goToIntercom(BuildContext context) {
    context.go('/intercom');
  }

  /// Navigate to calendar
  static void goToCalendar(BuildContext context) {
    context.go('/calendar');
  }

  /// Navigate to book amenity
  static void goToBookAmenity(BuildContext context) {
    context.go('/calendar/book');
  }

  /// Navigate to building management
  static void goToBuildings(BuildContext context) {
    context.go('/buildings');
  }

  /// Navigate to add building
  static void goToAddBuilding(BuildContext context) {
    context.go('/buildings/add');
  }

  /// Navigate to specific building
  static void goToBuilding(BuildContext context, String buildingId) {
    context.go('/buildings/$buildingId');
  }

  /// Navigate to user management
  static void goToUsers(BuildContext context) {
    context.go('/users');
  }

  /// Navigate to add user
  static void goToAddUser(BuildContext context) {
    context.go('/users/add');
  }

  /// Navigate to specific user
  static void goToUser(BuildContext context, String userId) {
    context.go('/users/$userId');
  }

  /// Navigate to settings
  static void goToSettings(BuildContext context) {
    context.go('/settings');
  }

  /// Navigate to contact/support
  static void goToContact(BuildContext context) {
    context.go('/contact');
  }

  /// Navigate to admin audit log
  static void goToAuditLog(BuildContext context) {
    context.go('/admin/audit-log');
  }

  /// Navigate to admin system status
  static void goToSystemStatus(BuildContext context) {
    context.go('/admin/system-status');
  }

  /// Get current route name from location
  static String? getRouteNameFromLocation(String location) {
    final routeMap = <String, String>{
      '/dashboard': 'dashboard',
      '/defects': 'defects',
      '/defects/new': 'defects-new',
      '/documents': 'documents',
      '/messaging': 'messaging',
      '/messaging/compose': 'messaging-compose',
      '/intercom': 'intercom',
      '/calendar': 'calendar',
      '/calendar/book': 'calendar-book',
      '/buildings': 'buildings',
      '/buildings/add': 'buildings-add',
      '/users': 'users',
      '/users/add': 'users-add',
      '/settings': 'settings',
      '/contact': 'contact',
      '/admin/audit-log': 'admin-audit-log',
      '/admin/system-status': 'admin-system-status',
    };

    // Check for exact matches first
    if (routeMap.containsKey(location)) {
      return routeMap[location];
    }

    // Check for parameterized routes
    for (final route in routeMap.keys) {
      if (location.startsWith(route) && route.contains(':')) {
        return routeMap[route];
      }
    }

    return null;
  }

  /// Check if route requires authentication
  static bool requiresAuth(String location) {
    const publicRoutes = ['/login', '/register'];
    return !publicRoutes.contains(location);
  }

  /// Check if route is accessible for role
  static bool isRouteAccessibleForRole(String location, UserRole role, List<String> capabilities) {
    // Admin has access to everything
    if (role == UserRole.admin) return true;

    // Define role-based route restrictions
    switch (role) {
      case UserRole.defectUser:
        return location.startsWith('/defects') || 
               location.startsWith('/dashboard') || 
               location.startsWith('/settings');
      
      case UserRole.resident:
        return !location.startsWith('/admin') && 
               !location.startsWith('/users') && 
               !location.startsWith('/buildings');
      
      case UserRole.staff:
        return !location.startsWith('/admin') && 
               !location.startsWith('/users') && 
               !location.startsWith('/buildings') &&
               !location.startsWith('/intercom') &&
               !location.startsWith('/calendar');
      
      case UserRole.buildingManager:
        return !location.startsWith('/admin/audit-log') &&
               !location.startsWith('/admin/system-status');
      
      case UserRole.admin:
        return true;
    }
  }

  /// Get default route for role
  static String getDefaultRouteForRole(UserRole role) {
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

  /// Extract ID from parameterized route
  static String? extractIdFromLocation(String location, String baseRoute) {
    if (location.startsWith(baseRoute)) {
      final parts = location.split('/');
      final baseParts = baseRoute.split('/');
      
      if (parts.length > baseParts.length) {
        return parts[baseParts.length];
      }
    }
    return null;
  }

  /// Build breadcrumb navigation from current location
  static List<Map<String, String>> buildBreadcrumbs(String location) {
    final breadcrumbs = <Map<String, String>>[];
    final parts = location.split('/').where((part) => part.isNotEmpty).toList();
    
    String currentPath = '';
    
    for (int i = 0; i < parts.length; i++) {
      currentPath += '/${parts[i]}';
      
      String label = _getRouteLabel(parts[i]);
      
      // Skip numeric IDs in breadcrumbs
      if (RegExp(r'^\d+$').hasMatch(parts[i])) {
        continue;
      }
      
      breadcrumbs.add({
        'label': label,
        'path': currentPath,
      });
    }
    
    return breadcrumbs;
  }

  static String _getRouteLabel(String routePart) {
    final labelMap = <String, String>{
      'dashboard': 'Dashboard',
      'defects': 'Defects',
      'documents': 'Documents',
      'messaging': 'Messages',
      'intercom': 'Intercom',
      'calendar': 'Calendar',
      'buildings': 'Buildings',
      'users': 'Users',
      'settings': 'Settings',
      'contact': 'Contact',
      'admin': 'Admin',
      'new': 'New',
      'add': 'Add',
      'compose': 'Compose',
      'book': 'Book',
      'audit-log': 'Audit Log',
      'system-status': 'System Status',
    };
    
    return labelMap[routePart] ?? routePart.split('-').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : word
    ).join(' ');
  }
}