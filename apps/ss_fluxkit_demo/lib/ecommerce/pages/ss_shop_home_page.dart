import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';
import 'package:ss_ui/ss_ui.dart';

import '../data/ss_home_quick_categories.dart';
import '../navigation/ss_shop_navigation.dart';
import '../providers/ss_home_search.dart';
import '../providers/ss_shop_catalog_providers.dart';
import '../theme/ss_shop_colors.dart';
import '../widgets/ss_product_card.dart';

class SSShopHomePage extends ConsumerStatefulWidget {
  const SSShopHomePage({super.key});

  @override
  ConsumerState<SSShopHomePage> createState() => _SSShopHomePageState();
}

class _SSShopHomePageState extends ConsumerState<SSShopHomePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(ssHomeSearchQueryProvider);

    if (SSEnv.config.useMock) {
      final products = ref.watch(ssHomeFilteredProductsProvider);
      return _buildHome(context, ref, products, query);
    }

    if (query.isNotEmpty) {
      return ref.watch(ssProductSearchProvider).when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Scaffold(
              body: SSErrorState(
                message: e is SSAppError ? e.message : e.toString(),
                onRetry: () => ref.invalidate(ssProductSearchProvider),
              ),
            ),
            data: (products) => _buildHome(context, ref, products, query),
          );
    }

    final homeAsync = ref.watch(ssShopHomeProvider);
    return homeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: SSErrorState(
          message: e is SSAppError ? e.message : e.toString(),
          onRetry: () => ref.invalidate(ssShopHomeProvider),
        ),
      ),
      data: (home) => _buildHome(
        context,
        ref,
        home.recommendedProducts,
        query,
        home: home,
      ),
    );
  }

  Widget _buildHome(
    BuildContext context,
    WidgetRef ref,
    List<SSShopProduct> products,
    String query, {
    SSShopHomeResponse? home,
  }) {
    final demoCatalog = home?.isDemoCatalog ?? SSEnv.config.useMock;
    final countLabel = demoCatalog ? '演示商品' : '商品';

    return Scaffold(
      backgroundColor: SSShopColors.pageBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: _HomeHeader(searchController: _searchController)),
          if (query.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  '共 ${products.length} 件$countLabel',
                  style: const TextStyle(
                    fontSize: 12,
                    color: SSShopColors.textTertiary,
                  ),
                ),
              ),
            ),
          if (query.isEmpty) ...[
            SliverToBoxAdapter(child: _PromoBanner(home: home)),
            SliverToBoxAdapter(child: _QuickCategoryGrid(home: home)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '猜你喜欢',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '推荐',
                      style: TextStyle(
                        fontSize: 12,
                        color: SSShopColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '搜索结果',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      query.isEmpty ? '暂无推荐商品' : '未找到匹配的商品',
                      style: const TextStyle(color: SSShopColors.textSecondary),
                    ),
                    if (query.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          ref.read(ssHomeSearchQueryProvider.notifier).state =
                              '';
                          _searchController.clear();
                        },
                        child: const Text('清除搜索'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => SSProductCard(product: products[index]),
                  childCount: products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), SSShopColors.pageBg],
          stops: [0, 0.55, 1],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  '送至 · 上海市浦东新区',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Icon(Icons.expand_more, size: 16, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              elevation: 1,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '搜索商品、品牌或店铺',
                  hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF999999)),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: SSShopColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      widthFactor: 1,
                      child: Text(
                        '热卖',
                        style: TextStyle(
                          fontSize: 11,
                          color: SSShopColors.primary,
                        ),
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) =>
                    ref.read(ssHomeSearchQueryProvider.notifier).state = v,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({this.home});

  final SSShopHomeResponse? home;

  @override
  Widget build(BuildContext context) {
    final banner =
        home?.banners.isNotEmpty == true ? home!.banners.first : null;
    final title = banner?.title ?? '暖冬焕新季';
    final subtitle = banner?.subtitle ?? '满299减50 · 演示活动文案';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                banner?.isDemo == false ? '活动详情暂未接入' : '演示活动：未连接真实营销活动',
              ),
            ),
          );
        },
        child: Container(
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6F60), Color(0xFFE53935), Color(0xFFC62828)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCategoryGrid extends ConsumerWidget {
  const _QuickCategoryGrid({this.home});

  final SSShopHomeResponse? home;

  static const _mockItems = [
    ('数码', Icons.phone_iphone, Color(0xFFE3F2FD)),
    ('服饰', Icons.checkroom, Color(0xFFFCE4EC)),
    ('生鲜', Icons.restaurant, Color(0xFFE8F5E9)),
    ('家居', Icons.weekend_outlined, Color(0xFFFFF3E0)),
    ('美妆', Icons.brush_outlined, Color(0xFFF3E5F5)),
    ('运动', Icons.sports_soccer, Color(0xFFE0F7FA)),
    ('母婴', Icons.child_care, Color(0xFFFFF8E1)),
    ('图书', Icons.menu_book_outlined, Color(0xFFECEFF1)),
    ('礼品', Icons.card_giftcard, Color(0xFFFFEBEE)),
    ('更多', Icons.more_horiz, Color(0xFFE8EAF6)),
  ];

  static const _iconForLabel = <String, IconData>{
    '数码': Icons.phone_iphone,
    '服饰': Icons.checkroom,
    '生鲜': Icons.restaurant,
    '家居': Icons.weekend_outlined,
    '美妆': Icons.brush_outlined,
    '运动': Icons.sports_soccer,
    '母婴': Icons.child_care,
    '图书': Icons.menu_book_outlined,
    '礼品': Icons.card_giftcard,
    '更多': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quick = home?.quickCategories;
    final useApi = quick != null && quick.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 4,
        children: (useApi
                ? quick.map(
                    (e) => _QuickCell(label: e.label, l1Id: e.categoryL1Id),
                  )
                : _mockItems.map(
                    (e) => _QuickCell(
                      label: e.$1,
                      l1Id: ssHomeQuickCategoryL1Id(e.$1),
                      icon: e.$2,
                      tint: e.$3,
                    ),
                  ))
            .toList(),
      ),
    );
  }
}

class _QuickCell extends ConsumerWidget {
  const _QuickCell({
    required this.label,
    this.l1Id,
    this.icon,
    this.tint,
  });

  final String label;
  final String? l1Id;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedIcon =
        icon ?? _QuickCategoryGrid._iconForLabel[label] ?? Icons.category;
    final resolvedTint = tint ?? SSShopColors.primaryLight;

    return Semantics(
      label: '品类-$label',
      button: true,
      child: InkWell(
        onTap: () {
          if (l1Id != null && l1Id!.isNotEmpty) {
            ssNavigateToCategoryTab(context, ref, l1CategoryId: l1Id!);
          } else {
            ssNavigateToCategoryTabDefault(context);
          }
        },
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: resolvedTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(resolvedIcon, size: 22, color: SSShopColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: SSShopColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
