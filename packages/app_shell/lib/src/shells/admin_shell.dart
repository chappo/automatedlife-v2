import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../models/models.dart';
import '../navigation/navigation.dart';
import '../widgets/widgets.dart';
import 'base_shell.dart';

/// Admin shell with capability-based navigation (same as residents, admin features handled within capabilities)
class AdminShell extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const AdminShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    
    // Ensure admin role is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigationState.userRole != UserRole.admin) {
        ref.read(navigationProvider.notifier).setUserRole(UserRole.admin);
      }
      
      // Admin users are subject to the same building capability filtering as other users
      // Capabilities should be set based on the current building's enabled capabilities
      // Admin privileges are handled within individual capability screens, not in navigation
    });

    return BaseShell(
      currentRoute: currentRoute,
      appBar: BrandedAppBar(
        title: _getPageTitle(currentRoute),
        showBuildingSwitcher: true,
        actions: [
          _buildNotificationButton(context),
          _buildAdminMenuButton(context, ref),
        ],
      ),
      navigationItems: navigationState.primaryNavigationItems,
      drawer: _buildAdminDrawer(context, ref),
      child: child,
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/defects':
        return 'Defects';
      case '/documents':
        return 'Documents';
      case '/messaging':
        return 'Messages';
      case '/intercom':
        return 'Intercom';
      case '/calendar':
        return 'Bookings';
      case '/settings':
        return 'Settings';
      default:
        return 'Building Management';
    }
  }

  Widget _buildNotificationButton(BuildContext context) {
    return IconButton(
      icon: const Badge(
        label: Text('3'),
        child: Icon(Icons.notifications),
      ),
      onPressed: () => _showNotifications(context),
      tooltip: 'Notifications',
    );
  }

  Widget _buildAdminMenuButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.admin_panel_settings),
      tooltip: 'Admin Menu',
      onSelected: (value) => _handleAdminMenuAction(context, ref, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'system_status',
          child: Row(
            children: [
              Icon(Icons.health_and_safety),
              SizedBox(width: 8),
              Text('System Status'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'audit_log',
          child: Row(
            children: [
              Icon(Icons.history),
              SizedBox(width: 8),
              Text('Audit Log'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'backup',
          child: Row(
            children: [
              Icon(Icons.backup),
              SizedBox(width: 8),
              Text('Backup & Restore'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'emergency',
          child: Row(
            children: [
              Icon(Icons.emergency, color: Colors.red),
              SizedBox(width: 8),
              Text('Emergency Actions'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminDrawer(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                Text(
                  'System Administrator',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (navigationState.availableBuildings.isNotEmpty) ...[
            BuildingSwitcherWidget(
              currentBuilding: navigationState.currentBuilding,
              onBuildingSelected: (building) {
                ref.read(navigationProvider.notifier).switchBuilding(building);
              },
            ),
            const Divider(),
          ],
          Expanded(
            child: ListView(
              children: [
                _buildQuickActions(context, ref),
                const Divider(),
                ..._buildNavigationItems(context, ref, navigationState.navigationItems),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerFooter(context, theme),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      leading: const Icon(Icons.flash_on),
      title: const Text('Quick Actions'),
      children: [
        ListTile(
          leading: const Icon(Icons.report_problem),
          title: const Text('System Check'),
          onTap: () => _runSystemCheck(context, ref),
        ),
      ],
    );
  }

  List<Widget> _buildNavigationItems(
    BuildContext context,
    WidgetRef ref,
    List<NavigationItem> items,
  ) {
    return items.map((item) => ListTile(
      leading: Icon(item.icon),
      title: Text(item.label),
      selected: currentRoute == item.route,
      onTap: () {
        Navigator.pop(context);
        ref.read(navigationProvider.notifier).navigateTo(item.route);
      },
    )).toList();
  }

  Widget _buildDrawerFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Secure Admin Access',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const AdminNotificationsSheet(),
    );
  }

  void _handleAdminMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'system_status':
        _showSystemStatus(context);
        break;
      case 'audit_log':
        _showAuditLog(context, ref);
        break;
      case 'backup':
        _showBackupOptions(context);
        break;
      case 'emergency':
        _showEmergencyActions(context);
        break;
    }
  }


  void _runSystemCheck(BuildContext context, WidgetRef ref) {
    // Implement system check functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Running system check...')),
    );
  }

  void _showSystemStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SystemStatusDialog(),
    );
  }

  void _showAuditLog(BuildContext context, WidgetRef ref) {
    ref.read(navigationProvider.notifier).navigateTo('/admin/audit-log');
  }

  void _showBackupOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BackupOptionsDialog(),
    );
  }

  void _showEmergencyActions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EmergencyActionsDialog(),
    );
  }
}

/// Admin notifications bottom sheet
class AdminNotificationsSheet extends StatelessWidget {
  const AdminNotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            'System Alert',
            'High CPU usage detected on server-01',
            Icons.warning,
            Colors.orange,
          ),
          _buildNotificationItem(
            'New User Registration',
            '5 new users pending approval',
            Icons.person_add,
            Colors.blue,
          ),
          _buildNotificationItem(
            'Backup Complete',
            'Daily backup completed successfully',
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('View All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {},
    );
  }
}

/// System status dialog
class SystemStatusDialog extends StatelessWidget {
  const SystemStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('System Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusItem('Database', 'Online', Colors.green),
          _buildStatusItem('API Server', 'Online', Colors.green),
          _buildStatusItem('File Storage', 'Online', Colors.green),
          _buildStatusItem('Email Service', 'Degraded', Colors.orange),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // Refresh status
          },
          child: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String service, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(service),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Backup options dialog
class BackupOptionsDialog extends StatelessWidget {
  const BackupOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Backup & Restore'),
      content: const Text('Backup and restore functionality will be implemented here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Implement backup
          },
          child: const Text('Start Backup'),
        ),
      ],
    );
  }
}

/// Emergency actions dialog
class EmergencyActionsDialog extends StatelessWidget {
  const EmergencyActionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.emergency, color: Colors.red),
          SizedBox(width: 8),
          Text('Emergency Actions'),
        ],
      ),
      content: const Text(
        'Emergency actions can be performed here. These actions require additional authorization.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Implement emergency actions
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Authorize'),
        ),
      ],
    );
  }
}