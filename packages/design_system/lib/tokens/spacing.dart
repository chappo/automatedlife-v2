/// Design system spacing tokens
/// 
/// Provides consistent spacing values throughout the app.
/// Based on 8px grid system for optimal visual rhythm.
class NWSpacing {
  static const double none = 0.0;
  static const double xSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xLarge = 32.0;
  static const double xxLarge = 48.0;
  static const double xxxLarge = 64.0;
  
  // Semantic spacing
  static const double contentPadding = medium;
  static const double sectionSpacing = large;
  static const double cardPadding = medium;
  static const double buttonPadding = medium;
  
  // Grid spacing
  static const double gridGap = medium;
  static const double listItemSpacing = small;
  
  private NWSpacing._();
}