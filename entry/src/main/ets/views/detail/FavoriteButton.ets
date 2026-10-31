import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/** 收藏按钮：心形图标 + 文案，随状态变色 */
@ComponentV2
export struct FavoriteButton {
  @Param active: boolean = false
  @Event onToggle: () => void = (): void => {}

  build() {
    Row({ space: 6 }) {
      Image(this.active ? $r('app.media.ic_heart_fill') : $r('app.media.ic_heart_outline'))
        .width(20)
        .height(20)
        .fillColor(this.active ? AppColor.favorite : AppColor.textSecondary)
      Text(this.active ? '已收藏' : '收藏')
        .fontSize(AppFont.caption)
        .fontColor(this.active ? AppColor.favorite : AppColor.textSecondary)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 16, right: 16, top: 9, bottom: 9 })
    .borderRadius(AppRadius.pill)
    .backgroundColor(this.active ? '#FDECEC' : AppColor.card)
    .border({
      width: 1,
      color: this.active ? '#F6C9C9' : AppColor.divider
    })
    .onClick((): void => {
      this.onToggle()
    })
  }
}
