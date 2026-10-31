import { Architecture, ArchitectureDetail, Architect, Continent, EraDef, StyleDef } from '../model/Architecture'
import { PresetReader } from '../datasource/local/PresetReader'

/**
 * 建筑内容只读仓库（预置内容）
 * 列表、搜索、详情、筛选都从这里取数
 */
export class ArchitectureRepository {
  static readonly instance: ArchitectureRepository = new ArchitectureRepository()
  private reader: PresetReader = new PresetReader()

  private architectures: ArchitectureDetail[] = this.reader.getArchitectures()
  private continents: Continent[] = this.reader.getContinents()
  private eras: EraDef[] = this.reader.getEras()
  private styles: StyleDef[] = this.reader.getStyles()
  private architects: Architect[] = this.reader.getArchitects()

  getAll(): ArchitectureDetail[] {
    return this.architectures
  }

  getById(id: string): ArchitectureDetail | undefined {
    return this.architectures.find((item: ArchitectureDetail): boolean => item.id === id)
  }

  getRecommended(): ArchitectureDetail[] {
    return this.architectures
      .filter((item: ArchitectureDetail): boolean => item.recommended)
      .sort((a: ArchitectureDetail, b: ArchitectureDetail): number => b.popularity - a.popularity)
  }

  /**
   * 三维度筛选：大洲 + 风格 + 时代；关键字匹配名称/国家/城市
   * 任一维度传 '' 表示该维度不限制
   */
  filter(continentId: string, styleId: string, eraId: string, keyword: string): ArchitectureDetail[] {
    const kw: string = keyword.trim().toLowerCase()
    return this.architectures.filter((item: ArchitectureDetail): boolean => {
      const matchContinent: boolean = continentId.length === 0 || item.continentId === continentId
      const matchStyle: boolean = styleId.length === 0 || item.styleIds.indexOf(styleId) >= 0
      const matchEra: boolean = eraId.length === 0 || item.eraId === eraId
      let matchKeyword: boolean = true
      if (kw.length > 0) {
        const haystack: string = `${item.name} ${item.nameEn} ${item.country} ${item.city}`.toLowerCase()
        matchKeyword = haystack.indexOf(kw) >= 0
      }
      return matchContinent && matchStyle && matchEra && matchKeyword
    })
  }

  /** 某时代下的建筑数量（首页时代长河用） */
  countByEra(eraId: string): number {
    return this.architectures.filter((item: ArchitectureDetail): boolean => item.eraId === eraId).length
  }

  getContinents(): Continent[] {
    return this.continents
  }

  getContinentName(id: string): string {
    const item: Continent | undefined = this.continents.find((c: Continent): boolean => c.id === id)
    return item ? item.name : ''
  }

  getContinentEmoji(id: string): string {
    const item: Continent | undefined = this.continents.find((c: Continent): boolean => c.id === id)
    return item ? item.emoji : '🏛️'
  }

  getEras(): EraDef[] {
    return this.eras
  }

  getEraName(id: string): string {
    const item: EraDef | undefined = this.eras.find((e: EraDef): boolean => e.id === id)
    return item ? item.name : ''
  }

  getStyles(): StyleDef[] {
    return this.styles
  }

  getStyleName(id: string): string {
    const item: StyleDef | undefined = this.styles.find((s: StyleDef): boolean => s.id === id)
    return item ? item.name : ''
  }

  getStyleNames(ids: string[]): string[] {
    return ids.map((id: string): string => this.getStyleName(id)).filter((n: string): boolean => n.length > 0)
  }

  getArchitects(): Architect[] {
    return this.architects
  }

  getArchitectName(id: string): string {
    const item: Architect | undefined = this.architects.find((a: Architect): boolean => a.id === id)
    return item ? item.name : ''
  }

  getArchitectNames(ids: string[]): string[] {
    return ids.map((id: string): string => this.getArchitectName(id)).filter((n: string): boolean => n.length > 0)
  }

  /** 轻量列表类型转换（需要时使用） */
  toListItem(detail: ArchitectureDetail): Architecture {
    return detail
  }
}
