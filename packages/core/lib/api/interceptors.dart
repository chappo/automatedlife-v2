import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_service.dart';
import '../storage/secure_storage_service.dart';
import '../utils/exceptions.dart';

/// Interceptor for automatically adding authentication headers
class AuthInterceptor extends Interceptor {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add common headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 unauthorized errors
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh the token
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          // Retry the original request with new token
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          
          final dio = Dio();
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, logout user
        await _authService.logout();
      }
    }
    
    handler.next(err);
  }
}

/// Interceptor for error handling and conversion to custom exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    CoreException exception;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException(
          'Request timeout: ${err.message}',
          originalError: err,
        );
        break;
        
      case DioExceptionType.connectionError:
        exception = NetworkException(
          'Network connection error: ${err.message}',
          originalError: err,
        );
        break;
        
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client errors
            if (statusCode == 401) {
              exception = AuthException(
                'Unauthorized access',
                code: statusCode.toString(),
                originalError: err,
              );
            } else if (statusCode == 422) {
              // Validation errors
              final errors = responseData is Map<String, dynamic> 
                  ? responseData['errors'] as Map<String, dynamic>?
                  : null;
              
              String message = 'Validation error';
              if (errors != null) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  message = firstError.first.toString();
                }
              }
              
              exception = ValidationException(
                message,
                code: statusCode.toString(),
                originalError: err,
                errors: errors?.map(
                  (key, value) => MapEntry(
                    key,
                    value is List ? value.map((e) => e.toString()).toList() : [value.toString()],
                  ),
                ),
              );
            } else {
              exception = ClientException(
                _extractErrorMessage(responseData) ?? 'Client error',
                code: statusCode.toString(),
                originalError: err,
                statusCode: statusCode,
              );
            }
          } else if (statusCode >= 500) {
            // Server errors
            exception = ServerException(
              _extractErrorMessage(responseData) ?? 'Server error',
              code: statusCode.toString(),
              originalError: err,
              statusCode: statusCode,
            );
          } else {
            exception = ApiException(
              _extractErrorMessage(responseData) ?? 'API error',
              code: statusCode.toString(),
              originalError: err,
              statusCode: statusCode,
              responseData: responseData is Map<String, dynamic> ? responseData : null,
            );
          }
        } else {
          exception = ApiException(
            'Unknown API error: ${err.message}',
            originalError: err,
          );
        }
        break;
        
      case DioExceptionType.cancel:
        exception = ApiException(
          'Request was cancelled',
          originalError: err,
        );
        break;
        
      case DioExceptionType.unknown:
      default:
        exception = ApiException(
          'Unknown error: ${err.message}',
          originalError: err,
        );
        break;
    }
    
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }
  
  /// Extract error message from response data
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try different common error message fields
      final message = responseData['message'] ??
          responseData['error'] ??
          responseData['detail'] ??
          responseData['msg'];
      
      if (message is String) {
        return message;
      }
    }
    return null;
  }
}

/// Interceptor for logging requests and responses (debug mode)
class LoggingInterceptor extends Interceptor {
  final bool enabled;
  
  const LoggingInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      debugPrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
      debugPrint('Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('Query Parameters: ${options.queryParameters}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      debugPrint('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      debugPrint('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      debugPrint('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      debugPrint('Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('Response Data: ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}

/// Interceptor for building-specific API endpoints
class BuildingInterceptor extends Interceptor {
  final SecureStorageService _storage = SecureStorageService();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Check if this is a relative path that needs building context
    if (!options.path.startsWith('http')) {
      final building = await _storage.getSelectedBuilding();
      if (building != null) {
        // Update the base URL to use building-specific API
        final baseUrl = building.getApiBaseUrl();
        options.baseUrl = baseUrl;
      }
    }
    
    handler.next(options);
  }
}