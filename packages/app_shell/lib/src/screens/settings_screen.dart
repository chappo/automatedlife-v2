import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../navigation/navigation_provider.dart';

/// Comprehensive settings screen with user preferences, account management, and app settings
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricsEnabled = false;
  double _textSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load user preferences from storage
    // This would typically come from SharedPreferences or user account
    setState(() {
      // Default values for now
      _notificationsEnabled = true;
      _darkModeEnabled = false;
      _biometricsEnabled = false;
      _textSize = 1.0;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed == true) {
      try {
        await AuthService.instance.logout();
        // Navigation will be handled by AuthWrapper listening to auth state
      } catch (e) {
        if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navigationState = ref.watch(navigationProvider);
    final user = navigationState.currentUser;
    final building = navigationState.currentBuilding;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NWSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfileCard(theme, user, building),
            
            const SizedBox(height: NWSpacing.large),
            
            // App Preferences
            _buildAppPreferencesSection(theme),
            
            const SizedBox(height: NWSpacing.large),
            
            // Account & Security
            _buildAccountSecuritySection(theme),
            
            const SizedBox(height: NWSpacing.large),
            
            // About & Support
            _buildAboutSupportSection(theme),
            
            const SizedBox(height: NWSpacing.large),
            
            // Sign Out Button
            _buildSignOutSection(theme),
            
            const SizedBox(height: NWSpacing.xLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(ThemeData theme, User? user, Building? building) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(NWSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF77B42D), // AL brand green
                      Color(0xFF558B2F), // Darker AL green
                    ],
                  ),
                  borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
                ),
                child: Center(
                  child: Text(
                    user?.displayName?.isNotEmpty == true 
                        ? user!.displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                        : 'U',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: NWSpacing.medium),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (building?.name != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
                        ),
                        child: Text(
                          building!.name!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferencesSection(ThemeData theme) {
    return _buildSettingsSection(
      theme: theme,
      title: 'App Preferences',
      children: [
        _buildSwitchListTile(
          theme: theme,
          title: 'Push Notifications',
          subtitle: 'Receive notifications for messages and updates',
          icon: Icons.notifications_outlined,
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildSwitchListTile(
          theme: theme,
          title: 'Dark Mode',
          subtitle: 'Use dark theme throughout the app',
          icon: Icons.dark_mode_outlined,
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),
        _buildListTile(
          theme: theme,
          title: 'Text Size',
          subtitle: 'Adjust text size for better readability',
          icon: Icons.text_fields_outlined,
          trailing: DropdownButton<double>(
            value: _textSize,
            underline: Container(),
            items: [
              DropdownMenuItem(value: 0.8, child: Text('Small')),
              DropdownMenuItem(value: 1.0, child: Text('Medium')),
              DropdownMenuItem(value: 1.2, child: Text('Large')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _textSize = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSecuritySection(ThemeData theme) {
    return _buildSettingsSection(
      theme: theme,
      title: 'Account & Security',
      children: [
        _buildListTile(
          theme: theme,
          title: 'Display Name',
          subtitle: 'Manage your display name and aliases',
          icon: Icons.badge_outlined,
          onTap: () {
            // TODO: Navigate to alias management
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Alias management coming soon')),
            );
          },
        ),
        _buildSwitchListTile(
          theme: theme,
          title: 'Biometric Login',
          subtitle: 'Use fingerprint or face recognition to sign in',
          icon: Icons.fingerprint_outlined,
          value: _biometricsEnabled,
          onChanged: (value) {
            setState(() {
              _biometricsEnabled = value;
            });
          },
        ),
        _buildListTile(
          theme: theme,
          title: 'Change Password',
          subtitle: 'Update your account password',
          icon: Icons.lock_outline,
          onTap: () {
            // TODO: Navigate to change password screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change password coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSupportSection(ThemeData theme) {
    return _buildSettingsSection(
      theme: theme,
      title: 'About & Support',
      children: [
        _buildListTile(
          theme: theme,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          icon: Icons.help_outline,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & support coming soon')),
            );
          },
        ),
        _buildListTile(
          theme: theme,
          title: 'Privacy Policy',
          subtitle: 'Review our privacy practices',
          icon: Icons.privacy_tip_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy policy coming soon')),
            );
          },
        ),
        _buildListTile(
          theme: theme,
          title: 'Terms of Service',
          subtitle: 'Review terms and conditions',
          icon: Icons.description_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of service coming soon')),
            );
          },
        ),
        _buildListTile(
          theme: theme,
          title: 'App Version',
          subtitle: '1.0.0 (Beta)',
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  Widget _buildSignOutSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildListTile(
        theme: theme,
        title: 'Sign Out',
        subtitle: 'Sign out of your account',
        icon: Icons.logout,
        iconColor: theme.colorScheme.error,
        titleColor: theme.colorScheme.error,
        onTap: _handleLogout,
      ),
    );
  }

  Widget _buildSettingsSection({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(NWSpacing.large),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required ThemeData theme,
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchListTile({
    required ThemeData theme,
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildListTile(
      theme: theme,
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }
}