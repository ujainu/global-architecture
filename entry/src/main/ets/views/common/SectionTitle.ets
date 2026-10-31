import { AppColor, AppFont } from '../../common/theme/Theme'

/** 区块标题：左侧竖条 + 名称，右侧可选操作 */
@ComponentV2
export struct SectionTitle {
  @Param title: string = ''
  @Param actionText: string = ''
  @Event onAction: () => void = (): void => {}

  build() {
    Row() {
      Row()
        .width(4)
        .height(16)
        .borderRadius(2)
        .backgroundColor(AppColor.accent)
        .margin({ right: 8 })
      Text(this.title)
        .fontSize(AppFont.subtitle)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColor.textPrimary)
        .layoutWeight(1)
      if (this.actionText.length > 0) {
        Text(this.actionText)
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .onClick((): void => this.onAction())
      }
    }
    .width('100%')
  }
}
