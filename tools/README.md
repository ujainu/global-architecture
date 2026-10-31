# tools —— 建筑内容生产管线

本目录不属于 App 运行时，是**离线内容生产工具**。App 只消费生成结果：
`entry/src/main/ets/datasource/local/`（数据）与
`entry/src/main/resources/rawfile/architecture/`（配图）。

## 数据流

```
data/taxonomy.json          大洲/时代/风格/建筑师 词表（手工维护）
data/skeleton.json          建筑结构元数据（手工维护，id 是主键）
data/prose/*.json           五段讲解文案（子代理撰写，人工/脚本校验）
        │
        ├─ prose_all.json           合并后的文案
        │
data/images_manifest.json   配图落盘记录（抓取脚本产出）
data/captions.json          图注覆盖（可选，键为 rawfile 相对路径）
        │
        ▼
scripts/gen_preset.py  ──►  entry/src/main/ets/datasource/local/
                              ├── data/Arch<Continent>.ets   按大洲拆分
                              └── PresetData.ets             词表 + 聚合导出
                            entry/src/main/resources/rawfile/architecture/<id>/<n>.jpg
```

## 命令

```bash
# 1) 抓取配图（下载 → 校验 → 统一 900px JPEG → 落盘 rawfile）
python3 scripts/fetch_images.py                 # 全部
python3 scripts/fetch_images.py taj_mahal       # 只跑指定 id

# 2) 由数据生成 ArkTS 模块（每次改完 JSON 都要重跑）
python3 scripts/gen_preset.py

# 3) 生成世界地图底图（图谱页「世界地图」视图用，改了矢量数据或配色才需重跑）
python3 scripts/gen_worldmap.py

# 4) 构建验证
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
  /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
  assembleHap --mode module -p product=default --no-daemon
```

## 世界地图底图

图谱页的「世界地图」视图需要一张**地理边界精确已知**的底图——否则标注点必然飘移。
网络上现成的世界地图多为墨卡托投影或经过裁切，无法确认经纬度范围；
故用 Natural Earth 50m 的 TopoJSON（world-atlas）自行栅格化：

- 投影：等距圆柱（Plate Carrée），严格 `lon∈[-180,180]`、`lat∈[-90,90]`，输出 2000×1000（正好 2:1）
- 于是 App 内定位只需线性换算：`u = (lng+180)/360`，`v = (90-lat)/180`
- 海洋透明（便于叠在卡片底色上）、陆地浅靛蓝、50m 国界/海岸线、30° 经纬网
- 依赖仅标准库——本机 `python3` 是 x86_64 而 PIL 是 arm64（`dlopen` 失败），
  故脚本自带一个极简 PNG 编码器（zlib + struct）

脚本会顺带导出 `data/worldmap-land-mask.bin`（陆地掩码），用于回归校验：
把每座建筑的经纬度投到掩码上，若落在海洋即说明坐标或投影有误。
**当前 39 座建筑 39/39 通过。** 新增建筑后建议重跑这条校验。

> 两个已修的栅格化坑：
> 1. 扫描线分桶的**起始行必须用 `floor` 而非 `ceil`**——边顶部端点所在行同样产生交点，
>    用 `ceil` 会整行漏掉，填充出现空洞（当时印度整块缺失）。
> 2. 导出陆地掩码时只认 `alpha=255`（陆地/边界），`alpha=120` 的经纬网不算陆地，
>    否则落在经纬网上的海洋点会被误判为陆地。
>
> 另注：110m 数据精度不够，伊斯坦布尔、悉尼两处海岸线城市会落进海里；
> 换 50m 后 39/39 全部落陆。

## 配图抓取策略

本机（中国大陆网络）**直连 Wikipedia / Wikimedia Commons 被阻断**，因此：

1. **Wikimedia Commons（首选图源）** —— 经 `wsrv.nl` 图片代理访问
   `commons.wikimedia.org/wiki/Special:FilePath/<Wikipedia 条目名>.jpg`。
   命中即为自由许可图源，出处记为该 Commons 文件页。
2. **Bing 图片检索（兜底）** —— 解析结果块中的 `murl`（图片直链）、
   `purl`（来源页，作为出处记录）、`t`（标题，用于相关性判定）。

抓取时的三道过滤：

- **相关性**：标题或来源页须命中建筑中文名 / 别名 / 英文名词元，
  并排除地图、简笔画、矢量素材、平面图等明显无关结果。
- **图源信誉**：排除中文水印图库（昵图网、摄图网、千图网等），
  优先 Commons / Unsplash / Pexels / Pixabay。
- **内容去重**：按字节 SHA1 去重；同一来源站最多取 2 张，保证多样性。

> ⚠️ **两个务必注意的坑（已踩过）**
> 1. `cn.bing.com/images/search` 的 `q` 参数若含**空格分词的中文多词查询**
>    （如「泰姬陵 建筑」），会返回完全无关的结果；必须使用**单词短语**查询。
> 2. 本机 `python3` 是 x86_64 而 `PIL` 是 arm64，`import PIL.Image` 会
>    `dlopen` 失败。因此图片处理统一改用 macOS 原生 **`sips`**，无第三方依赖。

## 图片规格

- 最长边 900px，JPEG，quality 82，progressive
- 拒绝：短边 < 340px、长宽比 > 2.6 的条幅
- 单张约 120–220 KB，39 座 × 3 张约 20 MB

## 已知遗留

- **未做视觉核验**：本机未配置视觉服务（`modlens doctor` 无 provider），
  且主模型不支持读图，因此图片**只做了文本层面的相关性过滤，未经人眼/AI 看图确认**。
  图注统一使用「<建筑名> 实景（i/n）」这类中性表述，详情页 ⓘ 可查看每张图的真实出处。
  后续如需精确图注，可接入视觉模型批量看图生成 `data/captions.json`。
- 版权：图源以 Commons 等自由许可为主，其余为「网络公开图片，仅作学习演示」。
  正式发布前建议逐张核查 `data/images_manifest.json` 中的 `source` 与 `credit`。
