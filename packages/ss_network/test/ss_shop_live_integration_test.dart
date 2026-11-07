import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_network/ss_network.dart';

/// 真实跨服务联调：本地 SSFluxServer + `LIVE_SHOP_INTEGRATION=1`。
/// 凭证：`LIVE_SHOP_EMAIL` / `LIVE_SHOP_PASSWORD`（勿提交仓库）。
void main() {
  final live = Platform.environment['LIVE_SHOP_INTEGRATION'] == '1';
  final base = Platform.environment['SS_API_BASE_URL'] ??
      'http://127.0.0.1:8080/api/v1';

  test(
    'shop catalog + cart against live server',
    () async {
    final email = Platform.environment['LIVE_SHOP_EMAIL'];
    final password = Platform.environment['LIVE_SHOP_PASSWORD'];
    if (email == null || password == null) {
      fail('LIVE_SHOP_EMAIL and LIVE_SHOP_PASSWORD required');
    }

    var accessToken = '';
    final publicDio = Dio(BaseOptions(baseUrl: base));
    final authDio = Dio(BaseOptions(baseUrl: base));
    authDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
      ),
    );

    final shopApi = SSShopApi(
      publicDio: publicDio,
      authorizedClient: SSHttpClient.fromDio(authDio),
    );

    final home = await shopApi.getHome();
    expect(home.isSuccess, isTrue);
    expect(home.dataOrNull!.recommendedProducts, isNotEmpty);

    try {
      await publicDio.get('/shop/cart');
      fail('expected 401 for unauthenticated cart');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 401);
    }

    final loginResp = await publicDio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    expect(loginResp.statusCode, 200);
    accessToken = loginResp.data!['accessToken'] as String;

    final me = await shopApi.getMe();
    expect(me.isSuccess, isTrue);
    expect(me.dataOrNull!.orderStatusCounts.pendingShipment, greaterThan(0));

    var cartBefore = await shopApi.getCart();
    expect(cartBefore.isSuccess, isTrue);
    var view = cartBefore.dataOrNull!;
    if (view.isEmpty) {
      final seeded = await shopApi.addCartLine(productId: 'p1', sku: '星空黑');
      expect(seeded.isSuccess, isTrue);
      view = seeded.dataOrNull!;
    }
    final lineId = view.lines.first.lineId;
    expect(lineId.contains('-'), isTrue);

    final patch = await shopApi.patchCartLine(lineId, quantity: 2);
    expect(patch.isSuccess, isTrue);
    final patched = patch.dataOrNull!;
    final patchedLine = patched.lines.firstWhere((l) => l.lineId == lineId);
    if (patchedLine.selected) {
      expect(
        patched.selectedTotalCents,
        patchedLine.product!.priceCents * patchedLine.quantity,
      );
    }

    final add = await shopApi.addCartLine(
      productId: 'p2',
      sku: '雾霾蓝',
      quantity: 1,
    );
    expect(add.isSuccess, isTrue);

    final search = await shopApi.getProducts(q: '耳机', limit: 5);
    expect(search.isSuccess, isTrue);
    expect(search.dataOrNull!.items, isNotEmpty);

    final l1 = await shopApi.getCategoriesL1();
    expect(l1.isSuccess, isTrue);
    final products = await shopApi.getProducts(categoryL1Id: 'digital', limit: 10);
    expect(products.isSuccess, isTrue);
    expect(
      products.dataOrNull!.items.every((p) => p.categoryL1Id == 'digital'),
      isTrue,
    );

    // ignore: avoid_print
    print(
      jsonEncode({
        'selectedTotalAfterPatch': patched.selectedTotalCents,
        'badgeAfterAdd': add.dataOrNull!.badgeCount,
        'searchHits': search.dataOrNull!.items.length,
        'categoryFilterCount': products.dataOrNull!.items.length,
      }),
    );
  },
    skip: live ? false : 'Set LIVE_SHOP_INTEGRATION=1 and start SSFluxServer',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
