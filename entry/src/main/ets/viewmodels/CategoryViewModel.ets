import { ArchitectureDetail, Continent, EraDef, StyleDef } from '../model/Architecture'
import { ArchitectureRepository } from '../repository/ArchitectureRepository'

@ObservedV2
export class CategoryViewModel {
  static readonly instance: CategoryViewModel = new CategoryViewModel()
  private repo: ArchitectureRepository = ArchitectureRepository.instance

  /** '' 表示「全部」 */
  @Trace selectedContinentId: string = ''
  @Trace selectedStyleId: string = ''
  @Trace selectedEraId: string = ''
  @Trace keyword: string = ''

  selectContinent(continentId: string): void {
    this.selectedContinentId = this.selectedContinentId === continentId ? '' : continentId
  }

  selectStyle(styleId: string): void {
    this.selectedStyleId = this.selectedStyleId === styleId ? '' : styleId
  }

  selectEra(eraId: string): void {
    this.selectedEraId = this.selectedEraId === eraId ? '' : eraId
  }

  resetFilters(): void {
    this.selectedContinentId = ''
    this.selectedStyleId = ''
    this.selectedEraId = ''
    this.keyword = ''
  }

  hasFilter(): boolean {
    return this.selectedContinentId.length > 0
      || this.selectedStyleId.length > 0
      || this.selectedEraId.length > 0
  }

  onKeywordChange(value: string): void {
    this.keyword = value
  }

  getFiltered(): ArchitectureDetail[] {
    return this.repo
      .filter(this.selectedContinentId, this.selectedStyleId, this.selectedEraId, this.keyword)
      .sort((a: ArchitectureDetail, b: ArchitectureDetail): number => b.popularity - a.popularity)
  }

  getContinents(): Continent[] {
    return this.repo.getContinents()
  }

  getStyles(): StyleDef[] {
    return this.repo.getStyles()
  }

  getEras(): EraDef[] {
    return this.repo.getEras()
  }
}
