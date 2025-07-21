import 'package:flutter/material.dart';

/// Smart icon mapper that pulls directly from Material Design Icons and caches on first access
class IconMapper {
  /// Cache for resolved icons to improve performance after first lookup
  static final Map<String, IconData> _iconCache = <String, IconData>{};
  
  /// Cache for failed lookups to avoid repeated attempts
  static final Set<String> _failedLookups = <String>{};
  
  /// Common icon aliases for better API compatibility
  static const Map<String, String> _iconAliases = {
    // Communication & Social
    'messaging': 'message',
    'chat': 'chat_bubble',
    'forum': 'forum',
    'announcement': 'announcement',
    'notifications': 'notifications',
    
    // Building & Maintenance
    'defects': 'build',
    'maintenance': 'handyman',
    'construction': 'construction',
    'engineering': 'engineering',
    'repair': 'build_circle',
    
    // Documents & Files
    'documents': 'description',
    'file_copy': 'file_copy',
    'upload_file': 'upload_file',
    'download': 'download',
    
    // Calendar & Booking
    'calendar': 'calendar_today',
    'schedule': 'schedule',
    'book_online': 'book_online',
    'booking': 'event_available',
    
    // Intercom & Communication
    'voip': 'dialer_sip',
    'intercom': 'record_voice_over',
    '2n_intercom': 'video_call',
    
    // Smart Home & IoT
    'smart_home': 'home_work',
    'wiser': 'thermostat',
    'clipsal_wiser': 'thermostat',
    'mitsubishi_aircon': 'ac_unit',
    'mitsubishi_air_con': 'ac_unit',
    
    // Security & Access
    'key': 'vpn_key',
    '2n_access': 'lock_open',
    
    // External Apps & Integration
    'open_in_new': 'open_in_new',
    'integration_instructions': 'integration_instructions',
    
    // Utilities
    'local_gas_station': 'local_gas_station',
    'network_check': 'network_check',
    
    // Business & Management
    'admin_panel_settings': 'admin_panel_settings',
    
    // Navigation & Movement
    'expand_more': 'expand_more',
    'expand_less': 'expand_less',
  };

  /// Convert API icon name to Flutter IconData by pulling directly from Material Icons
  /// Caches results for optimal performance
  static IconData getIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.extension;
    }
    
    final cleanIconName = iconName.toLowerCase().trim();
    
    // 1. Check cache first (fastest)
    if (_iconCache.containsKey(cleanIconName)) {
      return _iconCache[cleanIconName]!;
    }
    
    // 2. Check failed lookups to avoid retrying
    if (_failedLookups.contains(cleanIconName)) {
      return Icons.extension;
    }
    
    // 3. Try to resolve the icon from Material Design library
    IconData? resolvedIcon = _resolveIconFromMaterial(cleanIconName);
    
    // 4. Cache the result (success or failure)
    if (resolvedIcon != null) {
      _iconCache[cleanIconName] = resolvedIcon;
      return resolvedIcon;
    } else {
      _failedLookups.add(cleanIconName);
      _iconCache[cleanIconName] = Icons.extension;
      return Icons.extension;
    }
  }
  
  /// Resolve icon directly from Material Design Icons library
  static IconData? _resolveIconFromMaterial(String iconName) {
    // 1. Try alias mapping first
    final targetIconName = _iconAliases[iconName] ?? iconName;
    
    // 2. Try direct property lookup on Icons class using common patterns
    final variations = _generateIconVariations(targetIconName);
    
    for (final variation in variations) {
      final camelCaseProperty = _snakeToCamelCase(variation);
      final icon = _getIconProperty(camelCaseProperty);
      if (icon != null) {
        return icon;
      }
    }
    
    return null;
  }
  
  /// Get icon property from Icons class using string-based lookup
  static IconData? _getIconProperty(String propertyName) {
    // Use a comprehensive map of Material Design Icons
    // This is more reliable than reflection and covers all common icons
    final materialIcons = _getMaterialIconsMap();
    return materialIcons[propertyName];
  }
  
  /// Comprehensive Material Design Icons map for direct property lookup
  /// This covers all commonly used icons and can be easily extended
  static Map<String, IconData> _getMaterialIconsMap() {
    return {
      // Core Material Icons from API examples
      'message': Icons.message,
      'build': Icons.build,
      'event': Icons.event,
      'phone': Icons.phone,
      'description': Icons.description,
      'personAdd': Icons.person_add,
      'lockOpen': Icons.lock_open,
      'acUnit': Icons.ac_unit,
      'electricBolt': Icons.electric_bolt,
      'lightbulb': Icons.lightbulb,
      
      // Extended Material Design icon set (commonly used)
      'accessAlarm': Icons.access_alarm,
      'accessTime': Icons.access_time,
      'accessibility': Icons.accessibility,
      'accessible': Icons.accessible,
      'account': Icons.account_circle,
      'accountBox': Icons.account_box,
      'accountCircle': Icons.account_circle,
      'add': Icons.add,
      'addCircle': Icons.add_circle,
      'addCircleOutline': Icons.add_circle_outline,
      'adminPanelSettings': Icons.admin_panel_settings,
      'alarm': Icons.alarm,
      'announcement': Icons.announcement,
      'apps': Icons.apps,
      'arrowBack': Icons.arrow_back,
      'arrowForward': Icons.arrow_forward,
      'arrowUpward': Icons.arrow_upward,
      'arrowDownward': Icons.arrow_downward,
      'badge': Icons.badge,
      'bookOnline': Icons.book_online,
      'business': Icons.business,
      'calendar': Icons.calendar_today,
      'calendarToday': Icons.calendar_today,
      'call': Icons.call,
      'cameraAlt': Icons.camera_alt,
      'cancel': Icons.cancel,
      'chat': Icons.chat,
      'chatBubble': Icons.chat_bubble,
      'check': Icons.check,
      'checkCircle': Icons.check_circle,
      'close': Icons.close,
      'cloud': Icons.cloud,
      'construction': Icons.construction,
      'dashboard': Icons.dashboard,
      'delete': Icons.delete,
      'dialerSip': Icons.dialer_sip,
      'download': Icons.download,
      'edit': Icons.edit,
      'email': Icons.email,
      'engineering': Icons.engineering,
      'error': Icons.error,
      'eventAvailable': Icons.event_available,
      'expandLess': Icons.expand_less,
      'expandMore': Icons.expand_more,
      'extension': Icons.extension,
      'favorite': Icons.favorite,
      'fileCopy': Icons.file_copy,
      'fingerprint': Icons.fingerprint,
      'folder': Icons.folder,
      'forum': Icons.forum,
      'group': Icons.group,
      'handyman': Icons.handyman,
      'help': Icons.help,
      'home': Icons.home,
      'homeWork': Icons.home_work,
      'info': Icons.info,
      'infoOutline': Icons.info_outline,
      'integrationInstructions': Icons.integration_instructions,
      'launch': Icons.launch,
      'link': Icons.link,
      'localGasStation': Icons.local_gas_station,
      'lock': Icons.lock,
      'logout': Icons.logout,
      'menu': Icons.menu,
      'moreVert': Icons.more_vert,
      'networkCheck': Icons.network_check,
      'notifications': Icons.notifications,
      'openInNew': Icons.open_in_new,
      'people': Icons.people,
      'person': Icons.person,
      'power': Icons.power,
      'recordVoiceOver': Icons.record_voice_over,
      'save': Icons.save,
      'schedule': Icons.schedule,
      'search': Icons.search,
      'security': Icons.security,
      'sensors': Icons.sensors,
      'settings': Icons.settings,
      'thermostat': Icons.thermostat,
      'upload': Icons.upload,
      'uploadFile': Icons.upload_file,
      'videoCall': Icons.video_call,
      'vpnKey': Icons.vpn_key,
      'warning': Icons.warning,
      'waterDrop': Icons.water_drop,
      'wifi': Icons.wifi,
      
      // Additional icons that are likely to be used by APIs
      'airplaneTicket': Icons.airplane_ticket,
      'airportShuttle': Icons.airport_shuttle,
      'analytics': Icons.analytics,
      'apartment': Icons.apartment,
      'api': Icons.api,
      'architecture': Icons.architecture,
      'autorenew': Icons.autorenew,
      'backup': Icons.backup,
      'batteryFull': Icons.battery_full,
      'bluetooth': Icons.bluetooth,
      'brightnessAuto': Icons.brightness_auto,
      'buildCircle': Icons.build_circle,
      'category': Icons.category,
      'cellTower': Icons.cell_tower,
      'centralHeating': Icons.thermostat,
      'chargingStation': Icons.ev_station,
      'circleNotifications': Icons.circle_notifications,
      'cleaningServices': Icons.cleaning_services,
      'climate': Icons.thermostat,
      'computerIcon': Icons.computer,
      'contactSupport': Icons.contact_support,
      'deviceHub': Icons.device_hub,
      'devices': Icons.devices,
      'doorbell': Icons.doorbell,
      'electrical': Icons.electrical_services,
      'elevator': Icons.elevator,
      'energy': Icons.bolt,
      'facilities': Icons.business,
      'fitness': Icons.fitness_center,
      'garage': Icons.garage,
      'health': Icons.health_and_safety,
      'heating': Icons.thermostat,
      'hvac': Icons.air,
      'iot': Icons.sensors,
      'key': Icons.key,
      'lights': Icons.lightbulb_outline,
      'location': Icons.location_on,
      'maintenance': Icons.engineering,
      'monitoring': Icons.monitor,
      'motion': Icons.sensors,
      'parking': Icons.local_parking,
      'pool': Icons.pool,
      'recycling': Icons.recycling,
      'roofing': Icons.roofing,
      'safety': Icons.safety_check,
      'smartHome': Icons.home_work,
      'solar': Icons.solar_power,
      'sprinkler': Icons.water_drop,
      'utilities': Icons.construction,
      'ventilation': Icons.air,
      'water': Icons.water,
      'windows': Icons.window,
    };
  }
  
  /// Generate common variations of an icon name
  static List<String> _generateIconVariations(String iconName) {
    final variations = <String>[];
    
    // Original name
    variations.add(iconName);
    
    // Remove common suffixes
    final withoutSuffixes = iconName
        .replaceAll('_icon', '')
        .replaceAll('_outlined', '')
        .replaceAll('_filled', '')
        .replaceAll('_rounded', '')
        .replaceAll('_sharp', '');
    variations.add(withoutSuffixes);
    
    // Try with common suffixes
    variations.addAll([
      '${withoutSuffixes}_outlined',
      '${withoutSuffixes}_rounded',
      '${withoutSuffixes}_sharp',
    ]);
    
    // Try without underscores
    variations.add(iconName.replaceAll('_', ''));
    
    // Try with different common patterns
    if (iconName.contains('_')) {
      variations.add(iconName.split('_').first); // First part only
      variations.add(iconName.split('_').last);  // Last part only
    }
    
    return variations.toSet().toList(); // Remove duplicates
  }
  
  /// Convert snake_case to camelCase
  static String _snakeToCamelCase(String snakeCase) {
    final parts = snakeCase.split('_');
    if (parts.length == 1) return parts.first;
    
    final camelCase = parts.first + 
        parts.skip(1).map((part) => 
          part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1)
        ).join('');
    
    return camelCase;
  }

  /// Get icon from API capability icon object
  /// Handles the full icon object from API: {"name": "message", "color": "#2196F3", "backgroundColor": "#E3F2FD"}
  static IconData getIconFromApiData(Map<String, dynamic>? iconData) {
    if (iconData == null) {
      return Icons.extension;
    }
    
    final iconName = iconData['name'] as String?;
    return getIcon(iconName);
  }

  /// Get icon color from API capability icon object
  static Color? getIconColor(Map<String, dynamic>? iconData) {
    if (iconData == null) return null;
    
    final colorString = iconData['color'] as String?;
    if (colorString == null) return null;
    
    try {
      // Remove # if present and parse hex color
      final cleanColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$cleanColor', radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Get background color from API capability icon object
  static Color? getBackgroundColor(Map<String, dynamic>? iconData) {
    if (iconData == null) return null;
    
    final colorString = iconData['backgroundColor'] as String?;
    if (colorString == null) return null;
    
    try {
      // Remove # if present and parse hex color
      final cleanColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$cleanColor', radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Check if an icon name can be resolved (tries without caching)
  static bool hasIcon(String iconName) {
    if (iconName.isEmpty) return false;
    
    final cleanIconName = iconName.toLowerCase().trim();
    
    // Check cache first
    if (_iconCache.containsKey(cleanIconName)) {
      return _iconCache[cleanIconName] != Icons.extension;
    }
    
    // Try to resolve the icon
    final resolvedIcon = getIcon(iconName);
    return resolvedIcon != Icons.extension;
  }

  /// Get all cached icon names (grows as icons are resolved)
  static List<String> getCachedIconNames() {
    return _iconCache.keys.toList();
  }
  
  /// Clear the icon cache (useful for testing or memory management)
  static void clearCache() {
    _iconCache.clear();
    _failedLookups.clear();
  }
  
  /// Get cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    final materialIconsCount = _getMaterialIconsMap().length;
    return {
      'cachedIcons': _iconCache.length,
      'failedLookups': _failedLookups.length,
      'aliases': _iconAliases.length,
      'availableMaterialIcons': materialIconsCount,
      'cacheHitRate': _iconCache.isEmpty ? 0.0 : 
          (_iconCache.length - _failedLookups.length) / _iconCache.length,
    };
  }
  
  /// Warm up the cache by pre-loading common icons
  static void warmUpCache() {
    final commonIcons = [
      'message', 'build', 'event', 'phone', 'description',
      'person_add', 'lock_open', 'ac_unit', 'electric_bolt', 'lightbulb'
    ];
    
    for (final iconName in commonIcons) {
      getIcon(iconName); // This will cache the result
    }
  }
}