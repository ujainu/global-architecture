import { ArchitectureDetail } from '../model/Architecture'
import { Note } from '../model/Note'
import { ArchitectureRepository } from '../repository/ArchitectureRepository'
import { FavoriteRepository } from '../repository/FavoriteRepository'
import { NoteRepository } from '../repository/NoteRepository'

@ObservedV2
export class DetailViewModel {
  static readonly instance: DetailViewModel = new DetailViewModel()

  private archRepo: ArchitectureRepository = ArchitectureRepository.instance
  private favRepo: FavoriteRepository = FavoriteRepository.instance
  private noteRepo: NoteRepository = NoteRepository.instance

  @Trace archId: string = ''
  @Trace arch: ArchitectureDetail | undefined = undefined

  /** 页面 onReady 时按 ID 装载数据（通用复用页面的核心） */
  load(id: string): void {
    this.archId = id
    this.arch = this.archRepo.getById(id)
  }

  isFavorite(): boolean {
    return this.favRepo.isFavorite(this.archId)
  }

  toggleFavorite(): boolean {
    return this.favRepo.toggle(this.archId)
  }

  getNotes(): Note[] {
    return this.noteRepo.getByArch(this.archId)
  }

  noteCount(): number {
    return this.noteRepo.countByArch(this.archId)
  }

  getStyleNames(): string[] {
    if (!this.arch) {
      return []
    }
    return this.archRepo.getStyleNames(this.arch.styleIds)
  }

  getArchitectText(): string {
    if (!this.arch) {
      return ''
    }
    const names: string[] = this.archRepo.getArchitectNames(this.arch.architectIds)
    return names.length > 0 ? names.join('、') : '暂无考'
  }

  getLocationText(): string {
    if (!this.arch) {
      return ''
    }
    return `${this.arch.country} · ${this.arch.city}`
  }
}
