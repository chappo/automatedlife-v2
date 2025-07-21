import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../auth/auth_service.dart';
import '../storage/secure_storage_service.dart';
import '../utils/exceptions.dart';
import 'interceptors.dart';

/// Main API client for the Building Manager app
class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._internal();
  
  ApiClient._internal();

  late Dio _dio;
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  /// Initialize the API client
  void initialize({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool enableLogging = false,
    int maxRetries = 3,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'https://api.automatedlife.io/api/v1',
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        sendTimeout: sendTimeout ?? const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      if (enableLogging) const LoggingInterceptor(),
      BuildingInterceptor(),
      AuthInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(
        dio: _dio,
        logPrint: enableLogging ? debugPrint : null,
        retries: maxRetries,
        retryDelays: [
          const Duration(seconds: 1),
          const Duration(seconds: 2),
          const Duration(seconds: 3),
        ],
      ),
    ]);

    // Initialize auth service with dio instance
    _authService.initialize(_dio);
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Make a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Make a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Make a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Make a PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Make a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Upload a file
  Future<Response<T>> upload<T>(
    String path,
    String filePath,
    String fileKey, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        fileKey: await MultipartFile.fromFile(filePath),
      });

      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Download a file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get user profile
  Future<User> getUserProfile() async {
    final response = await get('/me');
    return User.fromJson(response.data['user']);
  }

  /// Get user buildings
  Future<List<Building>> getUserBuildings() async {
    final response = await get('/buildings');
    final responseData = response.data as Map<String, dynamic>;
    
    print('DEBUG: Full buildings response: $responseData');
    print('DEBUG: Response keys: ${responseData.keys.toList()}');
    
    // The API returns buildings in 'payload' field
    final payloadData = responseData['payload'];
    print('DEBUG: Raw payload data: $payloadData');
    print('DEBUG: Payload type: ${payloadData.runtimeType}');
    
    List<dynamic>? buildingsData;
    if (payloadData is List) {
      buildingsData = payloadData;
    } else {
      print('DEBUG: Payload is not a List, it is: ${payloadData.runtimeType}');
    }
    
    print('DEBUG: Buildings data type: ${buildingsData.runtimeType}');
    print('DEBUG: Buildings data length: ${buildingsData?.length}');
    
    if (buildingsData == null || buildingsData.isEmpty) {
      throw ApiException('No buildings data in response');
    }
    
    return buildingsData
        .map((buildingData) => Building.fromJson(buildingData))
        .toList();
  }

  /// Get building details
  Future<Building> getBuildingDetails(int buildingId) async {
    final response = await get('/buildings/$buildingId');
    return Building.fromJson(response.data['building']);
  }

  /// Get building-specific capabilities (enabled and available)
  /// This endpoint provides everything needed to render capability tiles:
  /// - Full capability definitions (name, description, type, category, icon, apps)
  /// - Building-specific data (sortOrder, linkId, dynamic data like counts)
  /// - Enabled vs available status for this building
  Future<BuildingCapabilitiesResponse> getBuildingCapabilities(int buildingId) async {
    final response = await get('/buildings/$buildingId/capabilities');
    final responseData = response.data as Map<String, dynamic>;
    return BuildingCapabilitiesResponse.fromJson(responseData['data']);
  }

  /// Update building branding
  Future<BuildingBranding> updateBuildingBranding(
    int buildingId,
    BuildingBranding branding,
  ) async {
    final response = await put(
      '/buildings/$buildingId/branding',
      data: branding.toJson(),
    );
    return BuildingBranding.fromJson(response.data['branding']);
  }

  /// Enable/disable building capability
  Future<Capability> toggleCapability(
    int buildingId,
    int capabilityId,
    bool enabled, {
    Map<String, dynamic>? configData,
  }) async {
    final response = await patch(
      '/buildings/$buildingId/capabilities/$capabilityId',
      data: {
        'is_enabled': enabled,
        if (configData != null) 'config_data': configData,
      },
    );
    return Capability.fromJson(response.data['capability']);
  }

  /// Send a test notification to verify capability configuration
  Future<void> testCapability(int buildingId, String capabilityKey) async {
    await post('/buildings/$buildingId/capabilities/$capabilityKey/test');
  }

  /// Update user profile
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? preferredName,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (preferredName != null) data['preferred_name'] = preferredName;
    
    final response = await put('/me', data: data);
    return User.fromJson(response.data['user']);
  }

  /// Update user preferred name (alias) - Legacy method
  Future<User> updateUserAlias({required String preferredName}) async {
    return updateUserProfile(preferredName: preferredName);
  }

  // === USER ALIAS MANAGEMENT ===

  /// Get user's aliases
  Future<List<UserAlias>> getUserAliases() async {
    final response = await get('/me/aliases');
    return (response.data['aliases'] as List)
        .map((alias) => UserAlias.fromJson(alias))
        .toList();
  }

  /// Create new alias
  Future<UserAlias> createUserAlias({
    required String alias,
    required String type,
    bool isPublic = true,
  }) async {
    final response = await post('/me/aliases', data: {
      'alias': alias,
      'type': type,
      'isPublic': isPublic,
    });
    return UserAlias.fromJson(response.data['alias']);
  }

  /// Update existing alias
  Future<UserAlias> updateUserAliasById({
    required String aliasId,
    String? alias,
    String? type,
    bool? isPublic,
  }) async {
    final data = <String, dynamic>{};
    if (alias != null) data['alias'] = alias;
    if (type != null) data['type'] = type;
    if (isPublic != null) data['isPublic'] = isPublic;

    final response = await put('/me/aliases/$aliasId', data: data);
    return UserAlias.fromJson(response.data['alias']);
  }

  /// Delete alias
  Future<void> deleteUserAlias(String aliasId) async {
    await delete('/me/aliases/$aliasId');
  }

  /// Set primary alias
  Future<UserAlias> setPrimaryAlias(String aliasId) async {
    final response = await post('/me/aliases/$aliasId/set-primary');
    return UserAlias.fromJson(response.data['alias']);
  }

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await put(
      '/auth/password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
    );
  }

  /// Handle DioException and convert to appropriate custom exception
  CoreException _handleDioException(DioException e) {
    if (e.error is CoreException) {
      return e.error as CoreException;
    }

    // Fallback for unhandled DioExceptions
    return ApiException(
      'API request failed: ${e.message}',
      originalError: e,
      statusCode: e.response?.statusCode,
      responseData: e.response?.data is Map<String, dynamic> 
          ? e.response?.data as Map<String, dynamic>
          : null,
    );
  }

  /// Set base URL for the API client
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Update API base URL for selected building
  Future<void> updateApiUrlForBuilding() async {
    final building = await _storage.getSelectedBuilding();
    if (building != null) {
      setBaseUrl(building.getApiBaseUrl());
    }
  }

  /// Clear any cached data (if implemented)
  void clearCache() {
    // Implementation depends on caching strategy
    // This could clear Dio cache interceptor if implemented
  }
}