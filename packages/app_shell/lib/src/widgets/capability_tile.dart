import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../utils/icon_mapper.dart';

class CapabilityTile extends StatelessWidget {
  final EnabledCapability capability;
  final VoidCallback? onTap;
  final bool showBadge;

  const CapabilityTile({
    super.key,
    required this.capability,
    this.onTap,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final icon = IconMapper.getIconFromApiData(capability.icon);
    final iconColor = _getCapabilityColor();
    final backgroundColor = iconColor.withOpacity(0.05);
    
    return Card(
      elevation: 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(NWSpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(NWSpacing.xSmall),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: iconColor,
                    ),
                  ),
                  if (showBadge && _getBadgeCount() > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: NWColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _getBadgeCount() > 99 ? '99+' : _getBadgeCount().toString(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: NWSpacing.xSmall),
              
              // Title
              Text(
                capability.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: NWColors.neutral800,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Subtitle with dynamic data or status
              if (_hasRelevantData()) ...[
                const SizedBox(height: 2),
                Text(
                  _getSubtitleText(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: NWColors.neutral600,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCapabilityColor() {
    // Use capability-specific colors from design system
    final capabilityColors = NWColors.capabilityColors;
    return capabilityColors[capability.key] ?? 
           capabilityColors[capability.type] ??
           NWColors.primaryGreen;
  }

  int _getBadgeCount() {
    final data = capability.data;
    if (data == null) return 0;

    // Common badge count fields
    int count = 0;
    count += (data['unreadCount'] as int?) ?? 0;
    count += (data['notificationCount'] as int?) ?? 0;
    count += (data['messagesCount'] as int?) ?? 0;
    count += (data['openCount'] as int?) ?? 0;
    count += (data['pendingCount'] as int?) ?? 0;
    count += (data['urgentCount'] as int?) ?? 0;
    count += (data['newCount'] as int?) ?? 0;

    return count;
  }

  bool _hasRelevantData() {
    final data = capability.data;
    if (data == null) return false;

    // Check for display-worthy data
    return data.containsKey('status') ||
           data.containsKey('lastUpdated') ||
           data.containsKey('totalCount') ||
           _getBadgeCount() > 0;
  }

  String _getSubtitleText() {
    final data = capability.data;
    if (data == null) return '';

    // Priority order for subtitle display
    if (data.containsKey('status')) {
      final status = data['status'] as String?;
      if (status != null) return _formatStatus(status);
    }

    final badgeCount = _getBadgeCount();
    if (badgeCount > 0) {
      return _formatCount(badgeCount);
    }

    if (data.containsKey('totalCount')) {
      final total = data['totalCount'] as int?;
      if (total != null && total > 0) {
        return '$total items';
      }
    }

    if (data.containsKey('lastUpdated')) {
      final updated = data['lastUpdated'] as String?;
      if (updated != null) return 'Updated $updated';
    }

    return '';
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return 'Online';
      case 'offline':
        return 'Offline';
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'connected':
        return 'Connected';
      case 'disconnected':
        return 'Disconnected';
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      default:
        return status;
    }
  }

  String _formatCount(int count) {
    if (count == 1) return '1 new';
    if (count > 99) return '99+ new';
    return '$count new';
  }
}