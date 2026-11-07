import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ss_cart_notifier.dart';
import '../theme/ss_shop_colors.dart';

class SSShopTabBar extends ConsumerWidget {
  const SSShopTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badge = ref.watch(ssCartProvider.select((s) => s.badgeCount));
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      height: 56,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '首页',
        ),
        const NavigationDestination(
          icon: Icon(Icons.apps_outlined),
          selectedIcon: Icon(Icons.apps),
          label: '分类',
        ),
        NavigationDestination(
          icon: badge > 0
              ? Badge(
                  label: Text('$badge'),
                  backgroundColor: SSShopColors.price,
                  child: const Icon(Icons.shopping_cart_outlined),
                )
              : const Icon(Icons.shopping_cart_outlined),
          selectedIcon: badge > 0
              ? Badge(
                  label: Text('$badge'),
                  backgroundColor: SSShopColors.price,
                  child: const Icon(Icons.shopping_cart),
                )
              : const Icon(Icons.shopping_cart),
          label: '购物车',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }
}
