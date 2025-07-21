/// Core package for Building Manager app with API client and authentication
library core;

// Export models
export 'models/models.dart';

// Export services
export 'services/core_service.dart';
export 'auth/auth_service.dart';
export 'storage/secure_storage_service.dart';

// Export API client
export 'api/api_client.dart';
export 'api/interceptors.dart';

// Export utilities
export 'utils/exceptions.dart';