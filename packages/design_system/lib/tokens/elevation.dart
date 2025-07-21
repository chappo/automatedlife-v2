/// Design system elevation tokens
/// 
/// Provides consistent elevation values for components.
/// Based on Material Design 3 elevation system.
class NWElevation {
  static const double level0 = 0.0;   // Surface
  static const double level1 = 1.0;   // Cards, chips
  static const double level2 = 3.0;   // FAB (resting), buttons (pressed)
  static const double level3 = 6.0;   // FAB (pressed), app bar
  static const double level4 = 8.0;   // Bottom nav, bottom sheets
  static const double level5 = 12.0;  // Dialogs, modals
  
  // Component-specific elevations
  static const double card = level1;
  static const double button = level0;
  static const double buttonPressed = level2;
  static const double appBar = level0; // Material 3 uses surface tint instead
  static const double bottomNav = level3;
  static const double dialog = level5;
  static const double bottomSheet = level4;
  static const double fab = level2;
  static const double fabPressed = level3;
  
  private NWElevation._();
}