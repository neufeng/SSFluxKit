import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_core/ss_core.dart';

import '../auth/ss_auth_controller.dart';

/// 原 SSFluxKit 框架 Demo 入口（从「我的」进入）。
class SSDevHubPage extends ConsumerWidget {
  const SSDevHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = SSEnv.config;
    final auth = ref.watch(ssAuthControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('SSFluxKit 框架演示')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '通用 Flutter 框架 — 可对接 SSFluxServer `/api/v1`（或 Mock）。',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text('API: ${config.apiBaseUrl}',
              style: Theme.of(context).textTheme.bodySmall),
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
              onTap: () => context.push('/dev/feed'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Media 演示'),
              subtitle: const Text('示例播放 + 真实 API 上传（需登录）'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/dev/media'),
            ),
          ),
          if (!config.useMock)
            Card(
              child: ListTile(
                leading: const Icon(Icons.login),
                title: const Text('登录'),
                onTap: () => context.push('/login'),
              ),
            ),
        ],
      ),
    );
  }
}
