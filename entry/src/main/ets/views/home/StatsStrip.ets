import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { StatItem } from '../../model/Architecture'

/** 资料库数据概览：建筑 / 大洲 / 风格 / 建筑师 数量，随预置数据规模自动更新 */
@ComponentV2
export struct StatsStrip {
  @Param stats: StatItem[] = []

  build() {
    Row() {
      ForEach(this.stats, (item: StatItem): void => {
        Column({ space: 2 }) {
          Text(`${item.value}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColor.primary)
          Text(item.label)
            .fontSize(AppFont.mini)
            .fontColor(AppColor.textHint)
        }
        .layoutWeight(1)
      }, (item: StatItem): string => item.label)
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
  }
}
