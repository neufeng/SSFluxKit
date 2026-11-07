/// 电商 Shop API 数据模型（契约见 SSFluxServer `docs/SHOP_API.md`）。

class SSShopProduct {
  const SSShopProduct({
    required this.id,
    required this.title,
    required this.priceCents,
    required this.categoryL1Id,
    required this.categoryL2Id,
    required this.shopName,
    required this.soldCount,
    required this.artKey,
    required this.skus,
    this.subtitle,
    this.isDemoCatalog = true,
  });

  final String id;
  final String title;
  final int priceCents;
  final String categoryL1Id;
  final String categoryL2Id;
  final String shopName;
  final int soldCount;
  final String artKey;
  final List<String> skus;
  final String? subtitle;
  final bool isDemoCatalog;

  factory SSShopProduct.fromJson(Map<String, dynamic> json) {
    return SSShopProduct(
      id: json['id'] as String,
      title: json['title'] as String,
      priceCents: _asInt(json['priceCents']),
      categoryL1Id: json['categoryL1Id'] as String,
      categoryL2Id: json['categoryL2Id'] as String,
      shopName: json['shopName'] as String,
      soldCount: _asInt(json['soldCount']),
      artKey: json['artKey'] as String,
      skus: (json['skus'] as List<dynamic>).map((e) => e as String).toList(),
      subtitle: json['subtitle'] as String?,
      isDemoCatalog: json['isDemoCatalog'] as bool? ?? true,
    );
  }

  String get priceLabel => (priceCents / 100).toStringAsFixed(2);

  String get soldLabel {
    if (soldCount >= 10000) {
      return '已售 ${(soldCount / 10000).toStringAsFixed(1)}万';
    }
    return '已售 $soldCount';
  }
}

class SSShopCategoryL1 {
  const SSShopCategoryL1({required this.id, required this.name});

  final String id;
  final String name;

  factory SSShopCategoryL1.fromJson(Map<String, dynamic> json) {
    return SSShopCategoryL1(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class SSShopCategoryL2 {
  const SSShopCategoryL2({
    required this.id,
    required this.l1Id,
    required this.name,
  });

  final String id;
  final String l1Id;
  final String name;

  factory SSShopCategoryL2.fromJson(Map<String, dynamic> json) {
    return SSShopCategoryL2(
      id: json['id'] as String,
      l1Id: json['l1Id'] as String? ?? json['categoryL1Id'] as String,
      name: json['name'] as String,
    );
  }
}

class SSShopQuickCategory {
  const SSShopQuickCategory({required this.label, this.categoryL1Id});

  final String label;
  final String? categoryL1Id;

  factory SSShopQuickCategory.fromJson(Map<String, dynamic> json) {
    return SSShopQuickCategory(
      label: json['label'] as String,
      categoryL1Id: json['categoryL1Id'] as String?,
    );
  }
}

class SSShopBanner {
  const SSShopBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.isDemo = true,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final bool isDemo;

  factory SSShopBanner.fromJson(Map<String, dynamic> json) {
    return SSShopBanner(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      badgeText: json['badgeText'] as String?,
      isDemo: json['isDemo'] as bool? ?? true,
    );
  }
}

class SSShopHomeResponse {
  const SSShopHomeResponse({
    required this.banners,
    required this.quickCategories,
    required this.recommendedProducts,
    this.isDemoCatalog = true,
  });

  final List<SSShopBanner> banners;
  final List<SSShopQuickCategory> quickCategories;
  final List<SSShopProduct> recommendedProducts;
  final bool isDemoCatalog;

  factory SSShopHomeResponse.fromJson(Map<String, dynamic> json) {
    return SSShopHomeResponse(
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map((e) => SSShopBanner.fromJson(e as Map<String, dynamic>))
          .toList(),
      quickCategories: (json['quickCategories'] as List<dynamic>? ?? [])
          .map((e) => SSShopQuickCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedProducts: (json['recommendedProducts'] as List<dynamic>? ?? [])
          .map((e) => SSShopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDemoCatalog: json['isDemoCatalog'] as bool? ?? true,
    );
  }
}

class SSShopProductPage {
  const SSShopProductPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<SSShopProduct> items;
  final bool hasMore;
  final String? nextCursor;

  factory SSShopProductPage.fromJson(Map<String, dynamic> json) {
    return SSShopProductPage(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SSShopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

class SSShopCartLine {
  const SSShopCartLine({
    required this.lineId,
    required this.productId,
    required this.sku,
    required this.quantity,
    required this.selected,
    this.product,
  });

  final String lineId;
  final String productId;
  final String sku;
  final int quantity;
  final bool selected;
  final SSShopProduct? product;

  factory SSShopCartLine.fromJson(Map<String, dynamic> json) {
    return SSShopCartLine(
      lineId: json['lineId'] as String,
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      quantity: _asInt(json['quantity']),
      selected: json['selected'] as bool? ?? true,
      product: json['product'] == null
          ? null
          : SSShopProduct.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  SSShopCartLine copyWith({
    String? lineId,
    String? productId,
    String? sku,
    int? quantity,
    bool? selected,
    SSShopProduct? product,
  }) {
    return SSShopCartLine(
      lineId: lineId ?? this.lineId,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      product: product ?? this.product,
    );
  }
}

class SSShopCartView {
  const SSShopCartView({
    required this.lines,
    required this.badgeCount,
    required this.selectedTotalCents,
    required this.allSelected,
    required this.selectedSkuCount,
    required this.isEmpty,
    this.isDemoCatalog = true,
  });

  final List<SSShopCartLine> lines;
  final int badgeCount;
  final int selectedTotalCents;
  final bool allSelected;
  final int selectedSkuCount;
  final bool isEmpty;
  final bool isDemoCatalog;

  factory SSShopCartView.fromJson(Map<String, dynamic> json) {
    return SSShopCartView(
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((e) => SSShopCartLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      badgeCount: _asInt(json['badgeCount']),
      selectedTotalCents: _asInt(json['selectedTotalCents']),
      allSelected: json['allSelected'] as bool? ?? false,
      selectedSkuCount: _asInt(json['selectedSkuCount']),
      isEmpty: json['isEmpty'] as bool? ?? false,
      isDemoCatalog: json['isDemoCatalog'] as bool? ?? true,
    );
  }
}

class SSShopCartSummary {
  const SSShopCartSummary({
    required this.badgeCount,
    required this.selectedTotalCents,
  });

  final int badgeCount;
  final int selectedTotalCents;

  factory SSShopCartSummary.fromJson(Map<String, dynamic> json) {
    return SSShopCartSummary(
      badgeCount: _asInt(json['badgeCount']),
      selectedTotalCents: _asInt(json['selectedTotalCents']),
    );
  }
}

class SSShopOrderStatusCounts {
  const SSShopOrderStatusCounts({
    this.pendingPayment = 0,
    this.pendingShipment = 0,
    this.pendingReceipt = 0,
    this.pendingReview = 0,
    this.afterSale = 0,
  });

  final int pendingPayment;
  final int pendingShipment;
  final int pendingReceipt;
  final int pendingReview;
  final int afterSale;

  factory SSShopOrderStatusCounts.fromJson(Map<String, dynamic> json) {
    return SSShopOrderStatusCounts(
      pendingPayment: _asInt(json['pendingPayment']),
      pendingShipment: _asInt(json['pendingShipment']),
      pendingReceipt: _asInt(json['pendingReceipt']),
      pendingReview: _asInt(json['pendingReview']),
      afterSale: _asInt(json['afterSale']),
    );
  }
}

class SSShopMeResponse {
  const SSShopMeResponse({
    required this.displayName,
    required this.email,
    required this.maskedPhone,
    required this.memberLevel,
    required this.orderStatusCounts,
    this.isDemoData = true,
    this.demoDisclaimer,
  });

  final String displayName;
  final String email;
  final String maskedPhone;
  final String memberLevel;
  final SSShopOrderStatusCounts orderStatusCounts;
  final bool isDemoData;
  final String? demoDisclaimer;

  factory SSShopMeResponse.fromJson(Map<String, dynamic> json) {
    return SSShopMeResponse(
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      maskedPhone: json['maskedPhone'] as String,
      memberLevel: json['memberLevel'] as String,
      orderStatusCounts: SSShopOrderStatusCounts.fromJson(
        json['orderStatusCounts'] as Map<String, dynamic>,
      ),
      isDemoData: json['isDemoData'] as bool? ?? true,
      demoDisclaimer: json['demoDisclaimer'] as String?,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
