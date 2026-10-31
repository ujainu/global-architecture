#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
极简 PNG 解码 + 图像取色分析（无第三方依赖）。

用途：本机没有视觉模型，无法"看"图，但可以把图下采样成小图后用纯 Python 解码，
      读出每个像素的实际 RGB，从而量化分析配色、亮度、透明度与层次结构。
"""
import struct
import sys
import zlib


def decode_png(path):
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", "不是 PNG"
    pos = 8
    idat = b""
    w = h = bitd = ctype = None
    while pos < len(data):
        ln = struct.unpack(">I", data[pos:pos + 4])[0]
        tag = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + ln]
        if tag == b"IHDR":
            w, h, bitd, ctype = struct.unpack(">IIBB", body[:10])
        elif tag == b"IDAT":
            idat += body
        elif tag == b"IEND":
            break
        pos += 12 + ln
    assert bitd == 8, f"只支持 8bit，当前 {bitd}"

    nch = {0: 1, 2: 3, 4: 2, 6: 4}[ctype]
    raw = zlib.decompress(idat)
    stride = w * nch
    out = bytearray(h * stride)
    prev = bytearray(stride)
    p = 0
    for y in range(h):
        ft = raw[p]
        p += 1
        line = bytearray(raw[p:p + stride])
        p += stride
        if ft == 1:
            for i in range(nch, stride):
                line[i] = (line[i] + line[i - nch]) & 0xFF
        elif ft == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ft == 3:
            for i in range(stride):
                a = line[i - nch] if i >= nch else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif ft == 4:
            for i in range(stride):
                a = line[i - nch] if i >= nch else 0
                b = prev[i]
                c = prev[i - nch] if i >= nch else 0
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        out[y * stride:(y + 1) * stride] = line
        prev = line

    px = []
    for y in range(h):
        row = []
        for x in range(w):
            i = y * stride + x * nch
            if nch >= 3:
                row.append((out[i], out[i + 1], out[i + 2]))
            else:
                v = out[i]
                row.append((v, v, v))
        px.append(row)
    return w, h, px


def lum(c):
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


RAMP = " .:-=+*#%@"


def show_ascii(w, h, px, title):
    print(f"\n=== {title}  {w}×{h} ===")
    for y in range(h):
        line = ""
        for x in range(w):
            line += RAMP[min(9, int(lum(px[y][x]) / 25.6))]
        print("  " + line)


def show_hex(w, h, px, title, step=1):
    print(f"\n=== {title} 色值网格（{w}×{h}）===")
    for y in range(0, h, step):
        print("  " + " ".join("%02x%02x%02x" % px[y][x] for x in range(0, w, step)))


def region_stat(px, x0, y0, x1, y1, name):
    xs = range(max(0, x0), min(len(px[0]), x1))
    ys = range(max(0, y0), min(len(px), y1))
    n = 0
    sr = sg = sb = 0
    vals = []
    for y in ys:
        for x in xs:
            c = px[y][x]
            sr += c[0]; sg += c[1]; sb += c[2]
            vals.append(lum(c))
            n += 1
    if not n:
        return
    avg = (sr // n, sg // n, sb // n)
    mean = sum(vals) / n
    var = sum((v - mean) ** 2 for v in vals) / n
    rng = max(vals) - min(vals)
    print(f"  {name:22} 均色 #{avg[0]:02x}{avg[1]:02x}{avg[2]:02x}  "
          f"亮度均值 {mean:5.1f}  标准差 {var ** 0.5:5.1f}  极差 {rng:5.1f}")


if __name__ == "__main__":
    path = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else "ascii"
    w, h, px = decode_png(path)
    if mode == "ascii":
        show_ascii(w, h, px, path.split("/")[-1])
    elif mode == "hex":
        show_hex(w, h, px, path.split("/")[-1])
    print(f"\n  尺寸 {w}×{h}")
