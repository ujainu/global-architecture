/** 个人笔记 */
export interface Note {
  id: string
  /** 关联建筑 ID，可为空（随手记） */
  archId: string
  title: string
  content: string
  /** 更新时间戳（毫秒） */
  updatedAt: number
}
