# SSFluxKit

基于 Flutter 的**通用 APP 开发框架** MVP 脚手架（Melos Monorepo）。公开 Dart 类型统一 **`SS` 前缀**（如 `SSHttpClient`、`SSFeedPage`）；包名/目录仍使用 snake_case。

## 仓库结构

| 路径 | 说明 |
| --- | --- |
| `apps/ss_fluxkit_demo` | Demo 宿主应用（go_router + Riverpod） |
| `packages/ss_core` | 环境、错误、Result、日志 |
| `packages/ss_network` | Dio 客户端、鉴权/刷新拦截器、App Auth API、分页模型 |
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

---

## 本地环境搭建与运行

以下命令可在终端**逐段复制粘贴**执行（默认仓库已 clone 到本地）。

### 1. 前置依赖

| 依赖 | 要求 |
| --- | --- |
| **Git** | 任意近期版本，用于克隆仓库 |
| **Flutter** | **stable** 渠道；工程 `environment.sdk` 为 **`^3.5.0`**（见根目录与各包 `pubspec.yaml`）。当前仓库 `pubspec.lock` 解析结果为 **Dart ≥ 3.13**、**Flutter ≥ 3.47**，建议使用与之匹配的 stable，避免 workspace 解析失败 |
| **Dart** | 随 Flutter 安装；也可单独安装，但 Demo 必须以 Flutter SDK 运行 |
| **Melos** | **8.x**（根 `pubspec.yaml` 中 `melos: ^8.0.0`），用于 monorepo 脚本与 bootstrap |

**安装 Flutter（若尚未安装）**

- 官方文档：[https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- 安装后执行：

```bash
flutter doctor
flutter --version
```

**安装 Melos 并配置 PATH**

Melos 通过 `dart pub global` 安装；可执行文件位于 `$HOME/.pub-cache/bin`，需加入 PATH：

```bash
dart pub global activate melos
export PATH="$PATH:$HOME/.pub-cache/bin"
melos --version
```

建议把 `export PATH="$PATH:$HOME/.pub-cache/bin"` 写入 `~/.bashrc` 或 `~/.zshrc`，新开终端后可直接使用 `melos`。

**可选 IDE**

- [VS Code](https://code.visualstudio.com/) + [Flutter 扩展](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Android Studio](https://developer.android.com/studio) / IntelliJ + Flutter 插件  
- 打开仓库**根目录**（含根 `pubspec.yaml` 的 workspace），不要只打开单个 package 目录，否则路径依赖与 Melos 脚本可能异常。

### 2. 克隆与首次初始化

```bash
git clone https://github.com/neufeng/SSFluxKit.git
cd SSFluxKit
```

在**仓库根目录**执行（顺序不要颠倒）：

```bash
# 1) 确保 melos 在 PATH 中（见上文）
export PATH="$PATH:$HOME/.pub-cache/bin"

# 2) 解析 Dart workspace（根 pubspec 列出全部 member 包）
dart pub get

# 3) 为各 member 执行 flutter pub get，并链接 workspace 依赖
melos bootstrap
```

首次 `melos bootstrap` 会下载较多依赖，耗时取决于网络。成功后根目录存在 `pubspec.lock`，各包通过 `resolution: workspace` 共用解析结果。

### 3. 运行 Demo 应用

```bash
cd apps/ss_fluxkit_demo
flutter devices          # 查看可用设备 / 模拟器
flutter run              # 默认选中列表中的第一个设备
flutter run -d chrome    # 示例：指定 Web
flutter run -d macos     # 示例：指定 macOS 桌面
```

**设备与模拟器**

- 无设备时：先启动 Android 模拟器、iOS 模拟器（仅 macOS + Xcode），或连接真机并开启 USB 调试 / 开发者模式。
- `flutter run` 交互：终端里按 **`d`** 可切换已连接设备（热重载 **`r`**，退出 **`q`**）。

**各平台注意点（MVP Demo）**

| 平台 | 说明 |
| --- | --- |
| **Android** | 需 Android SDK；首次建议 `flutter doctor --android-licenses`。Feed / 网络图片需联网。 |
| **iOS** | 仅 **macOS**；需 Xcode 与 CocoaPods。真机需 Apple 开发者账号与签名（本仓库未配置签名）。 |
| **macOS / Windows / Linux** | 桌面端可直接 `flutter run -d macos` 等；Linux 需对应桌面依赖（`flutter doctor` 会提示）。 |
| **Web** | `flutter run -d chrome`；`video_player` / `just_audio` 在 Web 上能力有限，Media 页可能无法播放或行为与移动端不一致，**完整音视频演示建议 Android/iOS/桌面**。 |

Demo 流程：首页 → Feed（下拉刷新、加载更多）→ 详情（大图）→ Media（示例音/视频 URL）。

### 4. 编译参数（Base URL / Mock）

| 参数 | 说明 |
| --- | --- |
| `SS_API_BASE_URL` | 后端 **App API 根路径**（含 `/api/v1`，无尾斜杠）。未设置时使用 `SSEnvConfig.defaultAppApiBaseUrl`（当前默认主机 `api.example.cn`，即 `http://api.example.cn/api/v1`；管理台路径为 `http://api.example.cn/admin/v1`）。联调本机 SSFluxServer 时请显式传入 `http://localhost:8080/api/v1`（Android 模拟器可用 `http://10.0.2.2:8080/api/v1`） |
| `SS_USE_MOCK` | `true` 时使用本地 Mock Feed/Media，**跳过登录**；`false`（默认）对接 [SSFluxServer](https://github.com/neufeng/SSFluxServer) |
| `SS_DEMO_USER_EMAIL` / `SS_DEMO_USER_PASSWORD` | 登录页预填（默认与服务器 seed 一致：`demo@ssflux.local` / `DemoUser123!`） |

```bash
cd apps/ss_fluxkit_demo
# 默认 Base URL（api.example.cn），无需 SS_API_BASE_URL
flutter run --dart-define=SS_USE_MOCK=false

# 无后端时纯 UI 演示
flutter run --dart-define=SS_USE_MOCK=true

# 本机 SSFluxServer / 真机局域网
flutter run --dart-define=SS_USE_MOCK=false \
  --dart-define=SS_API_BASE_URL=http://localhost:8080/api/v1
# 真机示例：--dart-define=SS_API_BASE_URL=http://192.168.1.10:8080/api/v1
```

### 5. 常用命令

在**仓库根目录**（Melos 脚本）：

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"

melos bootstrap          # 依赖变更后重新 bootstrap
melos run analyze        # 全 workspace：flutter analyze
melos run test           # 全 workspace：flutter test
melos run format         # 全 workspace：dart format
```

在**单个包**内（示例）：

```bash
cd packages/ss_core
flutter test
flutter analyze

cd apps/ss_fluxkit_demo
flutter test
flutter run --dart-define=SS_USE_MOCK=false
```

Melos 8 的脚本定义在根目录 **`pubspec.yaml`** 的 `melos:` 段（非独立 `melos.yaml`）。

### 6. 故障排查

| 现象 | 处理建议 |
| --- | --- |
| **`melos: command not found`** | 执行 `dart pub global activate melos`，并把 `$HOME/.pub-cache/bin` 加入 PATH（见上文）。 |
| **`melos bootstrap` 报 workspace / `resolution: workspace`** | 务必在**仓库根**先执行 `dart pub get`；Flutter/Dart 版本过旧时升级 stable 至满足 `pubspec.lock`（Dart ≥ 3.13、Flutter ≥ 3.47）。 |
| **`pub get` / 依赖解析失败** | 检查网络与代理；删除各包下 `.dart_tool` 后于根目录重新 `dart pub get && melos bootstrap`。不要删除根目录 **`pubspec.lock`**（已纳入版本控制）。 |
| **`flutter doctor` 有 ❌** | 按提示安装 Android SDK、Xcode、Linux 桌面库等；CI 仅跑 analyze/test，不代替本机运行环境。 |
| **Media 页无法播放视频/音频** | 确认设备联网；Web 平台限制较多，请换 Android/iOS/桌面。Linux 需 `video_player` 对应系统库（GStreamer 等，`flutter doctor -v` 可查）。 |
| **并发 analyze 报 Flutter lock** | 根脚本已设 `concurrency: 1`；本地勿同时对多包并行多个 `flutter` 命令。 |
| **IDE 找不到 package 路径** | 用根目录打开工程，并执行过 `melos bootstrap`。 |

---

## 对接真实后端（SSFluxServer 联调）

后端仓库：[neufeng/SSFluxServer](https://github.com/neufeng/SSFluxServer) 分支 `cursor/ssfluxserver-mvp-23e6`，契约见 `api/openapi.yaml`。

### 1. 启动后端

```bash
git clone -b cursor/ssfluxserver-mvp-23e6 https://github.com/neufeng/SSFluxServer.git
cd SSFluxServer
cp .env.example .env
docker compose up --build
# API: http://localhost:8080  （App 路径前缀 /api/v1）
```

种子 App 用户（`.env.example`）：`demo@ssflux.local` / `DemoUser123!`  
管理台（禁用用户联调）：`admin@ssflux.local` / `DemoAdmin123!`

### 2. 启动 Flutter Demo（真实 API）

```bash
cd SSFluxKit/apps/ss_fluxkit_demo
# 默认已指向 http://api.example.cn/api/v1；直连本机后端请加 SS_API_BASE_URL
flutter run -d chrome --dart-define=SS_USE_MOCK=false
# 或：flutter run -d chrome --dart-define=SS_USE_MOCK=false \
#       --dart-define=SS_API_BASE_URL=http://localhost:8080/api/v1
```

流程：登录 → Feed 游标分页 → 详情 → Media 页可 **presign 上传 PNG**（需登录）。

### 3. Web / CORS

浏览器调试时，请将 Flutter Web 来源（如 `http://localhost:8081`）加入服务端 `CORS_ALLOWED_ORIGINS`（见 SSFluxServer `.env.example`）。

### 4. 自动化联调测试

在 SSFluxServer 已启动的前提下：

```bash
cd packages/ss_network
SS_RUN_INTEGRATION=true \
SS_API_BASE_URL=http://localhost:8080/api/v1 \
flutter test test/ss_real_api_integration_test.dart
```

覆盖：App 登录、Feed 分页与详情、Refresh Token 轮换、Admin 禁用用户后 `ACCOUNT_DISABLED`、测试结束重新启用用户。

### 5. 客户端实现要点

| 模块 | 能力 |
| --- | --- |
| `ss_network` | `SSAuthApi`（login/refresh/logout/me）、`SSTokenRefreshInterceptor` 单飞刷新、`SSApiError` / `SSAccountDisabledError`、`SSTokenStorage`（secure + Web SharedPreferences 回退） |
| `ss_feed` | `GET /feed` 游标分页、`GET /feed/{id}` 详情 |
| `ss_media` | `POST /media/upload-url` → PUT presigned URL → `POST /media/{id}/confirm` |

### 6. Web 联调截图（本仓库）

| 文件 | 说明 |
| --- | --- |
| `docs/screenshots/real-api-web-login.png` | Web 登录页（`SS_USE_MOCK=false`，标签：**Web**） |
| `docs/screenshots/real-api-web-home-mock.png` | Web 首页 Mock 模式（**Web**） |

> 完整「登录后 Feed + 上传」截图需本地同时运行 SSFluxServer 与 Web Demo。

---

## Demo 功能

1. **登录**（非 Mock）→ SSFluxServer App JWT + 安全存储 Refresh Token  
2. **首页** → Feed 列表（游标分页、下拉刷新、加载更多）  
3. **Feed 详情** → 大图 + 正文  
4. **Media** → 示例音/视频 + 真实 API 上传（PNG presign 流程）

> **Phase 2（未实现）**：Feed 列表内视频自动播放、media_kit、生产主题、离线同步等。

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

GitHub Actions：`.github/workflows/ci.yml` — `dart pub get` → `melos bootstrap` → `melos run analyze` → `melos run test`。

## Roadmap Phase 2

- [ ] 统一 Design System / 主题与暗色模式
- [x] Auth 真实后端 + Token 刷新（MVP，见 SSFluxServer 联调）
- [ ] media_kit 视频实现与桌面/Web 适配
- [ ] Feed 流内自动播放与可见性检测
- [ ] 代码生成（Riverpod / Freezed）与模块模板 CLI
- [ ] 集成测试与 Golden 测试

## License

See [LICENSE](LICENSE).
