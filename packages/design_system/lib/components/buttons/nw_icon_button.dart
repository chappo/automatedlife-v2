import 'package:flutter/material.dart';
import '../../accessibility/touch_targets.dart';
import '../../tokens/dimensions.dart';

/// Icon button component with accessibility support
/// 
/// Used for icon-only actions like navigation, toggles, and quick actions.
/// Ensures proper touch targets and semantic labeling.
class NWIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? semanticLabel;
  final String? tooltip;
  final bool isSelected;
  
  const NWIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.semanticLabel,
    this.tooltip,
    this.isSelected = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? 
        (isSelected 
            ? theme.colorScheme.primary 
            : theme.iconTheme.color);
    
    Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: effectiveColor,
        size: size ?? NWDimensions.iconMedium,
      ),
      tooltip: tooltip,
    );
    
    // Add semantic information
    button = Semantics(
      label: semanticLabel ?? tooltip ?? 'Button',
      button: true,
      enabled: onPressed != null,
      selected: isSelected,
      child: button,
    );
    
    return AccessibleTouchTargets.ensureMinimumTouchTarget(
      onTap: onPressed,
      semanticLabel: semanticLabel ?? tooltip,
      child: button,
    );
  }
}