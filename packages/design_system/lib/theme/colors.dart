import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import '../accessibility/contrast_checker.dart';

/// Design system color palette
/// 
/// Provides accessible color schemes with WCAG AA compliance.
/// Supports building-specific branding and high contrast mode.
class NWColors {
  // Base brand colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  
  // High contrast alternatives
  static const Color primaryHighContrast = Color(0xFF000000);
  static const Color onPrimaryHighContrast = Color(0xFFFFFFFF);
  static const Color surfaceHighContrast = Color(0xFFFFFFFF);
  static const Color onSurfaceHighContrast = Color(0xFF000000);
  
  /// Checks if high contrast mode is enabled
  static bool get isHighContrastMode {
    return WidgetsBinding.instance.platformDispatcher
        .accessibilityFeatures.highContrast;
  }
  
  /// Creates a color scheme from a seed color for building branding
  /// 
  /// Generates Material 3 color scheme while ensuring accessibility.
  static ColorScheme createBrandedColorScheme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    
    // Validate key color combinations
    _validateColorScheme(scheme);
    
    return scheme;
  }
  
  /// Gets the default light color scheme
  static ColorScheme get lightColorScheme {
    return isHighContrastMode 
        ? _highContrastLightScheme
        : _defaultLightScheme;
  }
  
  /// Gets the default dark color scheme
  static ColorScheme get darkColorScheme {
    return isHighContrastMode 
        ? _highContrastDarkScheme
        : _defaultDarkScheme;
  }
  
  static final ColorScheme _defaultLightScheme = ColorScheme.fromSeed(
    seedColor: primaryBlue,
    brightness: Brightness.light,
  );
  
  static final ColorScheme _defaultDarkScheme = ColorScheme.fromSeed(
    seedColor: primaryBlue,
    brightness: Brightness.dark,
  );
  
  static const ColorScheme _highContrastLightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryHighContrast,
    onPrimary: onPrimaryHighContrast,
    secondary: primaryHighContrast,
    onSecondary: onPrimaryHighContrast,
    error: Color(0xFF000000),
    onError: Color(0xFFFFFFFF),
    surface: surfaceHighContrast,
    onSurface: onSurfaceHighContrast,
    background: surfaceHighContrast,
    onBackground: onSurfaceHighContrast,
  );
  
  static const ColorScheme _highContrastDarkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: onPrimaryHighContrast,
    onPrimary: primaryHighContrast,
    secondary: onPrimaryHighContrast,
    onSecondary: primaryHighContrast,
    error: Color(0xFFFFFFFF),
    onError: Color(0xFF000000),
    surface: primaryHighContrast,
    onSurface: onPrimaryHighContrast,
    background: primaryHighContrast,
    onBackground: onPrimaryHighContrast,
  );
  
  /// Validates a color scheme for accessibility compliance
  static void _validateColorScheme(ColorScheme scheme) {
    // Validate key color combinations in debug mode
    assert(() {
      ContrastChecker.validateContrast(
        scheme.onPrimary,
        scheme.primary,
        debugLabel: 'Primary colors',
      );
      
      ContrastChecker.validateContrast(
        scheme.onSurface,
        scheme.surface,
        debugLabel: 'Surface colors',
      );
      
      ContrastChecker.validateContrast(
        scheme.onError,
        scheme.error,
        debugLabel: 'Error colors',
      );
      
      return true;
    }());
  }
  
  /// Gets capability-specific colors with fallbacks
  static Map<String, Color> get capabilityColors => {
    'messaging': const Color(0xFF2196F3),
    'defects': const Color(0xFFF44336),
    'calendar': const Color(0xFF4CAF50),
    'documents': const Color(0xFF9C27B0),
    'intercom': const Color(0xFFFF9800),
  };
  
  private NWColors._();
}