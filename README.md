# SSFluxKit

基于 Flutter 的**通用 APP 开发框架** MVP 脚手架（Melos Monorepo）。公开 Dart 类型统一 **`SS` 前缀**（如 `SSHttpClient`、`SSFeedPage`）；包名/目录仍使用 snake_case。

## 仓库结构

| 路径 | 说明 |
| --- | --- |
| `apps/ss_fluxkit_demo` | Demo 宿主应用（go_router + Riverpod） |
| `packages/ss_core` | 环境、错误、Result、日志 |
| `packages/ss_network` | Dio 客户端、拦截器、分页模型 |
| `packages/ss_ui` | 骨架屏、空态/错态、网络图片 |
| `packages/ss_feed` | Feed 模型、Repository、列表/详情 UI |
| `packages/ss_media` | 音视频抽象与 Demo 播放器 |

## 架构

```
presentation (apps, ss_feed UI, ss_media UI)
        ↓
domain / application (Controllers, Repository 接口)
        ↓
data (SSHttpClient, SSFeedRepository)
        ↓
ss_core (SSEnv, SSResult, SSAppError)
```

依赖方向：**外层依赖内层**，业务通过 `SSResult` 与 `SSAppError` 统一错误形态。

## 快速开始

### 环境

- Flutter stable（3.22+ / Dart 3.5+）
- [Melos](https://melos.invertase.dev/)：`dart pub global activate melos`

### 安装与运行

```bash
# 仓库根目录
dart pub global activate melos   # 若尚未安装
export PATH="$PATH:$HOME/.pub-cache/bin"
dart pub get                     # 解析 Dart workspace
melos bootstrap

cd apps/ss_fluxkit_demo
flutter run
```

### 配置 API Base URL

默认使用 [JSONPlaceholder](https://jsonplaceholder.typicode.com) 作为公开示例 API（无密钥）。可通过编译参数覆盖：

```bash
flutter run --dart-define=SS_API_BASE_URL=https://your-api.example.com
```

Feed 在网络失败时会**自动降级为本地 Mock 数据**，便于离线演示。

### 静态检查

```bash
melos run analyze
melos run test
```

## Demo 功能

1. **首页** → Feed 列表（下拉刷新、滚动加载更多、空/错/加载态）
2. **Feed 详情** → 大图 + 正文（`cached_network_image`）
3. **Media** → 公开示例 MP3 / MP4（`just_audio` + `video_player`）；离开路由时 `dispose` 停止播放

> **Phase 2（未实现）**：Feed 列表内视频自动播放、media_kit 后端、真实鉴权、主题体系、离线同步等。

## SS 命名约定

- **必须**带 `SS` 前缀：所有对外公开的 `class` / `enum` / `typedef` / `extension` 类型名。
- **不必**带前缀：`package` 名、文件夹、文件名、私有成员（`_foo`）。

## 技术栈

| 能力 | 选型 |
| --- | --- |
| 状态管理 | Riverpod |
| 路由 | go_router |
| 网络 | Dio |
| 图片 | cached_network_image |
| 音频 | just_audio |
| 视频 | video_player（MVP；可替换为 media_kit，见 `SSVideoPlayer` 抽象） |

## CI

GitHub Actions：`.github/workflows/ci.yml` — `melos bootstrap` → `melos run analyze` → `melos run test`。

## Roadmap Phase 2

- [ ] 统一 Design System / 主题与暗色模式
- [ ] Auth 真实后端 + Token 刷新
- [ ] media_kit 视频实现与桌面/Web 适配
- [ ] Feed 流内自动播放与可见性检测
- [ ] 代码生成（Riverpod / Freezed）与模块模板 CLI
- [ ] 集成测试与 Golden 测试

## License

See [LICENSE](LICENSE).
