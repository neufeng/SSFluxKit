import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';
import 'package:ss_ui/ss_ui.dart';

import '../providers/ss_cart_notifier.dart';
import '../providers/ss_shop_catalog_providers.dart';
import '../theme/ss_shop_colors.dart';
import '../widgets/ss_demo_product_art.dart';

class SSProductDetailPage extends ConsumerStatefulWidget {
  const SSProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<SSProductDetailPage> createState() =>
      _SSProductDetailPageState();
}

class _SSProductDetailPageState extends ConsumerState<SSProductDetailPage> {
  String? _sku;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(ssShopProductProvider(widget.productId));

    return productAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: SSErrorState(
          message: e is SSAppError ? e.message : e.toString(),
          onRetry: () =>
              ref.invalidate(ssShopProductProvider(widget.productId)),
        ),
      ),
      data: (product) {
        _sku ??= product.skus.first;
        return _buildScaffold(context, product);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, SSShopProduct product) {
    final cart = ref.watch(ssCartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: cart.isMutating
                ? null
                : () async {
                    await ref.read(ssCartProvider.notifier).addProduct(
                          product.id,
                          sku: _sku,
                        );
                    if (!context.mounted) return;
                    final err = ref.read(ssCartProvider).errorMessage;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已加入购物车：${product.title}'),
                        action: SnackBarAction(
                          label: '去购物车',
                          onPressed: () => context.go('/cart'),
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('加入购物车'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: SSDemoProductArt(artKey: product.artKey, borderRadius: 0),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SSPriceText(cents: product.priceCents, fontSize: 24),
          Text(
            product.soldLabel,
            style: const TextStyle(
              fontSize: 12,
              color: SSShopColors.textTertiary,
            ),
          ),
          if (product.isDemoCatalog) ...[
            const SizedBox(height: 8),
            const Text(
              '演示目录商品（isDemoCatalog）',
              style: TextStyle(fontSize: 12, color: SSShopColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          const Text('规格', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: product.skus.map((sku) {
              final selected = sku == _sku;
              return ChoiceChip(
                label: Text(sku),
                selected: selected,
                onSelected: (_) => setState(() => _sku = sku),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            SSEnv.config.useMock
                ? '本页为本地演示商品，图文为内置插画占位。'
                : '价格与库存以服务端返回为准（priceCents，分）。',
            style: const TextStyle(
              fontSize: 13,
              color: SSShopColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
