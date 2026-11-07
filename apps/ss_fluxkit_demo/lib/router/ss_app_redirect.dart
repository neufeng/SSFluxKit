import 'package:ss_core/ss_core.dart';

/// 可单测的路由重定向逻辑（与 [ssAppRouterProvider] 保持一致）。
String? ssResolveAppRedirect({
  required SSEnvConfig config,
  required bool authInitialized,
  required bool isAuthenticated,
  required String matchedLocation,
}) {
  if (config.useMock) {
    return null;
  }
  if (!authInitialized) {
    return null;
  }
  final loggingIn = matchedLocation == '/login';
  final isShop = matchedLocation == '/' ||
      matchedLocation.startsWith('/category') ||
      matchedLocation.startsWith('/cart') ||
      matchedLocation.startsWith('/profile') ||
      matchedLocation.startsWith('/product');
  if (!isAuthenticated && !loggingIn && !isShop) {
    return '/login';
  }
  if (isAuthenticated && loggingIn) {
    return '/';
  }
  return null;
}
