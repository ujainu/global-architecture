import { ArchitectureDetail } from '../model/Architecture'
import { GraphEdge } from '../model/GraphEdge'
import { GraphData, GraphNode, GraphNodeType } from '../model/GraphNode'
import { ArchitectureRepository } from './ArchitectureRepository'

/**
 * 知识图谱仓库：由预置建筑数据派生出
 * 建筑 — 风格 / 时代 / 建筑师 的关联网络
 */
export class GraphRepository {
  static readonly instance: GraphRepository = new GraphRepository()
  private archRepo: ArchitectureRepository = ArchitectureRepository.instance

  buildGraph(): GraphData {
    const nodes: GraphNode[] = []
    const edges: GraphEdge[] = []
    const archs: ArchitectureDetail[] = this.archRepo.getAll()

    archs.forEach((arch: ArchitectureDetail): void => {
      const archNodeId: string = `arch_${arch.id}`
      nodes.push({
        id: archNodeId,
        label: arch.name,
        type: GraphNodeType.Architecture,
        archId: arch.id,
        x: 0,
        y: 0
      })

      edges.push({ from: archNodeId, to: `era_${arch.eraId}` })

      arch.styleIds.forEach((styleId: string): void => {
        edges.push({ from: archNodeId, to: `style_${styleId}` })
      })
      arch.architectIds.forEach((architectId: string): void => {
        edges.push({ from: archNodeId, to: `architect_${architectId}` })
      })
    })

    this.archRepo.getEras().forEach((era): void => {
      nodes.push({ id: `era_${era.id}`, label: era.name, type: GraphNodeType.Era, archId: '', x: 0, y: 0 })
    })
    this.archRepo.getStyles().forEach((style): void => {
      const used: boolean = archs.some((a: ArchitectureDetail): boolean => a.styleIds.indexOf(style.id) >= 0)
      if (used) {
        nodes.push({ id: `style_${style.id}`, label: style.name, type: GraphNodeType.Style, archId: '', x: 0, y: 0 })
      }
    })
    this.archRepo.getArchitects().forEach((architect): void => {
      const used: boolean = archs.some((a: ArchitectureDetail): boolean => a.architectIds.indexOf(architect.id) >= 0)
      if (used) {
        nodes.push({
          id: `architect_${architect.id}`,
          label: architect.name,
          type: GraphNodeType.Architect,
          archId: '',
          x: 0,
          y: 0
        })
      }
    })

    return { nodes, edges }
  }
}
