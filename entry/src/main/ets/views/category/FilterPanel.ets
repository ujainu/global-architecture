import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { Continent, EraDef, StyleDef } from '../../model/Architecture'
import { TagChip } from '../common/TagChip'

/**
 * 三维度筛选面板：按大洲 + 按时代 + 按建筑风格
 * 每个维度以「全部」作为互斥的清空入口，顶部另提供「清除筛选」一键重置。
 */
@ComponentV2
export struct FilterPanel {
  @Param continents: Continent[] = []
  @Param eras: EraDef[] = []
  @Param styles: StyleDef[] = []
  @Param selectedContinentId: string = ''
  @Param selectedEraId: string = ''
  @Param selectedStyleId: string = ''
  @Event onSelectContinent: (id: string) => void = (): void => {}
  @Event onSelectEra: (id: string) => void = (): void => {}
  @Event onSelectStyle: (id: string) => void = (): void => {}
  @Event onReset: () => void = (): void => {}

  private hasFilter(): boolean {
    return this.selectedContinentId.length > 0
      || this.selectedEraId.length > 0
      || this.selectedStyleId.length > 0
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('筛选条件')
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .layoutWeight(1)
        if (this.hasFilter()) {
          Text('清除筛选')
            .fontSize(AppFont.caption)
            .fontColor(AppColor.danger)
            .onClick((): void => this.onReset())
        }
      }
      .width('100%')

      // 维度一：大洲
      Column({ space: 8 }) {
        Text('按大洲')
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          TagChip({
            label: '全部',
            selected: this.selectedContinentId.length === 0,
            small: true,
            onTap: (): void => {
              if (this.selectedContinentId.length > 0) {
                this.onSelectContinent(this.selectedContinentId)
              }
            }
          })
            .margin({ right: 10, bottom: 10 })
          ForEach(this.continents, (item: Continent): void => {
            TagChip({
              label: `${item.emoji} ${item.name}`,
              selected: this.selectedContinentId === item.id,
              small: true,
              onTap: (): void => this.onSelectContinent(item.id)
            })
              .margin({ right: 10, bottom: 10 })
          }, (item: Continent): string => item.id)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Divider().color(AppColor.divider)

      // 维度二：时代
      Column({ space: 8 }) {
        Text('按时代')
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          TagChip({
            label: '全部',
            selected: this.selectedEraId.length === 0,
            small: true,
            onTap: (): void => {
              if (this.selectedEraId.length > 0) {
                this.onSelectEra(this.selectedEraId)
              }
            }
          })
            .margin({ right: 10, bottom: 10 })
          ForEach(this.eras, (item: EraDef): void => {
            TagChip({
              label: item.name,
              selected: this.selectedEraId === item.id,
              small: true,
              onTap: (): void => this.onSelectEra(item.id)
            })
              .margin({ right: 10, bottom: 10 })
          }, (item: EraDef): string => item.id)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Divider().color(AppColor.divider)

      // 维度三：建筑风格
      Column({ space: 8 }) {
        Text('按建筑风格')
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          TagChip({
            label: '全部',
            selected: this.selectedStyleId.length === 0,
            small: true,
            onTap: (): void => {
              if (this.selectedStyleId.length > 0) {
                this.onSelectStyle(this.selectedStyleId)
              }
            }
          })
            .margin({ right: 10, bottom: 10 })
          ForEach(this.styles, (item: StyleDef): void => {
            TagChip({
              label: item.name,
              selected: this.selectedStyleId === item.id,
              small: true,
              onTap: (): void => this.onSelectStyle(item.id)
            })
              .margin({ right: 10, bottom: 10 })
          }, (item: StyleDef): string => item.id)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
    .alignItems(HorizontalAlign.Start)
  }
}
