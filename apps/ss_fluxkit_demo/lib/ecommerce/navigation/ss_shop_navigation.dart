import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ss_category_selection.dart';

/// 跳转分类 Tab 并选中一级类目（保留其他 Tab 栈状态）。
void ssNavigateToCategoryTab(
  BuildContext context,
  WidgetRef ref, {
  required String l1CategoryId,
}) {
  ref.read(ssCategoryL1Provider.notifier).state = l1CategoryId;
  context.go('/category');
}

void ssNavigateToCategoryTabDefault(BuildContext context) {
  context.go('/category');
}
