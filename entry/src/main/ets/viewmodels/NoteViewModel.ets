import { Note } from '../model/Note'
import { ArchitectureRepository } from '../repository/ArchitectureRepository'
import { NoteRepository } from '../repository/NoteRepository'

export class NoteViewModel {
  static readonly instance: NoteViewModel = new NoteViewModel()
  private noteRepo: NoteRepository = NoteRepository.instance
  private archRepo: ArchitectureRepository = ArchitectureRepository.instance

  getAll(): Note[] {
    return this.noteRepo.getAll()
  }

  count(): number {
    return this.noteRepo.count()
  }

  remove(noteId: string): void {
    this.noteRepo.remove(noteId)
  }

  archNameOf(archId: string): string {
    if (archId.length === 0) {
      return '随手记'
    }
    const arch = this.archRepo.getById(archId)
    return arch ? arch.name : '关联建筑已移除'
  }
}
