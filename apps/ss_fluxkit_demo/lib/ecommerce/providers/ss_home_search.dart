import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ss_demo_catalog.dart';
import '../models/ss_demo_product.dart';

final ssHomeSearchQueryProvider = StateProvider<String>((ref) => '');

final ssHomeFilteredProductsProvider = Provider<List<SSDemoProduct>>((ref) {
  final query = ref.watch(ssHomeSearchQueryProvider);
  return SSDemoCatalog.search(query);
});
