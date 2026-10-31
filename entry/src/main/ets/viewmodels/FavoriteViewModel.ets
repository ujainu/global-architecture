import { ArchitectureDetail } from '../model/Architecture'
import { FavoriteRepository } from '../repository/FavoriteRepository'

export class FavoriteViewModel {
  static readonly instance: FavoriteViewModel = new FavoriteViewModel()
  private favRepo: FavoriteRepository = FavoriteRepository.instance

  getFavorites(): ArchitectureDetail[] {
    return this.favRepo.getFavorites()
  }

  count(): number {
    return this.favRepo.count()
  }

  remove(archId: string): void {
    if (this.favRepo.isFavorite(archId)) {
      this.favRepo.toggle(archId)
    }
  }
}
