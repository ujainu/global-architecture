import { promptAction } from '@kit.ArkUI'
import { AppColor, AppDims, AppFont, AppRadius } from '../../common/theme/Theme'
import { AppRouter } from '../../common/router/AppRouter'
import { ArchitectureRepository } from '../../repository/ArchitectureRepository'
import { ProfileViewModel } from '../../viewmodels/ProfileViewModel'
import { SyncService } from '../../service/SyncService'
import { UserCard } from '../../views/profile/UserCard'
import { SyncCard } from '../../views/profile/SyncCard'
import { SectionTitle } from '../../views/common/SectionTitle'

/** ⑦ 个人中心：分布式同步入口 + 基础设置 */
@ComponentV2
export struct ProfilePage {
  @Local vm: ProfileViewModel = ProfileViewModel.instance
  @Local syncService: SyncService = SyncService.instance
  private archRepo: ArchitectureRepository = ArchitectureRepository.instance
  // 本地 tick：Tabs 各页常驻，切 Tab 不会重新执行 build()，
  // 在详情页收藏 / 写笔记后切回本页，计数不会自己更新；靠「本页重新可见」自增强制重算
  @Local tick: number = 0

  private favCount(): number {
    if (this.tick < 0) {
      return 0
    }
    return this.vm.favoriteCount()
  }

  private noteCount(): number {
    if (this.tick < 0) {
      return 0
    }
    return this.vm.noteCount()
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: AppDims.cardGap }) {
        UserCard({
          favoriteCount: this.favCount(),
          noteCount: this.noteCount(),
          visitedCount: this.archRepo.getAll().length
        })

        Row({ space: 12 }) {
          Text('📝')
            .fontSize(20)
            .width(46)
            .height(46)
            .textAlign(TextAlign.Center)
            .backgroundColor(AppColor.accentLight)
            .borderRadius(23)
          Column({ space: 3 }) {
            Text('我的笔记')
              .fontSize(AppFont.body)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColor.textPrimary)
            Text(`${this.noteCount()} 篇观建筑笔记`)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textHint)
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
        .onClick((): void => AppRouter.pushNoteList())

        SectionTitle({ title: '数据同步' })
        SyncCard({
          state: this.syncService.state,
          lastSyncText: this.syncService.lastSyncText,
          conflictCount: this.syncService.unresolvedCount(),
          onTap: (): void => AppRouter.pushSyncPanel()
        })

        SectionTitle({ title: '基础设置' })

        Column() {
          this.ToggleRow('🔁', '自动同步', '收藏与笔记变更后自动同步到其他设备', this.vm.autoSync,
            (v: boolean): void => this.vm.onAutoSyncChange(v))
          Divider().color(AppColor.divider).margin({ left: 54 })
          this.ToggleRow('📶', '仅 Wi-Fi 下同步', '避免移动网络消耗流量', this.vm.wifiOnly,
            (v: boolean): void => this.vm.onWifiOnlyChange(v))
          Divider().color(AppColor.divider).margin({ left: 54 })
          this.ToggleRow('🌙', '深色模式', '跟随系统或手动切换深色外观', this.vm.darkMode,
            (v: boolean): void => this.vm.onDarkModeChange(v))
          Divider().color(AppColor.divider).margin({ left: 54 })
          this.ActionRow('ℹ️', '关于我们', '版本 1.0.0 · 离线建筑资料库', (): void => this.showAbout())
        }
        .width('100%')
        .backgroundColor(AppColor.card)
        .borderRadius(AppRadius.lg)
        .clip(true)

        Text('环球建筑博览 · Global Architecture')
          .fontSize(AppFont.mini)
          .fontColor(AppColor.textHint)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 6, bottom: 12 })
        }
        .width('100%')
        .padding({
          left: AppDims.pagePadding,
          right: AppDims.pagePadding,
          top: AppDims.pagePadding,
          bottom: AppDims.pagePadding + AppDims.navSafeSpace
        })
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColor.bg)
    // 本页重新可见时重算收藏 / 笔记计数
    .onVisibleAreaChange([0.0, 0.4], (isVisible: boolean): void => {
      if (isVisible) {
        this.tick++
      }
    })
  }

  @Builder
  ToggleRow(emoji: string, title: string, desc: string, isOn: boolean, onChange: (v: boolean) => void) {
    Row({ space: 12 }) {
      Text(emoji)
        .fontSize(18)
        .width(28)
        .textAlign(TextAlign.Center)
      Column({ space: 3 }) {
        Text(title)
          .fontSize(AppFont.body)
          .fontColor(AppColor.textPrimary)
        Text(desc)
          .fontSize(AppFont.mini)
          .fontColor(AppColor.textHint)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor(AppColor.primary)
        .onChange((v: boolean): void => onChange(v))
    }
    .width('100%')
    .height(64)
    .padding({ left: 14, right: 14 })
  }

  @Builder
  ActionRow(emoji: string, title: string, desc: string, onTap: () => void) {
    Row({ space: 12 }) {
      Text(emoji)
        .fontSize(18)
        .width(28)
        .textAlign(TextAlign.Center)
      Column({ space: 3 }) {
        Text(title)
          .fontSize(AppFont.body)
          .fontColor(AppColor.textPrimary)
        Text(desc)
          .fontSize(AppFont.mini)
          .fontColor(AppColor.textHint)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Image($r('app.media.ic_chevron_right'))
        .width(18)
        .height(18)
        .fillColor(AppColor.textHint)
    }
    .width('100%')
    .height(64)
    .padding({ left: 14, right: 14 })
    .onClick((): void => onTap())
  }

  private showAbout(): void {
    promptAction.showDialog({
      title: '环球建筑博览',
      message: '一款离线的世界建筑鉴赏应用，支持建筑检索、知识图谱浏览、笔记收藏以及多设备分布式同步。',
      buttons: [{ text: '知道了', color: AppColor.primary }]
    })
  }
}
