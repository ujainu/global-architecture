import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/** 空状态占位 */
@ComponentV2
export struct EmptyState {
  @Param emoji: string = '📭'
  @Param title: string = '暂无内容'
  @Param hint: string = ''

  build() {
    Column({ space: 10 }) {
      Text(this.emoji)
        .fontSize(48)
      Text(this.title)
        .fontSize(AppFont.subtitle)
        .fontColor(AppColor.textPrimary)
        .fontWeight(FontWeight.Medium)
      if (this.hint.length > 0) {
        Text(this.hint)
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
      }
    }
    .width('100%')
    .padding({ top: 56, bottom: 56, left: 24, right: 24 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
