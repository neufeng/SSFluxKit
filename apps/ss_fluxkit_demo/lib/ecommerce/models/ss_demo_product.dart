/// 本地演示商品（非真实 SKU / 库存）。
class SSDemoProduct {
  const SSDemoProduct({
    required this.id,
    required this.title,
    required this.priceCents,
    required this.categoryL1Id,
    required this.categoryL2Id,
    required this.shopName,
    required this.soldCount,
    required this.artKey,
    this.subtitle,
    this.skus = const ['默认规格'],
  });

  final String id;
  final String title;
  final int priceCents;
  final String categoryL1Id;
  final String categoryL2Id;
  final String shopName;
  final int soldCount;
  final String artKey;
  final String? subtitle;
  final List<String> skus;

  String get priceLabel => (priceCents / 100).toStringAsFixed(2);

  String get soldLabel {
    if (soldCount >= 10000) {
      return '已售 ${(soldCount / 10000).toStringAsFixed(1)}万';
    }
    return '已售 $soldCount';
  }
}

class SSDemoCategoryL1 {
  const SSDemoCategoryL1({required this.id, required this.name});

  final String id;
  final String name;
}

class SSDemoCategoryL2 {
  const SSDemoCategoryL2({
    required this.id,
    required this.l1Id,
    required this.name,
  });

  final String id;
  final String l1Id;
  final String name;
}
