#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成《环球建筑博览 App》软件原型设计汇报 PPT（更新版）。

做法：复用原始 build_ppt.py 的主题常量与全部绘制 helper（保证两版视觉语言一致），
只做两处注入 + 替换全部幻灯片内容：

  1. phone() 新增三种线框块：eraband（时代长河）、metric（概览数字）、map（世界地图）
  2. phone() 底部导航改为鸿蒙「光感悬浮导航栏」形态（悬浮圆角条 + 选中胶囊）

运行：
  PYTHONPATH=../.pptdeps /usr/local/bin/python3.9 build_ppt_v2.py

注意：本机 /opt/homebrew 的 arm64 python 无法加载 .pptdeps 里 x86_64 的 lxml，
      必须用 /usr/local/bin/python3.9。
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))   # .../ren_ji
ORIG = os.path.join(REPO, "build", "build_ppt.py")
OUT_PATH = os.environ.get(
    "PPT_OUT", "/Users/dumingzhu/Desktop/环球建筑博览App_原型设计汇报_v2.pptx")
BUILD = "/tmp/build_ppt_v2_merged.py"

# ---------- 1. 取出原始 helper 段（封面之前的所有内容）----------
src = open(ORIG, encoding="utf-8").read()
MARK = "# =========================================================\n# 1 封面"
if MARK not in src:
    sys.exit("找不到原脚本的分割标记，请检查 build_ppt.py")
head = src.split(MARK)[0]

# ---------- 2. 注入新的线框块类型 ----------
NEW_KINDS = '''        elif k == "eraband":
            # 时代长河：一条横向色带 + 若干格子，每格显示时代名与建筑数量
            items = b["items"]
            n = len(items)
            rrect(slide, cx, cy, cw, bh, fill=SOFT, line=LINE, radius=0.16)
            rrect(slide, cx, cy, cw, 0.028, fill=ACCENT, radius=0.5)
            cellw = cw / n
            for i, (nm, ct) in enumerate(items):
                txt(slide, cx + i * cellw, cy + bh * 0.26, cellw, 0.14, nm,
                    size=5.8, bold=True, color=INK2, align=PP_ALIGN.CENTER)
                txt(slide, cx + i * cellw, cy + bh * 0.60, cellw, 0.12, ct,
                    size=5.0, color=MUTED, align=PP_ALIGN.CENTER)
                if i > 0:
                    rrect(slide, cx + i * cellw, cy + bh * 0.20, 0.006, bh * 0.60,
                          fill=RGBColor(0xDC, 0xE2, 0xE8), radius=0.5)
        elif k == "metric":
            # 资料库概览：一行等宽数字
            items = b["items"]
            n = len(items)
            rrect(slide, cx, cy, cw, bh, fill=SOFT2, line=LINE, radius=0.16)
            cellw = cw / n
            for i, (v, lb) in enumerate(items):
                txt(slide, cx + i * cellw, cy + bh * 0.16, cellw, 0.16, v,
                    size=7.5, bold=True, color=TEAL, align=PP_ALIGN.CENTER)
                txt(slide, cx + i * cellw, cy + bh * 0.58, cellw, 0.12, lb,
                    size=5.0, color=MUTED, align=PP_ALIGN.CENTER)
        elif k == "map":
            # 世界地图：浅蓝底 + 简化大陆 + 锚点/引线/标签 + 右下角缩放控件
            rrect(slide, cx, cy, cw, bh, fill=RGBColor(0xEA, 0xF1, 0xF8),
                  line=LINE, radius=0.14)
            land = RGBColor(0xD6, 0xE1, 0xED)
            for (bx, by, bw2, bh2) in [(0.05, 0.28, 0.19, 0.30), (0.11, 0.66, 0.10, 0.20),
                                       (0.31, 0.20, 0.12, 0.22), (0.35, 0.50, 0.12, 0.34),
                                       (0.54, 0.18, 0.26, 0.30), (0.62, 0.66, 0.11, 0.15),
                                       (0.80, 0.62, 0.13, 0.22)]:
                rrect(slide, cx + bx * cw, cy + by * bh, bw2 * cw, bh2 * bh,
                      fill=land, line=None, radius=0.5, shape=MSO_SHAPE.OVAL)
            for (mx, my, lb, dx, dy) in b["items"]:
                px, py = cx + mx * cw, cy + my * bh
                ln = slide.shapes.add_connector(MSO_CONNECTOR.STRAIGHT,
                                                Inches(px), Inches(py),
                                                Inches(px + dx), Inches(py + dy))
                ln.line.color.rgb = RGBColor(0x8C, 0x9C, 0xB2)
                ln.line.width = Pt(0.5)
                rrect(slide, px + dx - 0.085, py + dy - 0.058, 0.17, 0.115,
                      fill=WHITE, line=RGBColor(0xC4, 0xD0, 0xDE), radius=0.32)
                txt(slide, px + dx - 0.085, py + dy - 0.048, 0.17, 0.09, lb,
                    size=3.4, color=INK2, align=PP_ALIGN.CENTER)
                rrect(slide, px - 0.028, py - 0.028, 0.056, 0.056, fill=ACCENT,
                      line=WHITE, radius=0.5, shape=MSO_SHAPE.OVAL)
            rrect(slide, cx + cw - 0.185, cy + bh - 0.42, 0.13, 0.34,
                  fill=WHITE, line=RGBColor(0xC4, 0xD0, 0xDE), radius=0.22)
            for i, gl in enumerate(("＋", "－", "⟲")):
                txt(slide, cx + cw - 0.185, cy + bh - 0.405 + i * 0.112, 0.13, 0.10,
                    gl, size=4.6, color=INK2, align=PP_ALIGN.CENTER)
'''
if '        elif k == "btn":' not in head:
    sys.exit("找不到 btn 分支锚点")
head = head.replace('        elif k == "btn":', NEW_KINDS + '        elif k == "btn":', 1)

# ---------- 3. 底部导航改为光感悬浮导航栏 ----------
NEW_NAV = '''    # 底部导航：鸿蒙光感悬浮导航栏（悬浮圆角条 + 选中胶囊）
    ny = nav_y + 0.03
    rrect(slide, cx + 0.02, ny, cw - 0.04, 0.40,
          fill=RGBColor(0xF3, 0xF6, 0xFA), line=RGBColor(0xD8, 0xE0, 0xE8),
          radius=0.42)
    gap2 = 0.03
    nw2 = (cw - 0.04 - gap2 * 4) / 5
    for i, lab in enumerate(NAV):
        on = (i == active)
        bx2 = cx + 0.02 + i * (nw2 + gap2)
        if on:
            rrect(slide, bx2, ny + 0.05, nw2, 0.30, fill=TINT_A, radius=0.42)
        txt(slide, bx2, ny + 0.135, nw2, 0.14, lab, size=5.8, bold=on,
            color=ACCENT if on else MUTED, align=PP_ALIGN.CENTER)
    rrect(slide, cx + cw / 2 - 0.22, y + h - 0.075, 0.44, 0.03,
          fill=RGBColor(0xD5, 0xDB, 0xE1), radius=0.5)
'''
if "    # 底部导航\n" not in head:
    sys.exit("找不到底部导航锚点")
# 底部导航是 helper 段的最后一段代码，直接截断后重写
head = head.split("    # 底部导航")[0] + NEW_NAV

# ---------- 4. 拼装并执行 ----------
slides_a = open(os.path.join(HERE, "_ppt_slides_v2.py"), encoding="utf-8").read()
slides_b = open(os.path.join(HERE, "_ppt_slides_v2b.py"), encoding="utf-8").read()

merged = ('# -*- coding: utf-8 -*-\n# 本文件由 build_ppt_v2.py 自动生成，请勿直接编辑\n'
          + head
          + f'\nOUT_PATH = {OUT_PATH!r}\n\n'
          + slides_a
          + "\n"
          + slides_b)

with open(BUILD, "w", encoding="utf-8") as f:
    f.write(merged)

print(f"已生成合并脚本 {BUILD}（{len(merged.splitlines())} 行）")
ns = {"__name__": "__main__", "__file__": BUILD}
exec(compile(merged, BUILD, "exec"), ns)
