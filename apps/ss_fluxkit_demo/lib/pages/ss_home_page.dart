import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_core/ss_core.dart';

class SSHomePage extends StatelessWidget {
  const SSHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSFluxKit Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '通用 Flutter 框架 MVP — 分层 monorepo，公开类型均带 SS 前缀。',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'API Base: ${SSEnv.config.apiBaseUrl}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dynamic_feed_outlined),
              title: const Text('Feed 列表'),
              subtitle: const Text('下拉刷新、加载更多、详情页'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/feed'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Media 演示'),
              subtitle: const Text('示例音频 / 视频播放'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/media'),
            ),
          ),
        ],
      ),
    );
  }
}
