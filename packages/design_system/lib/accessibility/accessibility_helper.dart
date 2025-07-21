import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helper utilities
/// 
/// Provides utilities for checking accessibility settings and
/// adapting the UI accordingly.
class AccessibilityHelper {
  /// Checks if reduce motion is enabled
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  /// Checks if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }
  
  /// Checks if high contrast is enabled
  static bool isHighContrastEnabled() {
    return WidgetsBinding.instance.platformDispatcher
        .accessibilityFeatures.highContrast;
  }
  
  /// Checks if screen reader is active
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }
  
  /// Gets the current text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }
  
  /// Checks if large text is enabled (> 130% scaling)
  static bool isLargeTextEnabled(BuildContext context) {
    return getTextScaleFactor(context) > 1.3;
  }
  
  /// Provides haptic feedback if enabled
  static void provideFeedback() {
    HapticFeedback.lightImpact();
  }
  
  /// Gets appropriate animation duration based on accessibility settings
  static Duration getAnimationDuration(
    BuildContext context,
    Duration defaultDuration,
  ) {
    return isReduceMotionEnabled(context) 
        ? Duration.zero 
        : defaultDuration;
  }
  
  /// Gets appropriate curve based on accessibility settings
  static Curve getAnimationCurve(BuildContext context, Curve defaultCurve) {
    return isReduceMotionEnabled(context) 
        ? Curves.linear 
        : defaultCurve;
  }
  
  /// Creates an accessibility-aware AnimationController
  static AnimationController createController({
    required TickerProvider vsync,
    required Duration duration,
    BuildContext? context,
  }) {
    final effectiveDuration = context != null
        ? getAnimationDuration(context, duration)
        : duration;
    
    return AnimationController(
      duration: effectiveDuration,
      vsync: vsync,
    );
  }
  
  /// Wraps a widget with appropriate semantics for lists
  static Widget wrapWithListSemantics({
    required Widget child,
    required int index,
    required int totalCount,
    String? itemLabel,
  }) {
    return Semantics(
      label: itemLabel,
      sortKey: OrdinalSortKey(index.toDouble()),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        child: child,
      ),
    );
  }
  
  /// Creates semantic information for form fields
  static Widget wrapWithFormFieldSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? error,
    bool required = false,
  }) {
    return Semantics(
      label: label + (required ? ', required' : ''),
      hint: hint,
      textField: true,
      child: error != null
          ? Semantics(
              liveRegion: true,
              child: child,
            )
          : child,
    );
  }
  
  /// Wraps navigation elements with proper semantics
  static Widget wrapWithNavigationSemantics({
    required Widget child,
    required String label,
    bool isSelected = false,
    int? index,
    int? totalCount,
  }) {
    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      sortKey: index != null ? OrdinalSortKey(index.toDouble()) : null,
      child: child,
    );
  }
  
  AccessibilityHelper._();
}