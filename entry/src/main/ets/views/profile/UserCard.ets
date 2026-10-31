import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/** 个人中心用户卡 */
@ComponentV2
export struct UserCard {
  @Param favoriteCount: number = 0
  @Param noteCount: number = 0
  @Param visitedCount: number = 0

  build() {
    Column({ space: 0 }) {
      Row({ space: 14 }) {
        Text('🧭')
          .fontSize(30)
          .width(64)
          .height(64)
          .textAlign(TextAlign.Center)
          .backgroundColor(AppColor.primaryLight)
          .borderRadius(32)

        Column({ space: 4 }) {
          Text('建筑探索者')
            .fontSize(AppFont.title)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColor.textPrimary)
          Text('在砖石与光影之间环游世界')
            .fontSize(AppFont.caption)
            .fontColor(AppColor.textHint)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)

      Row() {
        this.StatItem('收藏', this.favoriteCount)
        Divider().vertical(true).height(28).color(AppColor.divider)
        this.StatItem('笔记', this.noteCount)
        Divider().vertical(true).height(28).color(AppColor.divider)
        this.StatItem('建筑库', this.visitedCount)
      }
      .width('100%')
      .padding({ top: 10, bottom: 12 })
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
  }

  @Builder
  StatItem(label: string, value: number) {
    Column({ space: 2 }) {
      Text(`${value}`)
        .fontSize(AppFont.subtitle)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColor.primary)
      Text(label)
        .fontSize(AppFont.mini)
        .fontColor(AppColor.textHint)
    }
  }
}
