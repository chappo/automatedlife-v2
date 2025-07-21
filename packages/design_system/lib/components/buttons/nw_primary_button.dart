import 'package:flutter/material.dart';
import '../../accessibility/touch_targets.dart';
import '../../tokens/dimensions.dart';
import '../../tokens/animation.dart';
import '../../theme/colors.dart';

/// Enhanced primary button component with modern gradient styling
/// 
/// Used for primary actions like "Save", "Submit", "Login".
/// Features gradient backgrounds, enhanced shadows, and smooth animations.
/// Automatically handles touch targets, focus, and semantic labeling.
class NWPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final String? semanticLabel;
  final String? tooltip;
  final bool useGradient;
  
  const NWPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticLabel,
    this.tooltip,
    this.useGradient = true,
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
    this.useGradient = true,
  });

  @override
  State<NWPrimaryButton> createState() => _NWPrimaryButtonState();
}

class _NWPrimaryButtonState extends State<NWPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: NWAnimation.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: NWAnimation.buttonCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = widget.isLoading ? null : widget.onPressed;
    
    Widget button = ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: _handleTapUp,
        child: AnimatedContainer(
          duration: NWAnimation.buttonPress,
          curve: NWAnimation.buttonCurve,
          width: widget.isFullWidth ? double.infinity : null,
          height: NWDimensions.buttonHeight,
          decoration: BoxDecoration(
            gradient: widget.useGradient && effectiveOnPressed != null
                ? NWColors.primaryGradient
                : null,
            color: !widget.useGradient || effectiveOnPressed == null
                ? (effectiveOnPressed != null 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.outline)
                : null,
            borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
            boxShadow: effectiveOnPressed != null ? [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: _isPressed ? 8 : 12,
                offset: Offset(0, _isPressed ? 2 : 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: _isPressed ? 16 : 24,
                offset: Offset(0, _isPressed ? 4 : 12),
                spreadRadius: 0,
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: effectiveOnPressed,
              borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Center(child: _buildButtonChild(theme)),
              ),
            ),
          ),
        ),
      ),
    );
    
    // Wrap with accessibility features
    button = Semantics(
      label: widget.semanticLabel ?? widget.text,
      hint: widget.tooltip,
      button: true,
      enabled: effectiveOnPressed != null,
      child: button,
    );
    
    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    
    return AccessibleTouchTargets.ensureMinimumTouchTarget(
      onTap: effectiveOnPressed,
      child: button,
    );
  }

  void _handleTapDown() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }
  
  Widget _buildButtonChild(ThemeData theme) {
    if (widget.isLoading) {
      return SizedBox(
        height: NWDimensions.iconMedium,
        width: NWDimensions.iconMedium,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white,
          ),
        ),
      );
    }
    
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    
    return Text(
      widget.text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}