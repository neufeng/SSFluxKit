import 'package:ss_network/ss_network.dart';

/// 购物车行；API 模式含嵌套 `product` 与服务端 UUID `lineId`。
class SSCartLine {
  const SSCartLine({
    required this.lineId,
    required this.productId,
    required this.sku,
    required this.quantity,
    this.selected = true,
    this.product,
  });

  final String lineId;
  final String productId;
  final String sku;
  final int quantity;
  final bool selected;
  final SSShopProduct? product;

  SSCartLine copyWith({
    String? lineId,
    String? productId,
    String? sku,
    int? quantity,
    bool? selected,
    SSShopProduct? product,
  }) {
    return SSCartLine(
      lineId: lineId ?? this.lineId,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      product: product ?? this.product,
    );
  }

  int lineTotalCents() {
    final p = product;
    if (p == null) return 0;
    return p.priceCents * quantity;
  }
}
