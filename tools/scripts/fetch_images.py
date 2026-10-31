#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
建筑配图抓取管线。

策略（按优先级）：
  1) Wikimedia Commons —— 经 wsrv.nl 图片代理（本机直连 Wikimedia 被墙）。
     通过 Special:FilePath/<Wikipedia 条目名>.jpg 猜测规范文件名，命中即为首选图源。
  2) Bing 图片检索 —— 抓取 murl 直链，按域名信誉排序（Unsplash/Pexels/Pixabay 等
     可商用图源优先，图库水印站降权），逐个下载校验。

产出：
  entry/src/main/resources/rawfile/architecture/<id>/<n>.jpg   （统一 JPEG，最长边 900）
  tools/data/images_manifest.json                              （每张图的出处与许可记录）
"""
import hashlib
import html as html_mod
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.parse

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.dirname(ROOT)
RAW = os.path.join(APP, "entry/src/main/resources/rawfile/architecture")
MANIFEST = os.path.join(ROOT, "data/images_manifest.json")

UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/120.0 Safari/537.36")

TARGET_PER_BUILDING = 3
MAX_EDGE = 900
JPEG_Q = 82

# 可商用/开放许可图源 —— 优先
GOOD_HOSTS = ("upload.wikimedia.org", "commons.wikimedia.org", "unsplash.com",
              "pexels.com", "pixabay.com", "publicdomainpictures.net",
              "openverse.org", "flickr.com", "staticflickr.com")
# 图库水印 / 防盗链站 —— 排除（中文素材站图片普遍带水印，观感差）
BAD_HOSTS = ("699pic", "veer.com", "gettyimages", "shutterstock", "dreamstime",
             "alamy", "depositphotos", "istockphoto", "tuchong", "hippopx",
             "zhimg.com", "zhihu.com", "sinaimg", "zcool", "58pic", "qiantucdn",
             "baidu.com", "bdstatic", "gtimg", "sogou", "toutiao", "byteimg",
             "nipic", "wmpic", "588ku", "pngtree", "lovepik", "sucai", "photophoto",
             "ooopic", "16pic", "3png", "51yuansu", "chazidian", "anymake")

BUILDINGS = [
    # id, 中文名, 英文名, Wikipedia 条目名, 检索别名
    ("giza_pyramid",        "吉萨大金字塔",   "Great Pyramid of Giza",   "Great_Pyramid_of_Giza", ["吉萨金字塔", "大金字塔", "胡夫金字塔"]),
    ("angkor_wat",          "吴哥窟",         "Angkor Wat",              "Angkor_Wat",            ["吴哥寺", "小吴哥"]),
    ("taj_mahal",           "泰姬陵",         "Taj Mahal",               "Taj_Mahal",             ["泰姬玛哈"]),
    ("petra",               "佩特拉古城",     "Petra",                   "Petra",                 ["佩特拉"]),
    ("hagia_sophia",        "圣索菲亚大教堂", "Hagia Sophia",            "Hagia_Sophia",          ["圣索菲亚", "阿亚索菲亚"]),
    ("blue_mosque",         "蓝色清真寺",     "Blue Mosque",             "Blue_Mosque",           ["苏丹艾哈迈德清真寺"]),
    ("colosseum",           "罗马斗兽场",     "Colosseum",               "Colosseum",             ["斗兽场", "古罗马斗兽场", "圆形竞技场"]),
    ("pantheon",            "万神殿",         "Pantheon Rome",           "Pantheon,_Rome",        ["万神庙", "罗马万神殿"]),
    ("st_peters_basilica",  "圣彼得大教堂",   "St Peter's Basilica",     "St._Peter's_Basilica",  ["圣彼得", "圣伯多禄大殿"]),
    ("pisa_tower",          "比萨斜塔",       "Leaning Tower of Pisa",   "Leaning_Tower_of_Pisa", ["比萨塔"]),
    ("sagrada_familia",     "圣家族大教堂",   "Sagrada Familia",         "Sagrada_Família",       ["圣家堂", "圣家族教堂"]),
    ("alhambra",            "阿尔罕布拉宫",   "Alhambra",                "Alhambra",              ["阿尔罕布拉"]),
    ("parthenon",           "帕特农神庙",     "Parthenon",               "Parthenon",             ["帕特农", "雅典娜神庙"]),
    ("eiffel_tower",        "埃菲尔铁塔",     "Eiffel Tower",            "Eiffel_Tower",          ["艾菲尔铁塔"]),
    ("louvre",              "卢浮宫",         "Louvre Museum",           "Louvre",                ["罗浮宫"]),
    ("notre_dame",          "巴黎圣母院",     "Notre Dame Paris",        "Notre-Dame_de_Paris",   ["圣母院"]),
    ("versailles",          "凡尔赛宫",       "Palace of Versailles",    "Palace_of_Versailles",  ["凡尔赛"]),
    ("stonehenge",          "巨石阵",         "Stonehenge",              "Stonehenge",            ["索尔兹伯里巨石阵"]),
    ("big_ben",             "大本钟",         "Big Ben London",          "Big_Ben",               ["伊丽莎白塔", "威斯敏斯特宫"]),
    ("tower_bridge",        "伦敦塔桥",       "Tower Bridge",            "Tower_Bridge",          ["塔桥"]),
    ("cologne_cathedral",   "科隆大教堂",     "Cologne Cathedral",       "Cologne_Cathedral",     ["科隆主教座堂"]),
    ("neuschwanstein",      "新天鹅堡",       "Neuschwanstein Castle",   "Neuschwanstein_Castle", ["新天鹅石堡"]),
    ("st_basils_cathedral", "圣瓦西里大教堂", "Saint Basil's Cathedral", "Saint_Basil's_Cathedral", ["圣瓦西里", "瓦西里升天教堂"]),
    ("moscow_kremlin",      "莫斯科克里姆林宫", "Moscow Kremlin",        "Moscow_Kremlin",        ["克里姆林宫"]),
    ("winter_palace",       "冬宫",           "Winter Palace",           "Winter_Palace",         ["艾尔米塔什", "埃尔米塔日"]),
    ("statue_of_liberty",   "自由女神像",     "Statue of Liberty",       "Statue_of_Liberty",     ["自由女神"]),
    ("empire_state",        "帝国大厦",       "Empire State Building",   "Empire_State_Building", ["纽约帝国大厦"]),
    ("white_house",         "白宫",           "White House",             "White_House",           ["美国总统府"]),
    ("golden_gate_bridge",  "金门大桥",       "Golden Gate Bridge",      "Golden_Gate_Bridge",    ["金门桥"]),
    ("machu_picchu",        "马丘比丘",       "Machu Picchu",            "Machu_Picchu",          ["马丘比丘古城"]),
    ("cristo_redentor",     "基督救世主雕像", "Christ the Redeemer",     "Christ_the_Redeemer_(statue)", ["基督救世主", "救世基督像", "巴西基督像"]),
    ("sydney_opera",        "悉尼歌剧院",     "Sydney Opera House",      "Sydney_Opera_House",    ["雪梨歌剧院"]),
    ("burj_khalifa",        "哈利法塔",       "Burj Khalifa",            "Burj_Khalifa",          ["迪拜塔", "哈里发塔"]),
    ("petronas_towers",     "吉隆坡双子塔",   "Petronas Twin Towers",    "Petronas_Twin_Towers",  ["双子塔", "双峰塔", "国油双塔"]),
    ("potala_palace",       "布达拉宫",       "Potala Palace",           "Potala_Palace",         ["拉萨布达拉宫"]),
    ("forbidden_city",      "北京故宫",       "Forbidden City",          "Forbidden_City",        ["故宫", "紫禁城"]),
    ("kiyomizu_dera",       "清水寺",         "Kiyomizu-dera",           "Kiyomizu-dera",         ["京都清水寺", "清水舞台"]),
    ("himeji_castle",       "姬路城",         "Himeji Castle",           "Himeji_Castle",         ["白鹭城"]),
    ("fallingwater",        "流水别墅",       "Fallingwater",            "Fallingwater",          ["落水山庄", "考夫曼住宅"]),
]


def sh(args, timeout=45):
    try:
        p = subprocess.run(args, capture_output=True, timeout=timeout)
        return p.stdout
    except Exception:
        return b""


def fetch(url, referer=None, timeout=45):
    cmd = ["curl", "-sL", "-m", str(timeout), "-H", f"User-Agent: {UA}",
           "--compressed"]
    if referer:
        cmd += ["-H", f"Referer: {referer}"]
    cmd.append(url)
    return sh(cmd, timeout=timeout + 10)


def commons_via_proxy(wiki_title, width=1000):
    """经 wsrv.nl 代理取 Wikimedia Commons 规范图片。"""
    inner = f"commons.wikimedia.org/wiki/Special:FilePath/{urllib.parse.quote(wiki_title)}.jpg"
    url = f"https://wsrv.nl/?url={inner}&w={width}&output=jpg"
    return fetch(url)


def bing_candidates(query, limit=20):
    """抓取 Bing 图片检索结果，返回 [{murl, purl, t, turl}]，按图源信誉排序。"""
    q = urllib.parse.quote(query)
    page = fetch(f"https://cn.bing.com/images/search?q={q}&form=HDRSC2",
                 referer="https://cn.bing.com/").decode("utf-8", "replace")
    items = []
    for raw in re.findall(r'class="iusc"[^>]*?\sm="([^"]+)"', page):
        try:
            j = json.loads(html_mod.unescape(raw))
        except Exception:
            continue
        murl = j.get("murl", "")
        if not murl.startswith("http"):
            continue
        items.append({
            "murl": murl,
            "purl": j.get("purl", "") or murl,
            "t": (j.get("t", "") or "").strip(),
            "turl": j.get("turl", ""),
        })

    def score(it):
        low = it["murl"].lower()
        if any(h in low for h in GOOD_HOSTS):
            return 0
        if any(h in low for h in BAD_HOSTS):
            return 2
        return 1

    items.sort(key=score)
    return items[:limit]


# 明显不是建筑照片的结果（地图、简笔画、素材、平面图…）
JUNK_WORDS = ("地图", "简笔", "矢量", "素材", "平面图", "logo", "标志", "图标",
              "图标下载", "海报", "壁纸下载", "手绘", "插画", "线稿", "涂色",
              "map of", "floor plan", "clipart", "vector", "icon", "drawing",
              "sketch", "blueprint")


def relevant(item, zh, aliases, en):
    """用标题/来源页判定该结果是否与目标建筑相关。"""
    text = (item["t"] + " " + item["purl"]).lower()
    if any(w in text for w in JUNK_WORDS):
        return False
    for k in [zh] + list(aliases or []):
        if k and k.lower() in text:
            return True
    for tok in re.split(r"[^a-z]+", en.lower()):
        if len(tok) >= 5 and tok in text:
            return True
    return False


def _sips_probe(path):
    """用 macOS 原生 sips 读取尺寸；非图片或损坏返回 None。"""
    p = subprocess.run(["sips", "-g", "pixelWidth", "-g", "pixelHeight", path],
                       capture_output=True, text=True)
    if p.returncode != 0:
        return None
    w = h = None
    for line in p.stdout.splitlines():
        line = line.strip()
        if line.startswith("pixelWidth:"):
            w = int(line.split(":")[1])
        elif line.startswith("pixelHeight:"):
            h = int(line.split(":")[1])
    if not w or not h:
        return None
    return w, h


def normalize(raw_bytes):
    """校验并统一为 JPEG（最长边 MAX_EDGE）。返回 bytes 或 None。"""
    tmp = tempfile.mkdtemp(prefix="archimg_")
    try:
        src = os.path.join(tmp, "in.bin")
        with open(src, "wb") as f:
            f.write(raw_bytes)
        wh = _sips_probe(src)
        if not wh:
            return None
        w, h = wh
        if w < 480 or h < 340:            # 太小，糊
            return None
        if max(w, h) / min(w, h) > 2.6:   # 全景/长条，轮播里很丑
            return None
        dst = os.path.join(tmp, "out.jpg")
        p = subprocess.run(["sips", "-Z", str(MAX_EDGE), "-s", "format", "jpeg",
                            "-s", "formatOptions", str(JPEG_Q), src, "--out", dst],
                           capture_output=True)
        if p.returncode != 0 or not os.path.exists(dst):
            return None
        with open(dst, "rb") as f:
            return f.read()
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def host_of(u):
    try:
        return urllib.parse.urlparse(u).netloc.lower()
    except Exception:
        return ""


def credit_for(host):
    if "wikimedia" in host:
        return "Wikimedia Commons（自由许可，详见来源链接）"
    if "unsplash" in host:
        return "Unsplash License（可商用）"
    if "pexels" in host:
        return "Pexels License（可商用）"
    if "pixabay" in host:
        return "Pixabay License（可商用）"
    return "网络公开图片，仅作学习演示"


def process(bid, zh, en, wiki, aliases, force=False):
    outdir = os.path.join(RAW, bid)
    if os.path.isdir(outdir) and not force:
        existing = [f for f in os.listdir(outdir) if f.endswith(".jpg")]
        if len(existing) >= TARGET_PER_BUILDING:
            return {"id": bid, "status": "skip", "images": []}

    os.makedirs(outdir, exist_ok=True)
    picked, seen_hosts, seen_hash = [], {}, set()
    idx = 0

    def try_bytes(data, source, caption, note=""):
        nonlocal idx
        h = hashlib.sha1(data).hexdigest()
        if h in seen_hash:          # 同一张图重复命中，丢掉
            return False
        norm = normalize(data)
        if not norm:
            return False
        seen_hash.add(h)
        idx += 1
        fn = f"{idx}.jpg"
        with open(os.path.join(outdir, fn), "wb") as f:
            f.write(norm)
        host = host_of(source)
        seen_hosts[host] = seen_hosts.get(host, 0) + 1
        picked.append({
            "file": f"architecture/{bid}/{fn}",
            "source": source,
            "host": host,
            "credit": credit_for(host),
            "caption_hint": caption,
            "note": note,
        })
        return True

    # ---- 1) Commons（首选图源）----
    if len(picked) < TARGET_PER_BUILDING:
        for variant in (wiki, wiki.replace(",_", "_"), en.replace(" ", "_")):
            if len(picked) >= 2:
                break
            data = commons_via_proxy(variant)
            if data[:3] == b"\xff\xd8\xff" or data[:8] == b"\x89PNG\r\n\x1a\n":
                try_bytes(data, f"https://commons.wikimedia.org/wiki/File:{variant}.jpg",
                          f"{zh} 实景", "Wikimedia Commons via wsrv.nl proxy")

    # ---- 2) Bing 图片检索兜底（带相关性过滤 + 来源页记录）----
    # 注意：Bing 中文图片检索对「多词查询」会返回完全无关的结果，必须用单词短语查询。
    queries = [zh] + list(aliases or []) + [en]
    for q in queries:
        if len(picked) >= TARGET_PER_BUILDING:
            break
        for it in bing_candidates(q):
            if len(picked) >= TARGET_PER_BUILDING:
                break
            if not relevant(it, zh, aliases, en):
                continue
            h = host_of(it["purl"] or it["murl"])
            if any(b in h for b in BAD_HOSTS):   # 水印图库，直接跳过
                continue
            if seen_hosts.get(h, 0) >= 2:        # 同一来源站最多取 2 张，保证多样性
                continue
            data = fetch(it["murl"], referer=it["purl"] or "https://cn.bing.com/", timeout=30)
            if len(data) < 8000:
                # Bing 缩略图兜底（CDN 稳定，通常仍可用）
                data = fetch(it["turl"], referer="https://cn.bing.com/", timeout=25) if it["turl"] else b""
                if len(data) < 8000:
                    continue
            try_bytes(data, it["purl"] or it["murl"], it["t"], "Bing 图片检索")

    status = "ok" if len(picked) >= TARGET_PER_BUILDING else ("partial" if picked else "fail")
    return {"id": bid, "status": status, "images": picked}


def main():
    only = sys.argv[1:] if len(sys.argv) > 1 else None
    old = {}
    if os.path.exists(MANIFEST):
        try:
            old = {x["id"]: x for x in json.load(open(MANIFEST, encoding="utf-8"))["buildings"]}
        except Exception:
            old = {}

    results = []
    for bid, zh, en, wiki, aliases in BUILDINGS:
        if only and bid not in only:
            if bid in old:
                results.append(old[bid])
            continue
        t0 = time.time()
        r = process(bid, zh, en, wiki, aliases)
        if r["status"] == "skip" and bid in old:
            r = old[bid]
        results.append(r)
        print(f"[{r['status']:7}] {bid:22} {len(r['images'])} imgs  {time.time()-t0:.1f}s", flush=True)

    os.makedirs(os.path.dirname(MANIFEST), exist_ok=True)
    with open(MANIFEST, "w", encoding="utf-8") as f:
        json.dump({"buildings": results}, f, ensure_ascii=False, indent=2)

    n_ok = sum(1 for r in results if r["status"] == "ok")
    n_part = sum(1 for r in results if r["status"] == "partial")
    n_fail = sum(1 for r in results if r["status"] == "fail")
    total = sum(len(r["images"]) for r in results)
    print(f"\n=== 完成：ok={n_ok} partial={n_part} fail={n_fail}，共 {total} 张图 ===")


if __name__ == "__main__":
    main()
