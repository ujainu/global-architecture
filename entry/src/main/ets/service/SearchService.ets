import { ArchitectureDetail } from '../model/Architecture'
import { ArchitectureRepository } from '../repository/ArchitectureRepository'

/**
 * 本地检索服务：名称 / 英文名 / 国家 / 城市 / 建筑师联想
 */
export class SearchService {
  static search(keyword: string): ArchitectureDetail[] {
    const kw: string = keyword.trim().toLowerCase()
    if (kw.length === 0) {
      return []
    }
    const repo: ArchitectureRepository = ArchitectureRepository.instance
    return repo.getAll().filter((item: ArchitectureDetail): boolean => {
      const architectNames: string = repo.getArchitectNames(item.architectIds).join(' ')
      const haystack: string =
        `${item.name} ${item.nameEn} ${item.country} ${item.city} ${architectNames} ${item.summary}`.toLowerCase()
      return haystack.indexOf(kw) >= 0
    })
  }
}
