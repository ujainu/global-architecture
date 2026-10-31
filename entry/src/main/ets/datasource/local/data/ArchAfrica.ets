import { ArchitectureDetail } from '../../../model/Architecture'

/**
 * 非洲建筑预置数据（由 tools/scripts/gen_preset.py 生成，请勿手工编辑）
 * 数据源：tools/data/skeleton.json + prose_all.json + images_manifest.json
 */
export const ARCH_AFRICA: ArchitectureDetail[] = [
  {
    id: 'giza_pyramid',
    name: '吉萨大金字塔',
    nameEn: 'Great Pyramid of Giza',
    country: '埃及',
    city: '吉萨高原',
    lat: 29.9792,
    lng: 31.1342,
    continentId: 'africa',
    eraId: 'ancient',
    yearText: '约公元前 2560 年',
    architectIds: ['hemiunu'],
    styleIds: ['ancient_egypt'],
    summary: '世界七大奇迹中唯一留存至今的建筑，古埃及法老胡夫的陵墓。',
    coverFrom: '#8A5A2B',
    coverTo: '#D9A95E',
    recommended: true,
    popularity: 96,
    background: '大金字塔是古埃及第四王朝法老胡夫的陵墓，约建于公元前2560年前后，是吉萨三座金字塔中最早也最大的一座。古王国时期中央集权强盛，尼罗河每年的泛滥既带来肥沃淤泥，也提供了运输石料的水路，使大规模动员人力物力成为可能。选址吉萨高原，既靠近当时的都城孟菲斯，又有稳固的石灰岩地基，建筑材料可就近开采并借泛滥期的水道运送。',
    features: '塔身原有高度约146米，如今顶端剥落，残高约138米，底面边长超过230米，由数百万块巨石垒砌，平均每块重达数吨。内部依次有下降通道、上升走廊、著名的大走廊，以及用花岗岩砌成的国王室，室顶上方以层层减压石室分散上方巨重。四边几乎正对东南西北，误差极小。外墙曾覆盖光滑的白色石灰岩，在阳光下极为耀眼。',
    history: '建造大约持续了二十年。现代考古在金字塔附近发现了劳工村落、面包房与医疗遗迹，表明施工者多是有组织的轮换劳工，而非传说中大批被奴役的奴隶。此后数千年，金字塔长期被当作采石场，白色外层石被拆去修建开罗城，顶端也因地震与风化而缺失。在长达三千八百多年的时间里，它始终是世界最高的人造建筑，直到中世纪欧洲的教堂尖塔将其超越。',
    culture: '大金字塔集中体现了古埃及的宗教观念、天文知识与工程组织能力。它印证了法老作为神与人之间中介的地位，也反映出对来世与复活的执着信仰。精准的方位、庞大的体量与严整的几何秩序，使它成为古代世界七大奇迹中唯一留存至今者。1979年，孟菲斯及其墓地——吉萨金字塔区被列入世界遗产，它至今仍是人类文明最广为人知的象征之一。',
    story: '古希腊史学家希罗多德在公元前五世纪到访，记录下据说是祭司转述的说法：胡夫强迫全体埃及人为他服役，用十年修路、二十年建塔，甚至为筹钱不惜让女儿卖身。这些叙述带着明显的敌意，与考古发现的劳工营地和充足食物并不吻合。至今仍有人相信塔内藏有密室，2017年科学家借助宇宙线成像，发现大走廊上方存在一个此前未知的空腔。',
    images: [
      { file: 'architecture/giza_pyramid/1.jpg', caption: '吉萨大金字塔 实景（1/3）', source: 'https://commons.wikimedia.org/wiki/File:Great_Pyramid_of_Giza.jpg', credit: 'Wikimedia Commons（自由许可，详见来源链接）' },
      { file: 'architecture/giza_pyramid/2.jpg', caption: '吉萨大金字塔 实景（2/3）', source: 'https://touch.travel.qunar.com/poi/4449714', credit: '网络公开图片，仅作学习演示' },
      { file: 'architecture/giza_pyramid/3.jpg', caption: '吉萨大金字塔 实景（3/3）', source: 'https://bbs.zol.com.cn/dcbbs/d34039_3763.html', credit: '网络公开图片，仅作学习演示' },
    ]
  },
]
