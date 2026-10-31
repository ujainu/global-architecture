import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'

/**
 * 建筑封面（占位实现）：渐变 + 名称水印
 * 后续 rawfile 图片就绪后，可在调用处替换为 Image($rawfile(...))
 */
@ComponentV2
export struct ArchCover {
  @Param title: string = ''
  @Param fromColor: string = AppColor.primary
  @Param toColor: string = AppColor.primaryDark
  @Param radius: number = AppRadius.lg
  @Param showName: boolean = true
  @Param emoji: string = '🏛️'

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column({ space: 6 }) {
        Text(this.emoji)
          .fontSize(34)
          .opacity(0.92)
        if (this.showName) {
          Text(this.title)
            .fontSize(AppFont.caption)
            .fontColor('rgba(255,255,255,0.92)')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)

      // 底部压暗渐变，保证白字可读
      Column()
        .width('100%')
        .height('45%')
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.38)', 1]]
        })
        .borderRadius(this.radius)
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .borderRadius(this.radius)
    .linearGradient({
      angle: 135,
      colors: [[this.fromColor, 0], [this.toColor, 1]]
    })
  }
}
