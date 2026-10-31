import { promptAction } from '@kit.ArkUI'
import { ArchitectureDetail, ArchitectureImage } from '../../model/Architecture'
import { AppFont } from '../../common/theme/Theme'
import { ArchCover } from '../common/ArchCover'

/**
 * 详情页图片轮播
 * images 非空时渲染 Image($rawfile(path))，并在底部叠加图注；
 * images 为空时回退为三张渐变占位页。
 * 点击右下角 ⓘ 可查看该图出处与许可，便于核查替换。
 */
@ComponentV2
export struct ImageSwiper {
  @Param arch: ArchitectureDetail | null = null
  @Local currentIndex: number = 0

  private images(): ArchitectureImage[] {
    if (!this.arch) {
      return []
    }
    return this.arch.images
  }

  private panelCount(): number {
    const n: number = this.images().length
    return n > 0 ? n : 3
  }

  private getIndices(): number[] {
    const n: number = this.panelCount()
    const list: number[] = []
    for (let i: number = 0; i < n; i++) {
      list.push(i)
    }
    return list
  }

  private currentImage(): ArchitectureImage | undefined {
    const list: ArchitectureImage[] = this.images()
    if (list.length === 0) {
      return undefined
    }
    const i: number = Math.min(this.currentIndex, list.length - 1)
    return list[i]
  }

  private captionText(): string {
    const img: ArchitectureImage | undefined = this.currentImage()
    return img ? img.caption : ''
  }

  private showSource(): void {
    const img: ArchitectureImage | undefined = this.currentImage()
    if (!img) {
      return
    }
    promptAction.showDialog({
      title: '图片来源',
      message: `${img.credit}\n\n${img.source}`,
      buttons: [{ text: '知道了', color: '#173E6B' }]
    })
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Swiper() {
        ForEach(this.getIndices(), (index: number): void => {
          if (this.images().length > 0) {
            Image($rawfile(this.images()[index].file))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          } else {
            ArchCover({
              title: this.arch ? this.arch.name : '',
              fromColor: this.arch ? this.arch.coverFrom : '#173E6B',
              toColor: this.arch ? this.arch.coverTo : '#0F2A4C',
              radius: 0
            })
          }
        }, (index: number): string => `${index}`)
      }
      .width('100%')
      .height('100%')
      .indicator(false)
      .loop(true)
      .onChange((index: number): void => {
        this.currentIndex = index
      })

      // 底部压暗条：图注 + 页码 + 出处入口
      Row({ space: 8 }) {
        Text(this.captionText())
          .fontSize(AppFont.mini)
          .fontColor('rgba(255,255,255,0.94)')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        if (this.images().length > 0) {
          Text('ⓘ')
            .fontSize(AppFont.mini)
            .fontColor('rgba(255,255,255,0.94)')
            .padding({ left: 7, right: 7, top: 3, bottom: 3 })
            .backgroundColor('rgba(0,0,0,0.32)')
            .borderRadius(999)
            .onClick((): void => this.showSource())
        }

        Text(`${this.currentIndex + 1} / ${this.panelCount()}`)
          .fontSize(AppFont.mini)
          .fontColor('rgba(255,255,255,0.94)')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor('rgba(0,0,0,0.32)')
          .borderRadius(999)
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 22, bottom: 12 })
      .linearGradient({
        angle: 180,
        colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.55)', 1]]
      })
    }
    .width('100%')
    .height(272)
  }
}
