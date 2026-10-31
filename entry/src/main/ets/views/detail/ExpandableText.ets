import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/** 可折叠长文本区块 */
@ComponentV2
export struct ExpandableText {
  @Param title: string = ''
  @Param content: string = ''
  @Local expanded: boolean = false

  build() {
    Column({ space: 10 }) {
      Row() {
        Row()
          .width(4)
          .height(15)
          .borderRadius(2)
          .backgroundColor(AppColor.accent)
          .margin({ right: 8 })
        Text(this.title)
          .fontSize(AppFont.subtitle)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColor.textPrimary)
          .layoutWeight(1)
        Text(this.expanded ? '收起' : '展开')
          .fontSize(AppFont.caption)
          .fontColor(AppColor.primary)
      }
      .width('100%')

      Text(this.content)
        .fontSize(AppFont.body)
        .fontColor(AppColor.textSecondary)
        .lineHeight(24)
        .width('100%')
        .maxLines(this.expanded ? undefined : 3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onClick((): void => {
          this.expanded = !this.expanded
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
    .alignItems(HorizontalAlign.Start)
  }
}
