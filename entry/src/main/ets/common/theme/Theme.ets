/**
 * 全局主题：色彩 / 字号 / 圆角 / 间距
 * 建筑类应用采用「靛蓝 + 鎏金 + 米白」配色
 */
export class AppColor {
  static readonly primary: string = '#173E6B'
  static readonly primaryDark: string = '#0F2A4C'
  static readonly primaryLight: string = '#E9F0F8'
  static readonly accent: string = '#C8A35C'
  static readonly accentLight: string = '#F6EEDD'
  static readonly bg: string = '#F6F4EF'
  static readonly card: string = '#FFFFFF'
  static readonly textPrimary: string = '#1F2329'
  static readonly textSecondary: string = '#646A73'
  static readonly textHint: string = '#8F959E'
  static readonly divider: string = '#EDEAE3'
  static readonly danger: string = '#D9534F'
  static readonly favorite: string = '#E25B5B'
  static readonly success: string = '#3CA374'

  /** 知识图谱节点配色 */
  static readonly nodeArch: string = '#173E6B'
  static readonly nodeStyle: string = '#C8A35C'
  static readonly nodeEra: string = '#7B6BAF'
  static readonly nodeArchitect: string = '#3E8E7E'

  /** 占位封面色板（按取模取用） */
  static readonly coverPalette: string[][] = [
    ['#173E6B', '#3E6D9C'],
    ['#8A5A2B', '#C8A35C'],
    ['#5B3E6B', '#8E7BC0'],
    ['#2F5D50', '#5E9C88'],
    ['#6B2F3A', '#B85C6E'],
    ['#2B5A7A', '#5FA8C9'],
    ['#7A4B22', '#D09A5A']
  ]
}

export class AppFont {
  static readonly title: number = 22
  static readonly subtitle: number = 17
  static readonly body: number = 15
  static readonly caption: number = 13
  static readonly mini: number = 11
}

export class AppRadius {
  static readonly sm: number = 8
  static readonly md: number = 12
  static readonly lg: number = 16
  static readonly xl: number = 22
  static readonly pill: number = 999
}

export class AppDims {
  static readonly pagePadding: number = 16
  static readonly cardGap: number = 12
  static readonly sectionGap: number = 22

  /** 悬浮导航栏：条目高度 */
  static readonly navItemHeight: number = 54
  /** 悬浮导航栏：左右与底部外边距（形成悬浮感） */
  static readonly navMargin: number = 14
  /** 悬浮导航栏：栏内边距 */
  static readonly navPadding: number = 6
  /** 悬浮导航栏：圆角 */
  static readonly navRadius: number = 28
  /** 内容区底部需让出的高度 = 条目高 + 内边距×2 + 外边距 + 间隙 */
  static readonly navSafeSpace: number = 98
}
