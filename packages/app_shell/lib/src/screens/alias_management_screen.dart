import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';

/// Screen for managing user aliases and display names
class AliasManagementScreen extends ConsumerStatefulWidget {
  const AliasManagementScreen({super.key});

  @override
  ConsumerState<AliasManagementScreen> createState() => _AliasManagementScreenState();
}

class _AliasManagementScreenState extends ConsumerState<AliasManagementScreen> {
  List<UserAlias> _aliases = [];
  bool _isLoading = true;
  bool _isCreatingAlias = false;
  final _aliasController = TextEditingController();
  String _selectedAliasType = 'username';

  @override
  void initState() {
    super.initState();
    _loadAliases();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _loadAliases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ApiClient.instance;
      final aliases = await apiClient.getUserAliases();
      setState(() {
        _aliases = aliases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading aliases: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _createAlias() async {
    final aliasText = _aliasController.text.trim();
    if (aliasText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an alias')),
      );
      return;
    }

    setState(() {
      _isCreatingAlias = true;
    });

    try {
      final apiClient = ApiClient.instance;
      final newAlias = await apiClient.createUserAlias(
        alias: aliasText,
        type: _selectedAliasType,
        isPublic: true,
      );

      setState(() {
        _aliases.add(newAlias);
        _aliasController.clear();
        _isCreatingAlias = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alias "$aliasText" created successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCreatingAlias = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating alias: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _setPrimaryAlias(UserAlias alias) async {
    try {
      final apiClient = ApiClient.instance;
      await apiClient.setPrimaryAlias(alias.id);

      setState(() {
        // Update local state to reflect the new primary alias
        _aliases = _aliases.map((a) => a.copyWith(isPrimary: a.id == alias.id)).toList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set "${alias.alias}" as primary display name'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting primary alias: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAlias(UserAlias alias) async {
    if (alias.isPrimary) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete primary alias')),
      );
      return;
    }

    final confirmed = await _showDeleteConfirmation(alias);
    if (confirmed != true) return;

    try {
      final apiClient = ApiClient.instance;
      await apiClient.deleteUserAlias(alias.id);

      setState(() {
        _aliases.removeWhere((a) => a.id == alias.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted alias "${alias.alias}"'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting alias: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(UserAlias alias) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alias'),
        content: Text('Are you sure you want to delete "${alias.alias}"?'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manage Display Names'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(NWSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  _buildInfoCard(theme),
                  
                  const SizedBox(height: NWSpacing.large),
                  
                  // Create New Alias Section
                  _buildCreateAliasSection(theme),
                  
                  const SizedBox(height: NWSpacing.large),
                  
                  // Current Aliases Section
                  _buildCurrentAliasesSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(NWSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: NWSpacing.small),
              Text(
                'About Display Names',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: NWSpacing.small),
          Text(
            'Display names are used when sending messages and interacting with other residents. You can have multiple aliases and choose which one to use as your primary display name.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAliasSection(ThemeData theme) {
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
          Text(
            'Create New Alias',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: NWSpacing.medium),
          
          // Alias Type Selector
          Text(
            'Alias Type',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: NWSpacing.small),
          DropdownButtonFormField<String>(
            value: _selectedAliasType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: NWSpacing.medium,
                vertical: NWSpacing.small,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'username', child: Text('Username')),
              DropdownMenuItem(value: 'display_name', child: Text('Display Name')),
              DropdownMenuItem(value: 'nickname', child: Text('Nickname')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedAliasType = value;
                });
              }
            },
          ),
          
          const SizedBox(height: NWSpacing.medium),
          
          // Alias Input
          Text(
            'Alias',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: NWSpacing.small),
          TextField(
            controller: _aliasController,
            decoration: InputDecoration(
              hintText: 'Enter your alias or display name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: NWSpacing.medium,
                vertical: NWSpacing.small,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createAlias(),
          ),
          
          const SizedBox(height: NWSpacing.medium),
          
          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCreatingAlias ? null : _createAlias,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: NWSpacing.medium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
                ),
              ),
              child: _isCreatingAlias
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Alias'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAliasesSection(ThemeData theme) {
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
              'Your Aliases',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          
          if (_aliases.isEmpty)
            Padding(
              padding: const EdgeInsets.all(NWSpacing.large),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: NWSpacing.small),
                    Text(
                      'No aliases created yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_aliases.map((alias) => _buildAliasListItem(theme, alias)).toList()),
        ],
      ),
    );
  }

  Widget _buildAliasListItem(ThemeData theme, UserAlias alias) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: alias.isPrimary 
              ? theme.colorScheme.primary 
              : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
        ),
        child: Icon(
          alias.isPrimary ? Icons.star : Icons.badge_outlined,
          color: alias.isPrimary 
              ? Colors.white 
              : theme.colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        alias.alias,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: alias.isPrimary ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${alias.type.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}${alias.isPrimary ? ' • Primary' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (!alias.isPublic)
            Text(
              'Private',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          switch (action) {
            case 'primary':
              await _setPrimaryAlias(alias);
              break;
            case 'delete':
              await _deleteAlias(alias);
              break;
          }
        },
        itemBuilder: (context) => [
          if (!alias.isPrimary)
            const PopupMenuItem(
              value: 'primary',
              child: ListTile(
                leading: Icon(Icons.star_outline),
                title: Text('Set as Primary'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          if (!alias.isPrimary)
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}