import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_feed/ss_feed.dart';
import 'package:ss_network/ss_network.dart';

import 'package:ss_fluxkit_demo/main.dart';

void main() {
  setUp(() {
    SSEnv.init(const SSEnvConfig(apiBaseUrl: 'https://example.com'));
  });

  tearDown(SSEnv.reset);

  testWidgets('Home shows SSFluxKit Demo title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ssHttpClientProvider.overrideWith(
            (ref) => SSHttpClient(baseUrl: 'https://example.com'),
          ),
        ],
        child: const SSFluxKitDemoApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('SSFluxKit Demo'), findsOneWidget);
  });
}
