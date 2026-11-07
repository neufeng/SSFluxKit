import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/ss_demo_catalog.dart';
import '../providers/ss_cart_notifier.dart';
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
  late String _sku;

  @override
  void initState() {
    super.initState();
    final product = SSDemoCatalog.productById(widget.productId);
    _sku = product?.skus.first ?? '默认规格';
  }

  @override
  Widget build(BuildContext context) {
    final product = SSDemoCatalog.productById(widget.productId);
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('演示商品不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () {
              ref
                  .read(ssCartProvider.notifier)
                  .addProduct(product.id, sku: _sku);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已加入购物车（演示）：${product.title}'),
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
          const SizedBox(height: 16),
          const Text(
            '规格（演示）',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
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
            '本页为本地演示商品，图文为内置插画占位，未连接真实交易或库存。',
            style: TextStyle(
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
