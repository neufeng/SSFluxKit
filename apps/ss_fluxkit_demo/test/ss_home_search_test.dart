import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_fluxkit_demo/ecommerce/providers/ss_home_search.dart';

void main() {
  test('search filters demo catalog', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final all = container.read(ssHomeFilteredProductsProvider);
    expect(all.length, greaterThan(3));

    container.read(ssHomeSearchQueryProvider.notifier).state = '耳机';
    final filtered = container.read(ssHomeFilteredProductsProvider);
    expect(filtered.every((p) => p.title.contains('耳机')), isTrue);
    expect(filtered, isNotEmpty);

    container.read(ssHomeSearchQueryProvider.notifier).state = '不存在xyz';
    expect(container.read(ssHomeFilteredProductsProvider), isEmpty);
  });
}
