import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { ArchitectureDetail } from '../../model/Architecture'
import { GraphNode, GraphNodeType } from '../../model/GraphNode'
import { GraphViewModel } from '../../viewmodels/GraphViewModel'
import { ArchCover } from '../common/ArchCover'

/** 节点详情底部弹层：展示节点类型及关联建筑，点击建筑可进详情 */
@ComponentV2
export struct NodeDetailSheet {
  @Param node: GraphNode | null = null
  @Param related: ArchitectureDetail[] = []
  @Event onOpenArch: (archId: string) => void = (): void => {}

  private dotColor(type: GraphNodeType): string {
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

  build() {
    if (this.node) {
      Column({ space: 14 }) {
        // 顶部抓手
        Row()
          .width(38)
          .height(4)
          .borderRadius(2)
          .backgroundColor(AppColor.divider)
          .margin({ top: 10 })

        Row({ space: 8 }) {
          Circle({ width: 10, height: 10 }).fill(this.dotColor(this.node.type))
          Text(GraphViewModel.typeName(this.node.type))
            .fontSize(AppFont.mini)
            .fontColor(AppColor.textHint)
          Text(this.node.label)
            .fontSize(AppFont.title)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColor.textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')

        if (this.node.type === GraphNodeType.Architecture) {
          Text('点击下方建筑卡片可直接进入详情')
            .fontSize(AppFont.caption)
            .fontColor(AppColor.textHint)
            .width('100%')
        } else {
          Text(`关联建筑（${this.related.length}）`)
            .fontSize(AppFont.caption)
            .fontColor(AppColor.textHint)
            .width('100%')
        }

        if (this.related.length === 0) {
          Text('暂无关联建筑')
            .fontSize(AppFont.body)
            .fontColor(AppColor.textHint)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 20, bottom: 28 })
        } else {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.related, (arch: ArchitectureDetail): void => {
                Row({ space: 12 }) {
                  Stack() {
                    ArchCover({
                      title: arch.name,
                      fromColor: arch.coverFrom,
                      toColor: arch.coverTo,
                      radius: AppRadius.md
                    })
                  }
                  .width(72)
                  .height(58)

                  Column({ space: 5 }) {
                    Text(arch.name)
                      .fontSize(AppFont.body)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppColor.textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                    Text(`${arch.country} · ${arch.yearText}`)
                      .fontSize(AppFont.mini)
                      .fontColor(AppColor.textHint)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                    Text(arch.summary)
                      .fontSize(AppFont.mini)
                      .fontColor(AppColor.textSecondary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Image($r('app.media.ic_chevron_right'))
                    .width(18)
                    .height(18)
                    .fillColor(AppColor.textHint)
                }
                .width('100%')
                .padding(10)
                .backgroundColor(AppColor.bg)
                .borderRadius(AppRadius.lg)
                .onClick((): void => this.onOpenArch(arch.id))
              }, (arch: ArchitectureDetail): string => arch.id)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
      .backgroundColor(AppColor.card)
      .alignItems(HorizontalAlign.Start)
    }
  }
}
