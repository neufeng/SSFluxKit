# SSFluxKit × SSFluxServer 电商联调说明

契约源文件（只读对照）：[SSFluxServer `docs/SHOP_API.md`](https://github.com/neufeng/SSFluxServer/blob/cursor/ecommerce-shop-api-d486/docs/SHOP_API.md)、[`api/openapi.yaml`](https://github.com/neufeng/SSFluxServer/blob/cursor/ecommerce-shop-api-d486/api/openapi.yaml)。

后端 PR：https://github.com/neufeng/SSFluxServer/pull/2

## 环境变量

| 变量 | 说明 |
| --- | --- |
| `SS_USE_MOCK=true` | 纯本地演示目录/购物车，**不**调用 `/shop` API |
| `SS_USE_MOCK=false`（默认） | 目录走公开 `/shop/*`；购物车/`/shop/me` 需登录 Bearer |
| `SS_API_BASE_URL` | 与框架一致（契约文档中的 `SS_BASE_URL` 即此变量），须含 `/api/v1`，例：`http://localhost:8080/api/v1` |

```bash
# Mock（无需后端）
cd apps/ss_fluxkit_demo
flutter run -d chrome --dart-define=SS_USE_MOCK=true

# 联调 SSFluxServer（需已 migrate + seed + serve）
flutter run -d chrome \
  --dart-define=SS_USE_MOCK=false \
  --dart-define=SS_API_BASE_URL=http://localhost:8080/api/v1
```

登录页使用环境预填邮箱/密码（**勿在日志中打印 token**）。种子账户见服务端 `SHOP_API.md` 说明。

## 行为摘要

- **公开**：`GET /shop/home`、`categories/*`、`products`、`products/{id}`
- **需登录**：`cart/*`、`shop/me` — 未登录展示登录引导，登录后 `reloadFromServer`；登出清空私有态缓存
- **失败**：写操作以接口返回为准，失败时保留原购物车并提示 `errorMessage`，不静默回落 Mock
- **金额**：一律 `priceCents` / `selectedTotalCents`（分）

## 已知契约缺口（OpenAPI）

以下在 `SHOP_API.md` 有描述，当前 `openapi.yaml` 片段中路径/响应不完整，前端按文档实现：

- `GET /shop/categories/l1`、`GET /shop/categories/l1/{l1Id}/l2`
- `GET /shop/cart/summary`
- `PATCH /shop/cart/lines/{lineId}`、`POST /shop/cart/select`、`DELETE /shop/cart/lines/selected`

## 验证范围说明

- 本仓库 CI：`melos run analyze`、`melos run test`（含 `ss_shop_models_test` 与 Mock 模式 widget 测试）
- **非** 与真实 SSFluxServer 的跨服务联调（本 Cloud 环境未启动 Postgres/Go 服务）；真实联调请在本地同时运行 Server PR #2 与上述 `flutter run` 命令
