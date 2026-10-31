/**
 * 笔记冲突合并策略
 * 当前提供两种明确策略：保留本地 / 采用云端；
 * 后续可扩展按字段时间戳自动合并
 */
export class ConflictResolver {
  static pick(localContent: string, remoteContent: string, keepLocal: boolean): string {
    return keepLocal ? localContent : remoteContent
  }
}
