import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ss_demo_catalog.dart';
import '../models/ss_cart_item.dart';

class SSCartState {
  const SSCartState({this.lines = const []});

  final List<SSCartLine> lines;

  int get badgeCount => lines.fold<int>(0, (sum, line) => sum + line.quantity);

  bool get isEmpty => lines.isEmpty;

  List<SSCartLine> get selectedLines => lines.where((l) => l.selected).toList();

  int get selectedSkuCount => selectedLines.length;

  int get selectedTotalCents {
    var total = 0;
    for (final line in selectedLines) {
      final product = SSDemoCatalog.productById(line.productId);
      if (product != null) {
        total += line.lineTotalCents(product);
      }
    }
    return total;
  }

  bool get allSelected => lines.isNotEmpty && lines.every((l) => l.selected);

  bool get hasPartialSelection => lines.any((l) => l.selected) && !allSelected;

  SSCartState copyWith({List<SSCartLine>? lines}) =>
      SSCartState(lines: lines ?? this.lines);
}

class SSCartNotifier extends Notifier<SSCartState> {
  @override
  SSCartState build() {
    if (const bool.fromEnvironment('SS_CART_DEMO_EMPTY', defaultValue: false)) {
      return const SSCartState();
    }
    // 预置演示购物车，与设计稿一致（含一条未选中）。
    return SSCartState(
      lines: [
        SSCartLine(
          lineId: 'l1',
          productId: 'p1',
          sku: '星空黑',
          quantity: 1,
          selected: true,
        ),
        SSCartLine(
          lineId: 'l2',
          productId: 'p3',
          sku: '陶瓷白',
          quantity: 2,
          selected: true,
        ),
        SSCartLine(
          lineId: 'l3',
          productId: 'p4',
          sku: '120g 标准装',
          quantity: 1,
          selected: false,
        ),
      ],
    );
  }

  void addProduct(String productId, {String? sku}) {
    final product = SSDemoCatalog.productById(productId);
    if (product == null) return;
    final resolvedSku = sku ?? product.skus.first;
    final lines = [...state.lines];
    final idx = lines.indexWhere(
      (l) => l.productId == productId && l.sku == resolvedSku,
    );
    if (idx >= 0) {
      lines[idx] = lines[idx].copyWith(quantity: lines[idx].quantity + 1);
    } else {
      lines.add(
        SSCartLine(
          lineId: 'l${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          sku: resolvedSku,
          quantity: 1,
        ),
      );
    }
    state = state.copyWith(lines: lines);
  }

  void removeLine(String lineId) {
    state = state.copyWith(
      lines: state.lines.where((l) => l.lineId != lineId).toList(),
    );
  }

  void toggleLine(String lineId) {
    state = state.copyWith(
      lines: state.lines
          .map(
            (l) => l.lineId == lineId ? l.copyWith(selected: !l.selected) : l,
          )
          .toList(),
    );
  }

  void setQuantity(String lineId, int quantity) {
    if (quantity < 1) {
      removeLine(lineId);
      return;
    }
    state = state.copyWith(
      lines: state.lines
          .map(
            (l) => l.lineId == lineId ? l.copyWith(quantity: quantity) : l,
          )
          .toList(),
    );
  }

  void toggleSelectAll(bool? value) {
    final selectAll = value ?? !state.allSelected;
    state = state.copyWith(
      lines: state.lines.map((l) => l.copyWith(selected: selectAll)).toList(),
    );
  }

  void clear() {
    state = const SSCartState();
  }

  void removeSelectedLines() {
    state = state.copyWith(
      lines: state.lines.where((l) => !l.selected).toList(),
    );
  }

  /// 测试 / 演示用：重置为预置购物车。
  void resetDemoSeed() {
    state = SSCartState(
      lines: [
        SSCartLine(
          lineId: 'l1',
          productId: 'p1',
          sku: '星空黑',
          quantity: 1,
          selected: true,
        ),
        SSCartLine(
          lineId: 'l2',
          productId: 'p3',
          sku: '陶瓷白',
          quantity: 2,
          selected: true,
        ),
        SSCartLine(
          lineId: 'l3',
          productId: 'p4',
          sku: '120g 标准装',
          quantity: 1,
          selected: false,
        ),
      ],
    );
  }
}

final ssCartProvider =
    NotifierProvider<SSCartNotifier, SSCartState>(SSCartNotifier.new);
