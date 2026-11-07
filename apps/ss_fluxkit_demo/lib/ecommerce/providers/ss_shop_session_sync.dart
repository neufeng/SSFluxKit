import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/ss_auth_controller.dart';
import 'ss_cart_notifier.dart';
import 'ss_shop_me_provider.dart';

/// 登录/登出时刷新 Shop 私有数据，登出不清 Mock 本地购物车。
final ssShopSessionSyncProvider = Provider<void>((ref) {
  ref.listen(ssAuthControllerProvider, (previous, next) {
    final wasIn = previous?.isAuthenticated ?? false;
    final isIn = next.isAuthenticated;
    if (wasIn && !isIn) {
      ref.invalidate(ssShopMeProvider);
      ref.read(ssCartProvider.notifier).onLoggedOut();
    } else if (!wasIn && isIn) {
      ref.invalidate(ssShopMeProvider);
      ref.read(ssCartProvider.notifier).reloadFromServer();
    }
  });
});
