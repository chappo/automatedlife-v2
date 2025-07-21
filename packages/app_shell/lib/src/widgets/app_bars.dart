import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
class ProfileBottomSheet extends ConsumerStatefulWidget {
  final UserRole userRole;
  final Building? currentBuilding;

  const ProfileBottomSheet({
    super.key,
    required this.userRole,
    this.currentBuilding,
  });

  @override
  ConsumerState<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends ConsumerState<ProfileBottomSheet> {
  bool _isLoggingOut = false;

  Future<void> _handleSignOut() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        await AuthService.instance.logout();
        // Navigation will be handled by AuthWrapper listening to auth state
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showLogoutConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.pop(context);
    // Navigate to settings using go_router
    context.go('/settings');
  }

  void _navigateToHelp() {
    Navigator.pop(context);
    // TODO: Implement help & support navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & support coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationState = ref.watch(navigationProvider);
    final user = navigationState.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF77B42D), // AL brand green
                      Color(0xFF558B2F), // Darker AL green
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    user?.displayName?.isNotEmpty == true 
                        ? user!.displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                        : widget.userRole.displayName[0].toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User Profile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.userRole.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.currentBuilding?.name != null)
                      Text(
                        widget.currentBuilding!.name!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _navigateToSettings,
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: theme.colorScheme.primary),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _navigateToHelp,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              _isLoggingOut ? Icons.hourglass_empty : Icons.logout,
              color: theme.colorScheme.error,
            ),
            title: Text(
              _isLoggingOut ? 'Signing Out...' : 'Sign Out',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: _isLoggingOut ? null : _handleSignOut,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}