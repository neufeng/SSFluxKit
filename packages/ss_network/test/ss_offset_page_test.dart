import 'package:flutter_test/flutter_test.dart';
import 'package:ss_network/ss_network.dart';

void main() {
  test('SSOffsetPage.fromJson parses items', () {
    final page = SSOffsetPage.fromJson(
      {
        'items': [
          {'id': 1},
          {'id': 2},
        ],
        'page': 1,
        'pageSize': 2,
        'hasMore': true,
      },
      (json) => json['id'] as int,
    );
    expect(page.items, [1, 2]);
    expect(page.hasMore, isTrue);
  });
}
