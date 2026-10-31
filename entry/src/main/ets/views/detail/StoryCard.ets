import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/** 趣味小故事卡片 */
@ComponentV2
export struct StoryCard {
  @Param content: string = ''

  build() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text('💡')
          .fontSize(15)
        Text('趣味小故事')
          .fontSize(AppFont.subtitle)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColor.primaryDark)
      }
      .width('100%')

      Text(this.content)
        .fontSize(AppFont.body)
        .fontColor('#5C4A2E')
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .borderRadius(AppRadius.lg)
    .linearGradient({
      angle: 135,
      colors: [[AppColor.accentLight, 0], ['#FBF6EA', 1]]
    })
    .alignItems(HorizontalAlign.Start)
  }
}
