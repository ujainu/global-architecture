import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { ArchitectureDetail } from '../../model/Architecture'
import { ArchitectureRepository } from '../../repository/ArchitectureRepository'
import { ArchCover } from '../common/ArchCover'

/** 建筑列表项：封面 + 名称 + 区位年代 + 风格标签 */
@ComponentV2
export struct ArchitectureListItem {
  @Param item: ArchitectureDetail | null = null
  @Param favorited: boolean = false
  @Event onOpen: (archId: string) => void = (): void => {}
  @Event onToggleFavorite: (archId: string) => void = (): void => {}

  private repo: ArchitectureRepository = ArchitectureRepository.instance

  /** 有实拍图时用首图作封面，否则回退渐变占位 */
  private coverFile(): string {
    if (!this.item || this.item.images.length === 0) {
      return ''
    }
    return this.item.images[0].file
  }

  build() {
    if (this.item) {
      Row({ space: 12 }) {
        Stack() {
          if (this.coverFile().length > 0) {
            Image($rawfile(this.coverFile()))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(AppRadius.md)
          } else {
            ArchCover({
              title: this.item.name,
              fromColor: this.item.coverFrom,
              toColor: this.item.coverTo,
              radius: AppRadius.md
            })
          }
        }
        .width(96)
        .height(78)
        .borderRadius(AppRadius.md)
        .clip(true)

        Column({ space: 5 }) {
          Text(this.item.name)
            .fontSize(AppFont.subtitle)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColor.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row({ space: 4 }) {
            Image($r('app.media.ic_location'))
              .width(12)
              .height(12)
              .fillColor(AppColor.textHint)
            Text(`${this.item.country} · ${this.item.yearText}`)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textHint)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Text(this.repo.getStyleNames(this.item.styleIds).join(' / '))
            .fontSize(AppFont.mini)
            .fontColor(AppColor.primary)
            .backgroundColor(AppColor.primaryLight)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(AppRadius.sm)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.favorited) {
          Image($r('app.media.ic_heart_fill'))
            .width(22)
            .height(22)
            .fillColor(AppColor.favorite)
            .onClick((): void => this.onToggleFavorite(this.item!.id))
        } else {
          Image($r('app.media.ic_chevron_right'))
            .width(18)
            .height(18)
            .fillColor(AppColor.textHint)
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor(AppColor.card)
      .borderRadius(AppRadius.lg)
      .alignItems(VerticalAlign.Center)
      .onClick((): void => this.onOpen(this.item!.id))
    }
  }
}
