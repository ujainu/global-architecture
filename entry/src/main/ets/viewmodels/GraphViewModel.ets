import { ArchitectureDetail } from '../model/Architecture'
import { GraphData, GraphNode, GraphNodeType } from '../model/GraphNode'
import { GraphEdge } from '../model/GraphEdge'
import { MapLegendItem, MapMark } from '../model/MapMark'
import { ArchitectureRepository } from '../repository/ArchitectureRepository'
import { GraphRepository } from '../repository/GraphRepository'

/** 图谱页的两种视图 */
export enum GraphMode {
  /** 关联图谱：建筑—时代/风格/建筑师的力导向网络 */
  Relation = 0,
  /** 世界地图：按经纬度标注建筑 */
  Map = 1
}

/** 各大洲锚点配色（世界地图上用颜色区分地域） */
const CONTINENT_COLORS: string[] = ['#173E6B', '#C8A35C', '#7B6BAF', '#3E8E7E', '#B85C6E', '#2B7A8A']

/**
 * 知识图谱页面状态：
 * - 关联图谱：构建时执行一次力导向布局（斥力 + 弹簧 + 向心力 + 模拟退火）
 * - 世界地图：由预置经纬度生成标记，画布侧按等距圆柱投影定位
 * - 两种视图共用同一个 selectedNode，点选后由页面弹出 NodeDetailSheet
 */
@ObservedV2
export class GraphViewModel {
  static readonly instance: GraphViewModel = new GraphViewModel()
  private archRepo: ArchitectureRepository = ArchitectureRepository.instance
  private graph: GraphData = this.initGraph()
  private marks: MapMark[] = this.buildMarks()

  @Trace selectedNode: GraphNode | undefined = undefined
  @Trace mode: GraphMode = GraphMode.Relation

  private initGraph(): GraphData {
    const g: GraphData = GraphRepository.instance.buildGraph()
    this.layout(g)
    return g
  }

  /** 由预置经纬度构建地图标记；颜色按大洲取，便于一眼分辨地域分布 */
  private buildMarks(): MapMark[] {
    const continents: string[] = this.archRepo.getContinents().map((c): string => c.id)
    return this.archRepo.getAll().map((a: ArchitectureDetail): MapMark => {
      const ci: number = continents.indexOf(a.continentId)
      return {
        archId: a.id,
        name: a.name,
        lat: a.lat,
        lng: a.lng,
        popularity: a.popularity,
        color: CONTINENT_COLORS[ci >= 0 ? ci % CONTINENT_COLORS.length : 0]
      }
    })
  }

  getGraph(): GraphData {
    return this.graph
  }

  getMarks(): MapMark[] {
    return this.marks
  }

  /** 地图图例：大洲 -> 锚点颜色 */
  getLegend(): MapLegendItem[] {
    return this.archRepo.getContinents().map((c, i): MapLegendItem => {
      return { label: c.name, color: CONTINENT_COLORS[i % CONTINENT_COLORS.length] }
    })
  }

  switchMode(mode: GraphMode): void {
    this.mode = mode
  }

  /**
   * 地图上点选建筑：装配一个建筑类型节点塞进 selectedNode，
   * 这样底部弹层（NodeDetailSheet）与关联图谱完全复用同一条数据通路。
   */
  selectArch(archId: string): void {
    const arch: ArchitectureDetail | undefined = this.archRepo.getById(archId)
    if (!arch) {
      return
    }
    this.selectedNode = {
      id: `arch_${arch.id}`,
      label: arch.name,
      type: GraphNodeType.Architecture,
      archId: arch.id,
      x: 0,
      y: 0
    }
  }

  /** 当前选中的建筑 id（供地图高亮） */
  selectedArchId(): string {
    const n: GraphNode | undefined = this.selectedNode
    if (!n || n.type !== GraphNodeType.Architecture) {
      return ''
    }
    return n.archId
  }

  selectNode(id: string): void {
    this.selectedNode = this.graph.nodes.find((n: GraphNode): boolean => n.id === id)
  }

  clearSelection(): void {
    this.selectedNode = undefined
  }

  /** 节点关联的建筑：建筑节点返回自身，其他类型通过连线反查 */
  relatedArchitectures(node: GraphNode): ArchitectureDetail[] {
    const result: ArchitectureDetail[] = []
    if (node.type === GraphNodeType.Architecture) {
      const arch: ArchitectureDetail | undefined = this.archRepo.getById(node.archId)
      if (arch) {
        result.push(arch)
      }
      return result
    }
    this.graph.edges.forEach((edge: GraphEdge): void => {
      if (edge.to === node.id && edge.from.startsWith('arch_')) {
        const archId: string = edge.from.substring(5)
        const arch: ArchitectureDetail | undefined = this.archRepo.getById(archId)
        if (arch && !result.some((a: ArchitectureDetail): boolean => a.id === arch.id)) {
          result.push(arch)
        }
      }
    })
    return result
  }

  static typeName(type: GraphNodeType): string {
    if (type === GraphNodeType.Architecture) {
      return '建筑'
    }
    if (type === GraphNodeType.Style) {
      return '风格流派'
    }
    if (type === GraphNodeType.Era) {
      return '时代'
    }
    return '建筑师'
  }

  /**
   * Fruchterman-Reingold 风格力导向布局
   * 初始按类型分环，再迭代施加斥力/弹簧拉力/向心力，温度退火保证收敛
   */
  private layout(g: GraphData): void {
    const rings: Map<GraphNodeType, number> = new Map()
    rings.set(GraphNodeType.Era, 90)
    rings.set(GraphNodeType.Architect, 150)
    rings.set(GraphNodeType.Style, 220)
    rings.set(GraphNodeType.Architecture, 300)

    const counts: Map<GraphNodeType, number> = new Map()
    g.nodes.forEach((n: GraphNode): void => {
      const c: number | undefined = counts.get(n.type)
      counts.set(n.type, c === undefined ? 1 : c + 1)
    })

    const cursor: Map<GraphNodeType, number> = new Map()
    g.nodes.forEach((n: GraphNode): void => {
      const ringValue: number | undefined = rings.get(n.type)
      const ringRadius: number = ringValue === undefined ? 200 : ringValue
      const totalValue: number | undefined = counts.get(n.type)
      const total: number = totalValue === undefined ? 1 : totalValue
      const used: number | undefined = cursor.get(n.type)
      const index: number = used === undefined ? 0 : used
      cursor.set(n.type, index + 1)
      const angle: number = -Math.PI / 2 + (index / total) * Math.PI * 2
      const jitter: number = n.type === GraphNodeType.Architecture ? (index % 2 === 0 ? 14 : -14) : 0
      n.x = Math.cos(angle) * (ringRadius + jitter)
      n.y = Math.sin(angle) * (ringRadius + jitter)
    })

    const count: number = g.nodes.length
    const indexOf: Map<string, number> = new Map()
    g.nodes.forEach((n: GraphNode, i: number): void => {
      indexOf.set(n.id, i)
    })
    const dispX: number[] = []
    const dispY: number[] = []
    for (let i: number = 0; i < count; i++) {
      dispX.push(0)
      dispY.push(0)
    }

    const repulsion: number = 11000
    const spring: number = 0.02
    const gravity: number = 0.025
    let temperature: number = 36

    for (let iter: number = 0; iter < 180; iter++) {
      for (let i: number = 0; i < count; i++) {
        dispX[i] = 0
        dispY[i] = 0
      }

      for (let i: number = 0; i < count; i++) {
        for (let j: number = i + 1; j < count; j++) {
          let dx: number = g.nodes[i].x - g.nodes[j].x
          let dy: number = g.nodes[i].y - g.nodes[j].y
          let dist2: number = dx * dx + dy * dy
          if (dist2 < 0.01) {
            dx = (i % 2 === 0 ? 1 : -1) * 0.5
            dy = (j % 2 === 0 ? 0.5 : -0.5)
            dist2 = dx * dx + dy * dy
          }
          const force: number = repulsion / dist2
          const dist: number = Math.sqrt(dist2)
          const ux: number = dx / dist
          const uy: number = dy / dist
          dispX[i] += ux * force
          dispY[i] += uy * force
          dispX[j] -= ux * force
          dispY[j] -= uy * force
        }
      }

      g.edges.forEach((edge: GraphEdge): void => {
        const ai: number | undefined = indexOf.get(edge.from)
        const bi: number | undefined = indexOf.get(edge.to)
        if (ai === undefined || bi === undefined) {
          return
        }
        const dx: number = g.nodes[ai].x - g.nodes[bi].x
        const dy: number = g.nodes[ai].y - g.nodes[bi].y
        const dist: number = Math.max(Math.sqrt(dx * dx + dy * dy), 0.01)
        const restLength: number = 95
        const force: number = (dist - restLength) * spring
        const ux: number = dx / dist
        const uy: number = dy / dist
        dispX[ai] -= ux * force
        dispY[ai] -= uy * force
        dispX[bi] += ux * force
        dispY[bi] += uy * force
      })

      for (let i: number = 0; i < count; i++) {
        dispX[i] -= g.nodes[i].x * gravity
        dispY[i] -= g.nodes[i].y * gravity
        const len: number = Math.sqrt(dispX[i] * dispX[i] + dispY[i] * dispY[i])
        if (len > 0.01) {
          const step: number = Math.min(len, temperature)
          g.nodes[i].x += dispX[i] / len * step
          g.nodes[i].y += dispY[i] / len * step
        }
      }
      temperature *= 0.95
    }

    // 居中
    let sumX: number = 0
    let sumY: number = 0
    g.nodes.forEach((n: GraphNode): void => {
      sumX += n.x
      sumY += n.y
    })
    const cx: number = sumX / count
    const cy: number = sumY / count
    g.nodes.forEach((n: GraphNode): void => {
      n.x -= cx
      n.y -= cy
    })
  }
}
