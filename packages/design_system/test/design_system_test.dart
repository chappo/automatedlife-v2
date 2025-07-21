import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

void main() {
  test('design system exports components', () {
    // Test that the design system exports the expected components
    expect(NWSpacing.small, 8.0);
    expect(NWSpacing.medium, 16.0);
    expect(NWSpacing.large, 24.0);
  });
}
