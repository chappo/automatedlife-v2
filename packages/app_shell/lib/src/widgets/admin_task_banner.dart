import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AdminTaskBanner extends StatelessWidget {
  final int taskCount;
  final VoidCallback? onTap;
  final bool showDismiss;

  const AdminTaskBanner({
    super.key,
    required this.taskCount,
    this.onTap,
    this.showDismiss = false,
  });

  @override
  Widget build(BuildContext context) {
    if (taskCount <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      color: _getBannerColor(colorScheme),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(NWSpacing.small),
          child: Row(
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(colorScheme),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getTaskIcon(),
                  color: _getIconColor(colorScheme),
                  size: 20,
                ),
              ),
              const SizedBox(width: NWSpacing.small),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(colorScheme),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSubtitle(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getSubtitleColor(colorScheme),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: _getSubtitleColor(colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBannerColor(ColorScheme colorScheme) {
    if (taskCount >= 5) {
      // High priority - red tint
      return NWColors.errorLight.withOpacity(0.15);
    } else if (taskCount >= 2) {
      // Medium priority - orange tint
      return NWColors.warningLight.withOpacity(0.15);
    } else {
      // Low priority - info tint
      return NWColors.infoLight.withOpacity(0.15);
    }
  }

  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    if (taskCount >= 5) {
      return NWColors.error;
    } else if (taskCount >= 2) {
      return NWColors.warning;
    } else {
      return NWColors.info;
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    if (taskCount >= 5) {
      return colorScheme.onError;
    } else if (taskCount >= 2) {
      return Colors.white;
    } else {
      return colorScheme.onPrimary;
    }
  }

  Color _getTextColor(ColorScheme colorScheme) {
    if (taskCount >= 5) {
      return colorScheme.onErrorContainer;
    } else if (taskCount >= 2) {
      return Colors.orange.shade900;
    } else {
      return colorScheme.onPrimaryContainer;
    }
  }

  Color _getSubtitleColor(ColorScheme colorScheme) {
    return _getTextColor(colorScheme).withOpacity(0.7);
  }

  IconData _getTaskIcon() {
    if (taskCount >= 5) {
      return Icons.priority_high;
    } else if (taskCount >= 2) {
      return Icons.notification_important;
    } else {
      return Icons.task_alt;
    }
  }

  String _getTitle() {
    if (taskCount >= 5) {
      return 'Urgent: $taskCount tasks require attention';
    } else if (taskCount >= 2) {
      return '$taskCount tasks need approval';
    } else {
      return taskCount == 1 ? '1 task awaiting approval' : '$taskCount tasks awaiting approval';
    }
  }

  String _getSubtitle() {
    if (taskCount >= 5) {
      return 'High priority items need immediate action';
    } else if (taskCount >= 2) {
      return 'Tap to review and approve pending items';
    } else {
      return 'Tap to review and approve';
    }
  }
}