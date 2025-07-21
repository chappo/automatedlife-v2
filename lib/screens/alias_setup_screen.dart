import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';

/// First-time alias setup screen for new users
/// 
/// Guides users through creating their display name/username for messaging
/// and other communications within the building management system.
class AliasSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  final bool canSkip;

  const AliasSetupScreen({
    super.key,
    this.onComplete,
    this.canSkip = false,
  });

  @override
  ConsumerState<AliasSetupScreen> createState() => _AliasSetupScreenState();
}

class _AliasSetupScreenState extends ConsumerState<AliasSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _aliasFocusNode = FocusNode();
  
  String _selectedType = 'username';
  bool _isPublic = true;
  bool _isLoading = false;
  String? _errorMessage;

  static const List<String> _aliasTypes = [
    'username',
    'display_name',
    'nickname',
  ];

  @override
  void dispose() {
    _aliasController.dispose();
    _aliasFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAlias() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create the alias
      await ApiClient.instance.createUserAlias(
        alias: _aliasController.text.trim(),
        type: _selectedType,
        isPublic: _isPublic,
      );

      // Set it as primary
      final aliases = await ApiClient.instance.getUserAliases();
      final newAlias = aliases.firstWhere(
        (alias) => alias.alias == _aliasController.text.trim(),
      );
      
      await ApiClient.instance.setPrimaryAlias(newAlias.id);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alias "${_aliasController.text.trim()}" created successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Complete setup
        widget.onComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('alias already exists')
              ? 'This alias is already taken. Please choose a different one.'
              : 'Failed to create alias. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSkip() {
    if (widget.canSkip) {
      widget.onComplete?.call();
    }
  }

  String? _validateAlias(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an alias';
    }

    final alias = value.trim();
    
    if (alias.length < 2) {
      return 'Alias must be at least 2 characters';
    }

    if (alias.length > 50) {
      return 'Alias must be less than 50 characters';
    }

    // Check for valid characters based on type
    if (_selectedType == 'username') {
      if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(alias)) {
        return 'Username can only contain letters, numbers, periods, hyphens, and underscores';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(NWSpacing.large),
            child: Column(
              children: [
                // Skip button
                if (widget.canSkip)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _handleSkip,
                      child: const Text('Skip for now'),
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: NWSpacing.xLarge),

                        // Header
                        _buildHeader(theme),

                        const SizedBox(height: NWSpacing.xLarge),

                        // Setup form
                        _buildSetupForm(theme),

                        const SizedBox(height: NWSpacing.large),

                        // Info section
                        _buildInfoSection(theme),
                      ],
                    ),
                  ),
                ),

                // Create button
                _buildCreateButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Icon
        Container(
          width: 100,
          height: 100,
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
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_outlined,
            size: 45,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: NWSpacing.large),

        // Title
        Text(
          'Set Up Your Display Name',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: NWSpacing.small),

        // Subtitle
        Text(
          'Choose how you\'d like to appear in messages and communications',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSetupForm(ThemeData theme) {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(NWSpacing.medium),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: NWSpacing.small),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NWSpacing.medium),
            ],

            // Alias type selection
            Text(
              'Type',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: NWSpacing.small),
            
            Wrap(
              spacing: NWSpacing.small,
              children: _aliasTypes.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(_getTypeDisplayName(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: NWSpacing.large),

            // Alias input
            NWTextField(
              controller: _aliasController,
              focusNode: _aliasFocusNode,
              label: _getTypeDisplayName(_selectedType),
              hint: _getTypeHint(_selectedType),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              validator: _validateAlias,
              prefixIcon: Icon(_getTypeIcon(_selectedType)),
              onSubmitted: (_) => _handleCreateAlias(),
            ),

            const SizedBox(height: NWSpacing.medium),

            // Public/Private toggle
            Row(
              children: [
                Icon(
                  _isPublic ? Icons.public : Icons.lock_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: NWSpacing.small),
                Expanded(
                  child: Text(
                    _isPublic 
                        ? 'Visible to other residents'
                        : 'Private (visible only to administrators)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
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
                size: 20,
              ),
              const SizedBox(width: NWSpacing.small),
              Text(
                'About Display Names',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: NWSpacing.small),
          Text(
            '• Your display name appears in messages and communications\n'
            '• You can change it anytime in settings\n'
            '• Choose something that helps others recognize you\n'
            '• Keep it appropriate and professional',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    return Column(
      children: [
        NWPrimaryButton(
          text: 'Create Display Name',
          onPressed: _isLoading ? null : _handleCreateAlias,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
        
        if (widget.canSkip) ...[
          const SizedBox(height: NWSpacing.small),
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              'I\'ll set this up later',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'username':
        return 'Username';
      case 'display_name':
        return 'Display Name';
      case 'nickname':
        return 'Nickname';
      default:
        return type;
    }
  }

  String _getTypeHint(String type) {
    switch (type) {
      case 'username':
        return 'e.g. john.smith or jsmith';
      case 'display_name':
        return 'e.g. John Smith or John S.';
      case 'nickname':
        return 'e.g. Johnny or JS';
      default:
        return 'Enter your $type';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'username':
        return Icons.alternate_email;
      case 'display_name':
        return Icons.badge_outlined;
      case 'nickname':
        return Icons.tag;
      default:
        return Icons.label_outline;
    }
  }
}