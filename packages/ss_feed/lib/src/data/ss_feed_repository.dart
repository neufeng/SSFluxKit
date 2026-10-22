import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import 'ss_feed_item.dart';

/// Fetches feed items from remote API or local mock fallback.
class SSFeedRepository {
  SSFeedRepository(this._client, {this.useMockOnFailure = true});

  final SSHttpClient _client;
  final bool useMockOnFailure;

  static const _pageSize = 10;

  Future<SSResult<SSOffsetPage<SSFeedItem>>> fetchPage({required int page}) async {
    final result = await _client.get<List<dynamic>>(
      '/posts',
      queryParameters: {
        '_page': page,
        '_limit': _pageSize,
      },
    );

    return result.when(
      success: (list) {
        final items = list
            .map((e) => SSFeedItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return SSSuccess(
          SSOffsetPage(
            items: items,
            page: page,
            pageSize: _pageSize,
            hasMore: items.length >= _pageSize,
          ),
        );
      },
      failure: (error) {
        if (useMockOnFailure) {
          return SSSuccess(_mockPage(page));
        }
        return SSFailure(error);
      },
    );
  }

  Future<SSResult<SSFeedItem>> fetchDetail(int id) async {
    final result = await _client.get<Map<String, dynamic>>(
      '/posts/$id',
      parser: (json) => json as Map<String, dynamic>,
    );

    return result.when(
      success: (json) => SSSuccess(SSFeedItem.fromJson(json)),
      failure: (error) {
        if (useMockOnFailure) {
          SSFeedItem? mock;
          for (final item in _mockPage(1).items) {
            if (item.id == id) {
              mock = item;
              break;
            }
          }
          if (mock != null) {
            return SSSuccess(mock);
          }
        }
        return SSFailure(error);
      },
    );
  }

  SSOffsetPage<SSFeedItem> _mockPage(int page) {
    final start = (page - 1) * _pageSize;
    final items = List.generate(_pageSize, (i) {
      final id = start + i + 1;
      return SSFeedItem(
        id: id,
        title: 'Mock 动态 #$id',
        body: '这是本地 Mock 数据，用于演示 Feed 列表与详情（网络不可用时自动降级）。',
        userId: (id % 5) + 1,
        imageUrl: 'https://picsum.photos/seed/ssmock$id/800/450',
      );
    });
    return SSOffsetPage(
      items: items,
      page: page,
      pageSize: _pageSize,
      hasMore: page < 3,
    );
  }
}

final ssFeedRepositoryProvider = Provider<SSFeedRepository>((ref) {
  final client = ref.watch(ssHttpClientProvider);
  return SSFeedRepository(client);
});

/// Provided by the host app — see demo `ss_app_providers.dart`.
final ssHttpClientProvider = Provider<SSHttpClient>((ref) {
  throw UnimplementedError(
    'Override ssHttpClientProvider in the host app.',
  );
});
