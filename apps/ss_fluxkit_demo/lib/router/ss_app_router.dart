import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_feed/ss_feed.dart';

import '../auth/ss_auth_controller.dart';
import '../ecommerce/pages/ss_product_detail_page.dart';
import '../ecommerce/pages/ss_shop_cart_page.dart';
import '../ecommerce/pages/ss_shop_category_page.dart';
import '../ecommerce/pages/ss_shop_home_page.dart';
import '../ecommerce/pages/ss_shop_profile_page.dart';
import '../ecommerce/pages/ss_shop_shell.dart';
import '../pages/ss_dev_hub_page.dart';
import '../pages/ss_login_page.dart';
import '../pages/ss_media_route_page.dart';

final ssAppRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(ssAuthRefreshListenableProvider);
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      if (SSEnv.config.useMock) {
        return null;
      }
      final auth = ref.read(ssAuthControllerProvider);
      if (!auth.initialized) {
        return null;
      }
      final loggingIn = state.matchedLocation == '/login';
      final loc = state.matchedLocation;
      final isShop = loc == '/' ||
          loc.startsWith('/category') ||
          loc.startsWith('/cart') ||
          loc.startsWith('/profile') ||
          loc.startsWith('/product');
      if (!auth.isAuthenticated && !loggingIn && !isShop) {
        return '/login';
      }
      if (auth.isAuthenticated && loggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const SSLoginPage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SSProductDetailPage(productId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            SSShopShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'shopHome',
                builder: (context, state) => const SSShopHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/category',
                name: 'shopCategory',
                builder: (context, state) => const SSShopCategoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: 'shopCart',
                builder: (context, state) => const SSShopCartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'shopProfile',
                builder: (context, state) => const SSShopProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/dev',
        name: 'devHub',
        builder: (context, state) => const SSDevHubPage(),
        routes: [
          GoRoute(
            path: 'feed',
            name: 'feed',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Feed')),
              body: SSFeedPage(
                onItemTap: (id) => context.push('/dev/feed/$id'),
              ),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'feedDetail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return SSFeedDetailPage(itemId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'media',
            name: 'media',
            builder: (context, state) => const SSMediaRoutePage(),
          ),
        ],
      ),
    ],
  );
});
