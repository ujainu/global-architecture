/**
 * 分布式同步相关数据结构
 * 对接 distributedDataObject / 设备发现时复用这些类型
 */

/** 同步状态机 */
export enum SyncState {
  Idle = 0,
  Syncing = 1,
  Success = 2,
  Failed = 3
}

/** 可信组网中的对端设备 */
export interface DeviceInfo {
  id: string
  name: string
  emoji: string
  online: boolean
  lastSeenText: string
}

/** 同步操作流水 */
export interface SyncOpRecord {
  id: string
  typeText: string
  targetText: string
  timeText: string
}

/** 多端修改同一笔记产生的冲突 */
export interface ConflictItem {
  id: string
  archId: string
  noteTitle: string
  localContent: string
  remoteContent: string
  localTimeText: string
  remoteTimeText: string
  /** 是否已解决 */
  resolved: boolean
  /** 解决方式文案 */
  resolutionText: string
}
