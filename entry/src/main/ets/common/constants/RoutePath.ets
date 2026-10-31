/**
 * 路由路径常量（Navigation 事实来源）
 * 任何 pushPath 的目标都必须在 AppNavDestination 中注册
 */
export class RoutePath {
  static readonly DETAIL: string = 'DetailPage'
  static readonly NOTE_LIST: string = 'NoteListPage'
  static readonly NOTE_EDIT: string = 'NoteEditPage'
  static readonly SYNC_PANEL: string = 'SyncPanelPage'
}

/** 路由参数统一载体 */
export class RouteParam {
  archId: string = ''
  noteId: string = ''
}
