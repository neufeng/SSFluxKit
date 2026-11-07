import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ss_network/ss_network.dart';

void main() {
  test('SSShopHomeResponse parses banners and recommendedProducts', () {
    final raw = File('test/fixtures/shop_home.json').readAsStringSync();
    final home = SSShopHomeResponse.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    expect(home.isDemoCatalog, isTrue);
    expect(home.recommendedProducts.single.priceCents, 29900);
    expect(home.quickCategories.first.categoryL1Id, 'digital');
  });

  test('SSShopMeResponse parses orderStatusCounts', () {
    final raw = File('test/fixtures/shop_me.json').readAsStringSync();
    final me = SSShopMeResponse.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    expect(me.orderStatusCounts.pendingShipment, 2);
    expect(me.isDemoData, isTrue);
  });

  test('SSShopCartView parses priceCents and UUID lineId from fixture', () {
    final raw = File('test/fixtures/shop_cart.json').readAsStringSync();
    final view = SSShopCartView.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    expect(view.lines.single.lineId, contains('-'));
    expect(view.selectedTotalCents, 29900);
    expect(view.lines.single.product!.priceCents, 29900);
  });
}
