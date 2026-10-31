import { AppColor, AppDims } from '../common/theme/Theme'
import { AppState } from '../viewmodels/AppState'
import { HomePage } from './home/HomePage'
import { CategoryPage } from './category/CategoryPage'
import { GraphPage } from './graph/GraphPage'
import { FavoritePage } from './favorite/FavoritePage'
import { ProfilePage } from './profile/ProfilePage'

/** 一级导航条目 */
interface NavItem {
  title: string
  icon: Resource
}

/**
 * 应用壳：底部 5 个一级导航（鸿蒙光感悬浮导航栏）
 * 首页 ｜ 分类 ｜ 图谱 ｜ 收藏 ｜ 我的
 *
 * 实现要点：
 * - Tabs 只负责承载页面并保留各 Tab 的页面状态，barHeight 置 0 隐藏内置页签栏；
 *   导航栏本体由 Stack 叠在内容之上，因此是「真悬浮」而非贴着底边的普通页签栏。
 * - 光感玻璃由四层叠出来：
 *     ① 材质  backgroundBlurStyle 系统厚材质 + 跟随背景平均色（材质随内容变化）
 *     ② 受光面 自上而下的白色高光渐变，顶部更亮、底部渐隐，模拟光从上方来
 *     ③ 高光边 1px 亮边勾出玻璃厚度
 *     ④ 光晕   选中胶囊半透明（不遮住玻璃）并向外溢出鎏金柔光，像有光源从内部透出
 * - 选中项用「半透明亮胶囊 + 鎏金柔光」表达，切换带 220ms 缓动。
 * - Tabs 不设底部留白，内容可一直滚到屏幕底边、从悬浮栏下方穿过，
 *   毛玻璃才有内容可模糊；各页面在自身滚动内容末尾补 AppDims.navSafeSpace，
 *   保证最后一条内容能滚出悬浮栏而不被永久遮住。
 *
 * 选中态用组件本地 @Local currentIndex 驱动；
 * 「页面内代码请求切换 Tab」（如首页大洲入口）走 AppState.requestTab 的监听回调，
 * 由 MainPage 注册后直接驱动 tabsController.changeIndex，onChange 再把结果同步回两处状态。
 */
@ComponentV2
export struct MainPage {
  @Local currentIndex: number = 0
  @Local app: AppState = AppState.instance
  private tabsController: TabsController = new TabsController()
  private navItems: NavItem[] = [
    { title: '首页', icon: $r('app.media.ic_home') },
    { title: '分类', icon: $r('app.media.ic_category') },
    { title: '图谱', icon: $r('app.media.ic_graph') },
    { title: '收藏', icon: $r('app.media.ic_heart_fill') },
    { title: '我的', icon: $r('app.media.ic_user') }
  ]
  private tabRequestListener: (index: number) => void = (index: number): void => {
    this.currentIndex = index
    this.tabsController.changeIndex(index)
  }

  aboutToAppear(): void {
    this.app.addTabListener(this.tabRequestListener)
  }

  aboutToDisappear(): void {
    this.app.removeTabListener(this.tabRequestListener)
  }

  private switchTo(index: number): void {
    this.currentIndex = index
    this.app.mainTab = index
    this.tabsController.changeIndex(index)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          HomePage()
        }

        TabContent() {
          CategoryPage()
        }

        TabContent() {
          GraphPage()
        }

        TabContent() {
          FavoritePage()
        }

        TabContent() {
          ProfilePage()
        }
      }
      .barHeight(0)
      .scrollable(false)
      .animationDuration(220)
      .width('100%')
      .height('100%')
      .onChange((index: number): void => {
        this.currentIndex = index
        this.app.mainTab = index
      })

      this.FloatingNavBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColor.bg)
  }

  /** 选中项用主色、未选中用次级文字色（比 textHint 对比度更高，玻璃上更易读） */
  private itemColor(index: number): string {
    return this.currentIndex === index ? AppColor.primary : AppColor.textSecondary
  }

  /**
   * 鸿蒙光感悬浮导航栏 —— 参考 iOS 控制中心那种「通透玻璃」
   *
   * 关键约束（踩过的坑，改这块务必守住）：
   *   背景只能有一处。任何 width/height('100%') 的背景铺层都绝对不能用：
   *   Stack 的高度是内容撑开的，'100%' 会去参照外层全屏 Stack，
   *   于是玻璃层被拉成一整屏，把整个 App 都盖住（只剩状态栏露在外面）。
   *   所以这里只有最外层 Stack 设一次 backgroundEffect，
   *   受光效果用「1px 顶部高光条」这种有确定高度的元素来表达。
   *
   * 通透感来自模糊 + 高饱和，而不是靠白色蒙版：
   *   iOS 控制中心几乎没有白色底色，靠的是大半径模糊把身后内容糊开、
   *   再抬高饱和度让透出来的颜色更"活"。白色蒙版一重就变成奶白塑料，不像玻璃。
   */
  @Builder
  FloatingNavBar() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        // 导航内容：决定整条栏的高度（唯一有确定尺寸的子元素）
        Row() {
          ForEach(this.navItems, (item: NavItem, index: number): void => {
            Column({ space: 3 }) {
              Image(item.icon)
                .width(22)
                .height(22)
                .fillColor(this.itemColor(index))
                .animation({ duration: 220, curve: Curve.EaseOut })
              Text(item.title)
                .fontSize(10.5)
                .fontColor(this.itemColor(index))
                .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
                .animation({ duration: 220, curve: Curve.EaseOut })
            }
            .layoutWeight(1)
            .height(AppDims.navItemHeight)
            .justifyContent(FlexAlign.Center)
            .borderRadius(21)
            // 选中胶囊用半透明白，而不是不透明色块 —— 否则会把底下的玻璃糊死
            .backgroundColor(this.currentIndex === index ? 'rgba(255,255,255,0.62)' : Color.Transparent)
            // 光感核心：选中项向外溢出鎏金柔光，像有光源从胶囊里透出来
            .shadow(this.currentIndex === index
              ? { radius: 18, color: 'rgba(200,163,92,0.55)', offsetX: 0, offsetY: 0 }
              : { radius: 0, color: Color.Transparent, offsetX: 0, offsetY: 0 })
            .animation({ duration: 220, curve: Curve.EaseOut })
            .onClick((): void => this.switchTo(index))
          }, (item: NavItem): string => item.title)
        }
        .width('100%')
        .padding(AppDims.navPadding)

        // 顶部受光条：光从上方来，中间最亮、两端渐隐。高度只有 1vp，
        // 不会影响布局，也不会盖住任何东西
        Row()
          .width('100%')
          .height(1)
          .linearGradient({
            angle: 90,
            colors: [
              ['rgba(255,255,255,0)', 0],
              ['rgba(255,255,255,0.95)', 0.5],
              ['rgba(255,255,255,0)', 1]
            ]
          })
          .hitTestBehavior(HitTestMode.None)
      }
      .width('100%')
      .borderRadius(AppDims.navRadius)
      .clip(true)
      // 玻璃本体：唯一的一处背景。
      // 关键点：底色不能用纯白 —— 页面底色是米白 #F6F4EF，米白加白还是米白，
      // 栏体就会和页面糊成一片（实测截图里两者亮度完全相同，边界完全看不出）。
      // 这里用偏冷的淡蓝白，让材质与米白页面拉开色差，才读得出"这是一块玻璃"。
      .backgroundEffect({
        radius: 34,
        saturation: 1.9,
        brightness: 1.04,
        color: 'rgba(232,240,250,0.62)'
      })
      // 1px 高光边勾出玻璃上沿
      .border({ width: 1, color: 'rgba(255,255,255,0.92)' })
      // 落地投影：玻璃要有厚度就得压出边界，浅色页面上尤其需要
      .shadow({ radius: 26, color: 'rgba(23,62,107,0.28)', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .padding({
      left: AppDims.navMargin,
      right: AppDims.navMargin,
      bottom: AppDims.navMargin
    })
  }
}
