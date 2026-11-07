import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import '../data/ss_demo_catalog.dart';
import 'ss_home_search.dart';

final ssShopHomeProvider = FutureProvider<SSShopHomeResponse>((ref) async {
  if (SSEnv.config.useMock) {
    throw StateError('Mock 模式不使用 shop/home API');
  }
  final api = ref.watch(ssShopApiProvider);
  final result = await api.getHome();
  return result.when(
    success: (data) => data,
    failure: (e) => throw e,
  );
});

final ssShopL1Provider = FutureProvider<List<SSShopCategoryL1>>((ref) async {
  if (SSEnv.config.useMock) {
    return SSDemoCatalog.l1Categories
        .map((c) => SSShopCategoryL1(id: c.id, name: c.name))
        .toList();
  }
  final api = ref.watch(ssShopApiProvider);
  final result = await api.getCategoriesL1();
  return result.when(
    success: (data) => data,
    failure: (e) => throw e,
  );
});

final ssShopL2Provider =
    FutureProvider.family<List<SSShopCategoryL2>, String>((ref, l1Id) async {
  if (SSEnv.config.useMock) {
    return SSDemoCatalog.l2ForL1(l1Id)
        .map(
          (c) => SSShopCategoryL2(id: c.id, l1Id: c.l1Id, name: c.name),
        )
        .toList();
  }
  final api = ref.watch(ssShopApiProvider);
  final result = await api.getCategoriesL2(l1Id);
  return result.when(
    success: (data) => data,
    failure: (e) => throw e,
  );
});

class SSProductSearchNotifier
    extends AutoDisposeAsyncNotifier<List<SSShopProduct>> {
  int _generation = 0;

  @override
  Future<List<SSShopProduct>> build() async {
    final query = ref.watch(ssHomeSearchQueryProvider);
    if (SSEnv.config.useMock) {
      return SSDemoCatalog.search(query).map(_fromDemo).toList();
    }
    return _fetch(query);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<List<SSShopProduct>> _fetch(String query) async {
    final gen = ++_generation;
    if (query.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (gen != _generation) {
        final current = ref.read(ssHomeSearchQueryProvider);
        if (current != query) {
          return _fetch(current);
        }
      }
    }
    final api = ref.read(ssShopApiProvider);
    final result = await api.getProducts(q: query, limit: 50);
    return result.when(
      success: (page) => page.items,
      failure: (e) => throw e,
    );
  }
}

final ssProductSearchProvider = AutoDisposeAsyncNotifierProvider<
    SSProductSearchNotifier, List<SSShopProduct>>(
  SSProductSearchNotifier.new,
);

final ssShopProductProvider =
    FutureProvider.family<SSShopProduct, String>((ref, id) async {
  if (SSEnv.config.useMock) {
    final p = SSDemoCatalog.productById(id);
    if (p == null) throw const SSNotFoundError();
    return _fromDemo(p);
  }
  final api = ref.watch(ssShopApiProvider);
  final result = await api.getProduct(id);
  return result.when(
    success: (data) => data,
    failure: (e) => throw e,
  );
});

final ssShopCategoryProductsProvider =
    FutureProvider.family<List<SSShopProduct>, String>((ref, l1Id) async {
  if (SSEnv.config.useMock) {
    return SSDemoCatalog.productsForL1(l1Id).map(_fromDemo).toList();
  }
  final api = ref.watch(ssShopApiProvider);
  final result = await api.getProducts(categoryL1Id: l1Id, limit: 20);
  return result.when(
    success: (page) => page.items,
    failure: (e) => throw e,
  );
});

SSShopProduct _fromDemo(dynamic p) {
  return SSShopProduct(
    id: p.id,
    title: p.title,
    priceCents: p.priceCents,
    categoryL1Id: p.categoryL1Id,
    categoryL2Id: p.categoryL2Id,
    shopName: p.shopName,
    soldCount: p.soldCount,
    artKey: p.artKey,
    skus: p.skus,
    subtitle: p.subtitle,
  );
}
