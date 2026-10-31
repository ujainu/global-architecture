import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/** 顶部搜索框 */
@ComponentV2
export struct SearchBar {
  @Param keyword: string = ''
  @Event onKeywordChange: (value: string) => void = (): void => {}
  @Event onClear: () => void = (): void => {}

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_search'))
        .width(18)
        .height(18)
        .fillColor(AppColor.textHint)

      TextInput({ text: this.keyword, placeholder: '搜索建筑 / 城市 / 建筑师' })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .fontSize(AppFont.body)
        .fontColor(AppColor.textPrimary)
        .padding({ top: 0, bottom: 0, left: 0, right: 0 })
        .height(40)
        .onChange((value: string): void => this.onKeywordChange(value))

      if (this.keyword.length > 0) {
        Text('✕')
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .width(28)
          .height(28)
          .textAlign(TextAlign.Center)
          .onClick((): void => this.onClear())
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 14, right: 10 })
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.pill)
    .alignItems(VerticalAlign.Center)
    .shadow({ radius: 8, color: 'rgba(23,62,107,0.08)', offsetX: 0, offsetY: 3 })
  }
}
