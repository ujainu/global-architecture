import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN: number = 0x0A01
const TAG: string = 'GlobalArch'

export class Logger {
  static info(msg: string): void {
    hilog.info(DOMAIN, TAG, '%{public}s', msg)
  }

  static error(msg: string): void {
    hilog.error(DOMAIN, TAG, '%{public}s', msg)
  }
}
