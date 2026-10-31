/** 世界地图上的一个建筑标记（轻量结构，避免把整份建筑详情传进画布） */
export interface MapMark {
  archId: string
  name: string
  lat: number
  lng: number
  /** 热度，用于标签排布优先级 */
  popularity: number
  /** 所属大洲的强调色，用于锚点着色 */
  color: string
}

/** 地图图例项（大洲 -> 颜色） */
export interface MapLegendItem {
  label: string
  color: string
}
