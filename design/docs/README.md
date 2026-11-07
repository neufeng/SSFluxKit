# SSFluxKit 常规电商 UI — Phase 1 设计交付

> **范围说明**：本目录为设计资产与说明文档，不含业务代码实现。商品、价格、用户、订单均为**演示占位**，未对接真实交易、支付或账户体系。

## 打开方式

在浏览器中直接打开以下 HTML（建议 Chrome）：

| 页面 | 文件 |
| --- | --- |
| 首页 | [`screens/home.html`](./screens/home.html) |
| 分类 | [`screens/category.html`](./screens/category.html) |
| 购物车（有商品） | [`screens/cart.html`](./screens/cart.html) |
| 购物车（空态规范） | [`screens/cart-empty.html`](./screens/cart-empty.html) |
| 我的 | [`screens/profile.html`](./screens/profile.html) |
| 四页并排总览 | [`preview-overview.html`](./preview-overview.html) |

共享样式：[`tokens.css`](./tokens.css)（设计令牌）、[`phone-shell.css`](./phone-shell.css)（机壳、底部 Tab、通用组件）。

## 信息架构

固定 **4 个底部 Tab**（顺序不可变）：

1. **首页** — 定位/搜索、活动 Banner、10 宫格品类入口、双列猜你喜欢商品流  
2. **分类** — 左侧一级类目（约 96px）+ 右侧二级类目网格与热销列表  
3. **购物车** — 店铺分组、勾选、规格 SKU、数量步进器、底栏合计与结算；空态见 `cart-empty.html`  
4. **我的** — 用户头图、五态订单入口、常用服务宫格、设置类列表  

Tab 高度 **56px**，图标 **22px**，文案 **11px**；选中态使用品牌主色。

## 视觉方向

- **品牌主色**：`#1565C0`，与现有 Demo `ThemeData` seedColor 一致（`apps/ss_fluxkit_demo/lib/main.dart`）。  
- **价格/促销**：`#E53935`；辅助背景 `#F5F6F8`；卡片圆角 **12px**，按钮/搜索 **全圆角**。  
- **字体**：PingFang SC / 微软雅黑 / Noto Sans SC 系统栈。  
- **风格**：现代清爽的中文零售电商，Material 3 友好，便于 Phase 2 映射为 Flutter `ThemeData` + `NavigationBar`。

## 与现有技术栈的对应关系（实现参考，Phase 2）

| 仓库现状 | 设计映射建议 |
| --- | --- |
| Flutter Monorepo + Melos | 电商 Tab 壳层放在 `apps/ss_fluxkit_demo` 或新建 `apps/ss_shop_demo` |
| `go_router` | 四 Tab 可用 `StatefulShellRoute` + 子路由 |
| `flutter_riverpod` | 购物车选中态、Mock 商品列表 |
| `ss_ui` 空态/错态 | 购物车空态对齐 `SSEmptyState` 文案与插图规范 |
| Material 3 + seed `#1565C0` | 直接复用现有 `colorScheme`，扩展 `price` 语义色 |

## 截图产出

高分辨率 PNG 由 `scripts/capture-design-screenshots.mjs` 从本目录 HTML 渲染（需本机 Chrome + 临时安装 `puppeteer-core`、`sharp`），默认可输出至 `/opt/cursor/artifacts/ssfluxkit-ecommerce-design/`：

- `overview-four-tabs.png` — 四 Tab 并排总览  
- `tab-home.png` / `tab-category.png` / `tab-cart.png` / `tab-profile.png`  
- `tab-cart-empty.png` — 购物车空态补充稿  

## 下一阶段（实现）环境提示

- **Flutter stable**（SDK ^3.5，推荐与 `pubspec.lock` 一致的 3.47+）、**Melos 8.x**。  
- **Android / Web / Linux 桌面**：可在本类 Linux Cloud 环境完成大部分 UI 开发与 `flutter test`。  
- **iOS 模拟器与真机构建**：需 **macOS + Xcode**（本 Linux 环境不可代填 Apple 签名）。  
- 音视频等与电商无关的 Demo 路由可保留在 Shell 外或「更多」中，本设计未展开。

---

分支：`cursor/ecommerce-ui-design-6bca`（仅设计资产，不修改 `apps/`、`packages/` 业务实现）。
