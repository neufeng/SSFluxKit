import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import 'ss_feed_item.dart';

abstract class SSFeedRepository {
  Future<SSResult<SSCursorPage<SSFeedItem>>> fetchFeed({
    String? cursor,
    int limit = 20,
  });

  Future<SSResult<SSFeedItem>> fetchDetail(int id);
}

class SSFeedApiRepository implements SSFeedRepository {
  SSFeedApiRepository(this._client);

  final SSHttpClient _client;

  @override
  Future<SSResult<SSCursorPage<SSFeedItem>>> fetchFeed({
    String? cursor,
    int limit = 20,
  }) async {
    final result = await _client.get<Map<String, dynamic>>(
      '/feed',
      queryParameters: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return result.when(
      success: (json) {
        final page = SSCursorPage.fromJson(
          json,
          SSFeedItem.fromFeedJson,
          itemsKey: 'items',
          nextCursorKey: 'nextCursor',
          hasMoreKey: 'hasMore',
        );
        return SSSuccess(page);
      },
      failure: (error) => SSFailure(error),
    );
  }

  @override
  Future<SSResult<SSFeedItem>> fetchDetail(int id) async {
    final result = await _client.get<Map<String, dynamic>>(
      '/feed/$id',
      parser: (json) => json as Map<String, dynamic>,
    );
    return result.when(
      success: (json) => SSSuccess(SSFeedItem.fromFeedJson(json)),
      failure: (error) => SSFailure(error),
    );
  }
}

class SSFeedMockRepository implements SSFeedRepository {
  static const _pageSize = 10;

  @override
  Future<SSResult<SSCursorPage<SSFeedItem>>> fetchFeed({
    String? cursor,
    int limit = 20,
  }) async {
    final pageIndex = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
    final start = pageIndex * _pageSize;
    final items = List.generate(_pageSize, (i) {
      final id = start + i + 1;
      return SSFeedItem(
        id: id,
        title: 'Mock 动态 #$id',
        body: '本地 Mock 数据（SS_USE_MOCK=true）。',
        userId: (id % 5) + 1,
        imageUrl: 'https://picsum.photos/seed/ssmock$id/800/450',
        status: 'published',
      );
    });
    final hasMore = pageIndex < 2;
    return SSSuccess(
      SSCursorPage(
        items: items,
        nextCursor: hasMore ? '${pageIndex + 1}' : null,
        hasMore: hasMore,
      ),
    );
  }

  @override
  Future<SSResult<SSFeedItem>> fetchDetail(int id) async {
    final page = await fetchFeed();
    return page.when(
      success: (p) {
        for (final item in p.items) {
          if (item.id == id) {
            return SSSuccess(item);
          }
        }
        return SSFailure(SSNotFoundError());
      },
      failure: (e) => SSFailure(e),
    );
  }
}

final ssFeedRepositoryProvider = Provider<SSFeedRepository>((ref) {
  if (SSEnv.config.useMock) {
    return SSFeedMockRepository();
  }
  return SSFeedApiRepository(ref.watch(ssHttpClientProvider));
});
