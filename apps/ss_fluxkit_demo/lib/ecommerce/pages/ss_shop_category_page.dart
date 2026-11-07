import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';
import 'package:ss_ui/ss_ui.dart';

import '../providers/ss_category_selection.dart';
import '../providers/ss_shop_catalog_providers.dart';
import '../theme/ss_shop_colors.dart';
import '../widgets/ss_demo_product_art.dart';

class SSShopCategoryPage extends ConsumerWidget {
  const SSShopCategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l1Async = ref.watch(ssShopL1Provider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('全部分类'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: l1Async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SSErrorState(
          message: e is SSAppError ? e.message : e.toString(),
          onRetry: () => ref.invalidate(ssShopL1Provider),
        ),
        data: (l1s) => _CategorySplit(l1Categories: l1s),
      ),
    );
  }
}

class _CategorySplit extends ConsumerWidget {
  const _CategorySplit({required this.l1Categories});

  final List<SSShopCategoryL1> l1Categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedL1 = ref.watch(ssCategoryL1Provider);
    if (!l1Categories.any((c) => c.id == selectedL1) &&
        l1Categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ssCategoryL1Provider.notifier).state = l1Categories.first.id;
      });
    }
    final l1Name = l1Categories
        .firstWhere(
          (c) => c.id == selectedL1,
          orElse: () => l1Categories.first,
        )
        .name;
    final l2Async = ref.watch(ssShopL2Provider(selectedL1));
    final productsAsync = ref.watch(ssShopCategoryProductsProvider(selectedL1));

    return Row(
      children: [
        SizedBox(
          width: 96,
          child: ColoredBox(
            color: SSShopColors.pageBg,
            child: ListView.builder(
              itemCount: l1Categories.length,
              itemBuilder: (context, index) {
                final cat = l1Categories[index];
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
          child: l2Async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => SSErrorState(
              message: e is SSAppError ? e.message : e.toString(),
              onRetry: () => ref.invalidate(ssShopL2Provider(selectedL1)),
            ),
            data: (l2List) => productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => SSErrorState(
                message: e is SSAppError ? e.message : e.toString(),
                onRetry: () =>
                    ref.invalidate(ssShopCategoryProductsProvider(selectedL1)),
              ),
              data: (products) => ListView(
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                  Text(
                    SSEnv.config.useMock ? '热销推荐 · 演示数据' : '热销推荐',
                    style: const TextStyle(
                      fontSize: 12,
                      color: SSShopColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...products.map((p) => _MiniProductRow(product: p)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _artForL2(String l2Id) {
    return switch (l2Id) {
      'phone' || 'tablet' => 'phone',
      'earphone' || 'watch' => 'earphone',
      'accessory' => 'powerbank',
      'camera' => 'phone',
      _ => 'powerbank',
    };
  }
}

class _MiniProductRow extends StatelessWidget {
  const _MiniProductRow({required this.product});

  final SSShopProduct product;

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
