/**
 * 应用级共享状态：底部 Tab 当前选中项
 * 首页快捷筛选需要跨页面切换到「分类」Tab 时使用
 *
 * 说明：当前运行环境中 @Monitor 对「@Local 持有的外部单例深层属性」变化不稳定触发，
 * 因此跨页切换另外提供 requestTab + 监听器回调，MainPage 注册后直接驱动 TabsController。
 */
@ObservedV2
export class AppState {
  static readonly instance: AppState = new AppState()
  @Trace mainTab: number = 0

  private tabListeners: ((index: number) => void)[] = []

  /** 页面内代码请求切换底部 Tab（如首页大洲/风格入口） */
  requestTab(index: number): void {
    this.mainTab = index
    this.tabListeners.forEach((listener: (index: number) => void): void => {
      listener(index)
    })
  }

  addTabListener(listener: (index: number) => void): void {
    this.tabListeners.push(listener)
  }

  removeTabListener(listener: (index: number) => void): void {
    const idx: number = this.tabListeners.indexOf(listener)
    if (idx >= 0) {
      this.tabListeners.splice(idx, 1)
    }
  }
}
