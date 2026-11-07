import 'ss_demo_product.dart';

/// 购物车行（演示数据，内存态）。
class SSCartLine {
  const SSCartLine({
    required this.lineId,
    required this.productId,
    required this.sku,
    required this.quantity,
    this.selected = true,
  });

  final String lineId;
  final String productId;
  final String sku;
  final int quantity;
  final bool selected;

  SSCartLine copyWith({
    String? lineId,
    String? productId,
    String? sku,
    int? quantity,
    bool? selected,
  }) {
    return SSCartLine(
      lineId: lineId ?? this.lineId,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
    );
  }
}

extension SSCartLineProduct on SSCartLine {
  int lineTotalCents(SSDemoProduct product) => product.priceCents * quantity;
}
