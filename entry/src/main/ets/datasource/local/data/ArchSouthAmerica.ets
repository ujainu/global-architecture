import { ArchitectureDetail } from '../../../model/Architecture'

/**
 * 南美洲建筑预置数据（由 tools/scripts/gen_preset.py 生成，请勿手工编辑）
 * 数据源：tools/data/skeleton.json + prose_all.json + images_manifest.json
 */
export const ARCH_SOUTH_AMERICA: ArchitectureDetail[] = [
  {
    id: 'machu_picchu',
    name: '马丘比丘',
    nameEn: 'Machu Picchu',
    country: '秘鲁',
    city: '库斯科',
    lat: -13.1631,
    lng: -72.545,
    continentId: 'south_america',
    eraId: 'medieval',
    yearText: '约 1450 年',
    architectIds: [],
    styleIds: ['inca'],
    summary: '海拔 2430 米云雾中的印加山城，不用灰浆的巨石砌筑历经数百年地震而不倒。',
    coverFrom: '#3E6A4A',
    coverTo: '#A8CFA0',
    recommended: true,
    popularity: 92,
    background: '马丘比丘约建于十五世纪中叶，一般认为是印加君主帕查库特克或其继承者时期的皇家庄园兼宗教圣地。它坐落在安第斯山脉两座山峰之间的山脊上，海拔约2400米，俯瞰乌鲁班巴河谷。选址兼顾防御、水源与天文观测：地势险要，取水便利，四周陡峭的山壁形成天然屏障。正因隐蔽难至，它在西班牙征服印加之后被长期遗忘在丛林之中。',
    features: '全城由神庙区、皇家区与农业居住区组成，用打磨精细的石块干砌而成，不施灰浆，石块之间严丝合缝，地震时能轻微错动而不致坍塌。城内有太阳神庙、拴日石、层层梯田、引水渠与上百条排水暗道，梯田既用于耕作，也起到稳固山坡的作用。建筑顺应山势逐级展开，屋顶原本覆盖茅草，如今只留下石墙、壁龛与窗洞。',
    history: '这座山城的使用时间并不长，约在西班牙人到来后不久便被放弃，丛林逐渐将它覆盖。1911年，美国学者海勒姆·宾厄姆在当地农民指引下抵达这片废墟，并把它介绍给外界，此后他多次考察并带走大量文物。秘鲁与耶鲁大学曾为这批文物的归属长期交涉，部分藏品后来陆续归还。1983年，马丘比丘被列入世界遗产名录。',
    culture: '马丘比丘是印加文明现存最完整的城市遗存之一，体现了印加人在高山环境中的工程智慧与对自然的敬重。拴日石等遗迹反映出太阳崇拜与天文观测在印加宗教中的核心地位，石砌技术、梯田农业与水利系统也一并保存下来。由于遗址脆弱、游客压力巨大，管理方实行限流与分时段参观，它因此成为高负荷遗产保护的典型案例。',
    story: '马丘比丘在克丘亚语中通常被解释为古老的山峰，但这座城真正的印加名字至今无人确知。宾厄姆终生相信自己找到的是印加人最后的避难所比尔卡班巴，直到去世都未接受学界更可能的判断。有趣的是，他1911年到达时，当地已有农户在梯田上耕作居住，所以严格说来他并非发现者，而是让外界知道了它的存在。',
    images: [
      { file: 'architecture/machu_picchu/1.jpg', caption: '马丘比丘 实景（1/3）', source: 'https://commons.wikimedia.org/wiki/File:Machu_Picchu.jpg', credit: 'Wikimedia Commons（自由许可，详见来源链接）' },
      { file: 'architecture/machu_picchu/2.jpg', caption: '马丘比丘 实景（2/3）', source: 'https://touch.travel.qunar.com/comment/5108250', credit: '网络公开图片，仅作学习演示' },
      { file: 'architecture/machu_picchu/3.jpg', caption: '马丘比丘 实景（3/3）', source: 'http://qianye88.com/tupian/42564.html', credit: '网络公开图片，仅作学习演示' },
    ]
  },
  {
    id: 'cristo_redentor',
    name: '基督救世主雕像',
    nameEn: 'Christ the Redeemer',
    country: '巴西',
    city: '里约热内卢',
    lat: -22.9519,
    lng: -43.2105,
    continentId: 'south_america',
    eraId: 'modern',
    yearText: '1922–1931 年',
    architectIds: ['heitor_costa'],
    styleIds: ['art_deco'],
    summary: '科尔科瓦多山顶 30 米高的张开双臂的基督像，是里约与巴西的象征。',
    coverFrom: '#3E7A6A',
    coverTo: '#B0E0D0',
    recommended: true,
    popularity: 87,
    background: '基督救世主雕像建于1922至1931年间，最初是为迎接巴西独立百年而发起的纪念工程。里约天主教界希望在城市制高点竖立一座宗教地标，以彰显信仰，也回应当时社会日益世俗化的忧虑。工程由天主教会与民间募捐共同支持，最终选址科尔科瓦多山顶，这里海拔约700米，可俯瞰城区、海滩与瓜纳巴拉湾，从城中各处都能望见。',
    features: '雕像高约30米，立在约8米高的基座上，双臂展开宽约28米，通体由钢筋混凝土构成，表面覆以数百万片滑石小方片，呈浅灰色，能耐受日晒雨淋。内部设有电梯与阶梯，供检修人员登临。造型采用简洁的装饰艺术风格，长袍线条垂直下垂，远看如同一座巨大的十字架，夜间由灯光勾勒轮廓，从山下望去十分醒目。',
    history: '设计方案经过多轮征集，最终由巴西工程师埃托尔·达席尔瓦·科斯塔主持结构，法国雕塑家保罗·朗多夫斯基负责造型。雕像的头部与双手在法国分段制作，随后海运至里约，再沿山路运抵山顶拼装。1931年10月12日举行落成典礼。此后它经历过多次修缮，2010年前后进行过一次较大规模的整修，并陆续加装了照明与观光设施。',
    culture: '这座雕像已成为里约热内卢乃至巴西最鲜明的视觉符号，频繁出现在明信片、影视作品与大型活动的形象宣传中。它张开双臂的姿态常被解读为包容与欢迎，同时具有守护城市的宗教寓意。作为世界上最大的装饰艺术风格雕像之一，它体现了二十世纪宗教纪念建筑与现代工程、旅游观光相结合的趋势。2012年，它作为里约山海景观的一部分被列入世界遗产。',
    story: '落成那天有一段常被提起的插曲：点灯仪式原计划由远在罗马的无线电发报机发出信号触发，象征跨越大西洋的联结，但因天气干扰信号微弱，最终是现场工作人员手动接通了灯光。另一个细节是，工人常年要在强风与浓雾中作业，沉重的混凝土构件只能靠窄轨小火车和人力运上山顶，山顶施工条件之艰苦远超设计之初的预想。',
    images: [
      { file: 'architecture/cristo_redentor/1.jpg', caption: '基督救世主雕像 实景（1/3）', source: 'https://commons.wikimedia.org/wiki/File:Christ_the_Redeemer.jpg', credit: 'Wikimedia Commons（自由许可，详见来源链接）' },
      { file: 'architecture/cristo_redentor/2.jpg', caption: '基督救世主雕像 实景（2/3）', source: 'https://www.sohu.com/a/574037215_121124416', credit: '网络公开图片，仅作学习演示' },
      { file: 'architecture/cristo_redentor/3.jpg', caption: '基督救世主雕像 实景（3/3）', source: 'https://travel.ifeng.com/world/detail_2014_10/14/39066747_0.shtml', credit: '网络公开图片，仅作学习演示' },
    ]
  },
]
