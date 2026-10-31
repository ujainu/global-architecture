import { AppColor, AppDims, AppFont } from '../../common/theme/Theme'
import { AppRouter } from '../../common/router/AppRouter'
import { ArchitectureDetail } from '../../model/Architecture'
import { HomeViewModel } from '../../viewmodels/HomeViewModel'
import { SearchService } from '../../service/SearchService'
import { ArchitectureRepository } from '../../repository/ArchitectureRepository'
import { SearchBar } from '../../views/home/SearchBar'
import { ContinentNav } from '../../views/home/ContinentNav'
import { RecommendSwiper } from '../../views/home/RecommendSwiper'
import { DailyPickCard } from '../../views/home/DailyPickCard'
import { EraTimeline } from '../../views/home/EraTimeline'
import { StatsStrip } from '../../views/home/StatsStrip'
import { SectionTitle } from '../../views/common/SectionTitle'
import { ArchitectureListItem } from '../../views/category/ArchitectureListItem'
import { EmptyState } from '../../views/common/EmptyState'

/**
 * ① 首页
 * 结构：搜索 / 编辑推荐轮播 / 每日建筑推荐 / 资料库概览 / 大洲速览 / 时代长河
 *
 * 「每日建筑推荐」按日期确定性地推选一座建筑，同一天内保持不变；
 * 右上角「换一座」可在同一天内手动轮换（offset 只存在于组件本地，不影响按天的基准）。
 */
@ComponentV2
export struct HomePage {
  @Local vm: HomeViewModel = HomeViewModel.instance
  // 搜索关键词与结果用组件本地状态驱动（外部单例 @Trace 在前台页更新不可靠）
  @Local kw: string = ''
  @Local results: ArchitectureDetail[] = []
  // 「换一座」的手动偏移
  @Local dailyOffset: number = 0
  private repo: ArchitectureRepository = ArchitectureRepository.instance

  private dailyPick(): ArchitectureDetail | null {
    return this.vm.getDailyPick(this.dailyOffset)
  }

  private dailyStyleText(): string {
    const arch: ArchitectureDetail | null = this.dailyPick()
    if (!arch) {
      return ''
    }
    return this.repo.getStyleNames(arch.styleIds).join(' · ')
  }

  build() {
    Column() {
      // 顶部标题 + 搜索
      Column({ space: 12 }) {
        Row() {
          Column({ space: 3 }) {
            Text('环球建筑博览')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColor.primary)
            Text('发现穿越千年的建筑之美')
              .fontSize(AppFont.caption)
              .fontColor(AppColor.textHint)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('🏛️')
            .fontSize(20)
            .width(42)
            .height(42)
            .textAlign(TextAlign.Center)
            .backgroundColor(AppColor.primaryLight)
            .borderRadius(21)
        }
        .width('100%')

        SearchBar({
          keyword: this.kw,
          onKeywordChange: (v: string): void => {
            this.kw = v
            this.results = SearchService.search(v)
          },
          onClear: (): void => {
            this.kw = ''
            this.results = []
          }
        })
      }
      .width('100%')
      .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding, top: 14, bottom: 10 })

      if (this.kw.length > 0) {
        this.SearchResultBlock()
      } else {
        Scroll() {
          Column({ space: AppDims.sectionGap }) {
            RecommendSwiper({
              items: this.vm.getRecommends(),
              onOpen: (id: string): void => AppRouter.pushDetail(id)
            })

            // 每日建筑推荐
            Column({ space: 12 }) {
              SectionTitle({
                title: '每日建筑推荐',
                actionText: '换一座',
                onAction: (): void => {
                  this.dailyOffset++
                }
              })
              DailyPickCard({
                arch: this.dailyPick(),
                dateText: this.vm.getDailyDateText(),
                styleText: this.dailyStyleText(),
                onOpen: (id: string): void => AppRouter.pushDetail(id)
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 资料库概览
            StatsStrip({ stats: this.vm.getStats() })

            // 大洲速览
            Column({ space: 12 }) {
              SectionTitle({ title: '大洲速览' })
              ContinentNav({
                continents: this.vm.getContinents(),
                onSelect: (id: string): void => this.vm.openContinent(id)
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 时代长河
            Column({ space: 12 }) {
              SectionTitle({ title: '时代长河' })
              EraTimeline({
                eras: this.vm.getEraStats(),
                onSelect: (id: string): void => this.vm.openEra(id)
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Text('— 更多建筑请前往「分类」按大洲 · 时代 · 风格筛选 —')
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textHint)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 12 })
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
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColor.bg)
  }

  @Builder
  SearchResultBlock() {
    Column({ space: 10 }) {
      Text(`搜索结果（${this.results.length}）`)
        .fontSize(AppFont.caption)
        .fontColor(AppColor.textHint)
        .width('100%')
      if (this.results.length === 0) {
        EmptyState({
          emoji: '🔍',
          title: '没有找到相关建筑',
          hint: '试试建筑名、城市或建筑师关键词'
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.results, (item: ArchitectureDetail): void => {
              ArchitectureListItem({
                item,
                onOpen: (id: string): void => AppRouter.pushDetail(id)
              })
            }, (item: ArchitectureDetail): string => item.id)
          }
          .width('100%')
          .padding({ bottom: 12 + AppDims.navSafeSpace })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding })
    .alignItems(HorizontalAlign.Start)
  }
}
