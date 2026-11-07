/// 首页宫格 → 分类 Tab 一级类目映射（演示）。
const ssHomeQuickCategoryMap = <String, String?>{
  '数码': 'digital',
  '服饰': 'apparel',
  '生鲜': 'food',
  '家居': 'appliance',
  '美妆': 'beauty',
  '运动': 'sports',
  '母婴': 'baby',
  '图书': 'computer',
  '礼品': 'food',
  '更多': null,
};

String? ssHomeQuickCategoryL1Id(String label) => ssHomeQuickCategoryMap[label];
