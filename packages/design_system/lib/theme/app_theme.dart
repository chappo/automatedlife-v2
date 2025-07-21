import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import '../tokens/dimensions.dart';
import '../tokens/elevation.dart';

/// Main app theme configuration
/// 
/// Provides Material 3 themes with accessibility support and
/// building-specific branding capabilities.
class NWAppTheme {
  /// Creates the light theme
  static ThemeData light({
    Color? seedColor,
    String? fontFamily,
  }) {
    final colorScheme = seedColor != null
        ? NWColors.createBrandedColorScheme(
            seedColor: seedColor,
            brightness: Brightness.light,
          )
        : NWColors.lightColorScheme;
    
    return _createTheme(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
    );
  }
  
  /// Creates the dark theme
  static ThemeData dark({
    Color? seedColor,
    String? fontFamily,
  }) {
    final colorScheme = seedColor != null
        ? NWColors.createBrandedColorScheme(
            seedColor: seedColor,
            brightness: Brightness.dark,
          )
        : NWColors.darkColorScheme;
    
    return _createTheme(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
    );
  }
  
  /// Creates a theme from building branding configuration
  static ThemeData fromBranding({
    required BuildingBranding branding,
    required Brightness brightness,
  }) {
    final seedColor = Color(
      int.parse(branding.primaryColor.replaceFirst('#', '0xff'))
    );
    
    return brightness == Brightness.light
        ? light(seedColor: seedColor, fontFamily: branding.fontFamily)
        : dark(seedColor: seedColor, fontFamily: branding.fontFamily);
  }
  
  /// Creates the base theme configuration
  static ThemeData _createTheme({
    required ColorScheme colorScheme,
    String? fontFamily,
  }) {
    final textTheme = NWTypography.createTextTheme(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: NWElevation.appBar,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: _getSystemOverlayStyle(colorScheme),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: NWElevation.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: NWElevation.button,
          minimumSize: const Size(0, NWDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          ),
          textStyle: NWTypographySemantic.buttonText(colorScheme),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, NWDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          ),
          textStyle: NWTypographySemantic.buttonText(colorScheme),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, NWDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          ),
          textStyle: NWTypographySemantic.buttonText(colorScheme),
        ),
      ),
      
      // Input field theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // Bottom navigation theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: NWElevation.bottomNav,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: NWElevation.dialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        ),
        backgroundColor: colorScheme.surface,
      ),
      
      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: NWElevation.bottomSheet,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NWDimensions.radiusLarge),
          ),
        ),
        backgroundColor: colorScheme.surface,
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: NWElevation.fab,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
        ),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.5);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
      ),
    );
  }
  
  /// Gets system overlay style based on color scheme
  static SystemUiOverlayStyle _getSystemOverlayStyle(ColorScheme colorScheme) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: colorScheme.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness: colorScheme.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );
  }
  
  /// Creates the light theme with default settings
  static ThemeData get lightTheme => light();
  
  /// Creates the dark theme with default settings  
  static ThemeData get darkTheme => dark();

  NWAppTheme._();
}

/// Building branding configuration
/// 
/// Contains theming information for building-specific customization.
class BuildingBranding {
  final String primaryColor;
  final String? secondaryColor;
  final String? backgroundColor;
  final String? logoUrl;
  final String? iconUrl;
  final String? fontFamily;
  final String? customAppName;
  
  const BuildingBranding({
    required this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.logoUrl,
    this.iconUrl,
    this.fontFamily,
    this.customAppName,
  });
  
  factory BuildingBranding.fromJson(Map<String, dynamic> json) {
    return BuildingBranding(
      primaryColor: json['primary_color'] as String,
      secondaryColor: json['secondary_color'] as String?,
      backgroundColor: json['background_color'] as String?,
      logoUrl: json['logo_url'] as String?,
      iconUrl: json['icon_url'] as String?,
      fontFamily: json['font_family'] as String?,
      customAppName: json['custom_app_name'] as String?,
    );
  }
}