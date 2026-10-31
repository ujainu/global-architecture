export class TextUtil {
  /** 按最大长度截断并补省略号 */
  static ellipsis(text: string, max: number): string {
    if (text.length <= max) {
      return text
    }
    return `${text.substring(0, max)}…`
  }

  static isEmpty(text: string): boolean {
    return text === undefined || text === null || text.trim().length === 0
  }
}
