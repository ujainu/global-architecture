import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { ArchitectureDetail } from '../../model/Architecture'
import { ArchCover } from '../common/ArchCover'

/** 首页建筑推荐卡片轮播 */
@ComponentV2
export struct RecommendSwiper {
  @Param items: ArchitectureDetail[] = []
  @Event onOpen: (archId: string) => void = (): void => {}

  /** 有实拍图时用首图作背景，否则回退渐变占位 */
  private coverFile(item: ArchitectureDetail): string {
    return item.images.length > 0 ? item.images[0].file : ''
  }

  build() {
    Swiper() {
      ForEach(this.items, (item: ArchitectureDetail): void => {
        Stack({ alignContent: Alignment.BottomStart }) {
          if (this.coverFile(item).length > 0) {
            Image($rawfile(this.coverFile(item)))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
            // 底部压暗，保证白色标题可读
            Column()
              .width('100%')
              .height('78%')
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.75)', 1]]
              })
          } else {
            ArchCover({
              title: '',
              fromColor: item.coverFrom,
              toColor: item.coverTo,
              radius: AppRadius.xl
            })
          }

          Column({ space: 6 }) {
            Row({ space: 6 }) {
              Text('★ 编辑推荐')
                .fontSize(AppFont.mini)
                .fontColor(AppColor.primaryDark)
                .backgroundColor('rgba(200,163,92,0.92)')
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .borderRadius(AppRadius.pill)
            }
            Text(item.name)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text(`${item.country} · ${item.city}　|　${item.yearText}`)
              .fontSize(AppFont.caption)
              .fontColor('rgba(255,255,255,0.88)')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
        }
        .width('100%')
        .height('100%')
        .borderRadius(AppRadius.xl)
        .clip(true)
        .onClick((): void => this.onOpen(item.id))
      }, (item: ArchitectureDetail): string => item.id)
    }
    .width('100%')
    .height(208)
    .autoPlay(true)
    .interval(4000)
    .indicator(true)
    .indicatorStyle({
      size: 6,
      left: 18,
      bottom: 12,
      color: 'rgba(255,255,255,0.5)',
      selectedColor: Color.White
    })
    .borderRadius(AppRadius.xl)
  }
}
