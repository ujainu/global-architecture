import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { ConflictItem } from '../../model/SyncTypes'

/** 冲突对比：本机版本 vs 云端版本，二选一解决 */
@ComponentV2
export struct ConflictDiffView {
  @Param conflicts: ConflictItem[] = []
  @Event onResolve: (conflictId: string, keepLocal: boolean) => void = (): void => {}

  build() {
    Column({ space: 10 }) {
      ForEach(this.conflicts, (item: ConflictItem): void => {
        Column({ space: 10 }) {
          Row({ space: 6 }) {
            Text('⚠️').fontSize(14)
            Text(`笔记冲突：${item.noteTitle}`)
              .fontSize(AppFont.body)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColor.textPrimary)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            if (item.resolved) {
              Text('已解决')
                .fontSize(AppFont.mini)
                .fontColor(AppColor.success)
                .backgroundColor('#E7F5EE')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(AppRadius.pill)
            }
          }
          .width('100%')

          if (!item.resolved) {
            Row({ space: 8 }) {
              // 本机版本
              Column({ space: 5 }) {
                Text('📱 本机版本')
                  .fontSize(AppFont.mini)
                  .fontColor(AppColor.primary)
                  .fontWeight(FontWeight.Medium)
                Text(item.localContent)
                  .fontSize(AppFont.mini)
                  .fontColor(AppColor.textSecondary)
                  .lineHeight(18)
                Text(item.localTimeText)
                  .fontSize(10)
                  .fontColor(AppColor.textHint)
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor(AppColor.primaryLight)
              .borderRadius(AppRadius.md)
              .alignItems(HorizontalAlign.Start)

              // 云端版本
              Column({ space: 5 }) {
                Text('☁️ 云端版本')
                  .fontSize(AppFont.mini)
                  .fontColor('#8A6A2E')
                  .fontWeight(FontWeight.Medium)
                Text(item.remoteContent)
                  .fontSize(AppFont.mini)
                  .fontColor(AppColor.textSecondary)
                  .lineHeight(18)
                Text(item.remoteTimeText)
                  .fontSize(10)
                  .fontColor(AppColor.textHint)
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor(AppColor.accentLight)
              .borderRadius(AppRadius.md)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Row({ space: 10 }) {
              Text('保留本机')
                .layoutWeight(1)
                .height(36)
                .fontSize(AppFont.caption)
                .fontColor(AppColor.primary)
                .textAlign(TextAlign.Center)
                .backgroundColor(AppColor.primaryLight)
                .borderRadius(AppRadius.pill)
                .onClick((): void => this.onResolve(item.id, true))
              Text('采用云端')
                .layoutWeight(1)
                .height(36)
                .fontSize(AppFont.caption)
                .fontColor(Color.White)
                .textAlign(TextAlign.Center)
                .backgroundColor(AppColor.primary)
                .borderRadius(AppRadius.pill)
                .onClick((): void => this.onResolve(item.id, false))
            }
            .width('100%')
          } else {
            Text(item.resolutionText)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.success)
              .backgroundColor('#E7F5EE')
              .padding(10)
              .borderRadius(AppRadius.md)
              .width('100%')
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor(AppColor.card)
        .borderRadius(AppRadius.lg)
        .alignItems(HorizontalAlign.Start)
      }, (item: ConflictItem): string => `${item.id}_${item.resolved ? 'r' : 'u'}`)
    }
    .width('100%')
  }
}
