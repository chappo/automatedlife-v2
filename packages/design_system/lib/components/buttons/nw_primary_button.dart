import 'package:flutter/material.dart';
import '../../accessibility/touch_targets.dart';
import '../../tokens/dimensions.dart';
import '../../tokens/animation.dart';

/// Primary button component with accessibility support
/// 
/// Used for primary actions like "Save", "Submit", "Login".
/// Automatically handles touch targets, focus, and semantic labeling.
class NWPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final String? semanticLabel;
  final String? tooltip;
  
  const NWPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticLabel,
    this.tooltip,
  });
  
  /// Creates a primary button with an icon
  const NWPrimaryButton.icon({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticLabel,
    this.tooltip,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;
    
    Widget button = AnimatedContainer(
      duration: NWAnimation.buttonPress,
      curve: NWAnimation.buttonCurve,
      width: isFullWidth ? double.infinity : null,
      height: NWDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        child: _buildButtonChild(theme),
      ),
    );
    
    // Wrap with accessibility features
    button = Semantics(
      label: semanticLabel ?? text,
      hint: tooltip,
      button: true,
      enabled: effectiveOnPressed != null,
      child: button,
    );
    
    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return AccessibleTouchTargets.ensureMinimumTouchTarget(
      onTap: effectiveOnPressed,
      child: button,
    );
  }
  
  Widget _buildButtonChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: NWDimensions.iconMedium,
        width: NWDimensions.iconMedium,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.onPrimary,
          ),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    
    return Text(text);
  }
}