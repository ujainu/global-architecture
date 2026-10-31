import { AppColor, AppDims, AppFont } from '../../common/theme/Theme'
import { AppRouter } from '../../common/router/AppRouter'
import { ArchitectureDetail } from '../../model/Architecture'
import { CategoryViewModel } from '../../viewmodels/CategoryViewModel'
import { FilterPanel } from '../../views/category/FilterPanel'
import { ArchitectureListItem } from '../../views/category/ArchitectureListItem'
import { EmptyState } from '../../views/common/EmptyState'
import { FavoriteRepository } from '../../repository/FavoriteRepository'

/** ② 分类浏览：大洲 × 时代 × 风格 三维筛选 + 全部建筑列表 */
@ComponentV2
export struct CategoryPage {
  @Local vm: CategoryViewModel = CategoryViewModel.instance
  private favRepo: FavoriteRepository = FavoriteRepository.instance
  // 外部单例 @Trace 在前台页更新不可靠，筛选交互后用本地 tick 驱动重算
  @Local tick: number = 0

  private currentFiltered(): ArchitectureDetail[] {
    if (this.tick < 0) {
      return []
    }
    return this.vm.getFiltered()
  }

  private currentContinentId(): string {
    if (this.tick < 0) {
      return ''
    }
    return this.vm.selectedContinentId
  }

  private currentStyleId(): string {
    if (this.tick < 0) {
      return ''
    }
    return this.vm.selectedStyleId
  }

  private currentEraId(): string {
    if (this.tick < 0) {
      return ''
    }
    return this.vm.selectedEraId
  }

  private isFav(id: string): boolean {
    if (this.tick < 0) {
      return false
    }
    return this.favRepo.isFavorite(id)
  }

  build() {
    Column() {
      // 标题区
      Column({ space: 4 }) {
        Text('分类浏览')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColor.primary)
          .width('100%')
        Text(`大洲 × 时代 × 风格 三维筛选，共 ${this.currentFiltered().length} 座建筑`)
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .width('100%')
      }
      .width('100%')
      .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding, top: 14, bottom: 10 })

      Scroll() {
        Column({ space: 12 }) {
          FilterPanel({
            continents: this.vm.getContinents(),
            eras: this.vm.getEras(),
            styles: this.vm.getStyles(),
            selectedContinentId: this.currentContinentId(),
            selectedEraId: this.currentEraId(),
            selectedStyleId: this.currentStyleId(),
            onSelectContinent: (id: string): void => {
              this.vm.selectContinent(id)
              this.tick++
            },
            onSelectEra: (id: string): void => {
              this.vm.selectEra(id)
              this.tick++
            },
            onSelectStyle: (id: string): void => {
              this.vm.selectStyle(id)
              this.tick++
            },
            onReset: (): void => {
              this.vm.resetFilters()
              this.tick++
            }
          })

          if (this.currentFiltered().length === 0) {
            EmptyState({
              emoji: '🧭',
              title: '该条件下暂无建筑',
              hint: '换个大洲、时代或风格试试'
            })
          } else {
            ForEach(this.currentFiltered(), (item: ArchitectureDetail): void => {
              ArchitectureListItem({
                item,
                favorited: this.isFav(item.id),
                onOpen: (id: string): void => AppRouter.pushDetail(id),
                onToggleFavorite: (id: string): void => {
                  this.favRepo.toggle(id)
                  this.tick++
                }
              })
            }, (item: ArchitectureDetail): string => item.id)
          }
        }
        .width('100%')
        .padding({
          left: AppDims.pagePadding,
          right: AppDims.pagePadding,
          top: 4,
          bottom: 12 + AppDims.navSafeSpace
        })
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColor.bg)
    // 本页重新可见时重算列表与爱心状态 —— 覆盖「在详情页收藏后切回分类页」的场景
    .onVisibleAreaChange([0.0, 0.4], (isVisible: boolean): void => {
      if (isVisible) {
        this.tick++
      }
    })
  }
}
