import 'package:flutter/material.dart';
import '../accessibility/contrast_checker.dart';

/// Design system color palette
/// 
/// Provides accessible color schemes with WCAG AA compliance.
/// Supports building-specific branding and high contrast mode.
class NWColors {
  // Automated Life brand colors - official green branding
  static const Color primaryGreen = Color(0xFF77B42D);     // AL brand green
  static const Color primaryGreenLight = Color(0xFF8BC34A); // Lighter brand green
  static const Color primaryGreenDark = Color(0xFF558B2F);  // Deeper brand green
  
  // Brand-aligned gradient colors
  static const Color gradientStart = Color(0xFF77B42D);    // AL green gradient start
  static const Color gradientEnd = Color(0xFF558B2F);      // Darker AL green gradient end
  
  // Professional accent colors complementing green
  static const Color accent = Color(0xFF2196F3);           // Professional blue accent
  static const Color accentLight = Color(0xFF64B5F6);      // Light blue
  static const Color accentDark = Color(0xFF1976D2);       // Dark blue
  
  // Enhanced semantic colors - more vibrant and modern
  static const Color success = Color(0xFF10B981);         // Modern green
  static const Color successLight = Color(0xFF34D399);    // Light green
  static const Color warning = Color(0xFFF59E0B);         // Modern amber
  static const Color warningLight = Color(0xFFFBBF24);    // Light amber
  static const Color error = Color(0xFFEF4444);           // Modern red
  static const Color errorLight = Color(0xFFF87171);      // Light red
  static const Color info = Color(0xFF3B82F6);            // Modern blue
  static const Color infoLight = Color(0xFF60A5FA);       // Light blue
  
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
    seedColor: primaryGreen,
    brightness: Brightness.light,
  );
  
  static final ColorScheme _defaultDarkScheme = ColorScheme.fromSeed(
    seedColor: primaryGreen,
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
  
  /// Gets capability-specific colors with modern, vibrant palette
  static Map<String, Color> get capabilityColors => {
    'messaging': const Color(0xFF3B82F6),    // Modern blue
    'defects': const Color(0xFFEF4444),      // Modern red
    'calendar': const Color(0xFF10B981),     // Modern green
    'documents': const Color(0xFF8B5CF6),    // Modern purple
    'intercom': const Color(0xFFF59E0B),     // Modern amber
    'dashboard': const Color(0xFF6366F1),    // Indigo
    'residents': const Color(0xFF06B6D4),    // Cyan
    'maintenance': const Color(0xFFEAB308),  // Yellow
    'security': const Color(0xFFDC2626),     // Strong red
    'amenities': const Color(0xFF059669),    // Emerald
  };
  
  /// Gradient definitions for visual enhancements
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );
  
  NWColors._();
}