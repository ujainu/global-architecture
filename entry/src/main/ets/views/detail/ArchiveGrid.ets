import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

interface ArchiveCell {
  emoji: string
  label: string
  value: string
}

/** 建筑档案：国家 / 年代 / 建筑师 / 风格 四宫格 */
@ComponentV2
export struct ArchiveGrid {
  @Param locationText: string = ''
  @Param yearText: string = ''
  @Param architectText: string = ''
  @Param styleText: string = ''

  private cells(): ArchiveCell[] {
    return [
      { emoji: '🌍', label: '国家 / 地区', value: this.locationText },
      { emoji: '📅', label: '建造年代', value: this.yearText },
      { emoji: '👷', label: '建筑师', value: this.architectText },
      { emoji: '🎨', label: '建筑风格', value: this.styleText }
    ]
  }

  build() {
    Grid() {
      ForEach(this.cells(), (cell: ArchiveCell): void => {
        GridItem() {
          Column({ space: 6 }) {
            Row({ space: 5 }) {
              Text(cell.emoji).fontSize(13)
              Text(cell.label)
                .fontSize(AppFont.mini)
                .fontColor(AppColor.textHint)
            }
            Text(cell.value)
              .fontSize(AppFont.caption)
              .fontColor(AppColor.textPrimary)
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(12)
          .backgroundColor(AppColor.card)
          .borderRadius(AppRadius.md)
        }
      }, (cell: ArchiveCell): string => cell.label)
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(10)
    .columnsGap(10)
    .width('100%')
    .height(172)
  }
}
