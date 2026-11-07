import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_fluxkit_demo/ecommerce/providers/ss_cart_notifier.dart';

void main() {
  test('cart badge and total respect selection', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(ssCartProvider.notifier);
    var state = container.read(ssCartProvider);

    expect(state.badgeCount, greaterThan(0));
    expect(state.selectedTotalCents, greaterThan(0));

    expect(state.selectedSkuCount, 2);
    notifier.toggleLine('l3');
    state = container.read(ssCartProvider);
    expect(state.selectedSkuCount, 3);

    notifier.toggleSelectAll(false);
    state = container.read(ssCartProvider);
    expect(state.selectedTotalCents, 0);
    expect(state.selectedSkuCount, 0);

    notifier.addProduct('p2');
    state = container.read(ssCartProvider);
    expect(state.lines.any((l) => l.productId == 'p2'), isTrue);
  });

  test('setQuantity to zero removes line', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ssCartProvider.notifier);
    final before = container.read(ssCartProvider).lines.length;
    notifier.setQuantity('l1', 0);
    expect(container.read(ssCartProvider).lines.length, before - 1);
  });
}
