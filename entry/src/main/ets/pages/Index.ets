import { AppColor } from '../common/theme/Theme'
import { appStack } from '../common/router/AppRouter'
import { AppNavDestination } from '../views/AppNavDestination'
import { MainPage } from './MainPage'

/**
 * 应用入口：Navigation 容器
 * MainPage 作为根内容承载底部 5 个 Tab；
 * 详情 / 笔记 / 同步面板等二级页通过 appStack 压栈。
 */
@Entry
@ComponentV2
struct Index {
  build() {
    Navigation(appStack) {
      MainPage()
    }
    .navDestination(AppNavDestination)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .backgroundColor(AppColor.bg)
  }
}
