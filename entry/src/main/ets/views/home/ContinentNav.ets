import { AppColor, AppFont } from '../../common/theme/Theme'
import { Continent } from '../../model/Architecture'

/** 大洲快捷导航：横向滑动的圆形入口 */
@ComponentV2
export struct ContinentNav {
  @Param continents: Continent[] = []
  @Event onSelect: (continentId: string) => void = (): void => {}

  build() {
    Scroll(this.scroller) {
      Row({ space: 18 }) {
        ForEach(this.continents, (item: Continent): void => {
          Column({ space: 6 }) {
            Text(item.emoji)
              .fontSize(24)
              .width(54)
              .height(54)
              .textAlign(TextAlign.Center)
              .backgroundColor(AppColor.primaryLight)
              .borderRadius(27)
            Text(item.name)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textSecondary)
          }
          .onClick((): void => this.onSelect(item.id))
        }, (item: Continent): string => item.id)
      }
      .padding({ left: 2, right: 2 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  private scroller: Scroller = new Scroller()
}
