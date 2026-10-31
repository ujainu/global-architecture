import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { SyncState } from '../../model/SyncTypes'

/** 分布式同步入口卡片 */
@ComponentV2
export struct SyncCard {
  @Param state: SyncState = SyncState.Idle
  @Param lastSyncText: string = '尚未同步'
  @Param conflictCount: number = 0
  @Event onTap: () => void = (): void => {}

  private statusText(): string {
    if (this.state === SyncState.Syncing) {
      return '正在同步…'
    }
    if (this.conflictCount > 0) {
      return `${this.conflictCount} 处冲突待处理`
    }
    if (this.state === SyncState.Success) {
      return `上次同步：${this.lastSyncText}`
    }
    return '点击管理多端数据同步'
  }

  private dotColor(): string {
    if (this.state === SyncState.Syncing) {
      return AppColor.accent
    }
    if (this.conflictCount > 0) {
      return AppColor.danger
    }
    if (this.state === SyncState.Success) {
      return AppColor.success
    }
    return AppColor.textHint
  }

  build() {
    Row({ space: 12 }) {
      Text('🔄')
        .fontSize(22)
        .width(46)
        .height(46)
        .textAlign(TextAlign.Center)
        .backgroundColor(AppColor.primaryLight)
        .borderRadius(23)

      Column({ space: 4 }) {
        Text('分布式同步')
          .fontSize(AppFont.body)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColor.textPrimary)
        Row({ space: 5 }) {
          Circle({ width: 7, height: 7 }).fill(this.dotColor())
          Text(this.statusText())
            .fontSize(AppFont.mini)
            .fontColor(AppColor.textHint)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_chevron_right'))
        .width(18)
        .height(18)
        .fillColor(AppColor.textHint)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
    .onClick((): void => this.onTap())
  }
}
