import { ArchitectureDetail } from '../model/Architecture'
import { ArchitectureRepository } from './ArchitectureRepository'

/**
 * 收藏仓库（当前内存实现）
 * 后续可替换为 RDB / preferences 持久化，对外接口保持不变
 */
@ObservedV2
export class FavoriteRepository {
  static readonly instance: FavoriteRepository = new FavoriteRepository()
  @Trace ids: string[] = []

  isFavorite(archId: string): boolean {
    return this.ids.indexOf(archId) >= 0
  }

  toggle(archId: string): boolean {
    if (this.isFavorite(archId)) {
      this.ids = this.ids.filter((id: string): boolean => id !== archId)
      return false
    }
    this.ids = this.ids.concat([archId])
    return true
  }

  count(): number {
    return this.ids.length
  }

  /** 按收藏顺序返回建筑详情 */
  getFavorites(): ArchitectureDetail[] {
    const repo: ArchitectureRepository = ArchitectureRepository.instance
    const result: ArchitectureDetail[] = []
    this.ids.forEach((id: string): void => {
      const item: ArchitectureDetail | undefined = repo.getById(id)
      if (item) {
        result.push(item)
      }
    })
    return result
  }
}
