import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../models/models.dart';
import '../navigation/navigation.dart';
import '../widgets/widgets.dart';
import 'base_shell.dart';

/// Resident shell with building-specific capabilities
class ResidentShell extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const ResidentShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    
    // Ensure resident role is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigationState.userRole != UserRole.resident) {
        ref.read(navigationProvider.notifier).setUserRole(UserRole.resident);
      }
      
      // Set resident capabilities based on current building
      _updateCapabilitiesForBuilding(ref, navigationState.currentBuilding);
    });

    return BaseShell(
      currentRoute: currentRoute,
      appBar: BrandedAppBar(
        title: _getPageTitle(currentRoute),
        actions: [
          _buildQuickActionsButton(context, ref),
          _buildNotificationButton(context),
        ],
      ),
      navigationItems: navigationState.primaryNavigationItems,
      drawer: _buildResidentDrawer(context, ref),
      floatingActionButton: _buildFloatingActionButton(context, ref),
      child: child,
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'My Building';
      case '/defects':
        return 'Report Issue';
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
        return 'My Building';
    }
  }

  Widget _buildQuickActionsButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.apps),
      tooltip: 'Quick Actions',
      onSelected: (value) => _handleQuickAction(context, ref, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'report_defect',
          child: Row(
            children: [
              Icon(Icons.report_problem),
              SizedBox(width: 8),
              Text('Report Issue'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'book_amenity',
          child: Row(
            children: [
              Icon(Icons.calendar_today),
              SizedBox(width: 8),
              Text('Book Amenity'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'contact_management',
          child: Row(
            children: [
              Icon(Icons.contact_support),
              SizedBox(width: 8),
              Text('Contact Management'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'emergency',
          child: Row(
            children: [
              Icon(Icons.emergency, color: Colors.red),
              SizedBox(width: 8),
              Text('Emergency'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return IconButton(
      icon: const Badge(
        label: Text('2'),
        child: Icon(Icons.notifications),
      ),
      onPressed: () => _showNotifications(context),
      tooltip: 'Notifications',
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    // Show different FABs based on current route
    switch (currentRoute) {
      case '/defects':
        return FloatingActionButton(
          onPressed: () => _reportNewDefect(context, ref),
          tooltip: 'Report New Issue',
          child: const Icon(Icons.add),
        );
      case '/messaging':
        return FloatingActionButton(
          onPressed: () => _composeMessage(context, ref),
          tooltip: 'New Message',
          child: const Icon(Icons.edit),
        );
      case '/calendar':
        return FloatingActionButton(
          onPressed: () => _makeNewBooking(context, ref),
          tooltip: 'New Booking',
          child: const Icon(Icons.add),
        );
      default:
        return FloatingActionButton(
          onPressed: () => _showQuickActions(context, ref),
          tooltip: 'Quick Actions',
          child: const Icon(Icons.add),
        );
    }
  }

  Widget _buildResidentDrawer(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final building = navigationState.currentBuilding;
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: building?.branding?.primaryColor != null
                  ? Color(int.parse(building!.branding!.primaryColor!.substring(1), radix: 16) + 0xFF000000)
                  : theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (building?.branding?.logoUrl != null)
                  Image.network(
                    building!.branding!.logoUrl!,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.business,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                else
                  Icon(
                    Icons.business,
                    size: 40,
                    color: theme.colorScheme.onPrimary,
                  ),
                const SizedBox(height: 8),
                Text(
                  building?.name ?? 'My Building',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                Text(
                  'Resident Portal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          _buildQuickAccessSection(context, ref),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                ..._buildNavigationItems(context, ref, navigationState.navigationItems),
              ],
            ),
          ),
          const Divider(),
          _buildBuildingInfo(context, building, theme),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      leading: const Icon(Icons.flash_on),
      title: const Text('Quick Access'),
      initiallyExpanded: true,
      children: [
        ListTile(
          leading: const Icon(Icons.report_problem),
          title: const Text('Report Issue'),
          onTap: () => _reportNewDefect(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Book Amenity'),
          onTap: () => _makeNewBooking(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.contact_support),
          title: const Text('Contact Management'),
          onTap: () => _contactManagement(context, ref),
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
      trailing: item.badge != null && item.badge! > 0
          ? Badge(
              label: Text(item.badge.toString()),
              child: const SizedBox(width: 1),
            )
          : null,
      selected: currentRoute == item.route,
      onTap: () {
        Navigator.pop(context);
        ref.read(navigationProvider.notifier).navigateTo(item.route);
      },
    )).toList();
  }

  Widget _buildBuildingInfo(BuildContext context, Building? building, ThemeData theme) {
    if (building == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  building.address ?? 'Address not available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (building.description != null) ...[
            const SizedBox(height: 8),
            Text(
              building.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  void _updateCapabilitiesForBuilding(WidgetRef ref, Building? building) {
    if (building?.capabilities != null) {
      final capabilities = building!.capabilities!
          .where((cap) => cap.isEnabled)
          .map((cap) => cap.key)
          .toList();
      
      ref.read(navigationProvider.notifier).setAvailableCapabilities(capabilities);
    } else {
      // Set default resident capabilities
      ref.read(navigationProvider.notifier).setAvailableCapabilities(
        UserRole.resident.defaultCapabilities,
      );
    }
  }

  void _handleQuickAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'report_defect':
        _reportNewDefect(context, ref);
        break;
      case 'book_amenity':
        _makeNewBooking(context, ref);
        break;
      case 'contact_management':
        _contactManagement(context, ref);
        break;
      case 'emergency':
        _handleEmergency(context, ref);
        break;
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ResidentNotificationsSheet(),
    );
  }

  void _showQuickActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickActionsSheet(
        onActionSelected: (action) {
          Navigator.pop(context);
          _handleQuickAction(context, ref, action);
        },
      ),
    );
  }

  void _reportNewDefect(BuildContext context, WidgetRef ref) {
    ref.read(navigationProvider.notifier).navigateTo('/defects/new');
  }

  void _composeMessage(BuildContext context, WidgetRef ref) {
    ref.read(navigationProvider.notifier).navigateTo('/messaging/compose');
  }

  void _makeNewBooking(BuildContext context, WidgetRef ref) {
    ref.read(navigationProvider.notifier).navigateTo('/calendar/book');
  }

  void _contactManagement(BuildContext context, WidgetRef ref) {
    ref.read(navigationProvider.notifier).navigateTo('/contact');
  }

  void _handleEmergency(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const EmergencyDialog(),
    );
  }
}

/// Resident notifications bottom sheet
class ResidentNotificationsSheet extends StatelessWidget {
  const ResidentNotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            'Maintenance Notice',
            'Elevator maintenance scheduled for tomorrow 9-11 AM',
            Icons.build,
            Colors.orange,
          ),
          _buildNotificationItem(
            'Package Delivery',
            'Package delivered to your mailbox',
            Icons.local_shipping,
            Colors.blue,
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

/// Quick actions bottom sheet
class QuickActionsSheet extends StatelessWidget {
  final ValueChanged<String> onActionSelected;

  const QuickActionsSheet({
    super.key,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildActionCard(
                'Report Issue',
                Icons.report_problem,
                Colors.red,
                () => onActionSelected('report_defect'),
              ),
              _buildActionCard(
                'Book Amenity',
                Icons.calendar_today,
                Colors.blue,
                () => onActionSelected('book_amenity'),
              ),
              _buildActionCard(
                'Contact Management',
                Icons.contact_support,
                Colors.green,
                () => onActionSelected('contact_management'),
              ),
              _buildActionCard(
                'Emergency',
                Icons.emergency,
                Colors.red,
                () => onActionSelected('emergency'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Emergency dialog
class EmergencyDialog extends StatelessWidget {
  const EmergencyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.emergency, color: Colors.red),
          SizedBox(width: 8),
          Text('Emergency Contact'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('In case of emergency, please contact:'),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.local_fire_department, color: Colors.red),
            title: Text('Fire Department'),
            subtitle: Text('911'),
          ),
          ListTile(
            leading: Icon(Icons.local_police, color: Colors.blue),
            title: Text('Police'),
            subtitle: Text('911'),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital, color: Colors.green),
            title: Text('Medical Emergency'),
            subtitle: Text('911'),
          ),
          ListTile(
            leading: Icon(Icons.build, color: Colors.orange),
            title: Text('Building Emergency'),
            subtitle: Text('555-0123'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Implement emergency call
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Call Emergency'),
        ),
      ],
    );
  }
}