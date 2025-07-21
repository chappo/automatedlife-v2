import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

/// Service for secure storage of sensitive data using flutter_secure_storage
class SecureStorageService {
  static SecureStorageService? _instance;
  static SecureStorageService get instance => _instance ??= SecureStorageService._internal();
  factory SecureStorageService() => instance;
  SecureStorageService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _selectedBuildingKey = 'selected_building';
  static const String _buildingsKey = 'buildings_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _savedEmailKey = 'saved_email';

  /// Store authentication token
  Future<void> storeAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  /// Retrieve authentication token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Store refresh token
  Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Store user data
  Future<void> storeUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Retrieve user data
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      // If there's an error parsing the user data, remove it
      await deleteUser();
      return null;
    }
  }

  /// Store selected building
  Future<void> storeSelectedBuilding(Building building) async {
    final buildingJson = jsonEncode(building.toJson());
    await _storage.write(key: _selectedBuildingKey, value: buildingJson);
  }

  /// Retrieve selected building
  Future<Building?> getSelectedBuilding() async {
    final buildingJson = await _storage.read(key: _selectedBuildingKey);
    if (buildingJson == null) return null;
    
    try {
      final buildingMap = jsonDecode(buildingJson) as Map<String, dynamic>;
      return Building.fromJson(buildingMap);
    } catch (e) {
      // If there's an error parsing the building data, remove it
      await deleteSelectedBuilding();
      return null;
    }
  }

  /// Store buildings list
  Future<void> storeBuildings(List<Building> buildings) async {
    final buildingsJson = jsonEncode(buildings.map((b) => b.toJson()).toList());
    await _storage.write(key: _buildingsKey, value: buildingsJson);
  }

  /// Retrieve buildings list
  Future<List<Building>?> getBuildings() async {
    final buildingsJson = await _storage.read(key: _buildingsKey);
    if (buildingsJson == null) return null;
    
    try {
      final buildingsList = jsonDecode(buildingsJson) as List<dynamic>;
      return buildingsList
          .map((buildingMap) => Building.fromJson(buildingMap as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing the buildings data, remove it
      await deleteBuildings();
      return null;
    }
  }

  /// Store biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Delete authentication token
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  /// Delete selected building
  Future<void> deleteSelectedBuilding() async {
    await _storage.delete(key: _selectedBuildingKey);
  }

  /// Delete buildings list
  Future<void> deleteBuildings() async {
    await _storage.delete(key: _buildingsKey);
  }

  /// Delete biometric preference
  Future<void> deleteBiometricPreference() async {
    await _storage.delete(key: _biometricEnabledKey);
  }

  /// Store saved email for remember me functionality
  Future<void> saveEmail(String email) async {
    await _storage.write(key: _savedEmailKey, value: email);
  }

  /// Retrieve saved email
  Future<String?> getSavedEmail() async {
    return await _storage.read(key: _savedEmailKey);
  }

  /// Delete saved email
  Future<void> deleteSavedEmail() async {
    await _storage.delete(key: _savedEmailKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if user is logged in (has auth token)
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Get all stored keys (for debugging)
  Future<Map<String, String>> getAllData() async {
    return await _storage.readAll();
  }

  /// Check if storage contains a specific key
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}