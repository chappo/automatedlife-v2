import 'package:flutter/material.dart';

/// Design system typography
/// 
/// Provides consistent text styles that scale with accessibility settings.
/// Based on Material 3 typography with custom adjustments.
class NWTypography {
  // Font families
  static const String primaryFontFamily = 'Roboto';
  static const String secondaryFontFamily = 'RobotoMono';
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  /// Creates the text theme for the design system
  /// 
  /// Provides accessible text styles that work well with text scaling.
  static TextTheme createTextTheme({
    required ColorScheme colorScheme,
    String? fontFamily,
  }) {
    final baseTextTheme = Typography.material2021().black;
    final family = fontFamily ?? primaryFontFamily;
    
    return baseTextTheme.copyWith(
      // Display styles
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: family,
        fontWeight: light,
        color: colorScheme.onSurface,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: family,
        fontWeight: light,
        color: colorScheme.onSurface,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: family,
        fontWeight: regular,
        color: colorScheme.onSurface,
      ),
      
      // Headline styles
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: family,
        fontWeight: regular,
        color: colorScheme.onSurface,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: family,
        fontWeight: regular,
        color: colorScheme.onSurface,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: family,
        fontWeight: regular,
        color: colorScheme.onSurface,
      ),
      
      // Title styles
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: family,
        fontWeight: medium,
        color: colorScheme.onSurface,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: family,
        fontWeight: medium,
        color: colorScheme.onSurface,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: family,
        fontWeight: medium,
        color: colorScheme.onSurface,
      ),
      
      // Body styles
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: family,
        fontWeight: regular,
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: family,
        fontWeight: regular,
        color: colorScheme.onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: family,
        fontWeight: regular,
        color: colorScheme.onSurfaceVariant,
      ),
      
      // Label styles
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: family,
        fontWeight: medium,
        color: colorScheme.onSurface,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: family,
        fontWeight: medium,
        color: colorScheme.onSurface,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: family,
        fontWeight: medium,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
  
  /// Custom semantic text styles
  /// 
  /// Provides context-specific text styles for common use cases.
  static class Semantic {
    static TextStyle caption(ColorScheme colorScheme) => TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 12,
      fontWeight: regular,
      color: colorScheme.onSurfaceVariant,
      height: 1.33,
    );
    
    static TextStyle buttonText(ColorScheme colorScheme) => TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 14,
      fontWeight: medium,
      color: colorScheme.onPrimary,
      letterSpacing: 1.25,
    );
    
    static TextStyle errorText(ColorScheme colorScheme) => TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 12,
      fontWeight: regular,
      color: colorScheme.error,
      height: 1.33,
    );
    
    static TextStyle successText(ColorScheme colorScheme) => TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 12,
      fontWeight: regular,
      color: const Color(0xFF4CAF50),
      height: 1.33,
    );
    
    static TextStyle warningText(ColorScheme colorScheme) => TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 12,
      fontWeight: regular,
      color: const Color(0xFFFF9800),
      height: 1.33,
    );
    
    static TextStyle monoText(ColorScheme colorScheme) => TextStyle(
      fontFamily: secondaryFontFamily,
      fontSize: 14,
      fontWeight: regular,
      color: colorScheme.onSurface,
      height: 1.5,
    );
    
    private Semantic._();
  }
  
  /// Text style modifiers
  /// 
  /// Utility functions to modify existing text styles.
  static class Modifiers {
    static TextStyle withColor(TextStyle style, Color color) {
      return style.copyWith(color: color);
    }
    
    static TextStyle withWeight(TextStyle style, FontWeight weight) {
      return style.copyWith(fontWeight: weight);
    }
    
    static TextStyle withSize(TextStyle style, double size) {
      return style.copyWith(fontSize: size);
    }
    
    static TextStyle withOpacity(TextStyle style, double opacity) {
      return style.copyWith(color: style.color?.withOpacity(opacity));
    }
    
    static TextStyle withLetterSpacing(TextStyle style, double spacing) {
      return style.copyWith(letterSpacing: spacing);
    }
    
    private Modifiers._();
  }
  
  private NWTypography._();
}