import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_ui/ss_ui.dart';

import '../data/ss_feed_item.dart';
import '../data/ss_feed_repository.dart';

final ssFeedDetailProvider =
    FutureProvider.family<SSResult<SSFeedItem>, int>((ref, id) {
  return ref.watch(ssFeedRepositoryProvider).fetchDetail(id);
});

class SSFeedDetailPage extends ConsumerWidget {
  const SSFeedDetailPage({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ssFeedDetailProvider(itemId));

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: SSErrorState(message: e.toString()),
      ),
      data: (result) => result.when(
        success: (item) => Scaffold(
          appBar: AppBar(title: Text(item.title, maxLines: 1)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SSNetworkImage(
                url: item.imageUrl ?? '',
                height: 200,
                width: double.infinity,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 16),
              Text(item.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(item.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        failure: (error) => Scaffold(
          appBar: AppBar(),
          body: SSErrorState(
            message: error.message,
            onRetry: () => ref.invalidate(ssFeedDetailProvider(itemId)),
          ),
        ),
      ),
    );
  }
}
