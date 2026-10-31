import { AppColor, AppDims, AppFont, AppRadius } from '../../common/theme/Theme'
import { appStack } from '../../common/router/AppRouter'
import { ConflictItem, SyncOpRecord, SyncState } from '../../model/SyncTypes'
import { SyncService } from '../../service/SyncService'
import { SyncProgressBar } from '../../views/sync/SyncProgressBar'
import { DeviceList } from '../../views/sync/DeviceList'
import { ConflictDiffView } from '../../views/sync/ConflictDiffView'
import { SectionTitle } from '../../views/common/SectionTitle'

/** 二级页：分布式同步面板（进度 / 设备 / 冲突 / 流水） */
@ComponentV2
export struct SyncPanelPage {
  @Local service: SyncService = SyncService.instance
  // SyncService 在定时器中连续修改 @Trace 字段，外部单例状态在当前运行时不稳定驱动本页刷新，
  // 因此页面存活期间用 200ms 视图心跳强制按最新状态重绘（页面销毁即清除）
  @Local viewTick: number = 0
  private viewTimer: number = -1

  aboutToAppear(): void {
    this.viewTimer = setInterval((): void => {
      this.viewTick++
    }, 200)
  }

  aboutToDisappear(): void {
    if (this.viewTimer !== -1) {
      clearInterval(this.viewTimer)
      this.viewTimer = -1
    }
  }

  // 以下取值方法均先读取 viewTick，使调用处在心跳驱动下重新求值
  private currentProgress(): number {
    if (this.viewTick < 0) {
      return 0
    }
    return this.service.progress
  }

  private currentState(): SyncState {
    if (this.viewTick < 0) {
      return SyncState.Idle
    }
    return this.service.state
  }

  private currentLastText(): string {
    if (this.viewTick < 0) {
      return ''
    }
    return this.service.lastSyncText
  }

  private currentConflictCount(): number {
    if (this.viewTick < 0) {
      return 0
    }
    return this.service.unresolvedCount()
  }

  private currentConflicts(): ConflictItem[] {
    if (this.viewTick < 0) {
      return []
    }
    return this.service.conflicts
  }

  private currentOps(): SyncOpRecord[] {
    if (this.viewTick < 0) {
      return []
    }
    return this.service.ops
  }

  private syncing(): boolean {
    if (this.viewTick < 0) {
      return false
    }
    return this.service.isSyncing()
  }

  build() {
    NavDestination() {
      Column() {
        // 标题栏
        Row() {
          Row() {
            Image($r('app.media.ic_back'))
              .width(20)
              .height(20)
              .fillColor(AppColor.textPrimary)
          }
          .width(38)
          .height(38)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => {
            appStack.pop()
          })

          Text('同步面板')
            .fontSize(AppFont.subtitle)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColor.textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('开始同步')
            .fontSize(AppFont.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor(this.syncing() ? AppColor.textHint : AppColor.primary)
            .borderRadius(AppRadius.pill)
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .onClick((): void => {
              if (!this.service.isSyncing()) {
                this.service.startSync()
              }
            })
          Text('')
            .width(38)
        }
        .width('100%')
        .height(52)
        .padding({ left: 10, right: 16 })
        .backgroundColor(AppColor.card)
        .border({ width: { bottom: 1 }, color: AppColor.divider })

        Scroll() {
          Column({ space: AppDims.cardGap }) {
            Column({ space: 12 }) {
              SectionTitle({ title: '同步进度' })
              SyncProgressBar({
                progress: this.currentProgress(),
                state: this.currentState()
              })
              Text(`最近同步时间：${this.currentLastText()}`)
                .fontSize(AppFont.mini)
                .fontColor(AppColor.textHint)
                .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 10 }) {
              SectionTitle({ title: '我的设备' })
              DeviceList({ devices: this.service.devices })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 10 }) {
              SectionTitle({ title: `冲突记录（${this.currentConflictCount()}）` })
              if (this.currentConflicts().length === 0) {
                Text('暂无冲突记录')
                  .fontSize(AppFont.caption)
                  .fontColor(AppColor.textHint)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding(20)
              } else {
                ConflictDiffView({
                  conflicts: this.currentConflicts(),
                  onResolve: (id: string, keepLocal: boolean): void => {
                    this.service.resolveConflict(id, keepLocal)
                  }
                })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              SectionTitle({ title: '同步流水' })
              if (this.currentOps().length === 0) {
                Text('点击右上角「开始同步」模拟一次多端同步')
                  .fontSize(AppFont.caption)
                  .fontColor(AppColor.textHint)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding(20)
              } else {
                ForEach(this.currentOps(), (op: SyncOpRecord): void => {
                  Row({ space: 10 }) {
                    Circle({ width: 7, height: 7 })
                      .fill(AppColor.accent)
                      .margin({ left: 4 })
                    Column({ space: 2 }) {
                      Text(`${op.typeText} · ${op.targetText}`)
                        .fontSize(AppFont.caption)
                        .fontColor(AppColor.textPrimary)
                      Text(op.timeText)
                        .fontSize(AppFont.mini)
                        .fontColor(AppColor.textHint)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .padding({ top: 5, bottom: 5 })
                }, (op: SyncOpRecord): string => op.id)
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(AppDims.pagePadding)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColor.bg)
    }
    .hideTitleBar(true)
  }
}
