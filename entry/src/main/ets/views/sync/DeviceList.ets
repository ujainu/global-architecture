import { AppColor, AppFont, AppRadius } from '../../common/theme/Theme'
import { DeviceInfo } from '../../model/SyncTypes'

/** 可信组网设备列表 */
@ComponentV2
export struct DeviceList {
  @Param devices: DeviceInfo[] = []

  build() {
    Column({ space: 8 }) {
      ForEach(this.devices, (device: DeviceInfo): void => {
        Row({ space: 12 }) {
          Text(device.emoji)
            .fontSize(20)
            .width(42)
            .height(42)
            .textAlign(TextAlign.Center)
            .backgroundColor(AppColor.bg)
            .borderRadius(21)

          Column({ space: 3 }) {
            Text(device.name)
              .fontSize(AppFont.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColor.textPrimary)
            Text(device.online ? '在线' : `离线 · ${device.lastSeenText}`)
              .fontSize(AppFont.mini)
              .fontColor(device.online ? AppColor.success : AppColor.textHint)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row() {
            Circle({ width: 8, height: 8 })
              .fill(device.online ? AppColor.success : '#C4C9D1')
          }
          .width(24)
          .height(24)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      }, (device: DeviceInfo): string => device.id)
    }
    .width('100%')
    .padding(6)
    .backgroundColor(AppColor.card)
    .borderRadius(AppRadius.lg)
  }
}
