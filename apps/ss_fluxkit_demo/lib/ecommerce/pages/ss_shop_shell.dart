import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/ss_shop_tab_bar.dart';

class SSShopShell extends StatelessWidget {
  const SSShopShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SSShopTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
