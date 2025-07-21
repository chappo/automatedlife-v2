import 'dart:async';
import 'package:dio/dio.dart';
import '../models/models.dart';
import '../storage/secure_storage_service.dart';
import '../utils/exceptions.dart';

/// Authentication service for Laravel Sanctum token management
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._internal();
  factory AuthService() => instance;
  AuthService._internal();

  final SecureStorageService _storage = SecureStorageService();
  late Dio _dio;
  
  // Stream controllers for auth state changes
  final _authStateController = StreamController<AuthState>.broadcast();
  final _userController = StreamController<User?>.broadcast();
  final _selectedBuildingController = StreamController<Building?>.broadcast();

  /// Stream of authentication state changes
  Stream<AuthState> get authStateStream => _authStateController.stream;
  
  /// Stream of user changes
  Stream<User?> get userStream => _userController.stream;
  
  /// Stream of selected building changes
  Stream<Building?> get selectedBuildingStream => _selectedBuildingController.stream;

  /// Initialize the auth service with Dio instance
  void initialize(Dio dio) {
    _dio = dio;
  }

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
    String? buildingSubdomain,
  }) async {
    try {
      // Determine the API endpoint
      String baseUrl = buildingSubdomain != null && buildingSubdomain.isNotEmpty
          ? 'https://$buildingSubdomain.automatedlife.io/api/v1'
          : 'https://api.automatedlife.io/api/v1';

      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      // Extract tokens and user data
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String?;
      final userData = data['user'] as Map<String, dynamic>;
      final buildingsData = data['buildings'] as List<dynamic>?;

      // Parse user and buildings
      final user = User.fromJson(userData);
      final buildings = buildingsData
          ?.map((buildingData) => Building.fromJson(buildingData as Map<String, dynamic>))
          .toList();

      // Store tokens and user data
      await _storage.storeAuthToken(accessToken);
      if (refreshToken != null) {
        await _storage.storeRefreshToken(refreshToken);
      }
      await _storage.storeUser(user);
      if (buildings != null) {
        await _storage.storeBuildings(buildings);
        // Auto-select first building if available
        if (buildings.isNotEmpty) {
          await _storage.storeSelectedBuilding(buildings.first);
          _selectedBuildingController.add(buildings.first);
        }
      }

      // Notify listeners
      _authStateController.add(AuthState.authenticated);
      _userController.add(user);

      return AuthResult.success(
        user: user,
        buildings: buildings,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid credentials');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final message = errors?.values.first?.first ?? 'Validation error';
        throw AuthException(message);
      }
      throw AuthException('Login failed: ${e.message}');
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }

  /// Logout and clear stored data
  Future<void> logout() async {
    try {
      final token = await _storage.getAuthToken();
      final building = await _storage.getSelectedBuilding();
      
      if (token != null && building != null) {
        // Call logout endpoint
        await _dio.post(
          '${building.getApiBaseUrl()}/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear all stored data
      await _storage.clearAll();
      
      // Notify listeners
      _authStateController.add(AuthState.unauthenticated);
      _userController.add(null);
      _selectedBuildingController.add(null);
    }
  }

  /// Refresh authentication token
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      final building = await _storage.getSelectedBuilding();
      if (building == null) {
        throw AuthException('No building selected');
      }

      final response = await _dio.post(
        '${building.getApiBaseUrl()}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String?;

      // Store new tokens
      await _storage.storeAuthToken(newAccessToken);
      if (newRefreshToken != null) {
        await _storage.storeRefreshToken(newRefreshToken);
      }

      return newAccessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Refresh token is invalid, logout user
        await logout();
        throw AuthException('Session expired');
      }
      throw AuthException('Token refresh failed: ${e.message}');
    } catch (e) {
      throw AuthException('Token refresh failed: $e');
    }
  }

  /// Get current authentication state
  Future<AuthState> getAuthState() async {
    final isLoggedIn = await _storage.isLoggedIn();
    return isLoggedIn ? AuthState.authenticated : AuthState.unauthenticated;
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    return await _storage.getUser();
  }

  /// Get current selected building
  Future<Building?> getSelectedBuilding() async {
    return await _storage.getSelectedBuilding();
  }

  /// Get all buildings for current user
  Future<List<Building>?> getBuildings() async {
    return await _storage.getBuildings();
  }

  /// Select a building for API calls
  Future<void> selectBuilding(Building building) async {
    await _storage.storeSelectedBuilding(building);
    _selectedBuildingController.add(building);
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _storage.getAuthToken();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storage.isLoggedIn();
  }

  /// Validate current token by making a test API call
  Future<bool> validateToken() async {
    try {
      final token = await getAccessToken();
      final building = await getSelectedBuilding();
      
      if (token == null || building == null) return false;

      final response = await _dio.get(
        '${building.getApiBaseUrl()}/auth/user',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final token = await getAccessToken();
      final building = await getSelectedBuilding();
      
      if (token == null || building == null) {
        throw AuthException('Not authenticated');
      }

      final response = await _dio.put(
        '${building.getApiBaseUrl()}/auth/user',
        data: {
          'name': name,
          'email': email,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final userData = response.data['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);
      
      // Update stored user data
      await _storage.storeUser(user);
      _userController.add(user);
      
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        throw AuthException('Session expired');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final message = errors?.values.first?.first ?? 'Validation error';
        throw AuthException(message);
      }
      throw AuthException('Profile update failed: ${e.message}');
    } catch (e) {
      throw AuthException('Profile update failed: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await getAccessToken();
      final building = await getSelectedBuilding();
      
      if (token == null || building == null) {
        throw AuthException('Not authenticated');
      }

      await _dio.put(
        '${building.getApiBaseUrl()}/auth/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        throw AuthException('Session expired');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final message = errors?.values.first?.first ?? 'Validation error';
        throw AuthException(message);
      }
      throw AuthException('Password change failed: ${e.message}');
    } catch (e) {
      throw AuthException('Password change failed: $e');
    }
  }

  /// Dispose streams
  void dispose() {
    _authStateController.close();
    _userController.close();
    _selectedBuildingController.close();
  }
}

/// Authentication state enum
enum AuthState {
  authenticated,
  unauthenticated,
  unknown,
}

/// Authentication result class
class AuthResult {
  final bool success;
  final User? user;
  final List<Building>? buildings;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  const AuthResult._({
    required this.success,
    this.user,
    this.buildings,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  factory AuthResult.success({
    required User user,
    List<Building>? buildings,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthResult._(
      success: true,
      user: user,
      buildings: buildings,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}