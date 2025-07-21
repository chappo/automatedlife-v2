/// Base exception class for the core package
abstract class CoreException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const CoreException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'CoreException: $message';
}

/// Authentication related exceptions
class AuthException extends CoreException {
  const AuthException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// API related exceptions
class ApiException extends CoreException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  const ApiException(
    super.message, {
    super.code,
    super.originalError,
    this.statusCode,
    this.responseData,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Network related exceptions
class NetworkException extends CoreException {
  const NetworkException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'NetworkException: $message';
}

/// Storage related exceptions
class StorageException extends CoreException {
  const StorageException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'StorageException: $message';
}

/// Validation related exceptions
class ValidationException extends CoreException {
  final Map<String, List<String>>? errors;

  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Server error exceptions
class ServerException extends CoreException {
  final int? statusCode;

  const ServerException(
    super.message, {
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Client error exceptions
class ClientException extends CoreException {
  final int? statusCode;

  const ClientException(
    super.message, {
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ClientException: $message (Status: $statusCode)';
}

/// Timeout related exceptions
class TimeoutException extends CoreException {
  const TimeoutException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'TimeoutException: $message';
}

/// Building configuration exceptions
class BuildingConfigException extends CoreException {
  const BuildingConfigException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'BuildingConfigException: $message';
}

/// Capability related exceptions
class CapabilityException extends CoreException {
  const CapabilityException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'CapabilityException: $message';
}