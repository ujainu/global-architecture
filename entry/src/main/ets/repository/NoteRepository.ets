import { Note } from '../model/Note'
/** 笔记仓库（当前内存实现，含一条示例笔记）
 * 后续替换为 RDB（NoteDao）后对外接口保持不变
 */
@ObservedV2
export class NoteRepository {
  static readonly instance: NoteRepository = new NoteRepository()
  @Trace notes: Note[] = [
    {
      id: 'note_sample_1',
      archId: 'sagrada_familia',
      title: '高迪的自然主义',
      content: '立柱像森林一样分叉，光线从彩色玻璃洒进来时真的像置身海底。重點整理：双曲面几何 + 光影设计。',
      updatedAt: Date.now() - 1000 * 60 * 60 * 26
    }
  ]

  getAll(): Note[] {
    return this.notes.slice().sort((a: Note, b: Note): number => b.updatedAt - a.updatedAt)
  }

  getById(id: string): Note | undefined {
    return this.notes.find((n: Note): boolean => n.id === id)
  }

  getByArch(archId: string): Note[] {
    return this.notes
      .filter((n: Note): boolean => n.archId === archId)
      .sort((a: Note, b: Note): number => b.updatedAt - a.updatedAt)
  }

  countByArch(archId: string): number {
    return this.notes.filter((n: Note): boolean => n.archId === archId).length
  }

  count(): number {
    return this.notes.length
  }

  /** 新建或更新；返回保存后的笔记 */
  save(archId: string, title: string, content: string, noteId: string): Note {
    const now: number = Date.now()
    if (noteId.length > 0) {
      const target: Note | undefined = this.notes.find((n: Note): boolean => n.id === noteId)
      if (target) {
        const updated: Note = {
          id: target.id,
          archId: archId.length > 0 ? archId : target.archId,
          title,
          content,
          updatedAt: now
        }
        this.notes = this.notes.map((n: Note): Note => n.id === noteId ? updated : n)
        return updated
      }
    }
    const created: Note = {
      id: `note_${now}_${Math.floor(Math.random() * 10000)}`,
      archId,
      title,
      content,
      updatedAt: now
    }
    this.notes = this.notes.concat([created])
    return created
  }

  remove(id: string): void {
    this.notes = this.notes.filter((n: Note): boolean => n.id !== id)
  }
}
