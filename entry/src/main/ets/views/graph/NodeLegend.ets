import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { GraphNodeType } from '../../model/GraphNode'

interface LegendItem {
  name: string
  color: string
  type: GraphNodeType
}

/** 图谱图例 + 操作提示 */
@ComponentV2
export struct NodeLegend {
  private items: LegendItem[] = [
    { name: '建筑', color: AppColor.nodeArch, type: GraphNodeType.Architecture },
    { name: '流派', color: AppColor.nodeStyle, type: GraphNodeType.Style },
    { name: '时代', color: AppColor.nodeEra, type: GraphNodeType.Era },
    { name: '建筑师', color: AppColor.nodeArchitect, type: GraphNodeType.Architect }
  ]

  build() {
    Column({ space: 8 }) {
      Row({ space: 16 }) {
        ForEach(this.items, (item: LegendItem): void => {
          Row({ space: 5 }) {
            Circle({ width: 9, height: 9 })
              .fill(item.color)
            Text(item.name)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textSecondary)
          }
        }, (item: LegendItem): string => item.name)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Text('单指拖动平移 · 双指缩放 · 点击建筑节点直达详情')
        .fontSize(AppFont.mini)
        .fontColor(AppColor.textHint)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10, left: 12, right: 12 })
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.md)
  }
}
