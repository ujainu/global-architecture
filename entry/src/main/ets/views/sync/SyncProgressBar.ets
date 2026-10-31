import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { SyncState } from '../../model/SyncTypes'

/** 同步进度条 */
@ComponentV2
export struct SyncProgressBar {
  @Param progress: number = 0
  @Param state: SyncState = SyncState.Idle

  private statusText(): string {
    if (this.state === SyncState.Syncing) {
      return `同步中 ${Math.floor(this.progress)}%`
    }
    if (this.state === SyncState.Success) {
      return '同步完成'
    }
    if (this.state === SyncState.Failed) {
      return '同步中断（存在冲突）'
    }
    return '等待同步'
  }

  private barColor(): string {
    if (this.state === SyncState.Failed) {
      return AppColor.danger
    }
    if (this.state === SyncState.Success) {
      return AppColor.success
    }
    return AppColor.primary
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.statusText())
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textSecondary)
          .layoutWeight(1)
        Text(`${Math.floor(this.progress)}%`)
          .fontSize(AppFont.caption)
          .fontColor(AppColor.primary)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .borderRadius(4)
          .backgroundColor('#E7EBF0')
        Row()
          .width(`${this.progress}%`)
          .height(8)
          .borderRadius(4)
          .backgroundColor(this.barColor())
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
    .alignItems(HorizontalAlign.Start)
  }
}
