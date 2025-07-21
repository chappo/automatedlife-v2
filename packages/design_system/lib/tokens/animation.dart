/// Design system animation tokens
/// 
/// Provides consistent animation values for smooth interactions.
class NWAnimation {
  // Duration tokens
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 500);
  
  // Component-specific durations
  static const Duration buttonPress = fast;
  static const Duration cardHover = fast;
  static const Duration pageTransition = normal;
  static const Duration dialogFade = normal;
  static const Duration bottomSheetSlide = slow;
  static const Duration loading = Duration(milliseconds: 1200);
  
  // Curve tokens
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  
  // Component-specific curves
  static const Curve buttonCurve = easeOut;
  static const Curve pageCurve = easeInOut;
  static const Curve dialogCurve = easeOut;
  static const Curve bottomSheetCurve = easeOut;
  
  private NWAnimation._();
}