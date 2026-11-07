import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_network/ss_network.dart';

import '../data/ss_demo_catalog.dart';
import '../models/ss_demo_product.dart';

final ssHomeSearchQueryProvider = StateProvider<String>((ref) => '');

final ssHomeFilteredProductsProvider = Provider<List<SSShopProduct>>((ref) {
  final query = ref.watch(ssHomeSearchQueryProvider);
  return SSDemoCatalog.search(query).map(_demoToShop).toList();
});

SSShopProduct _demoToShop(SSDemoProduct p) => SSShopProduct(
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
