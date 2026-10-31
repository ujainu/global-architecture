import { ArchitectureDetail, Architect, Continent, EraDef, StyleDef } from '../../model/Architecture'
import { ARCH_ASIA } from './data/ArchAsia'
import { ARCH_EUROPE } from './data/ArchEurope'
import { ARCH_AFRICA } from './data/ArchAfrica'
import { ARCH_NORTH_AMERICA } from './data/ArchNorthAmerica'
import { ARCH_SOUTH_AMERICA } from './data/ArchSouthAmerica'
import { ARCH_OCEANIA } from './data/ArchOceania'

/**
 * 预置内容数据源（由 tools/scripts/gen_preset.py 生成，请勿手工编辑）
 *
 * 建筑详情已按大洲拆分为 ./data/Arch*.ets，此处仅做词表定义与聚合，
 * PresetReader 及上层 Repository 无需感知拆分细节。
 */

export const PRESET_CONTINENTS: Continent[] = [
  { id: 'asia', name: '亚洲', emoji: '🏯' },
  { id: 'europe', name: '欧洲', emoji: '🏰' },
  { id: 'africa', name: '非洲', emoji: '🛕' },
  { id: 'north_america', name: '北美洲', emoji: '🏙️' },
  { id: 'south_america', name: '南美洲', emoji: '🗿' },
  { id: 'oceania', name: '大洋洲', emoji: '🌊' },
]

export const PRESET_ERAS: EraDef[] = [
  { id: 'ancient', name: '古代' },
  { id: 'medieval', name: '中世纪' },
  { id: 'early_modern', name: '近代' },
  { id: 'modern', name: '现代' },
  { id: 'contemporary', name: '当代' },
]

export const PRESET_STYLES: StyleDef[] = [
  { id: 'ancient_egypt', name: '古埃及' },
  { id: 'ancient_greek', name: '古希腊' },
  { id: 'ancient_roman', name: '古罗马' },
  { id: 'prehistoric', name: '史前巨石' },
  { id: 'byzantine', name: '拜占庭' },
  { id: 'romanesque', name: '罗马式' },
  { id: 'gothic', name: '哥特式' },
  { id: 'neo_gothic', name: '新哥特式' },
  { id: 'renaissance', name: '文艺复兴' },
  { id: 'baroque', name: '巴洛克' },
  { id: 'rococo', name: '洛可可' },
  { id: 'neoclassical', name: '新古典主义' },
  { id: 'romanticism', name: '浪漫主义' },
  { id: 'victorian', name: '维多利亚' },
  { id: 'chinese_palace', name: '中式宫殿' },
  { id: 'chinese_garden', name: '中式园林' },
  { id: 'tibetan', name: '藏式' },
  { id: 'japanese_traditional', name: '日本传统' },
  { id: 'khmer', name: '高棉' },
  { id: 'islamic', name: '伊斯兰建筑' },
  { id: 'ottoman', name: '奥斯曼' },
  { id: 'moorish', name: '摩尔式' },
  { id: 'nabataean', name: '纳巴泰' },
  { id: 'russian_orthodox', name: '俄罗斯东正教' },
  { id: 'inca', name: '印加' },
  { id: 'mayan', name: '玛雅' },
  { id: 'art_nouveau', name: '新艺术运动' },
  { id: 'industrial', name: '工业风' },
  { id: 'art_deco', name: '装饰艺术' },
  { id: 'organic', name: '有机建筑' },
  { id: 'modernism', name: '现代主义' },
  { id: 'expressionism', name: '表现主义' },
  { id: 'brutalism', name: '粗野主义' },
  { id: 'high_tech', name: '高技派' },
  { id: 'modern_skyscraper', name: '现代摩天楼' },
  { id: 'modern_engineering', name: '现代工程结构' },
  { id: 'deconstructivism', name: '解构主义' },
  { id: 'sustainable', name: '生态可持续' },
]

export const PRESET_ARCHITECTS: Architect[] = [
  { id: 'hemiunu', name: '赫米乌努' },
  { id: 'callicrates', name: '卡利克拉特' },
  { id: 'apollodorus', name: '大马士革的阿波罗多罗斯' },
  { id: 'anthemius', name: '特拉勒斯的安提莫斯' },
  { id: 'suryavarman_ii', name: '苏利耶跋摩二世' },
  { id: 'kuai_xiang', name: '蒯祥' },
  { id: 'ustad_lahauri', name: '乌斯塔德·艾哈迈德·拉豪里' },
  { id: 'sedefkar_mehmed_agha', name: '赛德夫哈尔·穆罕默德·阿加' },
  { id: 'bramante', name: '多纳托·布拉曼特' },
  { id: 'michelangelo', name: '米开朗基罗' },
  { id: 'bernini', name: '乔瓦尼·洛伦佐·贝尔尼尼' },
  { id: 'bonanno_pisano', name: '博南诺·皮萨诺' },
  { id: 'maurice_de_sully', name: '莫里斯·德·苏利' },
  { id: 'pierre_lescot', name: '皮埃尔·莱斯科' },
  { id: 'i_m_pei', name: '贝聿铭' },
  { id: 'louis_le_vau', name: '路易·勒沃' },
  { id: 'jules_hardouin_mansart', name: '儒勒·阿杜安-芒萨尔' },
  { id: 'charles_barry', name: '查尔斯·巴里' },
  { id: 'augustus_pugin', name: '奥古斯都·普金' },
  { id: 'horace_jones', name: '霍勒斯·琼斯' },
  { id: 'john_wolfe_barry', name: '约翰·沃尔夫·巴里' },
  { id: 'gerhard_von_riel', name: '格哈德·冯·里勒' },
  { id: 'christian_jank', name: '克里斯蒂安·扬克' },
  { id: 'eduard_riedel', name: '爱德华·里德尔' },
  { id: 'postnik_yakovlev', name: '波斯尼克·雅科夫列夫' },
  { id: 'aristotle_fioravanti', name: '亚里士多德·菲奥拉万蒂' },
  { id: 'bartolomeo_rastrelli', name: '巴托洛梅奥·拉斯特雷利' },
  { id: 'frederic_bartholdi', name: '弗雷德里克·巴托尔迪' },
  { id: 'james_hoban', name: '詹姆斯·霍本' },
  { id: 'joseph_strauss', name: '约瑟夫·斯特劳斯' },
  { id: 'cesar_pelli', name: '西萨·佩里' },
  { id: 'gustave_eiffel', name: '古斯塔夫·埃菲尔' },
  { id: 'antoni_gaudi', name: '安东尼·高迪' },
  { id: 'shreve_lamb', name: '施里夫·兰姆·哈蒙' },
  { id: 'heitor_costa', name: '海托尔·达席尔瓦·科斯塔' },
  { id: 'frank_wright', name: '弗兰克·劳埃德·赖特' },
  { id: 'jorn_utzon', name: '约恩·乌松' },
  { id: 'adrian_smith', name: '阿德里安·史密斯' },
]

export const PRESET_ARCHITECTURES: ArchitectureDetail[] = [
  ...ARCH_ASIA,
  ...ARCH_EUROPE,
  ...ARCH_AFRICA,
  ...ARCH_NORTH_AMERICA,
  ...ARCH_SOUTH_AMERICA,
  ...ARCH_OCEANIA
]
