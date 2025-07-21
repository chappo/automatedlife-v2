import '../api/api_client.dart';
import '../auth/auth_service.dart';
import '../storage/secure_storage_service.dart';
import '../models/models.dart';

/// Core service that ties together all the core functionality
class CoreService {
  static CoreService? _instance;
  static CoreService get instance => _instance ??= CoreService._internal();
  
  CoreService._internal();

  final ApiClient _apiClient = ApiClient.instance;
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  bool _initialized = false;

  /// Initialize the core service
  Future<void> initialize({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool enableLogging = false,
    int maxRetries = 3,
  }) async {
    if (_initialized) return;

    // Initialize API client
    _apiClient.initialize(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      enableLogging: enableLogging,
      maxRetries: maxRetries,
    );

    _initialized = true;
  }

  /// Check if the service is initialized
  bool get isInitialized => _initialized;

  /// Get API client instance
  ApiClient get apiClient => _apiClient;

  /// Get auth service instance
  AuthService get authService => _authService;

  /// Get storage service instance
  SecureStorageService get storage => _storage;

  /// Get authentication state stream
  Stream<AuthState> get authStateStream => _authService.authStateStream;

  /// Get user stream
  Stream<User?> get userStream => _authService.userStream;

  /// Get selected building stream
  Stream<Building?> get selectedBuildingStream => _authService.selectedBuildingStream;

  /// Login with credentials
  Future<AuthResult> login({
    required String email,
    required String password,
    String? buildingSubdomain,
  }) async {
    return await _authService.login(
      email: email,
      password: password,
      buildingSubdomain: buildingSubdomain,
    );
  }

  /// Logout current user
  Future<void> logout() async {
    await _authService.logout();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  /// Get selected building
  Future<Building?> getSelectedBuilding() async {
    return await _authService.getSelectedBuilding();
  }

  /// Get all buildings for current user
  Future<List<Building>?> getBuildings() async {
    return await _authService.getBuildings();
  }

  /// Select a building
  Future<void> selectBuilding(Building building) async {
    await _authService.selectBuilding(building);
    await _apiClient.updateApiUrlForBuilding();
  }

  /// Refresh authentication token
  Future<String?> refreshToken() async {
    return await _authService.refreshToken();
  }

  /// Validate current token
  Future<bool> validateToken() async {
    return await _authService.validateToken();
  }

  /// Update user profile
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    return await _authService.updateProfile(name: name, email: email);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  /// Get building details
  Future<Building> getBuildingDetails(int buildingId) async {
    return await _apiClient.getBuildingDetails(buildingId);
  }

  /// Get building capabilities
  Future<List<Capability>> getBuildingCapabilities(int buildingId) async {
    return await _apiClient.getBuildingCapabilities(buildingId);
  }

  /// Update building branding
  Future<BuildingBranding> updateBuildingBranding(
    int buildingId,
    BuildingBranding branding,
  ) async {
    return await _apiClient.updateBuildingBranding(buildingId, branding);
  }

  /// Toggle building capability
  Future<Capability> toggleCapability(
    int buildingId,
    int capabilityId,
    bool enabled, {
    Map<String, dynamic>? configData,
  }) async {
    return await _apiClient.toggleCapability(
      buildingId,
      capabilityId,
      enabled,
      configData: configData,
    );
  }

  /// Test capability configuration
  Future<void> testCapability(int buildingId, String capabilityKey) async {
    await _apiClient.testCapability(buildingId, capabilityKey);
  }

  /// Set biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.setBiometricEnabled(enabled);
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    return await _storage.isBiometricEnabled();
  }

  /// Clear all data (logout and clear storage)
  Future<void> clearAllData() async {
    await logout();
    await _storage.clearAll();
  }

  /// Dispose resources
  void dispose() {
    _authService.dispose();
    _initialized = false;
  }
}