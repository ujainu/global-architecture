import { RouteParam, RoutePath } from '../common/constants/RoutePath'
import { DetailPage } from '../pages/detail/DetailPage'
import { NoteListPage } from '../pages/note/NoteListPage'
import { NoteEditPage } from '../pages/note/NoteEditPage'
import { SyncPanelPage } from '../pages/profile/SyncPanelPage'

/**
 * Navigation 目的地注册表（路由契约的唯一事实来源）
 * 新增可路由页面时：
 * 1. RoutePath 增加路径常量
 * 2. 在此 if 链中注册对应页面组件
 */
@Builder
export function AppNavDestination(name: string, param?: object) {
  if (name === RoutePath.DETAIL) {
    DetailPage({
      archId: param ? (param as RouteParam).archId : ''
    })
  } else if (name === RoutePath.NOTE_LIST) {
    NoteListPage()
  } else if (name === RoutePath.NOTE_EDIT) {
    NoteEditPage({
      archId: param ? (param as RouteParam).archId : '',
      noteId: param ? (param as RouteParam).noteId : ''
    })
  } else if (name === RoutePath.SYNC_PANEL) {
    SyncPanelPage()
  }
}
