import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import 'auth/ss_auth_controller.dart';
import 'ecommerce/providers/ss_shop_session_sync.dart';
import 'router/ss_app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  SSEnv.init(SSEnvConfig.fromEnvironment());
  SSLogger.init();
  final storage = await createSSTokenStorage();
  runApp(
    ProviderScope(
      overrides: [
        ssTokenStorageProvider.overrideWithValue(storage),
        ssAccountDisabledHandlerProvider.overrideWith((ref) {
          return () =>
              ref.read(ssAuthControllerProvider.notifier).onAccountDisabled();
        }),
      ],
      child: const SSFluxKitDemoApp(),
    ),
  );
}

class SSFluxKitDemoApp extends ConsumerWidget {
  const SSFluxKitDemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ssShopSessionSyncProvider);
    final router = ref.watch(ssAppRouterProvider);
    return MaterialApp.router(
      title: SSEnv.config.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
