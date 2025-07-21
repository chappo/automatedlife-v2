import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing biometric authentication
class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  static BiometricAuthService get instance => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if biometric authentication is available on the device
  Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if biometric authentication is enabled in user preferences
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Enable or disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      if (enabled) {
        // Test biometric authentication before enabling
        final bool authenticated = await authenticate(
          reason: 'Please verify your identity to enable biometric login',
        );
        if (!authenticated) {
          return false;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      return true;
    } catch (e) {
      debugPrint('Error setting biometric enabled: $e');
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final bool isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: [
          const AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            biometricHint: 'Verify your identity',
            biometricNotRecognized: 'Biometric not recognized, try again',
            biometricRequiredTitle: 'Biometric Required',
            biometricSuccess: 'Biometric authentication successful',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Device Credentials Required',
            deviceCredentialsSetupDescription: 'Please set up device credentials',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Please set up biometric authentication in device settings',
          ),
          const IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Please set up biometric authentication in device settings',
            lockOut: 'Biometric authentication is locked out. Please use device passcode.',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Get a human-readable description of available biometric types
  Future<String> getBiometricDescription() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.isEmpty) {
      return 'No biometric authentication available';
    }

    final descriptions = <String>[];
    
    for (final biometric in biometrics) {
      switch (biometric) {
        case BiometricType.fingerprint:
          descriptions.add('Fingerprint');
          break;
        case BiometricType.face:
          descriptions.add('Face ID');
          break;
        case BiometricType.iris:
          descriptions.add('Iris');
          break;
        case BiometricType.strong:
          descriptions.add('Strong biometric');
          break;
        case BiometricType.weak:
          descriptions.add('Weak biometric');
          break;
      }
    }

    if (descriptions.length == 1) {
      return descriptions.first;
    } else if (descriptions.length == 2) {
      return '${descriptions.first} or ${descriptions.last}';
    } else {
      return '${descriptions.take(descriptions.length - 1).join(', ')}, or ${descriptions.last}';
    }
  }

  /// Check if the user should be prompted to use biometric authentication
  Future<bool> shouldPromptForBiometric() async {
    final isEnabled = await isBiometricEnabled();
    final isAvailable = await this.isAvailable();
    return isEnabled && isAvailable;
  }

  /// Disable biometric authentication (for logout/security purposes)
  Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
    }
  }
}