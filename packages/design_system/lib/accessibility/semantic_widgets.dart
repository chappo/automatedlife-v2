import 'package:flutter/material.dart';
import 'text_scaling.dart';

/// Semantic widgets for screen reader accessibility
/// 
/// Provides widgets with proper semantic information for
/// assistive technologies like screen readers.
class NWSemanticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? hint;
  final bool enabled;
  
  const NWSemanticButton({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onPressed,
    this.hint,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: enabled && onPressed != null,
      child: child,
    );
  }
}

/// Semantic heading widget with proper hierarchy
class NWSemanticHeading extends StatelessWidget {
  final String text;
  final int level; // 1-6, where 1 is most important
  final TextStyle? style;
  final TextAlign? textAlign;
  
  const NWSemanticHeading({
    super.key,
    required this.text,
    required this.level,
    this.style,
    this.textAlign,
  });
  
  @override
  Widget build(BuildContext context) {
    assert(level >= 1 && level <= 6, 'Heading level must be between 1 and 6');
    
    return Semantics(
      header: true,
      sortKey: OrdinalSortKey(level.toDouble()),
      child: Text(
        text,
        style: AccessibleTextScaling.scaleTextStyle(
          context, 
          style ?? _getHeadingStyle(context, level),
        ),
        textAlign: textAlign,
      ),
    );
  }
  
  TextStyle _getHeadingStyle(BuildContext context, int level) {
    final theme = Theme.of(context);
    switch (level) {
      case 1: return theme.textTheme.headlineLarge!;
      case 2: return theme.textTheme.headlineMedium!;
      case 3: return theme.textTheme.headlineSmall!;
      case 4: return theme.textTheme.titleLarge!;
      case 5: return theme.textTheme.titleMedium!;
      case 6: return theme.textTheme.titleSmall!;
      default: return theme.textTheme.titleMedium!;
    }
  }
}

/// Accessible text widget with automatic scaling
class NWText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final String? semanticsLabel;
  final TextOverflow? overflow;
  
  const NWText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.semanticsLabel,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    final scaledStyle = style != null 
        ? AccessibleTextScaling.scaleTextStyle(context, style!)
        : null;
    
    return Semantics(
      label: semanticsLabel,
      child: Text(
        text,
        style: scaledStyle,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      ),
    );
  }
}

/// Screen reader announcement helper
class NWScreenReaderAnnouncement {
  /// Announces a message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Announces page navigation changes
  static void announcePageChange(BuildContext context, String pageName) {
    announce(context, 'Navigated to $pageName');
  }
  
  /// Announces status changes
  static void announceStatus(BuildContext context, String status) {
    announce(context, status);
  }
  
  /// Announces errors
  static void announceError(BuildContext context, String error) {
    announce(context, 'Error: $error');
  }
  
  /// Announces success messages
  static void announceSuccess(BuildContext context, String message) {
    announce(context, 'Success: $message');
  }
  
  private NWScreenReaderAnnouncement._();
}