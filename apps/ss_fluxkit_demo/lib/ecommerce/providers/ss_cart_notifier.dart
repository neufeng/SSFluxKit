import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import '../../auth/ss_auth_controller.dart';
import '../data/ss_demo_catalog.dart';
import '../models/ss_cart_item.dart';

class SSCartState {
  const SSCartState({
    this.lines = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.requiresAuth = false,
    this.serverBadgeCount,
    this.serverSelectedTotalCents,
    this.serverAllSelected,
    this.serverSelectedSkuCount,
    this.isEmpty = true,
  });

  final List<SSCartLine> lines;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final bool requiresAuth;
  final int? serverBadgeCount;
  final int? serverSelectedTotalCents;
  final bool? serverAllSelected;
  final int? serverSelectedSkuCount;
  final bool isEmpty;

  int get badgeCount {
    if (serverBadgeCount != null) return serverBadgeCount!;
    return lines.fold<int>(0, (sum, line) => sum + line.quantity);
  }

  bool get isEmptyEffective => SSEnv.config.useMock ? lines.isEmpty : isEmpty;

  List<SSCartLine> get selectedLines => lines.where((l) => l.selected).toList();

  int get selectedSkuCount => serverSelectedSkuCount ?? selectedLines.length;

  int get selectedTotalCents {
    if (serverSelectedTotalCents != null) {
      return serverSelectedTotalCents!;
    }
    var total = 0;
    for (final line in selectedLines) {
      total += line.lineTotalCents();
    }
    return total;
  }

  bool get allSelected {
    if (serverAllSelected != null) return serverAllSelected!;
    return lines.isNotEmpty && lines.every((l) => l.selected);
  }

  bool get hasPartialSelection => lines.any((l) => l.selected) && !allSelected;

  SSCartState copyWith({
    List<SSCartLine>? lines,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
    bool? requiresAuth,
    int? serverBadgeCount,
    int? serverSelectedTotalCents,
    bool? serverAllSelected,
    int? serverSelectedSkuCount,
    bool? isEmpty,
    bool clearServer = false,
  }) {
    return SSCartState(
      lines: lines ?? this.lines,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      requiresAuth: requiresAuth ?? this.requiresAuth,
      serverBadgeCount:
          clearServer ? null : (serverBadgeCount ?? this.serverBadgeCount),
      serverSelectedTotalCents: clearServer
          ? null
          : (serverSelectedTotalCents ?? this.serverSelectedTotalCents),
      serverAllSelected:
          clearServer ? null : (serverAllSelected ?? this.serverAllSelected),
      serverSelectedSkuCount: clearServer
          ? null
          : (serverSelectedSkuCount ?? this.serverSelectedSkuCount),
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }

  static SSCartState fromApiView(SSShopCartView view,
      {bool isLoading = false}) {
    return SSCartState(
      lines: view.lines
          .map(
            (l) => SSCartLine(
              lineId: l.lineId,
              productId: l.productId,
              sku: l.sku,
              quantity: l.quantity,
              selected: l.selected,
              product: l.product,
            ),
          )
          .toList(),
      isLoading: isLoading,
      serverBadgeCount: view.badgeCount,
      serverSelectedTotalCents: view.selectedTotalCents,
      serverAllSelected: view.allSelected,
      serverSelectedSkuCount: view.selectedSkuCount,
      isEmpty: view.isEmpty,
    );
  }
}

class SSCartNotifier extends Notifier<SSCartState> {
  @override
  SSCartState build() {
    if (SSEnv.config.useMock) {
      if (const bool.fromEnvironment('SS_CART_DEMO_EMPTY',
          defaultValue: false)) {
        return const SSCartState();
      }
      return _mockSeed();
    }
    Future.microtask(reloadFromServer);
    return const SSCartState(isLoading: true);
  }

  SSShopApi get _api => ref.read(ssShopApiProvider);

  bool get _authed => ref.read(ssAuthControllerProvider).isAuthenticated;

  SSCartState _mockSeed() {
    return SSCartState(
      isEmpty: false,
      lines: [
        SSCartLine(
          lineId: 'l1',
          productId: 'p1',
          sku: '星空黑',
          quantity: 1,
          product: _demoProduct('p1'),
        ),
        SSCartLine(
          lineId: 'l2',
          productId: 'p3',
          sku: '陶瓷白',
          quantity: 2,
          product: _demoProduct('p3'),
        ),
        SSCartLine(
          lineId: 'l3',
          productId: 'p4',
          sku: '120g 标准装',
          quantity: 1,
          selected: false,
          product: _demoProduct('p4'),
        ),
      ],
    );
  }

  SSShopProduct? _demoProduct(String id) {
    final p = SSDemoCatalog.productById(id);
    if (p == null) return null;
    return SSShopProduct(
      id: p.id,
      title: p.title,
      priceCents: p.priceCents,
      categoryL1Id: p.categoryL1Id,
      categoryL2Id: p.categoryL2Id,
      shopName: p.shopName,
      soldCount: p.soldCount,
      artKey: p.artKey,
      skus: p.skus,
      subtitle: p.subtitle,
    );
  }

  void onLoggedOut() {
    if (SSEnv.config.useMock) return;
    state = const SSCartState(requiresAuth: true, isEmpty: true);
  }

  Future<void> reloadFromServer() async {
    if (SSEnv.config.useMock) return;
    if (!_authed) {
      state = const SSCartState(requiresAuth: true, isEmpty: true);
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _api.getCart();
    result.when(
      success: (view) {
        state = SSCartState.fromApiView(view);
      },
      failure: (error) {
        state = _errorState(error);
      },
    );
  }

  SSCartState _errorState(SSAppError error) {
    if (error is SSUnauthorizedError) {
      return const SSCartState(requiresAuth: true, isEmpty: true);
    }
    return SSCartState(
      errorMessage: error.message,
      isLoading: false,
      lines: state.lines,
      serverBadgeCount: state.serverBadgeCount,
      serverSelectedTotalCents: state.serverSelectedTotalCents,
      serverAllSelected: state.serverAllSelected,
      serverSelectedSkuCount: state.serverSelectedSkuCount,
      isEmpty: state.isEmpty,
    );
  }

  Future<bool> _applyViewResult(SSResult<SSShopCartView> result) async {
    return result.when(
      success: (view) {
        state = SSCartState.fromApiView(view);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          isMutating: false,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  Future<void> addProduct(String productId, {String? sku}) async {
    if (SSEnv.config.useMock) {
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
            product: _demoProduct(productId),
          ),
        );
      }
      state = state.copyWith(lines: lines, isEmpty: false);
      return;
    }
    if (!_authed) {
      state = const SSCartState(requiresAuth: true, isEmpty: true);
      return;
    }
    state = state.copyWith(isMutating: true, clearError: true);
    final result = await _api.addCartLine(
      productId: productId,
      sku: sku,
    );
    await _applyViewResult(result);
    state = state.copyWith(isMutating: false);
  }

  Future<void> removeLine(String lineId) async {
    if (SSEnv.config.useMock) {
      final lines = state.lines.where((l) => l.lineId != lineId).toList();
      state = state.copyWith(lines: lines, isEmpty: lines.isEmpty);
      return;
    }
    state = state.copyWith(isMutating: true, clearError: true);
    await _applyViewResult(await _api.deleteCartLine(lineId));
    state = state.copyWith(isMutating: false);
  }

  Future<void> toggleLine(String lineId) async {
    if (SSEnv.config.useMock) {
      state = state.copyWith(
        lines: state.lines
            .map(
              (l) => l.lineId == lineId ? l.copyWith(selected: !l.selected) : l,
            )
            .toList(),
        clearServer: true,
      );
      return;
    }
    final line = state.lines.firstWhere((l) => l.lineId == lineId);
    state = state.copyWith(isMutating: true, clearError: true);
    await _applyViewResult(
      await _api.patchCartLine(lineId, selected: !line.selected),
    );
    state = state.copyWith(isMutating: false);
  }

  Future<void> setQuantity(String lineId, int quantity) async {
    if (quantity < 1) {
      await removeLine(lineId);
      return;
    }
    if (SSEnv.config.useMock) {
      state = state.copyWith(
        lines: state.lines
            .map((l) => l.lineId == lineId ? l.copyWith(quantity: quantity) : l)
            .toList(),
        clearServer: true,
      );
      return;
    }
    state = state.copyWith(isMutating: true, clearError: true);
    await _applyViewResult(
      await _api.patchCartLine(lineId, quantity: quantity),
    );
    state = state.copyWith(isMutating: false);
  }

  Future<void> toggleSelectAll(bool? value) async {
    if (SSEnv.config.useMock) {
      final selectAll = value ?? !state.allSelected;
      state = state.copyWith(
        lines: state.lines.map((l) => l.copyWith(selected: selectAll)).toList(),
        clearServer: true,
      );
      return;
    }
    final selectAll = value ?? !state.allSelected;
    state = state.copyWith(isMutating: true, clearError: true);
    await _applyViewResult(
      await _api.selectCart(all: true, selected: selectAll),
    );
    state = state.copyWith(isMutating: false);
  }

  Future<void> removeSelectedLines() async {
    if (SSEnv.config.useMock) {
      final remaining = state.lines.where((l) => !l.selected).toList();
      state = state.copyWith(
        lines: remaining,
        isEmpty: remaining.isEmpty,
        clearServer: true,
      );
      return;
    }
    state = state.copyWith(isMutating: true, clearError: true);
    await _applyViewResult(await _api.deleteSelectedLines());
    state = state.copyWith(isMutating: false);
  }
}

final ssCartProvider =
    NotifierProvider<SSCartNotifier, SSCartState>(SSCartNotifier.new);
