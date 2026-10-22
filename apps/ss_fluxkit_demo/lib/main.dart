import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_feed/ss_feed.dart';
import 'package:ss_network/ss_network.dart';

import 'router/ss_app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SSEnv.init(SSEnvConfig.fromEnvironment());
  SSLogger.init();
  runApp(
    ProviderScope(
      overrides: [
        ssHttpClientProvider.overrideWith((ref) {
          final config = SSEnv.config;
          return SSHttpClient(
            baseUrl: config.apiBaseUrl,
            enableLogging: config.enableHttpLogging,
          );
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
