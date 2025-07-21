import 'package:flutter/material.dart';
import '../tokens/dimensions.dart';

/// Accessibility helper for touch targets
/// 
/// Ensures interactive elements meet minimum size requirements
/// for users with motor impairments.
class AccessibleTouchTargets {
  /// Ensures a widget meets minimum touch target size requirements
  /// 
  /// Wraps the child in a container with minimum 48dp dimensions
  /// as required by WCAG 2.1 AA guidelines.
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    required VoidCallback? onTap,
    double? minSize,
    String? semanticLabel,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minSize ?? NWDimensions.minTouchTarget,
        minHeight: minSize ?? NWDimensions.minTouchTarget,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
          child: Semantics(
            label: semanticLabel,
            button: true,
            enabled: onTap != null,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
  
  /// Creates an accessible touch target with proper spacing
  /// 
  /// Includes minimum spacing between touch targets to prevent
  /// accidental activation.
  static Widget withSpacing({
    required Widget child,
    required VoidCallback? onTap,
    String? semanticLabel,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? 
          const EdgeInsets.all(NWDimensions.touchTargetSpacing),
      child: ensureMinimumTouchTarget(
        child: child,
        onTap: onTap,
        semanticLabel: semanticLabel,
      ),
    );
  }
  
  /// Validates if a size meets touch target requirements
  static bool meetsMinimumSize(Size size) {
    return size.width >= NWDimensions.minTouchTarget && 
           size.height >= NWDimensions.minTouchTarget;
  }
  
  AccessibleTouchTargets._();
}