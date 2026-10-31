#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成世界地图底图（等距圆柱投影 / Plate Carrée）。

为什么自己栅格化而不用现成地图图片：
  标注点必须精确落在海岸线正确的位置上，这要求底图的**地理边界已知且精确**。
  网络上的现成世界地图大多经过裁切或使用墨卡托投影，无法确认其经纬度范围，
  标注必然飘移。这里用 Natural Earth 50m 的 TopoJSON 自绘，
  投影固定为 lon∈[-180,180]、lat∈[-90,90]，得到严格 2:1 的等距圆柱图，
  于是 App 内可以用最简单的线性公式定位：
      u = (lng + 180) / 360
      v = (90 - lat) / 180

输出：entry/src/main/resources/rawfile/architecture/_map/world.png (2000×1000, RGBA)
      —— 海洋透明，便于叠在 App 的卡片底色上。

依赖：仅标准库（zlib/struct/json）。本机 python3 的 PIL 架构不匹配不可用，
      故这里自带一个极简 PNG 编码器。
"""
import json
import math
import os
import struct
import subprocess
import sys
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.dirname(ROOT)
OUT = os.path.join(APP, "entry/src/main/resources/rawfile/architecture/_map/world.png")
CACHE = os.path.join(ROOT, "data/world-atlas-countries-50m.json")
SRC_URL = "https://cdn.jsdelivr.net/npm/world-atlas@2/countries-50m.json"

W, H = 2000, 1000

# 配色（贴合 App 的「靛蓝 + 米白」体系）
LAND = (223, 231, 241, 255)      # 陆地填充：极浅靛蓝灰
BORDER = (163, 180, 202, 255)    # 国界 / 海岸线
GRAT = (198, 210, 224, 120)      # 经纬网


def proj(lon, lat):
    """经纬度 -> 像素坐标（等距圆柱）"""
    return ((lon + 180.0) / 360.0 * W, (90.0 - lat) / 180.0 * H)


def fetch_source():
    if os.path.exists(CACHE) and os.path.getsize(CACHE) > 10000:
        return
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    print(f"下载 {SRC_URL} ...")
    subprocess.run(["curl", "-sL", "-m", "60", "-o", CACHE, SRC_URL], check=True)
    if os.path.getsize(CACHE) < 10000:
        raise RuntimeError("世界矢量数据下载失败")


def decode_arcs(topo):
    """TopoJSON 弧 -> 经纬度点列（去量化 + 增量还原）"""
    sx, sy = topo["transform"]["scale"]
    tx, ty = topo["transform"]["translate"]
    arcs = []
    for arc in topo["arcs"]:
        x = y = 0
        pts = []
        for dx, dy in arc:
            x += dx
            y += dy
            pts.append((x * sx + tx, y * sy + ty))
        arcs.append(pts)
    return arcs


def ring_points(ring, arcs):
    """把一个环引用的若干弧拼成闭合点列（负索引表示反向引用）"""
    out = []
    for idx in ring:
        pts = arcs[idx] if idx >= 0 else list(reversed(arcs[~idx]))
        out.extend(pts[1:] if out else pts)
    return out


class Canvas:
    def __init__(self, w, h, bg):
        self.w, self.h = w, h
        self.px = bytearray(bytes(bg) * (w * h))

    def set(self, x, y, rgba):
        if 0 <= x < self.w and 0 <= y < self.h:
            i = (y * self.w + x) * 4
            self.px[i:i + 4] = bytes(rgba)

    def line(self, x0, y0, x1, y1, rgba):
        """Bresenham 直线"""
        dx = abs(x1 - x0)
        dy = -abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx + dy
        while True:
            self.set(x0, y0, rgba)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def fill_polygon(self, rings, rgba):
        """扫描线 + 奇偶规则填充多边形（rings 为该多边形的所有环，含洞）"""
        edges = []
        ymin_all = self.h
        ymax_all = -1
        for ring in rings:
            for i in range(len(ring)):
                lon0, lat0 = ring[i]
                lon1, lat1 = ring[(i + 1) % len(ring)]
                x0, y0 = proj(lon0, lat0)
                x1, y1 = proj(lon1, lat1)
                if y0 == y1:
                    continue
                if y0 > y1:
                    x0, y0, x1, y1 = x1, y1, x0, y0
                edges.append((y0, y1, x0, x1))
                ymin_all = min(ymin_all, int(math.ceil(y0)))
                ymax_all = max(ymax_all, int(math.floor(y1)))
        if not edges:
            return
        ymin_all = max(0, ymin_all)
        ymax_all = min(self.h - 1, ymax_all)

        # 按行分桶，避免每行遍历全部边。
        # 起始行必须用 floor：边顶部端点所在的那一行同样会产生交点，
        # 若用 ceil 会漏掉该行，填充出现空洞。多收进来的行由下方 yc 判定过滤。
        buckets = [[] for _ in range(ymax_all - ymin_all + 1)]
        for e in edges:
            y0, y1, x0, x1 = e
            r0 = max(ymin_all, int(math.floor(y0)))
            r1 = min(ymax_all, int(math.floor(y1)))
            for yy in range(r0, r1 + 1):
                buckets[yy - ymin_all].append(e)

        for yy in range(ymin_all, ymax_all + 1):
            active = buckets[yy - ymin_all]
            if not active:
                continue
            yc = yy + 0.5
            xs = []
            for (y0, y1, x0, x1) in active:
                if y1 <= yc or y0 > yc:
                    continue
                xs.append(x0 + (yc - y0) / (y1 - y0) * (x1 - x0))
            if len(xs) < 2:
                continue
            xs.sort()
            row = yy * self.w * 4
            for k in range(0, len(xs) - 1, 2):
                xa = max(0, int(math.ceil(xs[k] - 0.5)))
                xb = min(self.w - 1, int(math.floor(xs[k + 1] - 0.5)))
                if xb < xa:
                    continue
                start = row + xa * 4
                end = row + (xb + 1) * 4
                self.px[start:end] = bytes(rgba) * (xb - xa + 1)


def write_png(path, w, h, px):
    """极简 PNG 编码器（8bit RGBA，无滤波）"""
    raw = bytearray()
    stride = w * 4
    for y in range(h):
        raw.append(0)
        raw += px[y * stride:(y + 1) * stride]

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(png)


def main():
    fetch_source()
    topo = json.load(open(CACHE, encoding="utf-8"))
    arcs = decode_arcs(topo)
    geos = topo["objects"]["countries"]["geometries"]

    cv = Canvas(W, H, (0, 0, 0, 0))

    # 1) 经纬网（每 30°），会被陆地覆盖，只留海洋部分
    for lon in range(-180, 181, 30):
        x, _ = proj(lon, 0)
        cv.line(int(x), 0, int(x), H - 1, GRAT)
    for lat in range(-60, 61, 30):
        _, y = proj(0, lat)
        cv.line(0, int(y), W - 1, int(y), GRAT)

    # 2) 陆地填充：逐多边形奇偶填充（保证内陆海等"洞"被正确挖空）
    n_fill = 0
    for geo in geos:
        if geo["type"] == "Polygon":
            polys = [geo["arcs"]]
        elif geo["type"] == "MultiPolygon":
            polys = geo["arcs"]
        else:
            continue
        for poly in polys:
            rings = [ring_points(r, arcs) for r in poly]
            cv.fill_polygon(rings, LAND)
            n_fill += 1
    print(f"填充多边形 {n_fill} 个")

    # 3) 国界与海岸线
    n_seg = 0
    for geo in geos:
        polys = [geo["arcs"]] if geo["type"] == "Polygon" else geo.get("arcs", [])
        for poly in polys:
            for ring in poly:
                pts = ring_points(ring, arcs)
                if len(pts) < 2:
                    continue
                xs, ys = [], []
                for lon, lat in pts:
                    x, y = proj(lon, lat)
                    xs.append(int(round(x)))
                    ys.append(int(round(y)))
                for i in range(len(xs) - 1):
                    cv.line(xs[i], ys[i], xs[i + 1], ys[i + 1], BORDER)
                    n_seg += 1
    print(f"绘制边界线段 {n_seg} 条")

    write_png(OUT, W, H, cv.px)
    print(f"已写入 {OUT}  ({os.path.getsize(OUT) // 1024} KB, {W}×{H})")

    # 4) 自检：把陆地掩码导出，供标点校验
    mask_path = os.path.join(ROOT, "data/worldmap-land-mask.bin")
    with open(mask_path, "wb") as f:
        for i in range(0, len(cv.px), 4):
            # 陆地/边界线 alpha=255，经纬网 alpha=120：只有前者算陆地
            f.write(b"\x01" if cv.px[i + 3] >= 200 else b"\x00")
    print(f"已写入陆地掩码 {mask_path}")


if __name__ == "__main__":
    main()
