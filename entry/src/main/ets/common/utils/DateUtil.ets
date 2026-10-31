export class DateUtil {
  static formatTime(ts: number): string {
    const d: Date = new Date(ts)
    const pad = (n: number): string => n < 10 ? `0${n}` : `${n}`
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
  }

  static formatDate(ts: number): string {
    const d: Date = new Date(ts)
    const pad = (n: number): string => n < 10 ? `0${n}` : `${n}`
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
  }

  static nowText(): string {
    return DateUtil.formatTime(Date.now())
  }

  /** 「9月21日」式月日文本，首页每日推荐日期角标用 */
  static monthDayText(ts: number): string {
    const d: Date = new Date(ts)
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  /** 自 Unix 纪元起的天序号，用于「每日一建筑」这类按天轮换的确定性选取 */
  static dayIndex(ts: number): number {
    return Math.floor(ts / 86400000)
  }
}
