import 'package:flutter/material.dart';

/// Accessibility helper for text scaling
/// 
/// Ensures text scales properly with system accessibility settings
/// while maintaining layout integrity.
class AccessibleTextScaling {
  static const double minScaleFactor = 1.0;
  static const double maxScaleFactor = 2.0;
  
  /// Gets the clamped text scale factor from MediaQuery
  /// 
  /// Limits scaling to prevent layout breakage while supporting
  /// accessibility needs up to 200% scaling.
  static double getClampedTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.textScaler.scale(1.0).clamp(minScaleFactor, maxScaleFactor);
  }
  
  /// Scales a TextStyle based on accessibility settings
  /// 
  /// Adjusts font size and line height to maintain readability
  /// at different scale factors.
  static TextStyle scaleTextStyle(BuildContext context, TextStyle style) {
    final scaleFactor = getClampedTextScaleFactor(context);
    return style.copyWith(
      fontSize: (style.fontSize ?? 14.0) * scaleFactor,
      height: style.height != null ? style.height! / scaleFactor : null,
    );
  }
  
  /// Checks if large text accessibility setting is enabled
  static bool isLargeTextEnabled(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0) > 1.3;
  }
  
  /// Gets appropriate line height for scaled text
  static double getScaledLineHeight(BuildContext context, double baseHeight) {
    final scaleFactor = getClampedTextScaleFactor(context);
    return baseHeight / scaleFactor;
  }
  
  AccessibleTextScaling._();
}