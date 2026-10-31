import { ConflictItem, DeviceInfo, SyncOpRecord, SyncState } from '../model/SyncTypes'
import { ConflictResolver } from './ConflictResolver'
import { DateUtil } from '../common/utils/DateUtil'

/**
 * 分布式同步编排服务（当前为本地模拟实现）
 *
 * 真实接入点（后续在 datasource/remote 中实现，本类接口保持不变）：
 * 1. distributedDataObject 创建跨设备数据对象，同步收藏/笔记
 * 2. deviceManager 发现可信组网设备
 * 3. 同步进度、冲突通过 @Trace 状态广播给 UI
 */
@ObservedV2
export class SyncService {
  static readonly instance: SyncService = new SyncService()

  @Trace state: SyncState = SyncState.Idle
  /** 0 - 100 */
  @Trace progress: number = 0
  @Trace lastSyncText: string = '尚未同步'
  @Trace devices: DeviceInfo[] = [
    { id: 'local_phone', name: '本机（Phone）', emoji: '📱', online: true, lastSeenText: '使用中' },
    { id: 'mate_pad', name: 'MatePad Pro', emoji: '📲', online: true, lastSeenText: '2 分钟前在线' },
    { id: 'mate_book', name: 'MateBook X Pro', emoji: '💻', online: false, lastSeenText: '昨天 21:08' }
  ]
  @Trace conflicts: ConflictItem[] = [
    {
      id: 'conflict_1',
      archId: 'sagrada_familia',
      noteTitle: '高迪的自然主义',
      localContent: '立柱像森林一样分叉，重点：双曲面几何 + 光影设计。（手机端修改）',
      remoteContent: '立柱像森林一样分叉，彩色玻璃的光影是重点。（平板端修改）',
      localTimeText: '今天 09:24',
      remoteTimeText: '今天 08:51',
      resolved: false,
      resolutionText: ''
    }
  ]
  @Trace ops: SyncOpRecord[] = []

  private timerId: number = -1

  isSyncing(): boolean {
    return this.state === SyncState.Syncing
  }

  unresolvedCount(): number {
    return this.conflicts.filter((c: ConflictItem): boolean => !c.resolved).length
  }

  startSync(): void {
    if (this.state === SyncState.Syncing) {
      return
    }
    this.state = SyncState.Syncing
    this.progress = 0
    this.pushOp('开始同步', '向在线设备推送收藏与笔记')

    this.timerId = setInterval((): void => {
      const step: number = 6 + Math.floor(Math.random() * 12)
      const next: number = Math.min(100, this.progress + step)
      this.progress = next
      if (next >= 35 && next - step < 35) {
        this.pushOp('同步收藏', '已与 MatePad Pro 对齐 14 条收藏')
      }
      if (next >= 70 && next - step < 70) {
        this.pushOp('同步笔记', '检测到 1 处多端修改冲突')
      }
      if (next >= 100) {
        this.finishSync()
      }
    }, 260)
  }

  private finishSync(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    this.state = this.unresolvedCount() > 0 ? SyncState.Failed : SyncState.Success
    this.lastSyncText = DateUtil.nowText()
    this.pushOp('同步结束', this.state === SyncState.Success ? '所有数据已同步' : '存在待处理冲突')
  }

  resolveConflict(conflictId: string, keepLocal: boolean): void {
    this.conflicts = this.conflicts.map((c: ConflictItem): ConflictItem => {
      if (c.id !== conflictId || c.resolved) {
        return c
      }
      const finalContent: string = ConflictResolver.pick(c.localContent, c.remoteContent, keepLocal)
      const copy: ConflictItem = {
        id: c.id,
        archId: c.archId,
        noteTitle: c.noteTitle,
        localContent: c.localContent,
        remoteContent: c.remoteContent,
        localTimeText: c.localTimeText,
        remoteTimeText: c.remoteTimeText,
        resolved: true,
        resolutionText: `${keepLocal ? '已保留本机版本' : '已采用云端版本'}：${finalContent}`
      }
      return copy
    })
    if (this.state === SyncState.Failed && this.unresolvedCount() === 0) {
      this.state = SyncState.Success
    }
  }

  private pushOp(typeText: string, targetText: string): void {
    const record: SyncOpRecord = {
      id: `op_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
      typeText,
      targetText,
      timeText: DateUtil.nowText()
    }
    this.ops = [record].concat(this.ops).slice(0, 20)
  }
}
