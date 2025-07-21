import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../models/models.dart';
import '../navigation/navigation.dart';
import '../widgets/widgets.dart';
import 'base_shell.dart';

/// Defect user shell with defects-only interface
class DefectUserShell extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const DefectUserShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    
    // Ensure defect user role and capabilities are set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigationState.userRole != UserRole.defectUser) {
        ref.read(navigationProvider.notifier).setUserRole(UserRole.defectUser);
      }
      
      // Set defect-only capabilities
      if (!_hasDefectCapabilities(navigationState.availableCapabilities)) {
        ref.read(navigationProvider.notifier).setAvailableCapabilities(['defects']);
      }
    });

    return BaseShell(
      currentRoute: currentRoute,
      appBar: _buildSimpleAppBar(context, ref),
      navigationItems: _getDefectNavigationItems(),
      drawer: _buildDefectDrawer(context, ref),
      floatingActionButton: _buildDefectFAB(context, ref),
      child: child,
    );
  }

  PreferredSizeWidget _buildSimpleAppBar(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final building = navigationState.currentBuilding;
    
    return AppBar(
      title: Text(_getPageTitle(currentRoute)),
      backgroundColor: building?.branding?.primaryColor != null
          ? Color(int.parse(building!.branding!.primaryColor!.substring(1), radix: 16) + 0xFF000000)
          : Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelp(context),
          tooltip: 'Help',
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => _showProfile(context, ref),
          tooltip: 'Profile',
        ),
      ],
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'My Reports';
      case '/defects':
        return 'Report Issue';
      case '/defects/new':
        return 'New Report';
      case '/settings':
        return 'Settings';
      default:
        return 'Issue Reporting';
    }
  }

  List<NavigationItem> _getDefectNavigationItems() {
    return [
      const NavigationItem(
        key: 'dashboard',
        label: 'My Reports',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        route: '/dashboard',
      ),
      const NavigationItem(
        key: 'defects',
        label: 'Report Issue',
        icon: Icons.report_problem_outlined,
        selectedIcon: Icons.report_problem,
        route: '/defects',
        requiredCapabilities: ['defects'],
      ),
      const NavigationItem(
        key: 'settings',
        label: 'Settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        route: '/settings',
      ),
    ];
  }

  Widget _buildDefectFAB(BuildContext context, WidgetRef ref) {
    if (currentRoute == '/defects' || currentRoute == '/dashboard') {
      return FloatingActionButton.extended(
        onPressed: () => _createNewReport(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
        tooltip: 'Create New Defect Report',
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDefectDrawer(BuildContext context, WidgetRef ref) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_problem,
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Issue Reporting',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                Text(
                  building?.name ?? 'Building Portal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          _buildQuickActions(context, ref),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('My Reports'),
                  selected: currentRoute == '/dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(navigationProvider.notifier).navigateTo('/dashboard');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined),
                  title: const Text('Report Issue'),
                  selected: currentRoute == '/defects',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(navigationProvider.notifier).navigateTo('/defects');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Guide'),
                  onTap: () {
                    Navigator.pop(context);
                    _showHelp(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  selected: currentRoute == '/settings',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(navigationProvider.notifier).navigateTo('/settings');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildUserInfo(context, theme),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createNewReport(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('New Report'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _takePhoto(context, ref),
                icon: const Icon(Icons.camera_alt),
                tooltip: 'Take Photo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Defect Reporter',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Limited Access Mode',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasDefectCapabilities(List<String> capabilities) {
    return capabilities.contains('defects');
  }

  void _createNewReport(BuildContext context, WidgetRef ref) {
    ref.read(navigationProvider.notifier).navigateTo('/defects/new');
  }

  void _takePhoto(BuildContext context, WidgetRef ref) {
    // Implement photo capture functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo capture feature coming soon')),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DefectUserHelpDialog(),
    );
  }

  void _showProfile(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const DefectUserProfileSheet(),
    );
  }
}

/// Help dialog for defect users
class DefectUserHelpDialog extends StatelessWidget {
  const DefectUserHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.help_outline),
          SizedBox(width: 8),
          Text('How to Report Issues'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpSection(
              'Reporting an Issue',
              [
                '1. Tap "New Report" button',
                '2. Select the issue category',
                '3. Describe the problem clearly',
                '4. Take photos if possible',
                '5. Submit your report',
              ],
            ),
            const SizedBox(height: 16),
            _buildHelpSection(
              'Issue Categories',
              [
                '• Maintenance (plumbing, electrical)',
                '• Safety concerns',
                '• Common area issues',
                '• Facility problems',
                '• Other building-related issues',
              ],
            ),
            const SizedBox(height: 16),
            _buildHelpSection(
              'Tips for Better Reports',
              [
                '• Be specific about the location',
                '• Include photos when relevant',
                '• Describe urgency level',
                '• Provide contact information',
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildHelpSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(item),
            )),
      ],
    );
  }
}

/// Profile sheet for defect users
class DefectUserProfileSheet extends StatelessWidget {
  const DefectUserProfileSheet({super.key});

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
                      'Defect Reporter',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'Issue Reporting Access',
                      style: theme.textTheme.bodyMedium?.copyWith(
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
            title: const Text('Help & Guide'),
            onTap: () {
              Navigator.pop(context);
              // Show help
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            onTap: () {
              Navigator.pop(context);
              // Send feedback
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have limited access for issue reporting only.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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