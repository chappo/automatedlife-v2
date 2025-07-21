import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';

/// Building selection screen for users with multiple buildings
/// 
/// Allows users to select which building they want to access
/// when they have permission for multiple buildings.
class BuildingSelectionScreen extends StatefulWidget {
  final List<Building> buildings;
  final User user;

  const BuildingSelectionScreen({
    super.key,
    required this.buildings,
    required this.user,
  });

  @override
  State<BuildingSelectionScreen> createState() => _BuildingSelectionScreenState();
}

class _BuildingSelectionScreenState extends State<BuildingSelectionScreen> {
  Building? _selectedBuilding;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select first building if available
    if (widget.buildings.isNotEmpty) {
      _selectedBuilding = widget.buildings.first;
    }
  }

  Future<void> _selectBuilding() async {
    if (_selectedBuilding == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService.instance;
      await authService.selectBuilding(_selectedBuilding!);
      
      // Navigation will be handled by AuthWrapper listening to auth state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select building: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService.instance;
      await authService.logout();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Select Building'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NWSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(theme),
              
              const SizedBox(height: NWSpacing.large),
              
              // Building list
              Expanded(
                child: _buildBuildingList(theme),
              ),
              
              const SizedBox(height: NWSpacing.large),
              
              // Continue button
              NWPrimaryButton(
                text: 'Continue',
                onPressed: _selectedBuilding != null && !_isLoading 
                  ? _selectBuilding 
                  : null,
                isLoading: _isLoading,
                isFullWidth: true,
                semanticLabel: 'Continue with selected building',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Welcome message
        Text(
          'Welcome, ${widget.user.displayName}!',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: NWSpacing.small),
        
        // Instruction
        Text(
          'You have access to multiple buildings. Please select which building you\'d like to manage.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBuildingList(ThemeData theme) {
    if (widget.buildings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: NWSpacing.medium),
            Text(
              'No buildings available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: NWSpacing.small),
            Text(
              'Contact your administrator for access',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: widget.buildings.length,
      separatorBuilder: (context, index) => const SizedBox(height: NWSpacing.medium),
      itemBuilder: (context, index) {
        final building = widget.buildings[index];
        final isSelected = _selectedBuilding?.id == building.id;
        
        return _BuildingCard(
          building: building,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedBuilding = building;
            });
          },
        );
      },
    );
  }
}

class _BuildingCard extends StatelessWidget {
  final Building building;
  final bool isSelected;
  final VoidCallback onTap;

  const _BuildingCard({
    required this.building,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Building: ${building.name}',
      hint: building.description ?? 'Tap to select this building',
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected 
          ? colorScheme.primaryContainer 
          : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(NWSpacing.medium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
              border: Border.all(
                color: isSelected 
                  ? colorScheme.primary 
                  : colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Building icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? colorScheme.primary 
                      : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
                  ),
                  child: Icon(
                    Icons.business,
                    color: isSelected 
                      ? colorScheme.onPrimary 
                      : colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(width: NWSpacing.medium),
                
                // Building info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected 
                            ? colorScheme.onPrimaryContainer 
                            : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      if (building.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          building.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected 
                              ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8) 
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      if (building.address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: isSelected 
                                ? colorScheme.onPrimaryContainer.withValues(alpha: 0.6) 
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatAddress(building),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected 
                                    ? colorScheme.onPrimaryContainer.withValues(alpha: 0.6) 
                                    : colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Selection indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: colorScheme.outline,
                    size: 24,
                  ),
              ],
            ),
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
    return parts.join(', ');
  }
}