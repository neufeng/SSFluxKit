import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/ss_demo_catalog.dart';
import '../models/ss_demo_product.dart';
import '../providers/ss_category_selection.dart';
import '../theme/ss_shop_colors.dart';
import '../widgets/ss_demo_product_art.dart';

class SSShopCategoryPage extends ConsumerWidget {
  const SSShopCategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedL1 = ref.watch(ssCategoryL1Provider);
    final l2List = SSDemoCatalog.l2ForL1(selectedL1);
    final products = SSDemoCatalog.productsForL1(selectedL1);
    final l1Name =
        SSDemoCatalog.l1Categories.firstWhere((c) => c.id == selectedL1).name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('全部分类'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Row(
        children: [
          SizedBox(
            width: 96,
            child: ColoredBox(
              color: SSShopColors.pageBg,
              child: ListView.builder(
                itemCount: SSDemoCatalog.l1Categories.length,
                itemBuilder: (context, index) {
                  final cat = SSDemoCatalog.l1Categories[index];
                  final active = cat.id == selectedL1;
                  return InkWell(
                    onTap: () =>
                        ref.read(ssCategoryL1Provider.notifier).state = cat.id,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : null,
                        border: Border(
                          left: BorderSide(
                            color: active
                                ? SSShopColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: active
                              ? SSShopColors.primary
                              : SSShopColors.textSecondary,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text(
                  l1Name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: l2List.length,
                  itemBuilder: (context, index) {
                    final l2 = l2List[index];
                    return Column(
                      children: [
                        SSDemoProductArt(
                          artKey: _artForL2(l2.id),
                          size: 56,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l2.name,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '热销推荐 · 演示数据',
                  style: TextStyle(
                    fontSize: 12,
                    color: SSShopColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                ...products.map((p) => _MiniProductRow(product: p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _artForL2(String l2Id) {
    return switch (l2Id) {
      'phone' => 'phone',
      'tablet' => 'phone',
      'earphone' => 'earphone',
      'watch' => 'earphone',
      'accessory' => 'powerbank',
      'camera' => 'phone',
      _ => 'powerbank',
    };
  }
}

class _MiniProductRow extends StatelessWidget {
  const _MiniProductRow({required this.product});

  final SSDemoProduct product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SSDemoProductArt(artKey: product.artKey, size: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (product.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: SSShopColors.textTertiary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  SSPriceText(cents: product.priceCents, fontSize: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
