import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../navigation/navigation_provider.dart';
import '../models/user_role.dart';
import 'building_switcher.dart';

/// Main app bar with building branding support
class BrandedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool showBuildingSwitcher;
  final VoidCallback? onProfileTap;

  const BrandedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showBuildingSwitcher = false,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final building = navigationState.currentBuilding;
    final theme = Theme.of(context);

    // Use building branding if available
    final backgroundColor = building?.branding?.primaryColor != null
        ? Color(int.parse(building!.branding!.primaryColor!.substring(1), radix: 16) + 0xFF000000)
        : theme.colorScheme.primary;

    final foregroundColor = building?.branding?.primaryColor != null
        ? _getContrastingColor(backgroundColor)
        : theme.colorScheme.onPrimary;

    return AppBar(
      title: _buildTitle(building),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        if (showBuildingSwitcher && navigationState.userRole.canAccessMultipleBuildings)
          BuildingSwitcherButton(
            currentBuilding: building,
            onBuildingSelected: (selectedBuilding) {
              ref.read(navigationProvider.notifier).switchBuilding(selectedBuilding);
            },
          ),
        ...?actions,
        _buildProfileButton(context, ref),
      ],
      elevation: 2,
    );
  }

  Widget _buildTitle(Building? building) {
    if (building?.branding?.logoUrl != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            building!.branding!.logoUrl!,
            height: 32,
            errorBuilder: (context, error, stackTrace) => Text(title),
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      );
    }
    
    return Text(title);
  }

  Widget _buildProfileButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.account_circle),
      onPressed: onProfileTap ?? () => _showProfileMenu(context, ref),
      tooltip: 'Profile',
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final navigationState = ref.read(navigationProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => ProfileBottomSheet(
        userRole: navigationState.userRole,
        currentBuilding: navigationState.currentBuilding,
      ),
    );
  }

  Color _getContrastingColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Compact app bar for mobile devices
class CompactAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const CompactAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final building = navigationState.currentBuilding;
    final theme = Theme.of(context);

    final backgroundColor = building?.branding?.primaryColor != null
        ? Color(int.parse(building!.branding!.primaryColor!.substring(1), radix: 16) + 0xFF000000)
        : theme.colorScheme.primary;

    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      centerTitle: true,
      leading: leading,
      actions: [
        ...?actions,
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => _showProfileMenu(context, ref),
        ),
      ],
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final navigationState = ref.read(navigationProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => ProfileBottomSheet(
        userRole: navigationState.userRole,
        currentBuilding: navigationState.currentBuilding,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Profile bottom sheet for user actions
class ProfileBottomSheet extends StatelessWidget {
  final UserRole userRole;
  final Building? currentBuilding;

  const ProfileBottomSheet({
    super.key,
    required this.userRole,
    this.currentBuilding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Profile',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      userRole.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (currentBuilding != null)
                      Text(
                        currentBuilding!.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              // Handle sign out
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}