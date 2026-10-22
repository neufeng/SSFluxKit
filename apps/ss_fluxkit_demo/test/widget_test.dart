import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import 'package:ss_fluxkit_demo/main.dart';

void main() {
  setUp(() {
    SSEnv.init(
      const SSEnvConfig(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        useMock: true,
      ),
    );
  });

  tearDown(SSEnv.reset);

  testWidgets('Home shows SSFluxKit Demo title in mock mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = SSPreferencesTokenStorage(
      await SharedPreferences.getInstance(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ssTokenStorageProvider.overrideWithValue(storage),
        ],
        child: const SSFluxKitDemoApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('SSFluxKit Demo'), findsOneWidget);
  });
}
