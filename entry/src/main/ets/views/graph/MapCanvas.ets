import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { MapMark } from '../../model/MapMark'

/** 屏幕坐标点 */
interface Pt {
  x: number
  y: number
}

/** 已放置的标签矩形（用于防重叠与命中测试） */
interface LabelRect {
  mark: MapMark
  ax: number
  ay: number
  x: number
  y: number
  w: number
  h: number
}

/**
 * 世界地图标记画布
 *
 * 底图为等距圆柱投影（严格 lon∈[-180,180]、lat∈[-90,90]），因此经纬度到图面是纯线性：
 *     u = (lng + 180) / 360 ,  v = (90 - lat) / 180
 *
 * 为什么底图用 Image 组件、标记用 Canvas 叠加，而不是全部画在 Canvas 上：
 *   全部画在 Canvas 需要把 rawfile 解码成 PixelMap/ImageBitmap（要过 UIAbility context
 *   的异步链），在无真机可验证的前提下风险偏高；Image($rawfile(...)) 是已验证可用链路。
 *   底图只用「宽高 + position」定位，不使用 scale/translate 渲染变换，
 *   从而避免 ArkUI 变换合成顺序带来的坐标不一致。
 *
 * 标注方案：锚点钉在真实经纬度上，标签按优先级做防重叠排布，再用引线连回锚点。
 * 这是必需的——39 座建筑里有 13 组相距不足 60km（最近仅 0.4km），
 * 全球视野下若不做避让，标记会完全叠在一起。
 */
@ComponentV2
export struct MapCanvas {
  @Param marks: MapMark[] = []
  @Param selectedArchId: string = ''
  @Event onMarkTap: (archId: string) => void = (): void => {}

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  private readonly mapW: number = 2000
  private readonly mapH: number = 1000
  private readonly minScale: number = 1
  private readonly maxScale: number = 16

  /** 画布尺寸（vp）。仅用于 Canvas 内部计算，不参与 build 渲染 */
  private cw: number = 0
  private ch: number = 0
  private areaReady: boolean = false
  private canvasReady: boolean = false

  /**
   * userScale = 1 时底图的显示尺寸与左上角。
   * 必须是 @Local：Image 的宽高由它们算出，普通字段赋值不会触发重建，
   * 底图尺寸就永远停在初始值。
   */
  @Local baseW: number = 0
  @Local baseH: number = 0
  @Local baseX: number = 0
  @Local baseY: number = 0

  @Local userScale: number = 1
  @Local offsetX: number = 0
  @Local offsetY: number = 0

  private panStartX: number = 0
  private panStartY: number = 0
  private pinchStartScale: number = 1
  private pinchFocusU: number = 0.5
  private pinchFocusV: number = 0.5
  private pinchFocusX: number = 0
  private pinchFocusY: number = 0

  /** 上一帧的标签矩形，供点击命中 */
  private labelRects: LabelRect[] = []

  @Monitor('selectedArchId')
  onSelectionChange(): void {
    this.tryDraw()
  }

  private dispW(): number {
    return this.baseW * this.userScale
  }

  private dispH(): number {
    return this.baseH * this.userScale
  }

  /** 经纬度 -> 屏幕坐标 */
  private screenOf(lat: number, lng: number): Pt {
    const u: number = (lng + 180) / 360
    const v: number = (90 - lat) / 180
    return {
      x: this.baseX + this.offsetX + u * this.dispW(),
      y: this.baseY + this.offsetY + v * this.dispH()
    }
  }

  /** 屏幕坐标 -> 图面归一化位置（捏合缩放时锁定焦点用） */
  private fractionOf(sx: number, sy: number): Pt {
    return {
      x: (sx - this.baseX - this.offsetX) / Math.max(this.dispW(), 1),
      y: (sy - this.baseY - this.offsetY) / Math.max(this.dispH(), 1)
    }
  }

  /** 限制平移范围，保证底图不会被拖出画布 */
  private clampOffsets(): void {
    const dw: number = this.dispW()
    const dh: number = this.dispH()
    if (dw <= this.cw) {
      this.offsetX = (this.cw - dw) / 2 - this.baseX
    } else {
      const minX: number = this.cw - this.baseX - dw
      const maxX: number = -this.baseX
      this.offsetX = Math.min(maxX, Math.max(minX, this.offsetX))
    }
    if (dh <= this.ch) {
      this.offsetY = (this.ch - dh) / 2 - this.baseY
    } else {
      const minY: number = this.ch - this.baseY - dh
      const maxY: number = -this.baseY
      this.offsetY = Math.min(maxY, Math.max(minY, this.offsetY))
    }
  }

  /** 以画布某点为焦点缩放到指定倍率 */
  private zoomTo(next: number, focusX: number, focusY: number): void {
    const clamped: number = Math.min(this.maxScale, Math.max(this.minScale, next))
    const f: Pt = this.fractionOf(focusX, focusY)
    this.userScale = clamped
    this.offsetX = focusX - this.baseX - f.x * this.dispW()
    this.offsetY = focusY - this.baseY - f.y * this.dispH()
    this.clampOffsets()
    this.draw()
  }

  private zoomBy(factor: number): void {
    this.zoomTo(this.userScale * factor, this.cw / 2, this.ch / 2)
  }

  private resetView(): void {
    this.userScale = 1
    this.offsetX = 0
    this.offsetY = 0
    this.layoutBase()
    this.draw()
  }

  /**
   * 缩放控件所占的右下角区域。
   * 控件层为了不挡住画布的拖拽/捏合用了 HitTestMode.Transparent，
   * 代价是点击控件的触摸可能同时穿到画布上，因此命中测试要排除这块区域。
   * 尺寸：控件宽 34、高 32×3 + 分隔线，外边距 10。
   */
  private inControlArea(x: number, y: number): boolean {
    return x >= this.cw - 48 && y >= this.ch - 116
  }

  /** 计算 userScale=1 时的底图铺排（含画布居中的 baseX/baseY） */
  private layoutBase(): void {
    const fit: number = Math.min(this.cw / this.mapW, this.ch / this.mapH)
    this.baseW = this.mapW * fit
    this.baseH = this.mapH * fit
    this.baseX = (this.cw - this.baseW) / 2
    this.baseY = (this.ch - this.baseH) / 2
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 底图：只用布局定位，不做渲染变换
      Image($rawfile('architecture/_map/world.png'))
        .width(this.dispW())
        .height(this.dispH())
        .position({ x: this.baseX + this.offsetX, y: this.baseY + this.offsetY })
        .interpolation(ImageInterpolation.Medium)
        .draggable(false)

      // 标记层：全尺寸叠加，自行计算屏幕坐标（标记尺寸恒定，不随缩放放大）
      Canvas(this.ctx)
        .width('100%')
        .height('100%')
        .onReady((): void => {
          this.canvasReady = true
          this.tryDraw()
        })
        .onAreaChange((_oldArea: Area, area: Area): void => {
          this.cw = area.width as number
          this.ch = area.height as number
          this.areaReady = this.cw > 0 && this.ch > 0
          this.layoutBase()
          this.clampOffsets()
          this.tryDraw()
        })
        .gesture(
          GestureGroup(GestureMode.Parallel,
            TapGesture({ count: 1 })
              .onAction((event: GestureEvent): void => this.handleTap(event)),
            PanGesture()
              .onActionStart((): void => {
                this.panStartX = this.offsetX
                this.panStartY = this.offsetY
              })
              .onActionUpdate((event: PanGestureEvent): void => {
                this.offsetX = this.panStartX + event.offsetX
                this.offsetY = this.panStartY + event.offsetY
                this.clampOffsets()
                this.draw()
              }),
            PinchGesture({ fingers: 2 })
              .onActionStart((event: GestureEvent): void => {
                this.pinchStartScale = this.userScale
                this.pinchFocusX = event.pinchCenterX
                this.pinchFocusY = event.pinchCenterY
                const f: Pt = this.fractionOf(event.pinchCenterX, event.pinchCenterY)
                this.pinchFocusU = f.x
                this.pinchFocusV = f.y
              })
              .onActionUpdate((event: GestureEvent): void => {
                const next: number =
                  Math.min(this.maxScale, Math.max(this.minScale, this.pinchStartScale * event.scale))
                this.userScale = next
                this.offsetX = this.pinchFocusX - this.baseX - this.pinchFocusU * this.dispW()
                this.offsetY = this.pinchFocusY - this.baseY - this.pinchFocusV * this.dispH()
                this.clampOffsets()
                this.draw()
              })
          )
        )

      // 缩放控件：单独铺满一层再靠右下对齐，避免依赖 cw/ch（它们不参与 build）
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          this.zoomBtn('＋', (): void => this.zoomBy(1.5))
          Divider().color(AppColor.divider).width(26)
          this.zoomBtn('－', (): void => this.zoomBy(1 / 1.5))
          Divider().color(AppColor.divider).width(26)
          this.zoomBtn('⟲', (): void => this.resetView())
        }
        .backgroundColor('rgba(255,255,255,0.95)')
        .borderRadius(10)
        .border({ width: 1, color: 'rgba(196,208,222,0.9)' })
        .shadow({ radius: 8, color: 'rgba(23,62,107,0.16)', offsetX: 0, offsetY: 2 })
        .margin({ right: 10, bottom: 10 })
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .borderRadius(AppRadius.lg)
    .backgroundColor('#EDF2F8')
  }

  @Builder
  zoomBtn(label: string, action: () => void) {
    Text(label)
      .fontSize(15)
      .fontColor(AppColor.primary)
      .width(34)
      .height(32)
      .textAlign(TextAlign.Center)
      .onClick((): void => action())
  }

  private tryDraw(): void {
    if (this.areaReady && this.canvasReady && this.marks.length > 0) {
      this.draw()
    }
  }

  /** 命中优先级：标签 > 锚点 */
  private handleTap(event: GestureEvent): void {
    if (event.fingerList.length === 0) {
      return
    }
    const tx: number = event.fingerList[0].localX
    const ty: number = event.fingerList[0].localY
    if (this.inControlArea(tx, ty)) {
      return
    }

    for (let i: number = 0; i < this.labelRects.length; i++) {
      const r: LabelRect = this.labelRects[i]
      if (tx >= r.x && tx <= r.x + r.w && ty >= r.y && ty <= r.y + r.h) {
        this.onMarkTap(r.mark.archId)
        return
      }
    }

    let bestId: string = ''
    let bestDist: number = 18 * 18
    this.marks.forEach((m: MapMark): void => {
      const p: Pt = this.screenOf(m.lat, m.lng)
      const dx: number = p.x - tx
      const dy: number = p.y - ty
      const d: number = dx * dx + dy * dy
      if (d < bestDist) {
        bestDist = d
        bestId = m.archId
      }
    })
    if (bestId.length > 0) {
      this.onMarkTap(bestId)
    }
  }

  private draw(): void {
    if (!(this.areaReady && this.canvasReady)) {
      return
    }
    const ctx: CanvasRenderingContext2D = this.ctx
    ctx.clearRect(0, 0, this.cw, this.ch)
    this.labelRects = []

    // 绘制顺序：选中项优先，其次按热度降序，保证重要建筑的标签先占位
    const ordered: MapMark[] = this.marks.slice().sort((a: MapMark, b: MapMark): number => {
      const sa: number = a.archId === this.selectedArchId ? 1 : 0
      const sb: number = b.archId === this.selectedArchId ? 1 : 0
      if (sa !== sb) {
        return sb - sa
      }
      return b.popularity - a.popularity
    })

    // 1) 锚点
    ordered.forEach((m: MapMark): void => {
      const p: Pt = this.screenOf(m.lat, m.lng)
      if (p.x < -30 || p.x > this.cw + 30 || p.y < -30 || p.y > this.ch + 30) {
        return
      }
      this.drawAnchor(p, m.archId === this.selectedArchId, m.color)
    })

    // 2) 标签 + 引线
    const placed: LabelRect[] = []
    ordered.forEach((m: MapMark): void => {
      const p: Pt = this.screenOf(m.lat, m.lng)
      if (p.x < -60 || p.x > this.cw + 60 || p.y < -40 || p.y > this.ch + 40) {
        return
      }
      const rect: LabelRect | null = this.placeLabel(m, p, placed)
      if (!rect) {
        return
      }
      placed.push(rect)
      const cx: number = rect.x + rect.w / 2
      const cy: number = rect.y + rect.h / 2
      ctx.beginPath()
      ctx.moveTo(p.x, p.y)
      ctx.lineTo(cx, cy)
      ctx.strokeStyle = m.archId === this.selectedArchId
        ? 'rgba(200,163,92,0.95)'
        : 'rgba(120,140,165,0.65)'
      ctx.lineWidth = m.archId === this.selectedArchId ? 1.4 : 0.8
      ctx.stroke()
      this.drawLabelChip(rect, m.archId === this.selectedArchId)
    })

    this.labelRects = placed
  }

  private drawAnchor(p: Pt, selected: boolean, color: string): void {
    const ctx: CanvasRenderingContext2D = this.ctx
    if (selected) {
      ctx.beginPath()
      ctx.arc(p.x, p.y, 9, 0, Math.PI * 2)
      ctx.fillStyle = 'rgba(200,163,92,0.28)'
      ctx.fill()
    }
    ctx.beginPath()
    ctx.arc(p.x, p.y, selected ? 4.6 : 3.2, 0, Math.PI * 2)
    ctx.fillStyle = selected ? AppColor.accent : color
    ctx.fill()
    ctx.beginPath()
    ctx.arc(p.x, p.y, selected ? 4.6 : 3.2, 0, Math.PI * 2)
    ctx.strokeStyle = 'rgba(255,255,255,0.95)'
    ctx.lineWidth = 1.2
    ctx.stroke()
  }

  /** 标签防重叠排布：按候选方位依次尝试，全部冲突则放弃该标签 */
  private placeLabel(m: MapMark, p: Pt, placed: LabelRect[]): LabelRect | null {
    const ctx: CanvasRenderingContext2D = this.ctx
    ctx.font = '500 10px sans-serif'
    const tw: number = ctx.measureText(m.name).width
    const w: number = Math.ceil(tw) + 11
    const h: number = 16
    const gap: number = 3

    const cand: number[][] = [
      [0, -20], [0, 20], [w / 2 + 10, -12], [-w / 2 - 10, -12],
      [w / 2 + 10, 12], [-w / 2 - 10, 12],
      [0, -36], [0, 36], [w / 2 + 26, -26], [-w / 2 - 26, -26],
      [w / 2 + 26, 26], [-w / 2 - 26, 26]
    ]

    for (let i: number = 0; i < cand.length; i++) {
      const x: number = p.x + cand[i][0] - w / 2
      const y: number = p.y + cand[i][1] - h / 2
      if (x < 2 || x + w > this.cw - 2 || y < 2 || y + h > this.ch - 2) {
        continue
      }
      let hit: boolean = false
      for (let j: number = 0; j < placed.length; j++) {
        const r: LabelRect = placed[j]
        if (x < r.x + r.w + gap && x + w + gap > r.x && y < r.y + r.h + gap && y + h + gap > r.y) {
          hit = true
          break
        }
      }
      if (!hit) {
        return { mark: m, ax: p.x, ay: p.y, x: x, y: y, w: w, h: h }
      }
    }
    return null
  }

  private drawLabelChip(r: LabelRect, selected: boolean): void {
    const ctx: CanvasRenderingContext2D = this.ctx
    ctx.fillStyle = selected ? 'rgba(200,163,92,0.96)' : 'rgba(255,255,255,0.94)'
    ctx.fillRect(r.x, r.y, r.w, r.h)
    ctx.strokeStyle = selected ? 'rgba(160,124,52,0.95)' : 'rgba(196,208,222,0.95)'
    ctx.lineWidth = 1
    ctx.strokeRect(r.x + 0.5, r.y + 0.5, r.w - 1, r.h - 1)

    ctx.font = '500 10px sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillStyle = selected ? '#3A2C10' : AppColor.textPrimary
    ctx.fillText(r.mark.name, r.x + r.w / 2, r.y + r.h / 2)
  }
}
