import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { Note } from '../../model/Note'
import { DateUtil } from '../../common/utils/DateUtil'

/** 笔记卡片 */
@ComponentV2
export struct NoteCard {
  @Param note: Note | null = null
  @Param archName: string = ''
  @Event onEdit: () => void = (): void => {}
  @Event onRemove: () => void = (): void => {}

  build() {
    if (this.note) {
      Column({ space: 8 }) {
        Row() {
          Text(this.note.title.length > 0 ? this.note.title : '未命名笔记')
            .fontSize(AppFont.subtitle)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColor.textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Image($r('app.media.ic_edit'))
            .width(18)
            .height(18)
            .fillColor(AppColor.textHint)
            .padding(6)
            .onClick((): void => this.onEdit())

          Image($r('app.media.ic_trash'))
            .width(18)
            .height(18)
            .fillColor(AppColor.textHint)
            .padding(6)
            .onClick((): void => this.onRemove())
        }
        .width('100%')

        Text(this.note.content)
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textSecondary)
          .lineHeight(20)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row({ space: 5 }) {
          Image($r('app.media.ic_location'))
            .width(11)
            .height(11)
            .fillColor(AppColor.primary)
          Text(this.archName)
            .fontSize(AppFont.mini)
            .fontColor(AppColor.primary)
          Text('·')
            .fontSize(AppFont.mini)
            .fontColor(AppColor.textHint)
          Text(DateUtil.formatDate(this.note.updatedAt))
            .fontSize(AppFont.mini)
            .fontColor(AppColor.textHint)
        }
        .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor(AppColor.card)
      .borderRadius(AppRadius.lg)
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => this.onEdit())
    }
  }
}
