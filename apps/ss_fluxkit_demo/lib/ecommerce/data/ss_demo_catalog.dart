import '../models/ss_demo_product.dart';

/// 静态演示目录（本地 Mock，不接真实商品接口）。
class SSDemoCatalog {
  SSDemoCatalog._();

  static const l1Categories = <SSDemoCategoryL1>[
    SSDemoCategoryL1(id: 'digital', name: '手机数码'),
    SSDemoCategoryL1(id: 'computer', name: '电脑办公'),
    SSDemoCategoryL1(id: 'appliance', name: '家用电器'),
    SSDemoCategoryL1(id: 'apparel', name: '服饰鞋包'),
    SSDemoCategoryL1(id: 'beauty', name: '美妆护肤'),
    SSDemoCategoryL1(id: 'food', name: '食品生鲜'),
    SSDemoCategoryL1(id: 'baby', name: '母婴玩具'),
    SSDemoCategoryL1(id: 'sports', name: '运动户外'),
  ];

  static const l2Categories = <SSDemoCategoryL2>[
    SSDemoCategoryL2(id: 'phone', l1Id: 'digital', name: '智能手机'),
    SSDemoCategoryL2(id: 'tablet', l1Id: 'digital', name: '平板电脑'),
    SSDemoCategoryL2(id: 'earphone', l1Id: 'digital', name: '耳机音响'),
    SSDemoCategoryL2(id: 'watch', l1Id: 'digital', name: '智能手表'),
    SSDemoCategoryL2(id: 'accessory', l1Id: 'digital', name: '数码配件'),
    SSDemoCategoryL2(id: 'camera', l1Id: 'digital', name: '摄影摄像'),
    SSDemoCategoryL2(id: 'laptop', l1Id: 'computer', name: '笔记本'),
    SSDemoCategoryL2(id: 'desktop', l1Id: 'computer', name: '台式机'),
    SSDemoCategoryL2(id: 'coat', l1Id: 'apparel', name: '上装'),
    SSDemoCategoryL2(id: 'skincare', l1Id: 'beauty', name: '面部护理'),
  ];

  static const products = <SSDemoProduct>[
    SSDemoProduct(
      id: 'p1',
      title: '轻薄降噪无线耳机 演示款 Pro',
      priceCents: 29900,
      categoryL1Id: 'digital',
      categoryL2Id: 'earphone',
      shopName: 'Flux 演示旗舰店',
      soldCount: 23000,
      artKey: 'earphone',
      subtitle: '星空黑 · 官方标配',
      skus: ['星空黑', '陶瓷白'],
    ),
    SSDemoProduct(
      id: 'p2',
      title: '全棉宽松卫衣 中性款 雾霾蓝',
      priceCents: 15900,
      categoryL1Id: 'apparel',
      categoryL2Id: 'coat',
      shopName: '生活好物自营店',
      soldCount: 8600,
      artKey: 'apparel',
      skus: ['雾霾蓝', '米白'],
    ),
    SSDemoProduct(
      id: 'p3',
      title: '智能保温杯 液晶显温 500ml',
      priceCents: 8900,
      categoryL1Id: 'appliance',
      categoryL2Id: 'accessory',
      shopName: '生活好物自营店',
      soldCount: 11000,
      artKey: 'cup',
      subtitle: '陶瓷白 · 500ml',
      skus: ['陶瓷白', '曜石黑'],
    ),
    SSDemoProduct(
      id: 'p4',
      title: '氨基酸洁面乳 温和保湿 120g',
      priceCents: 6800,
      categoryL1Id: 'beauty',
      categoryL2Id: 'skincare',
      shopName: 'Flux 演示旗舰店',
      soldCount: 56000,
      artKey: 'beauty',
      skus: ['120g 标准装'],
    ),
    SSDemoProduct(
      id: 'p5',
      title: '5G 旗舰手机 演示版 256GB',
      priceCents: 399900,
      categoryL1Id: 'digital',
      categoryL2Id: 'phone',
      shopName: 'Flux 演示旗舰店',
      soldCount: 3200,
      artKey: 'phone',
      subtitle: '幻影黑 · 官方标配',
      skus: ['幻影黑 256GB', '陶瓷白 256GB'],
    ),
    SSDemoProduct(
      id: 'p6',
      title: '主动降噪蓝牙耳机',
      priceCents: 49900,
      categoryL1Id: 'digital',
      categoryL2Id: 'earphone',
      shopName: 'Flux 演示旗舰店',
      soldCount: 12500,
      artKey: 'earphone',
      subtitle: '白色 · 续航 30h',
      skus: ['白色', '黑色'],
    ),
    SSDemoProduct(
      id: 'p7',
      title: '快充移动电源 20000mAh',
      priceCents: 12900,
      categoryL1Id: 'digital',
      categoryL2Id: 'accessory',
      shopName: 'Flux 演示旗舰店',
      soldCount: 19800,
      artKey: 'powerbank',
      subtitle: '22.5W · 双向快充',
      skus: ['标准版'],
    ),
  ];

  static SSDemoProduct? productById(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  static List<SSDemoCategoryL2> l2ForL1(String l1Id) =>
      l2Categories.where((c) => c.l1Id == l1Id).toList();

  static List<SSDemoProduct> productsForL1(String l1Id) =>
      products.where((p) => p.categoryL1Id == l1Id).take(6).toList();

  static List<SSDemoProduct> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.shopName.toLowerCase().contains(q),
        )
        .toList();
  }
}
