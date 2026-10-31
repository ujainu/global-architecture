/**
 * 建筑领域模型：纯数据结构，无 UI、无 IO
 * 后续接入 rawfile/architecture/index.json + detail.json 时字段保持一致
 */

/** 大洲 */
export interface Continent {
  id: string
  name: string
  emoji: string
}

/** 建筑风格（流派） */
export interface StyleDef {
  id: string
  name: string
}

/** 历史时代 */
export interface EraDef {
  id: string
  name: string
}

/** 建筑师 */
export interface Architect {
  id: string
  name: string
}

/** 建筑（列表/索引使用的轻量结构，对应 index.json 中的条目） */
export interface Architecture {
  id: string
  name: string
  nameEn: string
  country: string
  city: string
  /** 纬度（北纬为正，南纬为负），世界地图标注用 */
  lat: number
  /** 经度（东经为正，西经为负），世界地图标注用 */
  lng: number
  continentId: string
  eraId: string
  /** 年代展示文本，如「公元 70–80 年」「1882 年至今」 */
  yearText: string
  architectIds: string[]
  styleIds: string[]
  summary: string
  /** 无图片资源时的占位封面渐变色 */
  coverFrom: string
  coverTo: string
  /** 是否进入首页推荐 */
  recommended: boolean
  /** 热度值，用于排序 */
  popularity: number
}

/** 建筑配图元数据 */
export interface ArchitectureImage {
  /** rawfile 相对路径，如 architecture/giza_pyramid/1.jpg */
  file: string
  /** 图片说明 */
  caption: string
  /** 原始图片来源链接（便于核查与替换） */
  source: string
  /** 作者 / 许可说明 */
  credit: string
}

/** 建筑详情（对应 detail.json），所有建筑共用详情页渲染 */
export interface ArchitectureDetail extends Architecture {
  /** 建筑背景：建造缘由、时代背景与选址 */
  background: string
  /** 建筑特点：结构体系、材料与空间特征 */
  features: string
  /** 历史变迁：建造、损毁与修复的历程 */
  history: string
  /** 文化价值：艺术、技术与象征意义 */
  culture: string
  /** 趣味小故事 */
  story: string
  /** 配图（rawfile 相对路径）；为空数组时使用渐变占位封面 */
  images: ArchitectureImage[]
}

/** 数据概览条目（首页资料库统计用） */
export interface StatItem {
  label: string
  value: number
}

/** 时代条目（含建筑数量，首页「时代长河」入口用） */
export interface EraStat {
  id: string
  name: string
  count: number
}
