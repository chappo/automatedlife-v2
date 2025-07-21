import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../navigation/navigation_provider.dart';

/// Building switcher button for app bar
class BuildingSwitcherButton extends ConsumerWidget {
  final Building? currentBuilding;
  final ValueChanged<Building> onBuildingSelected;

  const BuildingSwitcherButton({
    super.key,
    this.currentBuilding,
    required this.onBuildingSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final availableBuildings = navigationState.availableBuildings;

    if (availableBuildings.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<Building>(
      icon: const Icon(Icons.business),
      tooltip: 'Switch Building',
      onSelected: onBuildingSelected,
      itemBuilder: (context) => availableBuildings
          .map((building) => PopupMenuItem<Building>(
                value: building,
                child: Row(
                  children: [
                    Icon(
                      building.id == currentBuilding?.id
                          ? Icons.check_circle
                          : Icons.business,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            building.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (building.address != null)
                            Text(
                              building.address!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

/// Building switcher widget for navigation drawer or sidebar
class BuildingSwitcherWidget extends ConsumerWidget {
  final Building? currentBuilding;
  final ValueChanged<Building> onBuildingSelected;
  final bool isCompact;

  const BuildingSwitcherWidget({
    super.key,
    this.currentBuilding,
    required this.onBuildingSelected,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final availableBuildings = navigationState.availableBuildings;
    final theme = Theme.of(context);

    if (availableBuildings.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isCompact) {
      return _buildCompactSwitcher(context, availableBuildings, theme);
    } else {
      return _buildExpandedSwitcher(context, availableBuildings, theme);
    }
  }

  Widget _buildCompactSwitcher(BuildContext context, List<Building> buildings, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: DropdownButton<Building>(
        value: currentBuilding,
        isExpanded: true,
        underline: Container(
          height: 1,
          color: theme.colorScheme.outline,
        ),
        items: buildings
            .map((building) => DropdownMenuItem<Building>(
                  value: building,
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          building.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (building) {
          if (building != null) {
            onBuildingSelected(building);
          }
        },
      ),
    );
  }

  Widget _buildExpandedSwitcher(BuildContext context, List<Building> buildings, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Buildings',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...buildings.map((building) => _buildBuildingTile(context, building, theme)),
      ],
    );
  }

  Widget _buildBuildingTile(BuildContext context, Building building, ThemeData theme) {
    final isSelected = building.id == currentBuilding?.id;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.business,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(building.name),
      subtitle: building.address != null ? Text(building.address!) : null,
      selected: isSelected,
      onTap: () => onBuildingSelected(building),
      trailing: isSelected ? Icon(
        Icons.check,
        color: theme.colorScheme.primary,
      ) : null,
    );
  }
}

/// Building switcher dialog for mobile
class BuildingSwitcherDialog extends ConsumerWidget {
  final Building? currentBuilding;
  final ValueChanged<Building> onBuildingSelected;

  const BuildingSwitcherDialog({
    super.key,
    this.currentBuilding,
    required this.onBuildingSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final availableBuildings = navigationState.availableBuildings;
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Select Building'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: availableBuildings.length,
          itemBuilder: (context, index) {
            final building = availableBuildings[index];
            final isSelected = building.id == currentBuilding?.id;

            return ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.business,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
              title: Text(building.name),
              subtitle: building.address != null ? Text(building.address!) : null,
              selected: isSelected,
              onTap: () {
                Navigator.of(context).pop();
                onBuildingSelected(building);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Utility function to show building switcher dialog
void showBuildingSwitcherDialog(
  BuildContext context, {
  Building? currentBuilding,
  required ValueChanged<Building> onBuildingSelected,
}) {
  showDialog(
    context: context,
    builder: (context) => BuildingSwitcherDialog(
      currentBuilding: currentBuilding,
      onBuildingSelected: onBuildingSelected,
    ),
  );
}