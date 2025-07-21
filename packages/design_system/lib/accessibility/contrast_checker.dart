import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Accessibility helper for color contrast validation
/// 
/// Ensures color combinations meet WCAG 2.1 AA contrast requirements.
class ContrastChecker {
  /// Calculates the contrast ratio between two colors
  /// 
  /// Returns a value between 1 and 21, where higher values
  /// indicate better contrast.
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _getLuminance(foreground);
    final bgLuminance = _getLuminance(background);
    
    final lighter = math.max(fgLuminance, bgLuminance);
    final darker = math.min(fgLuminance, bgLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Checks if colors meet WCAG AA contrast requirements
  /// 
  /// - Normal text: 4.5:1 minimum
  /// - Large text (18pt+): 3:1 minimum
  /// - UI components: 3:1 minimum
  static bool meetsWCAGAA(
    Color foreground, 
    Color background, {
    bool isLargeText = false,
    bool isUIComponent = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    
    if (isUIComponent) return ratio >= 3.0;
    if (isLargeText) return ratio >= 3.0;
    return ratio >= 4.5;
  }
  
  /// Checks if colors meet WCAG AAA contrast requirements
  /// 
  /// - Normal text: 7:1 minimum
  /// - Large text (18pt+): 4.5:1 minimum
  static bool meetsWCAGAAA(
    Color foreground, 
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 4.5 : ratio >= 7.0;
  }
  
  /// Gets the relative luminance of a color
  /// 
  /// Used in contrast ratio calculations according to WCAG guidelines.
  static double _getLuminance(Color color) {
    final r = _getRelativeLuminance(color.red);
    final g = _getRelativeLuminance(color.green);
    final b = _getRelativeLuminance(color.blue);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  /// Calculates relative luminance for a single color component
  static double _getRelativeLuminance(int colorValue) {
    final value = colorValue / 255.0;
    return value <= 0.03928 
        ? value / 12.92 
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }
  
  /// Finds the best contrasting color for a background
  /// 
  /// Returns either black or white, whichever provides better contrast.
  static Color getBestContrastingColor(Color background) {
    final whiteContrast = calculateContrastRatio(Colors.white, background);
    final blackContrast = calculateContrastRatio(Colors.black, background);
    
    return whiteContrast > blackContrast ? Colors.white : Colors.black;
  }
  
  /// Validates color accessibility for development
  /// 
  /// Throws assertion error in debug mode if contrast is insufficient.
  static void validateContrast(
    Color foreground,
    Color background, {
    String? debugLabel,
    bool isLargeText = false,
    bool isUIComponent = false,
  }) {
    assert(() {
      final meetsAA = meetsWCAGAA(
        foreground, 
        background,
        isLargeText: isLargeText,
        isUIComponent: isUIComponent,
      );
      
      if (!meetsAA) {
        final ratio = calculateContrastRatio(foreground, background);
        final required = isUIComponent || isLargeText ? '3:1' : '4.5:1';
        
        throw FlutterError(
          'Color contrast violation${debugLabel != null ? ' in $debugLabel' : ''}:\n'
          'Contrast ratio: ${ratio.toStringAsFixed(2)}:1\n'
          'Required: $required\n'
          'Foreground: $foreground\n'
          'Background: $background'
        );
      }
      return true;
    }());
  }
  
  private ContrastChecker._();
}