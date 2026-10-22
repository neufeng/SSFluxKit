import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_feed/ss_feed.dart';
import '../pages/ss_home_page.dart';
import '../pages/ss_media_route_page.dart';

final ssAppRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const SSHomePage(),
        routes: [
          GoRoute(
            path: 'feed',
            name: 'feed',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Feed')),
              body: SSFeedPage(
                onItemTap: (id) => context.push('/feed/$id'),
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
