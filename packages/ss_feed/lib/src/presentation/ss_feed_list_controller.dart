import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ss_feed_item.dart';
import '../data/ss_feed_repository.dart';

enum SSFeedListStatus { initial, loading, success, empty, error, loadingMore }

class SSFeedListState {
  const SSFeedListState({
    this.status = SSFeedListStatus.initial,
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  final SSFeedListStatus status;
  final List<SSFeedItem> items;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  SSFeedListState copyWith({
    SSFeedListStatus? status,
    List<SSFeedItem>? items,
    int? page,
    bool? hasMore,
    String? errorMessage,
  }) {
    return SSFeedListState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

class SSFeedListController extends StateNotifier<SSFeedListState> {
  SSFeedListController(this._repository) : super(const SSFeedListState());

  final SSFeedRepository _repository;

  Future<void> refresh() async {
    state = state.copyWith(
      status: SSFeedListStatus.loading,
      errorMessage: null,
    );
    final result = await _repository.fetchPage(page: 1);
    result.when(
      success: (page) {
        state = SSFeedListState(
          status: page.items.isEmpty
              ? SSFeedListStatus.empty
              : SSFeedListStatus.success,
          items: page.items,
          page: 1,
          hasMore: page.hasMore,
        );
      },
      failure: (error) {
        state = state.copyWith(
          status: SSFeedListStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == SSFeedListStatus.loading ||
        state.status == SSFeedListStatus.loadingMore) {
      return;
    }
    state = state.copyWith(status: SSFeedListStatus.loadingMore);
    final nextPage = state.page + 1;
    final result = await _repository.fetchPage(page: nextPage);
    result.when(
      success: (page) {
        state = SSFeedListState(
          status: SSFeedListStatus.success,
          items: [...state.items, ...page.items],
          page: nextPage,
          hasMore: page.hasMore,
        );
      },
      failure: (error) {
        state = state.copyWith(
          status: SSFeedListStatus.success,
          errorMessage: error.message,
        );
      },
    );
  }
}

final ssFeedListControllerProvider =
    StateNotifierProvider<SSFeedListController, SSFeedListState>((ref) {
  final repo = ref.watch(ssFeedRepositoryProvider);
  return SSFeedListController(repo);
});
