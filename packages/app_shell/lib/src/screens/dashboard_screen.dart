import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../navigation/navigation_provider.dart';
import '../utils/icon_mapper.dart';
import '../widgets/capability_tile.dart' as widgets;
import '../widgets/admin_task_banner.dart';
import '../models/user_role.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final buildingCapabilities = navigationState.buildingCapabilities;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh building capabilities data
            // This would typically call an API refresh method
            await Future.delayed(const Duration(seconds: 1));
          },
          child: buildingCapabilities == null
              ? _buildLoadingState()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(NWSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome header
                      _buildWelcomeHeader(context, navigationState),
                      const SizedBox(height: NWSpacing.large),

                      // Admin task notification banner (if admin with pending tasks)
                      if (_shouldShowAdminBanner(navigationState))
                        Column(
                          children: [
                            AdminTaskBanner(
                              taskCount: _getAdminTaskCount(navigationState),
                              onTap: () => _handleAdminTasksTap(context),
                            ),
                            const SizedBox(height: NWSpacing.large),
                          ],
                        ),

                      // Dynamic capabilities section - only shows if there are enabled capabilities
                      if (buildingCapabilities.enabled.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Your Services'),
                        const SizedBox(height: NWSpacing.medium),
                        _buildDynamicCapabilityGrid(context, navigationState),
                        const SizedBox(height: NWSpacing.xLarge),
                      ],

                      // Show empty state if no capabilities
                      if (buildingCapabilities.enabled.isEmpty)
                        _buildEmptyState(context),

                      // Quick actions section - role-based
                      if (buildingCapabilities.enabled.isNotEmpty)
                        _buildQuickActionsSection(context, navigationState),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: NWSpacing.medium),
          Text('Loading your dashboard...'),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, NavigationState navigationState) {
    final buildingName = navigationState.currentBuilding?.name ?? 'Building Manager';
    final userRoleDisplay = _getUserRoleDisplay(navigationState.userRole);
    final timeOfDay = _getTimeOfDayGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$timeOfDay!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: NWColors.neutral800,
          ),
        ),
        const SizedBox(height: NWSpacing.xSmall),
        Container(
          decoration: BoxDecoration(
            gradient: NWColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: NWSpacing.medium,
            vertical: NWSpacing.xSmall,
          ),
          child: Text(
            buildingName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (userRoleDisplay != null) ...[
          const SizedBox(height: NWSpacing.xSmall),
          Text(
            userRoleDisplay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: NWColors.neutral600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: NWColors.neutral800,
      ),
    );
  }

  Widget _buildDynamicCapabilityGrid(BuildContext context, NavigationState navigationState) {
    final buildingCapabilities = navigationState.buildingCapabilities!;
    
    // Only show enabled capabilities - this is the key dynamic behavior
    final enabledCapabilities = buildingCapabilities.enabled;
    
    if (enabledCapabilities.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort by sortOrder for consistent display
    final sortedCapabilities = [...enabledCapabilities];
    sortedCapabilities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateGridColumns(constraints.maxWidth);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: NWSpacing.small,
            mainAxisSpacing: NWSpacing.small,
            childAspectRatio: 1.3,
          ),
          itemCount: sortedCapabilities.length,
          itemBuilder: (context, index) {
            final capability = sortedCapabilities[index];
            return widgets.CapabilityTile(
              capability: capability,
              onTap: () => _handleCapabilityTap(context, capability),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      color: NWColors.neutral50,
      child: Padding(
        padding: const EdgeInsets.all(NWSpacing.xLarge),
        child: Column(
          children: [
            Icon(
              Icons.apps_outlined,
              size: 64,
              color: NWColors.neutral400,
            ),
            const SizedBox(height: NWSpacing.medium),
            Text(
              'No Services Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: NWColors.neutral700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NWSpacing.small),
            Text(
              'Your building services will appear here when they become available. Contact your building manager for more information.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NWColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, NavigationState navigationState) {
    final quickActionItems = _getQuickActionItems(navigationState);
    
    if (quickActionItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Quick Actions'),
        const SizedBox(height: NWSpacing.medium),
        ...quickActionItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: NWSpacing.small),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleQuickAction(context, item['action'] as String),
              icon: Icon(
                item['icon'] as IconData,
                color: NWColors.accent,
              ),
              label: Text(item['label'] as String),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(NWSpacing.medium),
                side: BorderSide(color: NWColors.neutral300),
                foregroundColor: NWColors.neutral700,
              ),
            ),
          ),
        )),
      ],
    );
  }

  // Helper methods
  int _calculateGridColumns(double width) {
    if (width > 600) return 4;
    if (width > 450) return 3;
    if (width > 300) return 2;
    return 1;
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String? _getUserRoleDisplay(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'System Administrator';
      case UserRole.buildingManager:
        return 'Building Manager';
      case UserRole.resident:
        return null; // Don't show role for residents
      case UserRole.defectUser:
        return 'Defect Reporter';
      case UserRole.staff:
        return 'Staff Member';
    }
  }

  bool _shouldShowAdminBanner(NavigationState navigationState) {
    if (!navigationState.userRole.canManageBuildings) {
      return false;
    }

    // Check if there are any admin tasks
    return _getAdminTaskCount(navigationState) > 0;
  }

  int _getAdminTaskCount(NavigationState navigationState) {
    final capabilities = navigationState.buildingCapabilities;
    if (capabilities == null) return 0;

    int taskCount = 0;
    for (final cap in capabilities.enabled) {
      final data = cap.data;
      if (data != null) {
        // Look for common admin task indicators
        taskCount += (data['pendingApprovals'] as int?) ?? 0;
        taskCount += (data['pendingDefects'] as int?) ?? 0;
        taskCount += (data['pendingMaintenance'] as int?) ?? 0;
        taskCount += (data['pendingReports'] as int?) ?? 0;
        taskCount += (data['urgentCount'] as int?) ?? 0;
      }
    }

    return taskCount;
  }

  void _handleAdminTasksTap(BuildContext context) {
    // Navigate to first available admin capability or settings
    context.go('/settings');
  }

  void _handleCapabilityTap(BuildContext context, EnabledCapability capability) {
    context.go('/${capability.key}');
  }

  List<Map<String, dynamic>> _getQuickActionItems(NavigationState navigationState) {
    final items = <Map<String, dynamic>>[];
    final availableCapabilities = navigationState.availableCapabilities;

    // Add role-specific quick actions based on available capabilities
    switch (navigationState.userRole) {
      case UserRole.admin:
      case UserRole.buildingManager:
        // Settings is always available for admins
        items.add({
          'label': 'Settings',
          'icon': Icons.settings_outlined,
          'action': 'settings',
        });
        
        // Add defects action if capability is available
        if (availableCapabilities.contains('defects')) {
          items.add({
            'label': 'Manage Defects',
            'icon': Icons.build_outlined,
            'action': 'defects',
          });
        }
        
        // Add messaging action if capability is available
        if (availableCapabilities.contains('messaging')) {
          items.add({
            'label': 'Messages',
            'icon': Icons.message_outlined,
            'action': 'messaging',
          });
        }
        break;
        
      case UserRole.defectUser:
        // Only add defect action if capability is available
        if (availableCapabilities.contains('defects')) {
          items.add({
            'label': 'Report New Defect',
            'icon': Icons.add_circle_outline,
            'action': 'new_defect',
          });
        }
        break;
        
      case UserRole.resident:
        // Add messaging action if available
        if (availableCapabilities.contains('messaging')) {
          items.add({
            'label': 'Messages',
            'icon': Icons.message_outlined,
            'action': 'messaging',
          });
        }
        
        // Add documents action if available
        if (availableCapabilities.contains('documents')) {
          items.add({
            'label': 'Documents',
            'icon': Icons.description_outlined,
            'action': 'documents',
          });
        }
        
        // Add defects action if available
        if (availableCapabilities.contains('defects')) {
          items.add({
            'label': 'Report Issue',
            'icon': Icons.report_outlined,
            'action': 'defects',
          });
        }
        break;
        
      case UserRole.staff:
        // Add defects action if available
        if (availableCapabilities.contains('defects')) {
          items.add({
            'label': 'View Defects',
            'icon': Icons.list_alt_outlined,
            'action': 'defects',
          });
        }
        
        // Add messaging action if available
        if (availableCapabilities.contains('messaging')) {
          items.add({
            'label': 'Messages',
            'icon': Icons.message_outlined,
            'action': 'messaging',
          });
        }
        break;
    }

    return items;
  }
  
  void _handleQuickAction(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        context.go('/settings');
        break;
      case 'defects':
      case 'new_defect':
        context.go('/defects');
        break;
      case 'messaging':
        context.go('/messaging');
        break;
      case 'documents':
        context.go('/documents');
        break;
    }
  }
}