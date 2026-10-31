#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
由权威数据生成 ArkTS 预置数据模块。

输入（tools/data/）：
  taxonomy.json         大洲 / 时代 / 风格 / 建筑师 词表
  skeleton.json         建筑结构元数据（id、国家、年代、风格、建筑师…）
  prose_all.json        五段讲解文案（background/features/history/culture/story）
  images_manifest.json  配图落盘记录（file / source / credit）
  captions.json         图注（可选；缺省时用中性图注）

输出：
  entry/src/main/ets/datasource/local/data/Arch<Continent>.ets   按大洲拆分的数据模块
  entry/src/main/ets/datasource/local/PresetData.ets             词表 + 聚合导出

之所以生成 .ets 而非运行时读 rawfile JSON：仓库当前 PresetReader 为同步纯函数，
改为读 rawfile 需要引入 UIAbility context 与异步解码，在无真机/模拟器的情况下
无法验证运行时行为；生成 .ets 可保持既有已验证链路不变。图片仍走 rawfile。
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.dirname(ROOT)
DATA = os.path.join(ROOT, "data")
OUT_DATA = os.path.join(APP, "entry/src/main/ets/datasource/local/data")
OUT_PRESET = os.path.join(APP, "entry/src/main/ets/datasource/local/PresetData.ets")

CONTINENTS = [
    ("asia", "ASIA", "Asia", "亚洲"),
    ("europe", "EUROPE", "Europe", "欧洲"),
    ("africa", "AFRICA", "Africa", "非洲"),
    ("north_america", "NORTH_AMERICA", "NorthAmerica", "北美洲"),
    ("south_america", "SOUTH_AMERICA", "SouthAmerica", "南美洲"),
    ("oceania", "OCEANIA", "Oceania", "大洋洲"),
]

HEADER = """import {{ ArchitectureDetail }} from '../../../model/Architecture'

/**
 * {cn}建筑预置数据（由 tools/scripts/gen_preset.py 生成，请勿手工编辑）
 * 数据源：tools/data/skeleton.json + prose_all.json + images_manifest.json
 */
export const ARCH_{UP}: ArchitectureDetail[] = [
"""


def q(s: str) -> str:
    """输出 ArkTS 单引号字符串字面量。"""
    return "'" + str(s).replace("\\", "\\\\").replace("'", "\\'") + "'"


def arr(items) -> str:
    return "[" + ", ".join(q(x) for x in items) + "]"


def load(name, default):
    p = os.path.join(DATA, name)
    if not os.path.exists(p):
        return default
    with open(p, encoding="utf-8") as f:
        return json.load(f)


def default_caption(name: str, idx: int, total: int) -> str:
    if total <= 1:
        return f"{name} 实景"
    return f"{name} 实景（{idx}/{total}）"


def main():
    taxonomy = load("taxonomy.json", {})
    skeleton = load("skeleton.json", {"records": []})
    prose = load("prose_all.json", {})
    manifest = {b["id"]: b for b in load("images_manifest.json", {"buildings": []})["buildings"]}
    captions = load("captions.json", {})

    records = skeleton["records"]
    os.makedirs(OUT_DATA, exist_ok=True)

    by_continent = {}
    for r in records:
        by_continent.setdefault(r["continentId"], []).append(r)

    stats = {"records": 0, "images": 0, "missing_prose": [], "no_images": []}

    for cid, UP, cls, cn in CONTINENTS:
        recs = by_continent.get(cid, [])
        body = HEADER.format(cn=cn, UP=UP)
        for r in recs:
            p = prose.get(r["id"])
            if not p:
                stats["missing_prose"].append(r["id"])
                p = {k: "" for k in ("background", "features", "history", "culture", "story")}

            imgs = manifest.get(r["id"], {}).get("images", [])
            if not imgs:
                stats["no_images"].append(r["id"])

            body += "  {\n"
            body += f"    id: {q(r['id'])},\n"
            body += f"    name: {q(r['name'])},\n"
            body += f"    nameEn: {q(r['nameEn'])},\n"
            body += f"    country: {q(r['country'])},\n"
            body += f"    city: {q(r['city'])},\n"
            body += f"    lat: {r['lat']},\n"
            body += f"    lng: {r['lng']},\n"
            body += f"    continentId: {q(r['continentId'])},\n"
            body += f"    eraId: {q(r['eraId'])},\n"
            body += f"    yearText: {q(r['yearText'])},\n"
            body += f"    architectIds: {arr(r['architectIds'])},\n"
            body += f"    styleIds: {arr(r['styleIds'])},\n"
            body += f"    summary: {q(r['summary'])},\n"
            body += f"    coverFrom: {q(r['coverFrom'])},\n"
            body += f"    coverTo: {q(r['coverTo'])},\n"
            body += f"    recommended: {'true' if r['recommended'] else 'false'},\n"
            body += f"    popularity: {r['popularity']},\n"
            body += f"    background: {q(p['background'])},\n"
            body += f"    features: {q(p['features'])},\n"
            body += f"    history: {q(p['history'])},\n"
            body += f"    culture: {q(p['culture'])},\n"
            body += f"    story: {q(p['story'])},\n"
            body += "    images: [\n"
            for i, im in enumerate(imgs, 1):
                cap = captions.get(im["file"]) or default_caption(r["name"], i, len(imgs))
                body += ("      { file: " + q(im["file"]) + ", caption: " + q(cap) +
                         ", source: " + q(im["source"]) + ", credit: " + q(im.get("credit", "")) + " },\n")
            body += "    ]\n"
            body += "  },\n"
            stats["records"] += 1
            stats["images"] += len(imgs)
        body += "]\n"

        out = os.path.join(OUT_DATA, f"Arch{cls}.ets")
        with open(out, "w", encoding="utf-8") as f:
            f.write(body)

    # ---- PresetData.ets：词表 + 聚合 ----
    imports = "\n".join(
        f"import {{ ARCH_{UP} }} from './data/Arch{cls}'" for _, UP, cls, _ in CONTINENTS
    )
    agg = ",\n  ".join(f"...ARCH_{UP}" for _, UP, _, _ in CONTINENTS)

    def emit_defs(key, fields):
        out = ""
        for item in taxonomy[key]:
            vals = ", ".join(f"{f}: {q(item[f])}" for f in fields)
            out += "  { " + vals + " },\n"
        return out

    preset = f"""import {{ ArchitectureDetail, Architect, Continent, EraDef, StyleDef }} from '../../model/Architecture'
{imports}

/**
 * 预置内容数据源（由 tools/scripts/gen_preset.py 生成，请勿手工编辑）
 *
 * 建筑详情已按大洲拆分为 ./data/Arch*.ets，此处仅做词表定义与聚合，
 * PresetReader 及上层 Repository 无需感知拆分细节。
 */

export const PRESET_CONTINENTS: Continent[] = [
{emit_defs('continents', ['id', 'name', 'emoji'])}]

export const PRESET_ERAS: EraDef[] = [
{emit_defs('eras', ['id', 'name'])}]

export const PRESET_STYLES: StyleDef[] = [
{emit_defs('styles', ['id', 'name'])}]

export const PRESET_ARCHITECTS: Architect[] = [
{emit_defs('architects', ['id', 'name'])}]

export const PRESET_ARCHITECTURES: ArchitectureDetail[] = [
  {agg}
]
"""
    with open(OUT_PRESET, "w", encoding="utf-8") as f:
        f.write(preset)

    print(f"生成 {stats['records']} 座建筑 / {stats['images']} 张配图")
    print(f"  -> {OUT_DATA}/Arch*.ets ({len(CONTINENTS)} 个模块)")
    print(f"  -> {OUT_PRESET}")
    if stats["missing_prose"]:
        print("  !! 缺文案:", stats["missing_prose"])
    if stats["no_images"]:
        print(f"  !! 无配图 ({len(stats['no_images'])}):", stats["no_images"])


if __name__ == "__main__":
    main()
