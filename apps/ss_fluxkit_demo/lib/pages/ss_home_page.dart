import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_core/ss_core.dart';

import '../auth/ss_auth_controller.dart';

class SSHomePage extends ConsumerWidget {
  const SSHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = SSEnv.config;
    final auth = ref.watch(ssAuthControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSFluxKit Demo'),
        actions: [
          if (!config.useMock && auth.isAuthenticated)
            IconButton(
              tooltip: '退出登录',
              onPressed: () async {
                await ref.read(ssAuthControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '通用 Flutter 框架 — 已对接 SSFluxServer `/api/v1`（或使用 Mock）。',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text('API: ${config.apiBaseUrl}', style: Theme.of(context).textTheme.bodySmall),
          Text(
            'Mock: ${config.useMock ? "开启 (SS_USE_MOCK)" : "关闭"}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (auth.user != null) ...[
            const SizedBox(height: 4),
            Text(
              '当前用户: ${auth.user!.displayName} (${auth.user!.email})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dynamic_feed_outlined),
              title: const Text('Feed 列表'),
              subtitle: const Text('游标分页、详情'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/feed'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Media 演示'),
              subtitle: const Text('示例播放 + 真实 API 上传（需登录）'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/media'),
            ),
          ),
        ],
      ),
    );
  }
}
