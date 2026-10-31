# 环球建筑博览

> 一部装进口袋的世界建筑图鉴：39 座经典建筑、6 大洲、5 个时代，离线浏览、按维度检索、在知识图谱与世界地图之间自由穿行。

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-Stage%20Model-0A59F7?style=flat-square)
![ArkTS](https://img.shields.io/badge/ArkTS-API%2026-F26A22?style=flat-square)
![Offline](https://img.shields.io/badge/Offline-100%25-2E7D6F?style=flat-square)
![Devices](https://img.shields.io/badge/Devices-Phone-4A5568?style=flat-square)

## 项目简介

「环球建筑博览」是一款基于 HarmonyOS Stage 模型与 ArkTS / ArkUI 构建的移动端建筑文化应用。它把建筑档案、图文讲解、收藏笔记、关系图谱和世界地图整合进一个完全离线的体验中：无需网络，打开即可从古埃及金字塔一路浏览到当代地标。

内容侧收录 **39 座建筑**，覆盖 **6 个大洲**、**5 个历史时代**、**38 种建筑风格** 与 **38 位建筑师**，随包提供 **116 张建筑配图** 和 1 张世界地图底图（约 20 MB），全部来自 `rawfile`，不依赖任何在线接口。

| 维度 | 说明 |
| --- | --- |
| 应用名称 | 环球建筑博览 |
| 包名 | `com.example.myapplication` |
| 技术栈 | HarmonyOS、ArkTS、ArkUI、Hvigor |
| 编译 / 目标 SDK | API 26 |
| 最低兼容 | API 24（6.1.1） |
| 设备类型 | Phone |
| 内容规模 | 39 座建筑、6 大洲、5 时代、38 风格、38 建筑师 |
| 离线资源 | 116 张建筑配图 + 1 张世界地图底图 |
| 数据策略 | 预置内容随包、本地内存态、零网络依赖 |

## 功能一览

### 1. 首页

- 顶部全局搜索：按名称、英文名、国家、城市、建筑师即时检索。
- 推荐轮播：进入首页推荐位的建筑按热度排序展示。
- 每日建筑推荐：按日期轮换，可「换一座」。
- 资料库概览：遗址数量、大洲、时代、风格等统计。
- 大洲速览 / 时代长河：点击直接跳转「分类」页并带上筛选条件。

### 2. 分类浏览

- 三个维度组合筛选：**大洲 × 风格 × 时代**，任一维度可留空。
- 关键词与筛选条件叠加，结果实时刷新。
- 列表项展示封面、名称、国家/城市、年代与风格标签。

### 3. 建筑详情

- 顶部图集轮播：每座建筑 2–3 张实景配图，可查看图注、作者与来源。
- 档案网格：国家/城市、建造年代、建筑师、建筑风格。
- 故事卡：分段讲解建筑的历史、设计与观看要点。
- 收藏按钮与笔记入口：可为当前建筑新建/查看笔记，笔记按建筑聚合。

### 4. 知识图谱

图谱页提供两种视图，可一键切换：

- **关系图谱**：以「建筑 — 时代 / 风格 / 建筑师」构建节点网络，Canvas 绘制，支持双指缩放、单指平移、点选节点查看详情。
- **世界地图**：把每座建筑按经纬度钉在等距圆柱投影的世界地图上，支持双指缩放、单指拖拽；图例区分建筑、流派、时代、建筑师四类节点。

### 5. 收藏与笔记

- 收藏：建筑一键收藏/取消，收藏页按收藏顺序展示。
- 笔记：支持新建、编辑、删除；笔记列表按更新时间倒序，并与建筑详情双向关联。

### 6. 我的 / 同步面板

- 用户卡片、笔记数量、收藏数量等个人概览。
- 同步面板：设备列表、同步进度、冲突记录与差异对比，可选择「保留本地 / 采用云端」。

### 7. 界面与交互

- 配色为「靛蓝 + 鎏金 + 米白」的建筑图鉴风格。
- 底部为自绘的**光感悬浮导航栏**：系统厚材质背景模糊 + 顶部受光高光 + 1px 高光边 + 选中胶囊鎏金柔光，内容可从导航栏下方穿过。
- 一级导航五个 Tab：首页 / 分类 / 图谱 / 收藏 / 我的。

## 技术架构

### 分层设计（MVVM）

```text
┌──────────────────────────────────────────────┐
│ pages/        页面：首页 分类 图谱 收藏 我的    │
├──────────────────────────────────────────────┤
│ views/        可复用 UI 组件（卡片、画布、面板）│
├──────────────────────────────────────────────┤
│ viewmodels/   页面状态与展示逻辑（AppState 等） │
├──────────────────────────────────────────────┤
│ repository/   只读内容仓库 + 收藏/笔记仓库      │
├──────────────────────────────────────────────┤
│ datasource/   预置数据（PresetReader / Arch*） │
│ service/      搜索、同步编排、冲突合并          │
│ model/        纯数据模型，无 UI、无 IO          │
└──────────────────────────────────────────────┘
```

### 关键设计

| 设计点 | 实现方式 |
| --- | --- |
| 页面导航 | `Navigation` + 集中注册的 `AppNavDestination`，路径常量见 `RoutePath` |
| 状态管理 | `@ObservedV2 / @Trace`，跨页面 Tab 切换通过 `AppState` 单例与监听器回调 |
| 内容读取 | `PresetReader` 聚合按大洲拆分的 `Arch*.ets`，对上层屏蔽数据结构 |
| 检索 | `SearchService` 本地全量匹配名称 / 英文名 / 国家 / 城市 / 建筑师 / 摘要 |
| 筛选 | `ArchitectureRepository.filter(continent, style, era, keyword)` 四条件组合 |
| 图谱布局 | Canvas 直接以 vp 坐标绘制，手势驱动缩放/平移，不依赖三方图表库 |
| 地图投影 | 等距圆柱投影，`u = (lng + 180) / 360`、`v = (90 - lat) / 180`，标注不飘移 |
| 零依赖 | 运行时仅使用系统 Kit，无第三方 UI/图表依赖 |

> 当前版本的收藏、笔记为**内存态**（`FavoriteRepository` / `NoteRepository`），进程退出后不保留；同步面板为**本地模拟**（`SyncService`），尚未接入 `distributedDataObject` 与设备发现。详见「当前实现边界」。

## 工程结构

```text
jianzhu_app/
├── AppScope/                          应用级配置与图标
├── entry/src/main/ets/
│   ├── common/                        路由、主题、工具、常量
│   ├── datasource/local/              预置内容（生成物）
│   │   ├── data/Arch<Continent>.ets   按大洲拆分的建筑数据
│   │   ├── PresetData.ets             词表与聚合导出
│   │   └── PresetReader.ets           数据读取入口
│   ├── model/                         建筑、收藏、笔记、图谱、同步模型
│   ├── pages/                         页面（home/category/detail/graph/…）
│   ├── repository/                    内容、收藏、笔记、图谱仓库
│   ├── service/                       搜索、同步、冲突合并
│   ├── viewmodels/                    页面 ViewModel 与全局 AppState
│   ├── views/                         可复用 UI 组件
│   ├── entryability/                  应用入口
│   └── entrybackupability/            备份扩展
├── entry/src/main/resources/rawfile/
│   └── architecture/
│       ├── <arch_id>/1.jpg …          每座建筑 2–3 张配图
│       └── _map/world.png             世界地图底图
├── tools/                             离线内容生产工具（不参与打包）
├── build-profile.json5                构建配置（签名需本机补充）
└── oh-package.json5                   工程依赖
```

## 内容与数据

- 建筑主键为 `id`，字段包含中英文名、国家、城市、经纬度、大洲、时代、年代文本、建筑师、风格、摘要、封面渐变、推荐位与热度等。
- 详情页数据在列表字段之上增加图集、故事讲解、档案字段等。
- 配图位于 `rawfile/architecture/<id>/<n>.jpg`，图注与来源记录在 `tools/data/images_manifest.json`；正式公开发布前应核对图片授权。
- 世界地图底图为 `rawfile/architecture/_map/world.png`，2000×1000、等距圆柱投影，海洋透明以便叠加卡片底色。

## 内容生产管线（tools/）

`tools/` 是离线的数据与配图生产工具，不属于 App 运行时：

```text
data/taxonomy.json        大洲/时代/风格/建筑师词表（手工维护）
data/skeleton.json        建筑结构元数据（手工维护，id 为主键）
data/prose/*.json         分段讲解文案
        │
        ├─ prose_all.json           合并后的文案
data/images_manifest.json 配图落盘记录
        │
        ▼
scripts/gen_preset.py  ──►  entry/src/main/ets/datasource/local/
                             ├── data/Arch<Continent>.ets
                             └── PresetData.ets
                           entry/src/main/resources/rawfile/architecture/
```

常用命令：

```bash
cd tools
python3 scripts/fetch_images.py          # 抓取并统一处理配图
python3 scripts/gen_preset.py            # 由 JSON 重新生成 ArkTS 数据
python3 scripts/gen_worldmap.py          # 重建世界地图底图与陆地掩码
```

`gen_worldmap.py` 会导出 `data/worldmap-land-mask.bin` 做回归校验：把每座建筑的经纬度投到陆地掩码上，落在海洋即说明坐标或投影有误；当前 39 座建筑全部通过。

## 运行指南

### DevEco Studio

1. 用 DevEco Studio 打开项目根目录，选择 API 26 SDK，等待 Hvigor Sync 完成。
2. 在 **Project Structure → Signing Configs** 配置自动签名（当前 `build-profile.json5` 的 `signingConfigs` 为空）。
3. 选择 Phone 模拟器或真机，运行 `entry` 模块。

### 命令行构建

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
  /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
  assembleHap --mode module -p product=default --no-daemon
```

未配置签名时产物位于：

```text
entry/build/default/outputs/default/entry-default-unsigned.hap
```

## 当前实现边界

| 项目 | 现状 | 后续方向 |
| --- | --- | --- |
| 收藏 / 笔记 | 内存态，重启丢失 | 接入 RDB（`NoteDao` / `FavoriteDao`）或 Preferences |
| 多端同步 | 本地模拟：设备列表、进度、冲突均为演示数据 | 接入 `distributedDataObject` + `deviceManager`，复用现有 `SyncService` 接口 |
| 冲突合并 | 保留本地 / 采用云端 二选一 | 按字段时间戳自动合并 |
| 图片授权 | 来源与作者记录在 manifest | 公开发布前完成逐张授权核对 |
| 测试 | 保留 `ohosTest` / `test` 骨架 | 补充仓库层与合并策略单测 |

## 说明

- 应用完全离线运行，不申请网络权限。
- 建筑内容用于文化展示与学习，配图版权归原作者所有，来源见 `tools/data/images_manifest.json`。
- 版本：`1.0.0`
