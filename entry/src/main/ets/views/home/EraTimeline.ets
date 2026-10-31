import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { EraStat } from '../../model/Architecture'

/**
 * 时代长河：古代 → 当代 的时代入口
 * 顶端一条靛蓝→鎏金的渐变色带暗示时间流向，每格显示该时代的建筑数量。
 */
@ComponentV2
export struct EraTimeline {
  @Param eras: EraStat[] = []
  @Event onSelect: (eraId: string) => void = (): void => {}

  build() {
    Column() {
      // 时间流向色带
      Row()
        .width('100%')
        .height(3)
        .linearGradient({
          angle: 90,
          colors: [[AppColor.primary, 0], [AppColor.nodeEra, 0.5], [AppColor.accent, 1]]
        })

      Row() {
        ForEach(this.eras, (item: EraStat): void => {
          Column({ space: 3 }) {
            Text(item.name)
              .fontSize(AppFont.caption)
              .fontColor(AppColor.textPrimary)
              .fontWeight(FontWeight.Medium)
            Text(`${item.count} 座`)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textHint)
          }
          .layoutWeight(1)
          .padding({ top: 14, bottom: 14 })
          .onClick((): void => this.onSelect(item.id))
        }, (item: EraStat): string => item.id)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
    .clip(true)
  }
}
