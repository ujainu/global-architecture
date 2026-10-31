import { AppColor, AppDims, AppFont, AppRadius } from '../../common/theme/Theme'
import { AppRouter, appStack } from '../../common/router/AppRouter'
import { DetailViewModel } from '../../viewmodels/DetailViewModel'
import { FavoriteRepository } from '../../repository/FavoriteRepository'
import { ImageSwiper } from '../../views/detail/ImageSwiper'
import { ArchiveGrid } from '../../views/detail/ArchiveGrid'
import { ExpandableText } from '../../views/detail/ExpandableText'
import { StoryCard } from '../../views/detail/StoryCard'
import { FavoriteButton } from '../../views/detail/FavoriteButton'
import { EmptyState } from '../../views/common/EmptyState'

/**
 * ③ 建筑详情页（通用复用页面）
 * 所有建筑共用此页，仅接收 archId，按 ID 装载渲染
 */
@ComponentV2
export struct DetailPage {
  @Param archId: string = ''
  @Local vm: DetailViewModel = DetailViewModel.instance
  @Local favRepo: FavoriteRepository = FavoriteRepository.instance
  // 收藏选中态用组件本地布尔值驱动（@Param 子组件只可靠刷新本地基本类型状态）
  @Local favoriteActive: boolean = false

  aboutToAppear(): void {
    this.vm.load(this.archId)
    this.favoriteActive = this.favRepo.isFavorite(this.archId)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.vm.arch) {
          Column() {
            Scroll() {
              Column({ space: AppDims.sectionGap }) {
                ImageSwiper({ arch: this.vm.arch })

                // 标题区
                Column({ space: 8 }) {
                  Text(this.vm.arch.name)
                    .fontSize(26)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(AppColor.textPrimary)
                    .width('100%')
                  Text(this.vm.arch.nameEn)
                    .fontSize(AppFont.caption)
                    .fontColor(AppColor.textHint)
                    .fontStyle(FontStyle.Italic)
                    .width('100%')
                  Row({ space: 6 }) {
                    Image($r('app.media.ic_location'))
                      .width(14)
                      .height(14)
                      .fillColor(AppColor.textSecondary)
                    Text(this.vm.getLocationText())
                      .fontSize(AppFont.caption)
                      .fontColor(AppColor.textSecondary)
                    Text('·')
                      .fontSize(AppFont.caption)
                      .fontColor(AppColor.textHint)
                    Text(this.vm.arch.yearText)
                      .fontSize(AppFont.caption)
                      .fontColor(AppColor.textSecondary)
                  }
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.vm.getStyleNames(), (name: string): void => {
                      Text(name)
                        .fontSize(AppFont.mini)
                        .fontColor(AppColor.primary)
                        .backgroundColor(AppColor.primaryLight)
                        .padding({ left: 9, right: 9, top: 3, bottom: 3 })
                        .borderRadius(AppRadius.pill)
                        .margin({ right: 8, top: 4 })
                    }, (name: string): string => name)
                  }
                  .width('100%')

                  Text(this.vm.arch.summary)
                    .fontSize(AppFont.body)
                    .fontColor(AppColor.textSecondary)
                    .lineHeight(23)
                    .width('100%')
                    .margin({ top: 4 })
                }
                .width('100%')
                .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding })
                .alignItems(HorizontalAlign.Start)

                // 建筑档案
                Column({ space: 12 }) {
                  this.SectionHeader('建筑档案')
                  ArchiveGrid({
                    locationText: this.vm.getLocationText(),
                    yearText: this.vm.arch.yearText,
                    architectText: this.vm.getArchitectText(),
                    styleText: this.vm.getStyleNames().join('、')
                  })
                }
                .width('100%')
                .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding })
                .alignItems(HorizontalAlign.Start)

                // 建筑背景
                Column() {
                  ExpandableText({ title: '建筑背景', content: this.vm.arch.background })
                }
                .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding })
                .width('100%')

                // 建筑特点
                Column() {
                  ExpandableText({ title: '建筑特点', content: this.vm.arch.features })
                }
                .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding })
                .width('100%')

                // 历史变迁
                Column() {
                  ExpandableText({ title: '历史变迁', content: this.vm.arch.history })
                }
                .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding })
                .width('100%')

                // 文化价值
                Column() {
                  ExpandableText({ title: '文化价值', content: this.vm.arch.culture })
                }
                .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding })
                .width('100%')

                // 拓展小故事
                Column() {
                  StoryCard({ content: this.vm.arch.story })
                }
                .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding, bottom: 8 })
                .width('100%')
              }
              .width('100%')
              .padding({ bottom: 12 })
              .alignItems(HorizontalAlign.Start)
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .align(Alignment.Top)

            // 底部操作栏：收藏 + 新建笔记
            Row({ space: 12 }) {
              FavoriteButton({
                active: this.favoriteActive,
                onToggle: (): void => {
                  this.favRepo.toggle(this.archId)
                  this.favoriteActive = this.favRepo.isFavorite(this.archId)
                }
              })
              Button() {
                Row({ space: 6 }) {
                  Image($r('app.media.ic_edit'))
                    .width(16)
                    .height(16)
                    .fillColor(Color.White)
                  Text('新建笔记')
                    .fontSize(AppFont.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                }
              }
              .layoutWeight(1)
              .height(42)
              .backgroundColor(AppColor.primary)
              .borderRadius(AppRadius.pill)
              .onClick((): void => AppRouter.pushNoteEdit(this.archId, ''))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 10, bottom: 14 })
            .backgroundColor(AppColor.card)
            .border({ width: { top: 1 }, color: AppColor.divider })
          }
          .width('100%')
          .height('100%')
        } else {
          Column() {
            EmptyState({ emoji: '🏚️', title: '建筑内容走丢了', hint: '稍后再来看看' })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }

        // 悬浮返回按钮
        Row() {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
            .fillColor(AppColor.textPrimary)
        }
        .width(38)
        .height(38)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(255,255,255,0.92)')
        .borderRadius(19)
        .margin({ top: 44, left: 16 })
        .shadow({ radius: 6, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 2 })
        .onClick((): void => {
          appStack.pop()
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColor.bg)
    }
    .hideTitleBar(true)
  }

  @Builder
  SectionHeader(title: string) {
    Row() {
      Row()
        .width(4)
        .height(16)
        .borderRadius(2)
        .backgroundColor(AppColor.accent)
        .margin({ right: 8 })
      Text(title)
        .fontSize(AppFont.subtitle)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColor.textPrimary)
    }
    .width('100%')
  }
}
