import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/** 可选中的胶囊标签 */
@ComponentV2
export struct TagChip {
  @Param label: string = ''
  @Param selected: boolean = false
  @Param small: boolean = false
  @Event onTap: () => void = (): void => {}

  build() {
    Text(this.label)
      .fontSize(this.small ? AppFont.caption : AppFont.body)
      .fontColor(this.selected ? Color.White : AppColor.textSecondary)
      .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Regular)
      .padding({
        left: this.small ? 12 : 15,
        right: this.small ? 12 : 15,
        top: this.small ? 5 : 8,
        bottom: this.small ? 5 : 8
      })
      .backgroundColor(this.selected ? AppColor.primary : AppColor.card)
      .borderRadius(AppRadius.pill)
      .border({
        width: 1,
        color: this.selected ? AppColor.primary : AppColor.divider
      })
      .onClick((): void => this.onTap())
  }
}
