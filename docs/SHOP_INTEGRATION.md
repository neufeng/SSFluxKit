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
  --dart-define=SS_API_BASE_URL=http://127.0.0.1:8080/api/v1
```

登录页使用环境预填邮箱/密码（**勿在日志中打印 token**）。种子账户见服务端 `SHOP_API.md` / `.env.example` 中 `SEED_DEMO_USER_*`。

## 行为摘要

- **公开**：`GET /shop/home`、`categories/*`、`products`、`products/{id}`
- **需登录**：`cart/*`、`shop/me` — 未登录展示登录引导，登录后 `reloadFromServer`；登出清空私有态缓存
- **失败**：写操作以接口返回为准，失败时保留原购物车并提示 `errorMessage`，不静默回落 Mock
- **金额**：一律 `priceCents` / `selectedTotalCents`（分）

## 本机启动后端（临时栈）

推荐 [SSFluxServer `docker-compose.yml`](https://github.com/neufeng/SSFluxServer/blob/cursor/ecommerce-shop-api-d486/docker-compose.yml)（Postgres + Redis + MinIO + API）。

无 Docker 时可本地安装 Postgres/Redis，从 `.env.example` 派生环境变量后：

```bash
go build -o ssflux-server ./cmd/server
./ssflux-server migrate
./ssflux-server seed   # 幂等；会重置演示账号购物车 canonical 行
./ssflux-server serve
```

`seed` 须在 `SEED_DEMO_USER_EMAIL` / `SEED_DEMO_USER_PASSWORD` 与登录一致时执行，否则会出现 `INVALID_CREDENTIALS`。

## 真实跨服务验证（2026-11-07，Cloud VM）

在 **SSFluxKit PR #6** 分支上，对 **分支 `cursor/ecommerce-shop-api-d486`（commit `e6279126`）** 编译运行的本机进程完成 HTTP 联调（**非** fixture / Mock）。

### 环境说明与限制

| 项 | 说明 |
| --- | --- |
| Docker | Cloud VM **无** `docker`；使用 `apt` PostgreSQL 16 + `redis-server`，数据仅在 `127.0.0.1` |
| 源码 | 私有库 `git clone` 对 Cursor shell token 返回 404；服务端源码由受权 GitHub MCP 同步至 VM 本地目录后 `go build`（**不**提交进 SSFluxKit） |
| MinIO | 官方二进制下载 410；`serve` 启动时 `EnsureBucket` 失败仅 **warn**，Shop 接口不依赖对象存储 |
| 凭证 | 联调使用种子演示账号；日志与本文 **不含** JWT / 密码 |

### HTTP 结果摘要

| 请求 | 状态 | 备注 |
| --- | --- | --- |
| `GET /shop/home` | 200 | `isDemoCatalog: true`，含 banners / quickCategories / recommendedProducts |
| `GET /shop/categories/l1` | 200 | `items[]` + `isDemoCatalog` |
| `GET /shop/products?limit=3` | 200 | 游标分页字段 `items` |
| `GET /shop/products?q=耳机` | 200 | 命中耳机类商品 |
| `GET /shop/cart`（无 Bearer） | 401 | `{"code":"UNAUTHORIZED","message":"需要登录"}` |
| `GET /shop/me`（无 Bearer） | 401 | 同上 |
| `POST /auth/login` + Bearer | 200 | 随后 `GET /shop/me` 200，`orderStatusCounts.pendingShipment ≥ 1` |
| `GET /shop/cart`（已登录） | 200 | 种子 3 行；`lineId` 为 UUID |
| `PATCH cart/lines/{uuid}` `quantity:2` | 200 | `selectedTotalCents` 与服务端重算一致（例：47700） |
| `POST cart/lines` 加购 p2 | 200 | `badgeCount` 递增（例：6） |
| `GET /shop/products?categoryL1Id=digital` | 200 | 项均为 `digital` |

后端：`go test ./internal/integration/ -run TestShop` **PASS**（同一数据库 URL）。

前端：`packages/ss_network/test/ss_shop_live_integration_test.dart` 在 `LIVE_SHOP_INTEGRATION=1` 时 **PASS**（打印指标 JSON，无 token）。

Mock 回归：`melos run test` 默认 **跳过** live 用例；`SS_USE_MOCK=true` widget/购物车单测仍 PASS。

### 一键冒烟

```bash
export SS_API_BASE_URL=http://127.0.0.1:8080/api/v1
export LIVE_SHOP_EMAIL=demo@ssflux.local
export LIVE_SHOP_PASSWORD='…'   # 与 seed 一致，勿写入仓库
./tools/shop_live_smoke.sh /tmp/shop-live-smoke.log

# Dart 同上 env，另加：
export LIVE_SHOP_INTEGRATION=1
cd packages/ss_network && flutter test test/ss_shop_live_integration_test.dart
```

## OpenAPI

后端 commit `e6279126` 已补齐 Shop 路径；若你方检出更旧 OpenAPI，请以 `SHOP_API.md` 与运行中 `/docs` 为准。
