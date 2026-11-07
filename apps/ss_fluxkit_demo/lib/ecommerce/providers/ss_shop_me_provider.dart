import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

import '../../auth/ss_auth_controller.dart';

final ssShopMeProvider = FutureProvider<SSShopMeResponse?>((ref) async {
  if (SSEnv.config.useMock) {
    return const SSShopMeResponse(
      displayName: '演示用户',
      email: 'demo@ssflux.local',
      maskedPhone: '138****8888',
      memberLevel: '普通会员',
      orderStatusCounts: SSShopOrderStatusCounts(
        pendingShipment: 2,
      ),
      isDemoData: true,
      demoDisclaimer: '订单数量为演示数据，非真实交易',
    );
  }
  final auth = ref.watch(ssAuthControllerProvider);
  if (!auth.isAuthenticated) {
    return null;
  }
  final api = ref.watch(ssShopApiProvider);
  final result = await api.getMe();
  return result.when(
    success: (data) => data,
    failure: (e) => throw e,
  );
});
