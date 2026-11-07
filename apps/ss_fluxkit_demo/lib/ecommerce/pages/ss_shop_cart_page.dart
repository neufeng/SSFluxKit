import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_ui/ss_ui.dart';

import '../data/ss_demo_catalog.dart';
import '../models/ss_cart_item.dart';
import '../providers/ss_cart_edit_mode.dart';
import '../providers/ss_cart_notifier.dart';
import '../theme/ss_shop_colors.dart';
import '../widgets/ss_demo_product_art.dart';

class SSShopCartPage extends ConsumerWidget {
  const SSShopCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(ssCartProvider);
    final editMode = ref.watch(ssCartEditModeProvider);

    ref.listen<SSCartState>(ssCartProvider, (_, next) {
      if (next.isEmpty) {
        ref.read(ssCartEditModeProvider.notifier).state = false;
      }
    });

    return Scaffold(
      backgroundColor: SSShopColors.pageBg,
      appBar: AppBar(
        title: Text(cart.isEmpty ? '购物车' : '购物车 (${cart.lines.length})'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        scrolledUnderElevation: 0,
        actions: [
          Semantics(
            label: editMode ? '购物车-完成编辑' : '购物车-编辑',
            button: true,
            child: TextButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      ref.read(ssCartEditModeProvider.notifier).state =
                          !editMode;
                    },
              child: Text(editMode ? '完成' : '编辑'),
            ),
          ),
        ],
      ),
      body: cart.isEmpty
          ? SSEmptyState(
              title: '购物车还是空的',
              message: '快去挑选心仪好物吧\n此处为 UI 演示，未连接真实商品与库存',
              action: Semantics(
                label: '购物车-去逛逛',
                button: true,
                child: FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('去逛逛'),
                ),
              ),
            )
          : Column(
              children: [
                if (editMode)
                  Material(
                    color: SSShopColors.primaryLight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: SSShopColors.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '编辑模式：勾选后点「删除选中」，或点「取消编辑」退出',
                              style: TextStyle(
                                fontSize: 12,
                                color: SSShopColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '演示店铺商品，非真实库存',
                          style: TextStyle(
                            fontSize: 12,
                            color: SSShopColors.textTertiary,
                          ),
                        ),
                      ),
                      _SelectAllRow(cart: cart),
                      ..._groupedLines(cart.lines).entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ShopHeader(shopName: entry.key),
                            ...entry.value.map(
                              (line) => _CartLineTile(
                                line: line,
                                showQuantity: !editMode,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                if (editMode)
                  _EditModeBar(cart: cart)
                else
                  _CheckoutBar(cart: cart),
              ],
            ),
    );
  }

  static Map<String, List<SSCartLine>> _groupedLines(List<SSCartLine> lines) {
    final map = <String, List<SSCartLine>>{};
    for (final line in lines) {
      final product = SSDemoCatalog.productById(line.productId);
      final shop = product?.shopName ?? '演示店铺';
      map.putIfAbsent(shop, () => []).add(line);
    }
    return map;
  }
}

class _SelectAllRow extends ConsumerWidget {
  const _SelectAllRow({required this.cart});

  final SSCartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      child: CheckboxListTile(
        value:
            cart.allSelected ? true : (cart.hasPartialSelection ? null : false),
        tristate: true,
        onChanged: (_) =>
            ref.read(ssCartProvider.notifier).toggleSelectAll(null),
        title: const Text('全选', style: TextStyle(fontSize: 14)),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.shopName});

  final String shopName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.storefront_outlined, size: 18),
          const SizedBox(width: 8),
          Text(shopName, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line, this.showQuantity = true});

  final SSCartLine line;
  final bool showQuantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = SSDemoCatalog.productById(line.productId);
    if (product == null) return const SizedBox.shrink();
    final notifier = ref.read(ssCartProvider.notifier);

    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: line.selected,
              onChanged: (_) => notifier.toggleLine(line.lineId),
            ),
            SSDemoProductArt(artKey: product.artKey, size: 88),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: line.selected
                          ? Colors.black
                          : SSShopColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SSShopColors.pageBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      line.sku,
                      style: const TextStyle(
                        fontSize: 11,
                        color: SSShopColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SSPriceText(
                        cents: product.priceCents,
                        fontSize: 17,
                        muted: !line.selected,
                      ),
                      const Spacer(),
                      if (showQuantity)
                        _QuantityStepper(
                          quantity: line.quantity,
                          onDec: () => notifier.setQuantity(
                            line.lineId,
                            line.quantity - 1,
                          ),
                          onInc: () => notifier.setQuantity(
                            line.lineId,
                            line.quantity + 1,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDec,
    required this.onInc,
  });

  final int quantity;
  final VoidCallback onDec;
  final VoidCallback onInc;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(label: '−', onTap: onDec),
          Container(
            width: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Text('$quantity', style: const TextStyle(fontSize: 13)),
          ),
          _StepButton(label: '+', onTap: onInc),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(child: Text(label)),
      ),
    );
  }
}

class _EditModeBar extends ConsumerWidget {
  const _EditModeBar({required this.cart});

  final SSCartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = cart.lines.where((l) => l.selected).length;
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(ssCartEditModeProvider.notifier).state = false;
                  },
                  child: const Text('取消编辑'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  label: '购物车-删除选中',
                  button: true,
                  child: FilledButton(
                    onPressed: selected == 0
                        ? null
                        : () {
                            ref
                                .read(ssCartProvider.notifier)
                                .removeSelectedLines();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已删除 $selected 个演示商品行'),
                              ),
                            );
                            if (ref.read(ssCartProvider).isEmpty) {
                              ref.read(ssCartEditModeProvider.notifier).state =
                                  false;
                            }
                          },
                    child: Text('删除选中 ($selected)'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({required this.cart});

  final SSCartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCount = cart.selectedSkuCount;
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: cart.allSelected
                    ? true
                    : (cart.hasPartialSelection ? null : false),
                tristate: true,
                onChanged: (_) =>
                    ref.read(ssCartProvider.notifier).toggleSelectAll(null),
              ),
              const Text('全选', style: TextStyle(fontSize: 13)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SSPriceText(cents: cart.selectedTotalCents, fontSize: 20),
                  const Text(
                    '已优惠 ¥20.00 · 不含运费',
                    style: TextStyle(
                      fontSize: 11,
                      color: SSShopColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: selectedCount == 0
                    ? null
                    : () {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('演示结算'),
                            content: Text(
                              '已选 $selectedCount 件演示商品，合计 ¥${(cart.selectedTotalCents / 100).toStringAsFixed(2)}。\n\n未连接真实支付或下单接口。',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('知道了'),
                              ),
                            ],
                          ),
                        );
                      },
                child: Text('结算 ($selectedCount)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
