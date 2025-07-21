import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';

/// Home screen placeholder for the authenticated state
/// 
/// This will be replaced with the actual building management interface
/// once the authentication flow is working properly.
class HomeScreen extends StatelessWidget {
  final User user;
  final Building building;

  const HomeScreen({
    super.key,
    required this.user,
    required this.building,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(building.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'switch_building':
                  await _switchBuilding(context);
                  break;
                case 'logout':
                  await _logout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch_building',
                child: ListTile(
                  leading: Icon(Icons.swap_horiz),
                  title: Text('Switch Building'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NWSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome card
              Container(
                padding: const EdgeInsets.all(NWSpacing.large),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user.name}!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: NWSpacing.small),
                    
                    Text(
                      'You\'re now managing ${building.name}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                    
                    if (building.description != null) ...[
                      const SizedBox(height: NWSpacing.small),
                      Text(
                        building.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: NWSpacing.large),
              
              // Building info
              Text(
                'Building Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: NWSpacing.medium),
              
              _InfoCard(
                icon: Icons.business,
                title: 'Building Name',
                value: building.name,
              ),
              
              if (building.address != null) ...[
                const SizedBox(height: NWSpacing.small),
                _InfoCard(
                  icon: Icons.location_on,
                  title: 'Address',
                  value: _formatAddress(building),
                ),
              ],
              
              if (building.timeZone != null) ...[
                const SizedBox(height: NWSpacing.small),
                _InfoCard(
                  icon: Icons.schedule,
                  title: 'Time Zone',
                  value: building.timeZone!,
                ),
              ],
              
              const SizedBox(height: NWSpacing.small),
              _InfoCard(
                icon: building.isActive ? Icons.check_circle : Icons.cancel,
                title: 'Status',
                value: building.isActive ? 'Active' : 'Inactive',
                valueColor: building.isActive 
                  ? Colors.green 
                  : Colors.red,
              ),
              
              const Spacer(),
              
              // Placeholder message
              Container(
                padding: const EdgeInsets.all(NWSpacing.medium),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
                ),
                child: Text(
                  'This is a placeholder home screen. The building management features will be added here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(Building building) {
    final parts = <String>[];
    if (building.address?.isNotEmpty == true) parts.add(building.address!);
    if (building.city?.isNotEmpty == true) parts.add(building.city!);
    if (building.state?.isNotEmpty == true) parts.add(building.state!);
    if (building.zipCode?.isNotEmpty == true) parts.add(building.zipCode!);
    if (building.country?.isNotEmpty == true) parts.add(building.country!);
    return parts.join(', ');
  }

  Future<void> _switchBuilding(BuildContext context) async {
    try {
      final authService = AuthService.instance;
      final buildings = await authService.getBuildings();
      
      if (buildings != null && buildings.length > 1) {
        // Clear selected building to trigger building selection screen
        await authService.selectBuilding(buildings.first);
        // This is a temporary workaround - ideally we'd navigate properly
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch building: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService.instance.logout();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(NWSpacing.medium),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
          
          const SizedBox(width: NWSpacing.medium),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}