import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:app_shell/app_shell.dart';

void main() {
  group('AppShell Tests', () {
    late User testUser;
    late Building testBuilding;

    setUp(() {
      testUser = User(
        id: 1,
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        isAdmin: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testBuilding = Building(
        id: 1,
        name: 'Test Building',
        isActive: true,
        capabilities: [
          Capability(
            id: 1,
            name: 'Defects',
            key: 'defects',
            type: 'internal',
          ),
          Capability(
            id: 2,
            name: 'Documents',
            key: 'documents',
            type: 'internal',
          ),
        ],
      );
    });

    testWidgets('UserRole enum works correctly', (WidgetTester tester) async {
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.resident.isAdmin, isFalse);
      expect(UserRole.admin.canManageBuildings, isTrue);
      expect(UserRole.defectUser.isDefectOnly, isTrue);
      expect(UserRole.defectUser.defaultCapabilities, contains('defects'));
    });

    testWidgets('NavigationItem shouldShow works correctly', (WidgetTester tester) async {
      const navigationItem = NavigationItem(
        key: 'defects',
        label: 'Defects',
        icon: Icons.report_problem,
        route: '/defects',
        requiredCapabilities: ['defects'],
        allowedRoles: [UserRole.admin, UserRole.resident],
      );

      // Should show for admin with defects capability
      expect(
        navigationItem.shouldShow(
          userRole: UserRole.admin,
          availableCapabilities: ['*'],
        ),
        isTrue,
      );

      // Should show for resident with defects capability
      expect(
        navigationItem.shouldShow(
          userRole: UserRole.resident,
          availableCapabilities: ['defects'],
        ),
        isTrue,
      );

      // Should not show for resident without defects capability
      expect(
        navigationItem.shouldShow(
          userRole: UserRole.resident,
          availableCapabilities: ['documents'],
        ),
        isFalse,
      );

      // Should not show for defect user (not in allowed roles)
      expect(
        navigationItem.shouldShow(
          userRole: UserRole.defectUser,
          availableCapabilities: ['defects'],
        ),
        isFalse,
      );
    });

    testWidgets('NavigationConfig filters items correctly', (WidgetTester tester) async {
      // Admin should see all items
      final adminItems = NavigationConfig.getNavigationItems(
        userRole: UserRole.admin,
        availableCapabilities: ['*'],
      );
      expect(adminItems.length, greaterThan(5));

      // Defect user should only see limited items
      final defectUserItems = NavigationConfig.getDefectUserNavigationItems();
      expect(defectUserItems.length, equals(3)); // dashboard, defects, settings
      expect(defectUserItems.any((item) => item.key == 'defects'), isTrue);
      expect(defectUserItems.any((item) => item.key == 'documents'), isFalse);
    });

    testWidgets('Building capabilities are checked correctly', (WidgetTester tester) async {
      expect(testBuilding.hasCapability('defects'), isTrue);
      expect(testBuilding.hasCapability('documents'), isTrue);
      expect(testBuilding.hasCapability('nonexistent'), isFalse);
    });

    group('AppShellFactory', () {
      testWidgets('creates correct shell for admin', (WidgetTester tester) async {
        final adminShell = AppShellFactory.createForAdmin(
          user: testUser,
          currentBuilding: testBuilding,
          availableBuildings: [testBuilding],
        );

        expect(adminShell, isA<ProviderScope>());
      });

      testWidgets('creates correct shell for resident', (WidgetTester tester) async {
        final residentShell = AppShellFactory.createForResident(
          user: testUser,
          building: testBuilding,
        );

        expect(residentShell, isA<ProviderScope>());
      });

      testWidgets('creates correct shell for defect user', (WidgetTester tester) async {
        final defectUserShell = AppShellFactory.createForDefectUser(
          user: testUser,
          building: testBuilding,
        );

        expect(defectUserShell, isA<ProviderScope>());
      });
    });
  });

  group('Route Utils Tests', () {
    testWidgets('getDefaultRouteForRole returns correct routes', (WidgetTester tester) async {
      expect(RouteUtils.getDefaultRouteForRole(UserRole.admin), equals('/dashboard'));
      expect(RouteUtils.getDefaultRouteForRole(UserRole.resident), equals('/dashboard'));
      expect(RouteUtils.getDefaultRouteForRole(UserRole.defectUser), equals('/defects'));
    });

    testWidgets('isRouteAccessibleForRole works correctly', (WidgetTester tester) async {
      // Admin can access everything
      expect(RouteUtils.isRouteAccessibleForRole('/admin', UserRole.admin, ['*']), isTrue);
      
      // Defect user can only access specific routes
      expect(RouteUtils.isRouteAccessibleForRole('/defects', UserRole.defectUser, ['defects']), isTrue);
      expect(RouteUtils.isRouteAccessibleForRole('/documents', UserRole.defectUser, ['defects']), isFalse);
      
      // Resident cannot access admin routes
      expect(RouteUtils.isRouteAccessibleForRole('/admin', UserRole.resident, ['defects']), isFalse);
    });

    testWidgets('buildBreadcrumbs creates correct breadcrumbs', (WidgetTester tester) async {
      final breadcrumbs = RouteUtils.buildBreadcrumbs('/defects/new');
      expect(breadcrumbs.length, equals(2));
      expect(breadcrumbs[0]['label'], equals('Defects'));
      expect(breadcrumbs[1]['label'], equals('New'));
    });
  });
}
