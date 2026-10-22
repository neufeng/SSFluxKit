import 'package:flutter_test/flutter_test.dart';
import 'package:ss_core/ss_core.dart';

void main() {
  test('SSSuccess holds data', () {
    const result = SSSuccess(42);
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, 42);
  });

  test('SSFailure holds error', () {
    const result = SSFailure<int>(SSNetworkError('offline'));
    expect(result.isFailure, isTrue);
    expect(result.errorOrNull, isA<SSNetworkError>());
  });
}
