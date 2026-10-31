import { ArchitectureDetail } from '../../../model/Architecture'

/**
 * 大洋洲建筑预置数据（由 tools/scripts/gen_preset.py 生成，请勿手工编辑）
 * 数据源：tools/data/skeleton.json + prose_all.json + images_manifest.json
 */
export const ARCH_OCEANIA: ArchitectureDetail[] = [
  {
    id: 'sydney_opera',
    name: '悉尼歌剧院',
    nameEn: 'Sydney Opera House',
    country: '澳大利亚',
    city: '悉尼',
    lat: -33.8568,
    lng: 151.2153,
    continentId: 'oceania',
    eraId: 'contemporary',
    yearText: '1959–1973 年',
    architectIds: ['jorn_utzon'],
    styleIds: ['expressionism'],
    summary: '贝壳状薄壳屋顶覆盖的表演艺术中心，从设计竞赛到建成耗时十四年、超支十余倍。',
    coverFrom: '#2F6A8A',
    coverTo: '#A8D8E8',
    recommended: true,
    popularity: 93,
    background: '悉尼歌剧院诞生于二战后澳大利亚文化自信上升的时期。1955年，新南威尔士州政府发起国际设计竞赛，希望在海港边建一座能演出歌剧与音乐会的场所。丹麦建筑师约恩·乌松的方案起初被评委认为难以实施而搁置，后由芬兰裔评委埃罗·沙里宁从废稿中拣出并力荐，才最终中选。选址便利朗角，三面环水，与海港大桥隔湾相望。',
    features: '建筑最醒目的是那组层叠的壳片屋顶，最高处约67米，相当于二十余层楼。屋顶由一百多万块瑞典制造的瓷砖铺成，分亮面与哑面两种，在阳光下呈现不同光泽。为解决壳体结构难题，工程最终采用球面几何，所有壳片都取自同一个半径的球体，从而可以预制拼装。内部设音乐厅、歌剧院、剧场等多个演出空间，外墙以玻璃幕墙面向海港。',
    history: '工程1959年动工，但壳体方案反复修改，预算不断攀升，工期一再拖延。1966年，因费用争议与政治摩擦，乌松辞职离开澳大利亚，此后由本土建筑师团队接手完成内部与收尾。1973年10月，歌剧院由英国女王伊丽莎白二世正式揭幕。2003年乌松获颁普利兹克建筑奖，2007年歌剧院被列入世界遗产，2008年乌松去世，双方的和解来得颇晚。',
    culture: '悉尼歌剧院是二十世纪最具辨识度的建筑之一，它的壳片造型几乎成了澳大利亚的国家标志。它把现代主义的结构探索与雕塑般的形态结合起来，推动了薄壳与大跨度屋盖在公共建筑中的发展。作为仍在运营的表演艺术中心，它兼具地标、旅游目的地与演出场所的多重身份。世界遗产委员会称它是人类创造性天才的杰作，也是现代建筑入选遗产的早期代表。',
    story: '当年竞赛收到两百多个方案，乌松的图纸线条松散、说明简略，起初被认为难以实施而弃置一旁。沙里宁到达评审现场后翻检废稿，坚持把这份方案重新提上来，才改变了最终结果。另一个常被提起的细节是，乌松本人从未亲眼见过建成的歌剧院。他生前表示希望骨灰能有一部分撒在悉尼港，但据报道这一愿望最终未能实现。',
    images: [
      { file: 'architecture/sydney_opera/1.jpg', caption: '悉尼歌剧院 实景（1/3）', source: 'https://commons.wikimedia.org/wiki/File:Sydney_Opera_House.jpg', credit: 'Wikimedia Commons（自由许可，详见来源链接）' },
      { file: 'architecture/sydney_opera/2.jpg', caption: '悉尼歌剧院 实景（2/3）', source: 'https://pixabay.com/images/search/sydney opera house/', credit: 'Pixabay License（可商用）' },
      { file: 'architecture/sydney_opera/3.jpg', caption: '悉尼歌剧院 实景（3/3）', source: 'https://dp.pconline.com.cn/dphoto/list_3525291.html', credit: '网络公开图片，仅作学习演示' },
    ]
  },
]
