import { ArchitectureDetail, Continent, EraStat, StatItem } from '../model/Architecture'
import { ArchitectureRepository } from '../repository/ArchitectureRepository'
import { SearchService } from '../service/SearchService'
import { DateUtil } from '../common/utils/DateUtil'
import { AppState } from './AppState'
import { CategoryViewModel } from './CategoryViewModel'

@ObservedV2
export class HomeViewModel {
  static readonly instance: HomeViewModel = new HomeViewModel()
  private repo: ArchitectureRepository = ArchitectureRepository.instance

  @Trace keyword: string = ''
  @Trace searchResults: ArchitectureDetail[] = []

  getRecommends(): ArchitectureDetail[] {
    return this.repo.getRecommended()
  }

  getContinents(): Continent[] {
    return this.repo.getContinents()
  }

  /** 时代长河：各时代 + 建筑数量 */
  getEraStats(): EraStat[] {
    return this.repo.getEras().map((e): EraStat => {
      return { id: e.id, name: e.name, count: this.repo.countByEra(e.id) }
    })
  }

  /** 资料库概览数字，随预置数据规模自动更新 */
  getStats(): StatItem[] {
    return [
      { label: '座建筑', value: this.repo.getAll().length },
      { label: '大洲', value: this.repo.getContinents().length },
      { label: '种风格', value: this.repo.getStyles().length },
      { label: '位建筑师', value: this.repo.getArchitects().length }
    ]
  }

  /**
   * 每日建筑推荐：以「自纪元起的天序号」为索引，同一天内稳定不变，
   * offset 供「换一座」手动轮换使用。
   *
   * 注意：预置列表是按大洲分组的，若直接用「天序号 % 总数」顺序取，
   * 会连续二十多天都推荐同一大洲的建筑。因此用与总数互质的步长跳跃，
   * 既保证 n 天内不重复，又让相邻两天落在列表的不同区段。
   */
  getDailyPick(offset: number): ArchitectureDetail | null {
    const all: ArchitectureDetail[] = this.repo.getAll()
    const n: number = all.length
    if (n === 0) {
      return null
    }
    const step: number = HomeViewModel.coprimeStep(n)
    const day: number = DateUtil.dayIndex(Date.now())
    const idx: number = (((day * step + offset) % n) + n) % n
    return all[idx]
  }

  /** 取一个与 n 互质、接近黄金分割的步长 */
  private static coprimeStep(n: number): number {
    if (n <= 2) {
      return 1
    }
    let s: number = Math.floor(n * 0.618)
    if (s < 1) {
      s = 1
    }
    while (HomeViewModel.gcd(s, n) !== 1) {
      s++
      if (s >= n) {
        s = 1
      }
    }
    return s
  }

  private static gcd(a: number, b: number): number {
    let x: number = a
    let y: number = b
    while (y !== 0) {
      const t: number = y
      y = x % y
      x = t
    }
    return x
  }

  getDailyDateText(): string {
    return DateUtil.monthDayText(Date.now())
  }

  onKeywordChange(value: string): void {
    this.keyword = value
    this.searchResults = SearchService.search(value)
  }

  clearKeyword(): void {
    this.keyword = ''
    this.searchResults = []
  }

  /**
   * 快捷入口跳转到分类 Tab。
   * 先清空既有筛选再套用本次条件，避免与上一次残留的条件叠加出空结果。
   */
  openContinent(continentId: string): void {
    const cvm: CategoryViewModel = CategoryViewModel.instance
    cvm.resetFilters()
    cvm.selectContinent(continentId)
    AppState.instance.requestTab(1)
  }

  openEra(eraId: string): void {
    const cvm: CategoryViewModel = CategoryViewModel.instance
    cvm.resetFilters()
    cvm.selectEra(eraId)
    AppState.instance.requestTab(1)
  }

  openStyle(styleId: string): void {
    const cvm: CategoryViewModel = CategoryViewModel.instance
    cvm.resetFilters()
    cvm.selectStyle(styleId)
    AppState.instance.requestTab(1)
  }
}
