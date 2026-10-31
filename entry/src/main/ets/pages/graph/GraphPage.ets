import { AppColor, AppDims, AppFont, AppRadius } from '../../common/theme/Theme'
import { AppRouter } from '../../common/router/AppRouter'
import { GraphData } from '../../model/GraphNode'
import { MapLegendItem } from '../../model/MapMark'
import { GraphMode, GraphViewModel } from '../../viewmodels/GraphViewModel'
import { GraphCanvas } from '../../views/graph/GraphCanvas'
import { MapCanvas } from '../../views/graph/MapCanvas'
import { NodeLegend } from '../../views/graph/NodeLegend'
import { NodeDetailSheet } from '../../views/graph/NodeDetailSheet'

/**
 * ⑥ 图谱页
 * 两种视图共用同一个 selectedNode 与底部弹层：
 * - 关联图谱：建筑 — 时代 / 风格 / 建筑师 的力导向关系网络
 * - 世界地图：按经纬度把建筑钉在等距圆柱投影的世界地图上，可缩放拖拽
 */
@ComponentV2
export struct GraphPage {
  @Local vm: GraphViewModel = GraphViewModel.instance
  @Local showSheet: boolean = false
  @Local mode: GraphMode = GraphMode.Relation
  private graph: GraphData = this.vm.getGraph()

  private isMap(): boolean {
    return this.mode === GraphMode.Map
  }

  private subtitle(): string {
    if (this.isMap()) {
      return '按真实经纬度定位，双指缩放 · 拖动平移 · 点击标记查看'
    }
    return '建筑 · 时代 · 流派 · 建筑师 的关联网络'
  }

  private onNodeTap(id: string): void {
    this.vm.selectNode(id)
    this.showSheet = true
  }

  private onMarkTap(archId: string): void {
    this.vm.selectArch(archId)
    this.showSheet = true
  }

  build() {
    Column({ space: 10 }) {
      Column({ space: 4 }) {
        Text('建筑知识图谱')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColor.primary)
          .width('100%')
        Text(this.subtitle())
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .width('100%')
      }
      .width('100%')
      .padding({ top: 14 })

      // 视图切换
      Row() {
        this.modeTab('关联图谱', GraphMode.Relation)
        this.modeTab('世界地图', GraphMode.Map)
      }
      .width('100%')
      .padding(3)
      .backgroundColor(AppColor.primaryLight)
      .borderRadius(AppRadius.pill)

      if (this.isMap()) {
        this.MapLegend()
      } else {
        NodeLegend()
      }

      Stack() {
        if (this.isMap()) {
          MapCanvas({
            marks: this.vm.getMarks(),
            selectedArchId: this.vm.selectedArchId(),
            onMarkTap: (archId: string): void => this.onMarkTap(archId)
          })
        } else {
          GraphCanvas({
            nodes: this.graph.nodes,
            edges: this.graph.edges,
            selectedId: this.vm.selectedNode ? this.vm.selectedNode.id : '',
            onNodeTap: (id: string): void => this.onNodeTap(id)
          })
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({
      left: AppDims.pagePadding,
      right: AppDims.pagePadding,
      bottom: 12 + AppDims.navSafeSpace
    })
    .backgroundColor(AppColor.bg)
    .bindSheet($$this.showSheet, this.sheetBuilder(), {
      height: SheetSize.MEDIUM,
      dragBar: false,
      backgroundColor: AppColor.card
    })
  }

  /** 地图模式下的图例：大洲 -> 锚点颜色 */
  @Builder
  MapLegend() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.vm.getLegend(), (item: MapLegendItem): void => {
        Row({ space: 5 }) {
          Circle({ width: 7, height: 7 }).fill(item.color)
          Text(item.label)
            .fontSize(AppFont.mini)
            .fontColor(AppColor.textSecondary)
        }
        .margin({ right: 14 })
      }, (item: MapLegendItem): string => item.label)
    }
    .width('100%')
  }

  @Builder
  modeTab(title: string, target: GraphMode) {
    Text(title)
      .fontSize(AppFont.caption)
      .fontWeight(this.mode === target ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.mode === target ? AppColor.primary : AppColor.textSecondary)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(30)
      .backgroundColor(this.mode === target ? AppColor.card : Color.Transparent)
      .borderRadius(AppRadius.pill)
      .animation({ duration: 180, curve: Curve.EaseOut })
      .onClick((): void => {
        this.mode = target
        this.vm.switchMode(target)
      })
  }

  @Builder
  sheetBuilder() {
    if (this.vm.selectedNode) {
      NodeDetailSheet({
        node: this.vm.selectedNode,
        related: this.vm.relatedArchitectures(this.vm.selectedNode),
        onOpenArch: (id: string): void => {
          this.showSheet = false
          AppRouter.pushDetail(id)
        }
      })
    }
  }
}
