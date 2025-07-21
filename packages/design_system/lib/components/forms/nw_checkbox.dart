import 'package:flutter/material.dart';
import '../../accessibility/touch_targets.dart';
import '../../tokens/spacing.dart';

/// Accessible checkbox component with proper labeling
/// 
/// Provides consistent styling and accessibility features.
/// Automatically handles touch targets, focus, and semantic labeling.
class NWCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;
  final String? semanticLabel;
  final String? tooltip;
  final CrossAxisAlignment alignment;
  
  const NWCheckbox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.semanticLabel,
    this.tooltip,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget checkbox = InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(NWSpacing.small),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: enabled ? onChanged : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: NWSpacing.small),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: enabled 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with accessibility features
    checkbox = Semantics(
      label: semanticLabel ?? label,
      hint: tooltip,
      checked: value,
      enabled: enabled,
      child: checkbox,
    );

    // Add tooltip if provided
    if (tooltip != null) {
      checkbox = Tooltip(
        message: tooltip!,
        child: checkbox,
      );
    }

    return AccessibleTouchTargets.ensureMinimumTouchTarget(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      child: checkbox,
    );
  }
}