import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import 'package:ss_fluxkit_demo/ecommerce/providers/ss_category_selection.dart';
import 'package:ss_fluxkit_demo/main.dart';

void main() {
  SemanticsHandle? semanticsHandle;

  setUp(() {
    SSEnv.init(
      const SSEnvConfig(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        useMock: true,
      ),
    );
    semanticsHandle = SemanticsBinding.instance.ensureSemantics();
  });

  tearDown(() {
    semanticsHandle?.dispose();
    semanticsHandle = null;
    SSEnv.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = SSPreferencesTokenStorage(
      await SharedPreferences.getInstance(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [ssTokenStorageProvider.overrideWithValue(storage)],
        child: const SSFluxKitDemoApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  }

  testWidgets('home quick category navigates to category tab', (tester) async {
    await pumpApp(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NavigationBar)),
    );
    expect(container.read(ssCategoryL1Provider), 'digital');

    final apparelInGrid = find.descendant(
      of: find.byType(GridView),
      matching: find.text('服饰'),
    );
    await tester.ensureVisible(apparelInGrid);
    await tester.tap(apparelInGrid);
    await tester.pumpAndSettle();

    expect(find.text('全部分类'), findsOneWidget);
    expect(container.read(ssCategoryL1Provider), 'apparel');
    expect(find.text('服饰鞋包'), findsWidgets);
  });

  testWidgets('cart edit mode deletes selected and empty goes home',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('购物车'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('购物车-删除选中'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, '全选'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('购物车-删除选中'));
    await tester.pumpAndSettle();
    expect(find.text('购物车还是空的'), findsOneWidget);

    await tester.tap(find.text('去逛逛'));
    await tester.pumpAndSettle();
    expect(find.textContaining('搜索商品'), findsOneWidget);
  });
}
