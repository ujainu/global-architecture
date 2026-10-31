import { GraphEdge } from './GraphEdge'

/** 图谱节点类型：建筑 / 风格流派 / 时代 / 建筑师 */
export enum GraphNodeType {
  Architecture = 0,
  Style = 1,
  Era = 2,
  Architect = 3
}

export interface GraphNode {
  id: string
  label: string
  type: GraphNodeType
  /** 建筑节点对应的建筑 ID，用于点击跳转详情 */
  archId: string
  /** 力导向布局坐标（vp 逻辑单位），布局算法写入 */
  x: number
  y: number
}

/** 图谱完整数据 */
export interface GraphData {
  nodes: GraphNode[]
  edges: GraphEdge[]
}
