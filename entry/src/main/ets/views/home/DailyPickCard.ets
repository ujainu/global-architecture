import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { ArchitectureDetail } from '../../model/Architecture'

/**
 * 每日建筑推荐
 * 由首页按日期确定性地推选一座建筑（同一天内保持稳定），
 * 展示封面、名称、区位年代、简介，并从「拓展小故事」摘一句冷知识作引子。
 */
@ComponentV2
export struct DailyPickCard {
  @Param arch: ArchitectureDetail | null = null
  @Param dateText: string = ''
  @Param styleText: string = ''
  @Event onOpen: (archId: string) => void = (): void => {}

  private coverFile(): string {
    if (!this.arch || this.arch.images.length === 0) {
      return ''
    }
    return this.arch.images[0].file
  }

  /** 取小故事开头作为「冷知识」引子 */
  private teaser(): string {
    if (!this.arch) {
      return ''
    }
    const s: string = this.arch.story
    return s.length > 44 ? `${s.substring(0, 44)}…` : s
  }

  build() {
    Column() {
      // 封面区：实拍图（缺图时回退渐变）+ 底部压暗 + 标题
      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.coverFile().length > 0) {
          Image($rawfile(this.coverFile()))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        } else if (this.arch) {
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 135,
              colors: [[this.arch.coverFrom, 0], [this.arch.coverTo, 1]]
            })
        }

        Column()
          .width('100%')
          .height('64%')
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.66)', 1]]
          })

        Column({ space: 5 }) {
          Row({ space: 6 }) {
            Text('今日')
              .fontSize(AppFont.mini)
              .fontColor(AppColor.primaryDark)
              .backgroundColor('rgba(200,163,92,0.94)')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(AppRadius.pill)
            Text(this.dateText)
              .fontSize(AppFont.mini)
              .fontColor('rgba(255,255,255,0.9)')
          }

          Text(this.arch ? this.arch.name : '')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(this.arch ? this.arch.nameEn : '')
            .fontSize(AppFont.mini)
            .fontColor('rgba(255,255,255,0.82)')
            .fontStyle(FontStyle.Italic)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(166)

      // 信息区
      if (this.arch) {
        Column({ space: 10 }) {
          Row({ space: 6 }) {
            Image($r('app.media.ic_location'))
              .width(13)
              .height(13)
              .fillColor(AppColor.textSecondary)
            Text(`${this.arch.country} · ${this.arch.city}`)
              .fontSize(AppFont.caption)
              .fontColor(AppColor.textSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
            Text(this.arch.yearText)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textHint)
              .maxLines(1)
          }
          .width('100%')

          Text(this.arch.summary)
            .fontSize(AppFont.caption)
            .fontColor(AppColor.textPrimary)
            .lineHeight(21)
            .width('100%')

          if (this.styleText.length > 0) {
            Text(this.styleText)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.primary)
              .backgroundColor(AppColor.primaryLight)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(AppRadius.sm)
          }

          Divider().color(AppColor.divider)

          Row({ space: 8 }) {
            Text('💡')
              .fontSize(14)
            Text(this.teaser())
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textSecondary)
              .lineHeight(19)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
        .width('100%')
        .padding(14)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.xl)
    .clip(true)
    .onClick((): void => {
      if (this.arch) {
        this.onOpen(this.arch.id)
      }
    })
  }
}
