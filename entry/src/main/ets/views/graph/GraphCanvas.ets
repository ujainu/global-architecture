import { AppColor } from '../../common/theme/Theme'
import { GraphNode, GraphNodeType } from '../../model/GraphNode'
import { GraphEdge } from '../../model/GraphEdge'

/**
 * 知识图谱画布
 * - Canvas 绘制节点 / 连线 / 文字底衬
 * - 双指缩放（PinchGesture）、单指平移（PanGesture）、点选节点（TapGesture）
 * - 注意：当前 SDK 的 Canvas 绘图坐标系与触摸 localX/Y 均为 vp 单位，
 *   因此布局坐标、半径、线宽、字号全部直接使用 vp，无需 dpr/vp2px 换算
 */
@ComponentV2
export struct GraphCanvas {
  @Param nodes: GraphNode[] = []
  @Param edges: GraphEdge[] = []
  @Param selectedId: string = ''
  @Event onNodeTap: (id: string) => void = (): void => {}

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  /** 画布尺寸（vp） */
  private cw: number = 0
  private ch: number = 0
  private areaReady: boolean = false
  private canvasReady: boolean = false

  @Local offsetX: number = 0
  @Local offsetY: number = 0
  @Local userScale: number = 1
  private panStartX: number = 0
  private panStartY: number = 0
  private pinchStartScale: number = 1

  /** 当前帧变换参数（命中测试复用，vp 空间） */
  private fitScale: number = 1
  private baseTx: number = 0
  private baseTy: number = 0

  @Monitor('selectedId')
  onSelectedChange(): void {
    this.tryDraw()
  }

  private radiusOf(type: GraphNodeType): number {
    return type === GraphNodeType.Architecture ? 17 : 12
  }

  private colorOf(type: GraphNodeType): string {
    if (type === GraphNodeType.Architecture) {
      return AppColor.nodeArch
    }
    if (type === GraphNodeType.Style) {
      return AppColor.nodeStyle
    }
    if (type === GraphNodeType.Era) {
      return AppColor.nodeEra
    }
    return AppColor.nodeArchitect
  }

  /** 逻辑布局坐标(vp) -> 画布坐标(vp) */
  private toScreenX(x: number): number {
    return x * this.fitScale * this.userScale + this.baseTx + this.offsetX
  }

  private toScreenY(y: number): number {
    return y * this.fitScale * this.userScale + this.baseTy + this.offsetY
  }

  /**
   * 缩放范围：右下角控件与双指缩放共用同一组边界。
   * 原双指缩放上限为 2.6，加入控件后连点三次即触顶、手感偏死；
   * 图谱为矢量绘制（节点半径与字号均不随缩放放大，只是拉开间距），
   * 放大后不会失真，故上限放宽到 6。
   */
  private readonly minScale: number = 0.5
  private readonly maxScale: number = 6

  /**
   * 以画布某点为焦点缩放。
   *
   * 变换可写成「以内容中心为原点」的形式：
   *     screen = total * (x - cx) + cw / 2 + offset
   * （baseTx = cw/2 - cx*total 已把居中算进去了，故与 baseTx 无关）
   * 要让焦点下的内容点保持不动：
   *     offset' = offset + (total - total') * u ,  u = (focus - cw/2 - offset) / total
   */
  private zoomTo(next: number, focusX: number, focusY: number): void {
    const total: number = this.fitScale * this.userScale
    if (total <= 0 || this.cw <= 0) {
      return
    }
    const ux: number = (focusX - this.cw / 2 - this.offsetX) / total
    const uy: number = (focusY - this.ch / 2 - this.offsetY) / total
    const clamped: number = Math.min(this.maxScale, Math.max(this.minScale, next))
    this.userScale = clamped
    const nextTotal: number = this.fitScale * clamped
    this.offsetX = this.offsetX + (total - nextTotal) * ux
    this.offsetY = this.offsetY + (total - nextTotal) * uy
    this.draw()
  }

  /** 缩放控件：以画布中心为焦点 */
  private zoomBy(factor: number): void {
    this.zoomTo(this.userScale * factor, this.cw / 2, this.ch / 2)
  }

  /** 回到自适应全览（userScale=1 即「铺满画布」的基准视图） */
  private resetView(): void {
    this.userScale = 1
    this.offsetX = 0
    this.offsetY = 0
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

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
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
                this.draw()
              }),
            PinchGesture()
              .onActionStart((): void => {
                this.pinchStartScale = this.userScale
              })
              .onActionUpdate((event: PinchGestureEvent): void => {
                const next: number = this.pinchStartScale * event.scale
                this.userScale = Math.min(this.maxScale, Math.max(this.minScale, next))
                this.draw()
              })
          )
        )

      // 缩放控件：与「世界地图」视图保持一致的交互与外观
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          this.zoomBtn('＋', (): void => this.zoomBy(1.5))
          Divider().color(AppColor.divider).width(26)
          this.zoomBtn('－', (): void => this.zoomBy(1 / 1.5))
          Divider().color(AppColor.divider).width(26)
          this.zoomBtn('⟲', (): void => this.resetView())
        }
        .backgroundColor('rgba(255,255,255,0.96)')
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
    .borderRadius(16)
    .backgroundColor(AppColor.card)
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
    if (this.areaReady && this.canvasReady && this.nodes.length > 0) {
      this.draw()
    }
  }

  private handleTap(event: GestureEvent): void {
    if (event.fingerList.length === 0) {
      return
    }
    // 触摸 localX/Y 与绘图坐标系同为 vp
    const tapX: number = event.fingerList[0].localX
    const tapY: number = event.fingerList[0].localY
    if (this.inControlArea(tapX, tapY)) {
      return
    }
    const total: number = this.fitScale * this.userScale
    const logicalX: number = (tapX - this.baseTx - this.offsetX) / total
    const logicalY: number = (tapY - this.baseTy - this.offsetY) / total

    // 优先命中建筑节点
    const archHits: GraphNode[] = []
    const otherHits: GraphNode[] = []
    this.nodes.forEach((n: GraphNode): void => {
      const hitRadius: number = this.radiusOf(n.type) + 5
      const dx: number = n.x - logicalX
      const dy: number = n.y - logicalY
      if (dx * dx + dy * dy <= hitRadius * hitRadius) {
        if (n.type === GraphNodeType.Architecture) {
          archHits.push(n)
        } else {
          otherHits.push(n)
        }
      }
    })
    if (archHits.length > 0) {
      this.onNodeTap(archHits[0].id)
    } else if (otherHits.length > 0) {
      this.onNodeTap(otherHits[0].id)
    }
  }

  private draw(): void {
    if (!(this.areaReady && this.canvasReady) || this.nodes.length === 0) {
      return
    }
    const ctx: CanvasRenderingContext2D = this.ctx
    ctx.clearRect(0, 0, this.cw, this.ch)

    // 1. 计算包围盒与自适应缩放（全程 vp）
    let minX: number = Number.MAX_VALUE
    let maxX: number = -Number.MAX_VALUE
    let minY: number = Number.MAX_VALUE
    let maxY: number = -Number.MAX_VALUE
    this.nodes.forEach((n: GraphNode): void => {
      const r: number = this.radiusOf(n.type) + 22
      minX = Math.min(minX, n.x - r)
      maxX = Math.max(maxX, n.x + r)
      minY = Math.min(minY, n.y - r)
      maxY = Math.max(maxY, n.y + r)
    })
    const spanX: number = maxX - minX
    const spanY: number = maxY - minY
    const pad: number = 12
    this.fitScale = Math.min((this.cw - pad * 2) / spanX, (this.ch - pad * 2) / spanY)
    const total: number = this.fitScale * this.userScale
    this.baseTx = this.cw / 2 - (minX + maxX) / 2 * total
    this.baseTy = this.ch / 2 - (minY + maxY) / 2 * total

    const indexOf: Map<string, GraphNode> = new Map()
    this.nodes.forEach((n: GraphNode): void => {
      indexOf.set(n.id, n)
    })

    // 2. 连线
    this.edges.forEach((edge: GraphEdge): void => {
      const a: GraphNode | undefined = indexOf.get(edge.from)
      const b: GraphNode | undefined = indexOf.get(edge.to)
      if (!a || !b) {
        return
      }
      const active: boolean =
        this.selectedId.length > 0 && (edge.from === this.selectedId || edge.to === this.selectedId)
      ctx.beginPath()
      ctx.moveTo(this.toScreenX(a.x), this.toScreenY(a.y))
      ctx.lineTo(this.toScreenX(b.x), this.toScreenY(b.y))
      ctx.strokeStyle = active ? 'rgba(200,163,92,0.9)' : 'rgba(160,175,195,0.55)'
      ctx.lineWidth = active ? 1.6 : 0.8
      ctx.stroke()
    })

    // 3. 节点 + 标签
    this.nodes.forEach((n: GraphNode): void => {
      const sx: number = this.toScreenX(n.x)
      const sy: number = this.toScreenY(n.y)
      const r: number = this.radiusOf(n.type)
      const selected: boolean = n.id === this.selectedId

      ctx.beginPath()
      ctx.arc(sx, sy, r, 0, Math.PI * 2)
      ctx.fillStyle = this.colorOf(n.type)
      ctx.fill()

      if (n.type === GraphNodeType.Architecture) {
        ctx.beginPath()
        ctx.arc(sx, sy, r, 0, Math.PI * 2)
        ctx.strokeStyle = 'rgba(255,255,255,0.85)'
        ctx.lineWidth = 1.2
        ctx.stroke()
      }

      if (selected) {
        ctx.beginPath()
        ctx.arc(sx, sy, r + 3.5, 0, Math.PI * 2)
        ctx.strokeStyle = AppColor.accent
        ctx.lineWidth = 2
        ctx.stroke()
      }

      // 文字底衬 + 标签
      const fontSize: number = n.type === GraphNodeType.Architecture ? 10.5 : 9.5
      ctx.font = `${n.type === GraphNodeType.Architecture ? '600 ' : ''}${fontSize}px sans-serif`
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      const labelW: number = ctx.measureText(n.label).width
      const labelY: number = sy + r + fontSize * 0.95
      ctx.fillStyle = 'rgba(255,255,255,0.82)'
      ctx.fillRect(sx - labelW / 2 - 3, labelY - fontSize * 0.75, labelW + 6, fontSize * 1.5)
      ctx.fillStyle = n.type === GraphNodeType.Architecture ? AppColor.primaryDark : '#4E5560'
      ctx.fillText(n.label, sx, labelY)
    })
  }
}
