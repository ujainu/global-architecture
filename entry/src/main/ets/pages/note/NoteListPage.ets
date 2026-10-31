import { promptAction } from '@kit.ArkUI'
import { AppColor, AppDims, AppFont, AppRadius } from '../../common/theme/Theme'
import { AppRouter, appStack } from '../../common/router/AppRouter'
import { Note } from '../../model/Note'
import { NoteViewModel } from '../../viewmodels/NoteViewModel'
import { NoteRepository } from '../../repository/NoteRepository'
import { NoteCard } from '../../views/note/NoteCard'
import { EmptyState } from '../../views/common/EmptyState'

/** ⑤ 我的笔记列表（可由个人中心进入） */
@ComponentV2
export struct NoteListPage {
  // 直接持有 @ObservedV2 仓库：笔记增删后 @Trace notes 变化才能驱动本页 ForEach 刷新
  // （经普通 class 的 NoteViewModel 间接读取不会建立响应式依赖）
  @Local noteRepo: NoteRepository = NoteRepository.instance
  @Local vm: NoteViewModel = NoteViewModel.instance
  // 外部单例 @Trace 变化在当前运行时不稳定驱动前台页面重绘，
  // 用本地 tick 强制重算：删除后自增；从编辑页返回时由 onShown 自增
  @Local tick: number = 0

  build() {
    NavDestination() {
      Column() {
        // 标题栏：返回 + 标题 + 新建
        Row() {
          Row() {
            Image($r('app.media.ic_back'))
              .width(20)
              .height(20)
              .fillColor(AppColor.textPrimary)
          }
          .width(38)
          .height(38)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => {
            appStack.pop()
          })

          Column({ space: 2 }) {
            Text('我的笔记')
              .fontSize(AppFont.subtitle)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColor.textPrimary)
            Text(`共 ${this.currentNotes().length} 篇`)
              .fontSize(AppFont.mini)
              .fontColor(AppColor.textHint)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row({ space: 4 }) {
            Image($r('app.media.ic_plus'))
              .width(16)
              .height(16)
              .fillColor(Color.White)
            Text('记一笔')
              .fontSize(AppFont.mini)
              .fontColor(Color.White)
          }
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .backgroundColor(AppColor.primary)
          .borderRadius(AppRadius.pill)
          .onClick((): void => AppRouter.pushNoteEdit('', ''))
        }
        .width('100%')
        .height(52)
        .padding({ left: 10, right: 16 })
        .backgroundColor(AppColor.card)
        .border({ width: { bottom: 1 }, color: AppColor.divider })

        if (this.currentNotes().length === 0) {
          Column() {
            EmptyState({
              emoji: '📝',
              title: '还没有笔记',
              hint: '在建筑详情页点击「新建笔记」，记录你的观建筑心得'
            })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.currentNotes(), (note: Note): void => {
                NoteCard({
                  note,
                  archName: this.vm.archNameOf(note.archId),
                  onEdit: (): void => AppRouter.pushNoteEdit('', note.id),
                  onRemove: (): void => this.confirmDelete(note.id)
                })
              }, (note: Note): string => note.id)
            }
            .width('100%')
            .padding(AppDims.pagePadding)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColor.bg)
    }
    .hideTitleBar(true)
    .onShown((): void => {
      this.tick++
    })
  }

  /** 取最新笔记列表；方法内读取本地 tick，使所有调用处在 tick 变化时重新求值 */
  private currentNotes(): Note[] {
    if (this.tick < 0) {
      return []
    }
    return this.noteRepo.getAll()
  }

  private confirmDelete(noteId: string): void {
    promptAction.showDialog({
      title: '删除笔记',
      message: '确定要删除这篇笔记吗？删除后不可恢复。',
      buttons: [
        { text: '取消', color: AppColor.textSecondary },
        { text: '删除', color: AppColor.danger }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse): void => {
      if (result.index === 1) {
        this.noteRepo.remove(noteId)
        this.tick++
      }
    })
  }
}
