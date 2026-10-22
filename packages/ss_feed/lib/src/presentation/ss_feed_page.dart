import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_ui/ss_ui.dart';

import 'ss_feed_list_controller.dart';

typedef SSFeedItemTap = void Function(int id);

class SSFeedPage extends ConsumerStatefulWidget {
  const SSFeedPage({super.key, required this.onItemTap});

  final SSFeedItemTap onItemTap;

  @override
  ConsumerState<SSFeedPage> createState() => _SSFeedPageState();
}

class _SSFeedPageState extends ConsumerState<SSFeedPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ssFeedListControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(ssFeedListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ssFeedListControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(ssFeedListControllerProvider.notifier).refresh(),
      child: switch (state.status) {
        SSFeedListStatus.initial || SSFeedListStatus.loading =>
          const SSSkeletonList(),
        SSFeedListStatus.empty => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              SSEmptyState(message: '下拉刷新试试'),
            ],
          ),
        SSFeedListStatus.error => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SSErrorState(
                message: state.errorMessage ?? '加载失败',
                onRetry: () =>
                    ref.read(ssFeedListControllerProvider.notifier).refresh(),
              ),
            ],
          ),
        SSFeedListStatus.success || SSFeedListStatus.loadingMore => _buildList(state),
      },
    );
  }

  Widget _buildList(SSFeedListState state) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = state.items[index];
        return ListTile(
          leading: SSNetworkImage(
            url: item.imageUrl ?? '',
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            item.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => widget.onItemTap(item.id),
        );
      },
    );
  }
}
