import 'dart:async';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
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
  final _buildingCapabilitiesController = StreamController<BuildingCapabilitiesResponse?>.broadcast();
  
  // Cache building capabilities to prevent duplicate API calls
  BuildingCapabilitiesResponse? _cachedCapabilities;
  int? _cachedBuildingId;
  final Map<int, Future<BuildingCapabilitiesResponse>> _ongoingRequests = {};

  /// Stream of authentication state changes
  Stream<AuthState> get authStateStream => _authStateController.stream;
  
  /// Stream of user changes
  Stream<User?> get userStream => _userController.stream;
  
  /// Stream of selected building changes
  Stream<Building?> get selectedBuildingStream => _selectedBuildingController.stream;
  
  /// Stream of building capabilities changes
  Stream<BuildingCapabilitiesResponse?> get buildingCapabilitiesStream => _buildingCapabilitiesController.stream;

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
      // For development, use local server - try different approaches
      String baseUrl = 'http://10.10.0.203:8000/api/v1';
      
      // Try alternative endpoint first to bypass throttle middleware
      String loginEndpoint = '$baseUrl/auth/login';
      
      print('DEBUG: Attempting login to: $baseUrl/auth/login');
      print('DEBUG: Email: $email');
      
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('DEBUG: Login response status: ${response.statusCode}');
      print('DEBUG: Full login response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;
      
      if (data == null) {
        print('ERROR: Missing data field in login response');
        print('Response structure: ${responseData.keys.toList()}');
        throw AuthException('Missing data in login response');
      }
      
      print('DEBUG: Data structure: ${data.keys.toList()}');
      
      // Extract tokens and user data with correct field names
      final accessToken = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?; // Usually null for this API
      final userData = data['user'] as Map<String, dynamic>?;
      
      // Validate required fields
      if (accessToken == null) {
        throw AuthException('Missing access token in login response');
      }
      if (userData == null) {
        throw AuthException('Missing user data in login response');
      }

      // Parse user
      final user = User.fromJson(userData);

      // Store tokens and user data first
      await _storage.storeAuthToken(accessToken);
      if (refreshToken != null) {
        await _storage.storeRefreshToken(refreshToken);
      }
      await _storage.storeUser(user);

      // Fetch user's buildings with the new token
      List<Building>? buildings;
      try {
        print('Fetching user buildings...');
        final fetchedBuildings = await ApiClient.instance.getUserBuildings();
        print('Successfully fetched ${fetchedBuildings.length} buildings');
        buildings = fetchedBuildings;
        
        await _storage.storeBuildings(fetchedBuildings);
        
        // Select building based on previous session or default to first
        if (fetchedBuildings.isNotEmpty) {
          Building selectedBuilding;
          
          // Check if user has a previously selected building
          final previousBuilding = await _storage.getSelectedBuilding();
          if (previousBuilding != null) {
            // Check if the previous building is still available
            final matchingBuilding = fetchedBuildings.where(
              (building) => building.id == previousBuilding.id,
            ).firstOrNull ?? fetchedBuildings.first;
            selectedBuilding = matchingBuilding;
            
            if (matchingBuilding.id == previousBuilding.id) {
              print('Restored previous building: ${selectedBuilding.name}');
            } else {
              print('Previous building no longer available, selected: ${selectedBuilding.name}');
            }
          } else {
            // No previous building, select first
            selectedBuilding = fetchedBuildings.first;
            print('New user, selected first building: ${selectedBuilding.name}');
          }
          
          await _storage.storeSelectedBuilding(selectedBuilding);
          _selectedBuildingController.add(selectedBuilding);
          
          // Fetch building capabilities after selecting a building (with caching)
          _fetchBuildingCapabilitiesWithCache(selectedBuilding.id, selectedBuilding.name);
        } else {
          print('No buildings returned from API');
        }
      } catch (e, stackTrace) {
        // Buildings fetch failed, but login was successful
        print('ERROR: Failed to fetch user buildings: $e');
        print('Stack trace: $stackTrace');
        buildings = null;
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
      print('ERROR: DioException during login');
      print('Status Code: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('Message: ${e.message}');
      
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid credentials');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final message = errors?.values.first?.first ?? 'Validation error';
        throw AuthException(message);
      } else if (e.response?.statusCode == 500) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String?;
        
        if (message?.contains('Rate limiter') == true) {
          throw AuthException('Server configuration error: Rate limiter not configured. Please contact system administrator.');
        }
        throw AuthException('Server error (500): ${message ?? 'Internal server error'}');
      }
      throw AuthException('Login failed: ${e.message}');
    } catch (e, stackTrace) {
      print('ERROR: General exception during login: $e');
      print('Stack trace: $stackTrace');
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
    
    // Fetch capabilities for the newly selected building (with caching)
    _fetchBuildingCapabilitiesWithCache(building.id, building.name);
  }
  
  /// Get current building capabilities with caching
  Future<BuildingCapabilitiesResponse?> getBuildingCapabilities() async {
    final building = await getSelectedBuilding();
    if (building == null) return null;
    
    // Return cached data if available for this building
    if (_cachedCapabilities != null && _cachedBuildingId == building.id) {
      print('DEBUG: Returning cached capabilities for building ${building.id}');
      return _cachedCapabilities;
    }
    
    return await _fetchBuildingCapabilitiesWithCache(building.id, building.name);
  }
  
  /// Fetch building capabilities with caching and deduplication
  Future<BuildingCapabilitiesResponse?> _fetchBuildingCapabilitiesWithCache(int buildingId, String buildingName) async {
    // Return cached data if available for this building
    if (_cachedCapabilities != null && _cachedBuildingId == buildingId) {
      print('DEBUG: Using cached capabilities for building: $buildingName');
      _buildingCapabilitiesController.add(_cachedCapabilities);
      return _cachedCapabilities;
    }
    
    // Check if there's already an ongoing request for this building
    if (_ongoingRequests.containsKey(buildingId)) {
      print('DEBUG: Waiting for ongoing request for building: $buildingName');
      try {
        final capabilities = await _ongoingRequests[buildingId]!;
        _buildingCapabilitiesController.add(capabilities);
        return capabilities;
      } catch (e) {
        _ongoingRequests.remove(buildingId);
        _buildingCapabilitiesController.add(null);
        return null;
      }
    }
    
    // Start new request
    print('DEBUG: Starting new capabilities request for building: $buildingName');
    final requestFuture = ApiClient.instance.getBuildingCapabilities(buildingId);
    _ongoingRequests[buildingId] = requestFuture;
    
    try {
      final capabilities = await requestFuture;
      
      // Cache the result
      _cachedCapabilities = capabilities;
      _cachedBuildingId = buildingId;
      
      // Remove from ongoing requests
      _ongoingRequests.remove(buildingId);
      
      print('DEBUG: Successfully fetched and cached ${capabilities.enabled.length} enabled capabilities');
      _buildingCapabilitiesController.add(capabilities);
      return capabilities;
    } catch (e) {
      print('ERROR: Failed to fetch building capabilities: $e');
      _ongoingRequests.remove(buildingId);
      _buildingCapabilitiesController.add(null);
      return null;
    }
  }
  
  /// Clear capabilities cache (useful when switching buildings)
  void _clearCapabilitiesCache() {
    _cachedCapabilities = null;
    _cachedBuildingId = null;
    _ongoingRequests.clear();
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
        '${building.getApiBaseUrl()}/auth/me',
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
        '${building.getApiBaseUrl()}/me',
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