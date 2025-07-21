import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences and app settings
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  static PreferencesService get instance => _instance;
  PreferencesService._internal();

  // Notifier for preference changes
  final ValueNotifier<Map<String, dynamic>> preferencesNotifier = ValueNotifier({
    'dark_mode_enabled': false,
    'text_size': 1.0,
    'notifications_enabled': true,
  });

  // Cache SharedPreferences instance for better performance
  SharedPreferences? _prefs;

  /// Initialize SharedPreferences - call this early in app lifecycle
  Future<void> initialize() async {
    try {
      debugPrint('PreferencesService: Initializing SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      debugPrint('PreferencesService: SharedPreferences initialized successfully');
    } catch (e) {
      debugPrint('PreferencesService: Failed to initialize SharedPreferences: $e');
      _prefs = null;
    }
  }

  /// Get SharedPreferences instance with fallback
  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) {
      return _prefs;
    }
    
    try {
      debugPrint('PreferencesService: Getting fresh SharedPreferences instance...');
      _prefs = await SharedPreferences.getInstance();
      return _prefs;
    } catch (e) {
      debugPrint('PreferencesService: Failed to get SharedPreferences: $e');
      return null;
    }
  }

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _darkModeEnabledKey = 'dark_mode_enabled';
  static const String _textSizeKey = 'text_size';

  /// Get notifications enabled preference
  Future<bool> getNotificationsEnabled() async {
    try {
      debugPrint('PreferencesService: Getting notifications preference...');
      final prefs = await _getPrefs();
      if (prefs == null) {
        debugPrint('PreferencesService: SharedPreferences not available, returning default');
        return true;
      }
      final value = prefs.getBool(_notificationsEnabledKey) ?? true;
      debugPrint('PreferencesService: Retrieved notifications = $value');
      return value;
    } catch (e) {
      debugPrint('PreferencesService: Error getting notifications preference: $e');
      return true; // Default fallback
    }
  }

  /// Set notifications enabled preference
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      debugPrint('PreferencesService: Setting notifications preference to $enabled...');
      final prefs = await _getPrefs();
      if (prefs == null) {
        debugPrint('PreferencesService: SharedPreferences not available, cannot save');
        return false;
      }
      final result = await prefs.setBool(_notificationsEnabledKey, enabled);
      debugPrint('PreferencesService: Notifications preference saved: $enabled, result: $result');
      
      // Verify the save by reading it back
      final verification = prefs.getBool(_notificationsEnabledKey);
      debugPrint('PreferencesService: Verification read: $verification');
      
      return result;
    } catch (e) {
      debugPrint('PreferencesService: Error saving notifications preference: $e');
      return false;
    }
  }

  /// Get dark mode enabled preference
  Future<bool> getDarkModeEnabled() async {
    try {
      debugPrint('PreferencesService: Getting dark mode preference...');
      final prefs = await _getPrefs();
      if (prefs == null) {
        debugPrint('PreferencesService: SharedPreferences not available, returning default');
        return false;
      }
      final value = prefs.getBool(_darkModeEnabledKey) ?? false;
      debugPrint('PreferencesService: Retrieved dark mode = $value');
      return value;
    } catch (e) {
      debugPrint('PreferencesService: Error getting dark mode preference: $e');
      return false; // Default fallback
    }
  }

  /// Set dark mode enabled preference
  Future<bool> setDarkModeEnabled(bool enabled) async {
    try {
      debugPrint('PreferencesService: Setting dark mode preference to $enabled...');
      final prefs = await _getPrefs();
      if (prefs == null) {
        debugPrint('PreferencesService: SharedPreferences not available, cannot save');
        return false;
      }
      final result = await prefs.setBool(_darkModeEnabledKey, enabled);
      debugPrint('PreferencesService: Dark mode preference saved: $enabled, result: $result');
      
      // Update the notifier
      final currentPrefs = Map<String, dynamic>.from(preferencesNotifier.value);
      currentPrefs['dark_mode_enabled'] = enabled;
      preferencesNotifier.value = currentPrefs;
      
      // Verify the save by reading it back
      final verification = prefs.getBool(_darkModeEnabledKey);
      debugPrint('PreferencesService: Dark mode verification read: $verification');
      
      return result;
    } catch (e) {
      debugPrint('PreferencesService: Error saving dark mode preference: $e');
      return false;
    }
  }

  /// Get text size preference
  Future<double> getTextSize() async {
    try {
      debugPrint('PreferencesService: Getting text size preference...');
      final prefs = await _getPrefs();
      if (prefs == null) {
        debugPrint('PreferencesService: SharedPreferences not available, returning default');
        return 1.0;
      }
      final value = prefs.getDouble(_textSizeKey) ?? 1.0;
      debugPrint('PreferencesService: Retrieved text size = $value');
      return value;
    } catch (e) {
      debugPrint('PreferencesService: Error getting text size preference: $e');
      return 1.0; // Default fallback
    }
  }

  /// Set text size preference
  Future<bool> setTextSize(double size) async {
    try {
      debugPrint('PreferencesService: Setting text size preference to $size...');
      final prefs = await _getPrefs();
      if (prefs == null) {
        debugPrint('PreferencesService: SharedPreferences not available, cannot save');
        return false;
      }
      final result = await prefs.setDouble(_textSizeKey, size);
      debugPrint('PreferencesService: Text size preference saved: $size, result: $result');
      
      // Update the notifier
      final currentPrefs = Map<String, dynamic>.from(preferencesNotifier.value);
      currentPrefs['text_size'] = size;
      preferencesNotifier.value = currentPrefs;
      
      // Verify the save by reading it back
      final verification = prefs.getDouble(_textSizeKey);
      debugPrint('PreferencesService: Text size verification read: $verification');
      
      return result;
    } catch (e) {
      debugPrint('PreferencesService: Error saving text size preference: $e');
      return false;
    }
  }

  /// Get all preferences at once for efficiency
  Future<Map<String, dynamic>> getAllPreferences() async {
    try {
      debugPrint('PreferencesService: Getting all preferences...');
      final prefs = await _getPrefs();
      if (prefs == null) {
        debugPrint('PreferencesService: SharedPreferences not available, returning defaults');
        return {
          'notifications_enabled': true,
          'dark_mode_enabled': false,
          'text_size': 1.0,
        };
      }
      
      final result = {
        'notifications_enabled': prefs.getBool(_notificationsEnabledKey) ?? true,
        'dark_mode_enabled': prefs.getBool(_darkModeEnabledKey) ?? false,
        'text_size': prefs.getDouble(_textSizeKey) ?? 1.0,
      };
      
      debugPrint('PreferencesService: Retrieved all preferences: $result');
      return result;
    } catch (e) {
      debugPrint('PreferencesService: Error getting all preferences: $e');
      return {
        'notifications_enabled': true,
        'dark_mode_enabled': false,
        'text_size': 1.0,
      };
    }
  }

  /// Set multiple preferences at once for efficiency
  Future<bool> setMultiplePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final results = <bool>[];
      
      if (preferences.containsKey('notifications_enabled')) {
        results.add(await prefs.setBool(_notificationsEnabledKey, preferences['notifications_enabled']));
      }
      
      if (preferences.containsKey('dark_mode_enabled')) {
        results.add(await prefs.setBool(_darkModeEnabledKey, preferences['dark_mode_enabled']));
      }
      
      if (preferences.containsKey('text_size')) {
        results.add(await prefs.setDouble(_textSizeKey, preferences['text_size']));
      }
      
      // Return true if all operations succeeded
      return results.every((result) => result == true);
    } catch (e) {
      return false;
    }
  }

  /// Clear all preferences (useful for logout or reset)
  Future<bool> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final results = await Future.wait([
        prefs.remove(_notificationsEnabledKey),
        prefs.remove(_darkModeEnabledKey),
        prefs.remove(_textSizeKey),
      ]);
      return results.every((result) => result == true);
    } catch (e) {
      return false;
    }
  }

  /// Text size helpers for UI
  static final Map<double, String> textSizeLabels = {
    0.8: 'Small',
    1.0: 'Medium',
    1.2: 'Large',
  };

  static String getTextSizeLabel(double size) {
    return textSizeLabels[size] ?? 'Medium';
  }

  static List<double> getAvailableTextSizes() {
    return textSizeLabels.keys.toList()..sort();
  }
}