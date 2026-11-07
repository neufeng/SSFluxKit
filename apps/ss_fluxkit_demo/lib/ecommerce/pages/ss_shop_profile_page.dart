import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';
import 'package:ss_ui/ss_ui.dart';

import '../../auth/ss_auth_controller.dart';
import '../providers/ss_shop_me_provider.dart';
import '../theme/ss_shop_colors.dart';

class SSShopProfilePage extends ConsumerWidget {
  const SSShopProfilePage({super.key});

  void _demoSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(ssShopMeProvider);
    final auth = ref.watch(ssAuthControllerProvider);

    return Scaffold(
      backgroundColor: SSShopColors.pageBg,
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SSErrorState(
          message: e is SSAppError ? e.message : e.toString(),
          onRetry: () => ref.invalidate(ssShopMeProvider),
        ),
        data: (me) {
          if (!SSEnv.config.useMock && !auth.isAuthenticated) {
            return _LoggedOutBody(
              onLogin: () => context.push('/login'),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ProfileHeader(me: me)),
              if (me?.demoDisclaimer != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Material(
                      color: SSShopColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          me!.demoDisclaimer!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SSShopColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: _OrderCard(
                  counts: me?.orderStatusCounts,
                  onTap: _demoSnack,
                ),
              ),
              SliverToBoxAdapter(
                child: _ServiceGrid(
                  onService: (label) {
                    if (label == '框架演示') {
                      context.push('/dev');
                    } else if (label == 'Feed 列表') {
                      context.push('/dev/feed');
                    } else if (label == 'Media 演示') {
                      context.push('/dev/media');
                    } else if (label == '登录 / 账户') {
                      context.push('/login');
                    } else {
                      _demoSnack(context, '「$label」为演示入口，未连接真实业务');
                    }
                  },
                ),
              ),
              SliverToBoxAdapter(child: _SettingsList(onTap: _demoSnack)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _LoggedOutBody extends StatelessWidget {
  const _LoggedOutBody({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline,
                size: 64, color: SSShopColors.textTertiary),
            const SizedBox(height: 16),
            const Text(
              '登录后查看订单与账户信息',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '商品浏览无需登录；购物车与我的页需 Bearer 会话',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: SSShopColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onLogin,
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.me});

  final SSShopMeResponse? me;

  @override
  Widget build(BuildContext context) {
    final display = me?.displayName ?? '演示用户';
    final phone = me?.maskedPhone ?? '手机号未绑定';
    final member = me?.memberLevel ?? '普通会员';
    final initial = display.isNotEmpty ? display.characters.first : '?';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _MemberBadge(level: member),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          '✦ $level',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.counts, required this.onTap});

  final SSShopOrderStatusCounts? counts;
  final void Function(BuildContext, String) onTap;

  static const _items = [
    ('待付款', Icons.payment_outlined, _CountKey.pendingPayment),
    ('待发货', Icons.inventory_2_outlined, _CountKey.pendingShipment),
    ('待收货', Icons.local_shipping_outlined, _CountKey.pendingReceipt),
    ('待评价', Icons.star_outline, _CountKey.pendingReview),
    ('退换/售后', Icons.assignment_return_outlined, _CountKey.afterSale),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, -16, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的订单',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => onTap(context, '全部订单'),
                child: const Text(
                  '全部订单 ›',
                  style: TextStyle(
                    fontSize: 12,
                    color: SSShopColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _items.map((e) {
              final badge = _badgeFor(e.$3, counts);
              return InkWell(
                onTap: () => onTap(context, e.$1),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: SSShopColors.pageBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(e.$2, color: SSShopColors.primary),
                        ),
                        if (badge != null)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: SSShopColors.price,
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.$1,
                      style: const TextStyle(
                        fontSize: 11,
                        color: SSShopColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String? _badgeFor(_CountKey key, SSShopOrderStatusCounts? counts) {
    if (counts == null) return null;
    final value = switch (key) {
      _CountKey.pendingPayment => counts.pendingPayment,
      _CountKey.pendingShipment => counts.pendingShipment,
      _CountKey.pendingReceipt => counts.pendingReceipt,
      _CountKey.pendingReview => counts.pendingReview,
      _CountKey.afterSale => counts.afterSale,
    };
    return value > 0 ? '$value' : null;
  }
}

enum _CountKey {
  pendingPayment,
  pendingShipment,
  pendingReceipt,
  pendingReview,
  afterSale,
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({required this.onService});

  final void Function(String label) onService;

  static const _services = [
    ('优惠券', Icons.confirmation_number_outlined),
    ('收货地址', Icons.location_on_outlined),
    ('我的收藏', Icons.favorite_border),
    ('浏览记录', Icons.history),
    ('联系客服', Icons.support_agent),
    ('Feed 列表', Icons.dynamic_feed_outlined),
    ('Media 演示', Icons.play_circle_outline),
    ('框架演示', Icons.developer_mode_outlined),
    ('登录 / 账户', Icons.login_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '常用服务',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            children: _services.map((s) {
              return InkWell(
                onTap: () => onService(s.$1),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: SSShopColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(s.$2, size: 20, color: SSShopColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.$1,
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.onTap});

  final void Function(BuildContext, String) onTap;

  @override
  Widget build(BuildContext context) {
    final rows = [
      '账户与安全',
      '消息通知',
      '关于 SSFluxKit 电商 Demo',
    ];
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.map((title) {
          return ListTile(
            title: Text(title, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => onTap(context, title),
          );
        }).toList(),
      ),
    );
  }
}
