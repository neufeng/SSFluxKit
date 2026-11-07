import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_fluxkit_demo/ecommerce/providers/ss_cart_notifier.dart';

void main() {
  setUp(() {
    SSEnv.init(
      const SSEnvConfig(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        useMock: true,
      ),
    );
  });

  tearDown(SSEnv.reset);

  test('cart badge and total respect selection', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(ssCartProvider.notifier);
    var state = container.read(ssCartProvider);

    expect(state.badgeCount, greaterThan(0));
    expect(state.selectedTotalCents, greaterThan(0));

    expect(state.selectedSkuCount, 2);
    await notifier.toggleLine('l3');
    state = container.read(ssCartProvider);
    expect(state.selectedSkuCount, 3);

    await notifier.toggleSelectAll(false);
    state = container.read(ssCartProvider);
    expect(state.selectedTotalCents, 0);
    expect(state.selectedSkuCount, 0);

    await notifier.addProduct('p2');
    state = container.read(ssCartProvider);
    expect(state.lines.any((l) => l.productId == 'p2'), isTrue);
  });

  test('removeSelectedLines removes only selected rows', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ssCartProvider.notifier);
    await notifier.toggleSelectAll(true);
    final before = container.read(ssCartProvider).lines.length;
    await notifier.removeSelectedLines();
    expect(container.read(ssCartProvider).lines, isEmpty);
    expect(before, greaterThan(0));
  });

  test('setQuantity to zero removes line', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ssCartProvider.notifier);
    final before = container.read(ssCartProvider).lines.length;
    await notifier.setQuantity('l1', 0);
    expect(container.read(ssCartProvider).lines.length, before - 1);
  });
}
