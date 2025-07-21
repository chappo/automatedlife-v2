import 'package:flutter_test/flutter_test.dart';

import 'package:core/core.dart';

void main() {
  group('Core Package Tests', () {
    test('Core service initialization', () {
      final coreService = CoreService.instance;
      expect(coreService.isInitialized, false);
    });

    test('API client singleton instance', () {
      final apiClient1 = ApiClient.instance;
      final apiClient2 = ApiClient.instance;
      expect(identical(apiClient1, apiClient2), true);
    });

    test('Auth service singleton instance', () {
      final authService1 = AuthService();
      final authService2 = AuthService();
      expect(identical(authService1, authService2), true);
    });

    test('Storage service singleton instance', () {
      final storage1 = SecureStorageService();
      final storage2 = SecureStorageService();
      expect(identical(storage1, storage2), true);
    });
  });
}
