import { AppColor, AppDims, AppFont, AppRadius } from '../../common/theme/Theme'
import { AppRouter, appStack } from '../../common/router/AppRouter'
import { Note } from '../../model/Note'
import { ArchitectureDetail } from '../../model/Architecture'
import { NoteRepository } from '../../repository/NoteRepository'
import { ArchitectureRepository } from '../../repository/ArchitectureRepository'
import { ArchCover } from '../../views/common/ArchCover'
import { TextUtil } from '../../common/utils/TextUtil'

/** 二级页：新建 / 编辑笔记 */
@ComponentV2
export struct NoteEditPage {
  /** 新建笔记时由详情页传入；编辑笔记时可能为空，以笔记内的 archId 为准 */
  @Param archId: string = ''
  @Param noteId: string = ''

  @Local targetArchId: string = this.archId
  @Local title: string = ''
  @Local content: string = ''
  @Local arch: ArchitectureDetail | undefined = undefined
  @Local pageTitle: string = '写笔记'

  private noteRepo: NoteRepository = NoteRepository.instance
  private archRepo: ArchitectureRepository = ArchitectureRepository.instance

  aboutToAppear(): void {
    if (this.noteId.length > 0) {
      const note: Note | undefined = this.noteRepo.getById(this.noteId)
      if (note) {
        this.title = note.title
        this.content = note.content
        this.targetArchId = note.archId
        this.pageTitle = '编辑笔记'
      }
    }
    if (this.targetArchId.length > 0) {
      this.arch = this.archRepo.getById(this.targetArchId)
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 自定义标题栏
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

          Text(this.pageTitle)
            .fontSize(AppFont.subtitle)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColor.textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('保存')
            .fontSize(AppFont.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor(AppColor.primary)
            .borderRadius(AppRadius.pill)
            .padding({ left: 16, right: 16, top: 7, bottom: 7 })
            .onClick((): void => this.save())
        }
        .width('100%')
        .height(52)
        .padding({ left: 10, right: 16 })
        .backgroundColor(AppColor.card)
        .border({ width: { bottom: 1 }, color: AppColor.divider })

        Scroll() {
          Column({ space: 14 }) {
            // 关联建筑
            if (this.arch) {
              Row({ space: 12 }) {
                Stack() {
                  ArchCover({
                    title: this.arch.name,
                    fromColor: this.arch.coverFrom,
                    toColor: this.arch.coverTo,
                    radius: AppRadius.md
                  })
                }
                .width(64)
                .height(52)
                Column({ space: 4 }) {
                  Text('关联建筑')
                    .fontSize(AppFont.mini)
                    .fontColor(AppColor.textHint)
                  Text(this.arch.name)
                    .fontSize(AppFont.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(AppColor.textPrimary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Image($r('app.media.ic_chevron_right'))
                  .width(18)
                  .height(18)
                  .fillColor(AppColor.textHint)
              }
              .width('100%')
              .padding(10)
              .backgroundColor(AppColor.card)
              .borderRadius(AppRadius.lg)
              .onClick((): void => AppRouter.pushDetail(this.targetArchId))
            }

            // 标题
            TextInput({ text: this.title, placeholder: '给笔记起个标题' })
              .width('100%')
              .height(50)
              .fontSize(AppFont.subtitle)
              .fontColor(AppColor.textPrimary)
              .backgroundColor(AppColor.card)
              .borderRadius(AppRadius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string): void => {
                this.title = v
              })

            // 正文
            TextArea({ text: this.content, placeholder: '记录结构细节、参观感受、历史八卦……' })
              .width('100%')
              .height(340)
              .fontSize(AppFont.body)
              .fontColor(AppColor.textPrimary)
              .backgroundColor(AppColor.card)
              .borderRadius(AppRadius.lg)
              .padding(14)
              .onChange((v: string): void => {
                this.content = v
              })
          }
          .width('100%')
          .padding(AppDims.pagePadding)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColor.bg)
    }
    .hideTitleBar(true)
  }

  private save(): void {
    if (TextUtil.isEmpty(this.title) && TextUtil.isEmpty(this.content)) {
      return
    }
    const finalTitle: string = TextUtil.isEmpty(this.title) ? '未命名笔记' : this.title.trim()
    this.noteRepo.save(this.targetArchId, finalTitle, this.content.trim(), this.noteId)
    appStack.pop()
  }
}
