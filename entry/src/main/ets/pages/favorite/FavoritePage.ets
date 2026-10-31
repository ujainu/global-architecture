import { AppColor, AppDims, AppFont } from '../../common/theme/Theme'
import { AppRouter } from '../../common/router/AppRouter'
import { ArchitectureDetail } from '../../model/Architecture'
import { FavoriteRepository } from '../../repository/FavoriteRepository'
import { ArchitectureListItem } from '../../views/category/ArchitectureListItem'
import { EmptyState } from '../../views/common/EmptyState'

/** ④ 收藏页 */
@ComponentV2
export struct FavoritePage {
  // 直接持有 @ObservedV2 仓库，取消收藏后 @Trace ids 变化实时驱动列表刷新
  @Local favRepo: FavoriteRepository = FavoriteRepository.instance
  // 本地 tick：用于强制重算列表。两种情况下自增：
  //   1) 在本页取消收藏
  //   2) 本页重新变为可见（从详情页收藏后切回收藏 Tab）
  // 第 2 点是必需的：Tabs 的各页是常驻的，切 Tab 不会重新执行 build()，
  // 只在详情页 toggle 不会让本页重算，列表就会一直是旧的。
  @Local tick: number = 0

  build() {
    Column() {
      Column({ space: 4 }) {
        Text('我的收藏')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColor.primary)
          .width('100%')
        Text(`已收藏 ${this.currentFavorites().length} 座建筑`)
          .fontSize(AppFont.caption)
          .fontColor(AppColor.textHint)
          .width('100%')
      }
      .width('100%')
      .padding({ left: AppDims.pagePadding, right: AppDims.pagePadding, top: 14, bottom: 10 })

      if (this.currentFavorites().length === 0) {
        Column() {
          EmptyState({
            emoji: '💛',
            title: '还没有收藏任何建筑',
            hint: '在建筑详情页点亮爱心，即可在此快速访问'
          })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.currentFavorites(), (item: ArchitectureDetail): void => {
              ArchitectureListItem({
                item,
                favorited: true,
                onOpen: (id: string): void => AppRouter.pushDetail(id),
                onToggleFavorite: (id: string): void => {
                  this.favRepo.toggle(id)
                  this.tick++
                }
              })
            }, (item: ArchitectureDetail): string => item.id)
          }
          .width('100%')
          .padding({
            left: AppDims.pagePadding,
            right: AppDims.pagePadding,
            top: 4,
            bottom: 12 + AppDims.navSafeSpace
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColor.bg)
    // 本页从隐藏变为可见时重算列表 —— 覆盖「在详情页收藏后切回来」的场景
    .onVisibleAreaChange([0.0, 0.4], (isVisible: boolean): void => {
      if (isVisible) {
        this.tick++
      }
    })
  }

  /** 取最新收藏列表；方法内读取本地 tick，使所有调用处在 tick 变化时重新求值 */
  private currentFavorites(): ArchitectureDetail[] {
    if (this.tick < 0) {
      return []
    }
    return this.favRepo.getFavorites()
  }
}
