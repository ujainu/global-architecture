import { FavoriteRepository } from '../repository/FavoriteRepository'
import { NoteRepository } from '../repository/NoteRepository'
import { SyncService } from '../service/SyncService'

@ObservedV2
export class ProfileViewModel {
  static readonly instance: ProfileViewModel = new ProfileViewModel()
  private favRepo: FavoriteRepository = FavoriteRepository.instance
  private noteRepo: NoteRepository = NoteRepository.instance
  private syncService: SyncService = SyncService.instance

  @Trace autoSync: boolean = true
  @Trace wifiOnly: boolean = false
  @Trace darkMode: boolean = false

  favoriteCount(): number {
    return this.favRepo.count()
  }

  noteCount(): number {
    return this.noteRepo.count()
  }

  onAutoSyncChange(value: boolean): void {
    this.autoSync = value
    if (value) {
      this.syncService.startSync()
    }
  }

  onWifiOnlyChange(value: boolean): void {
    this.wifiOnly = value
  }

  onDarkModeChange(value: boolean): void {
    this.darkMode = value
  }
}
