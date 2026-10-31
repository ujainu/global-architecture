import { ArchitectureDetail, Architect, Continent, EraDef, StyleDef } from '../../model/Architecture'
import { PRESET_ARCHITECTS, PRESET_ARCHITECTURES, PRESET_CONTINENTS, PRESET_ERAS, PRESET_STYLES } from './PresetData'

/**
 * 预置内容读取层。
 * 当前直接返回代码内占位数据；
 * 后续改为：通过 resourceManager.getRawFileContent 读取
 * rawfile/architecture/index.json 与各建筑 detail.json（JSON.parse）。
 */
export class PresetReader {
  getArchitectures(): ArchitectureDetail[] {
    return PRESET_ARCHITECTURES
  }

  getContinents(): Continent[] {
    return PRESET_CONTINENTS
  }

  getEras(): EraDef[] {
    return PRESET_ERAS
  }

  getStyles(): StyleDef[] {
    return PRESET_STYLES
  }

  getArchitects(): Architect[] {
    return PRESET_ARCHITECTS
  }
}
