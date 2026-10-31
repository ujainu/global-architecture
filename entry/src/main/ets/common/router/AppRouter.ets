import { RouteParam, RoutePath } from '../constants/RoutePath'

/**
 * 全局路由栈：所有页面共用，Tab 页通过它 push 二级页面
 */
export const appStack: NavPathStack = new NavPathStack()

export class AppRouter {
  static pushDetail(archId: string): void {
    const p: RouteParam = new RouteParam()
    p.archId = archId
    appStack.pushPath({ name: RoutePath.DETAIL, param: p })
  }

  static pushNoteEdit(archId: string, noteId: string): void {
    const p: RouteParam = new RouteParam()
    p.archId = archId
    p.noteId = noteId
    appStack.pushPath({ name: RoutePath.NOTE_EDIT, param: p })
  }

  static pushNoteList(): void {
    appStack.pushPath({ name: RoutePath.NOTE_LIST })
  }

  static pushSyncPanel(): void {
    appStack.pushPath({ name: RoutePath.SYNC_PANEL })
  }

  static back(): void {
    appStack.pop()
  }
}
