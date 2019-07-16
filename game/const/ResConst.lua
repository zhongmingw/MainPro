--[[--
 游戏资源(路径)名
]]

--游戏预制资源路径
PrefabRes = {
    effect = "res/effects/",             --特效目录
    player = "res/things/players/",      --玩家目录
    npc = "res/things/npcs/",            --npc目录
    pet = "res/things/pets/",             --pet目录
    weapon = "res/things/weapons/",      --武器目录
    wing = "res/things/wings/",          --翅膀目录
    monster = "res/things/monsters/",    --怪物目录
    mount = "res/things/mounts/",        --坐骑目录
    other = "res/things/others/",          --其他目录
    map = "res/maps/",                   --地图目录

    prop = "res/ui_dyn/props/",           --道具目录
    bg = "res/ui_dyn/bgs/",               --背景图片
    icon = "res/ui_dyn/icons/",           --icon图片

    taskicon = "res/ui_dyn/taskicon/",           --任务名称
}

Platform = {
    android = "android",
    win = "win",
    ios = "ios"
}

--场景名称
if g_var.platform == "win" then
    SceneRes = {
        UPDATE_SCENE = "enter_scene",
        LOGIN_SCENE = "login_scene",
        MAIN_SCENE = "main_scene2",
    }
else
    SceneRes = {
        UPDATE_SCENE = "update_scene",
        LOGIN_SCENE = "login_scene",
        MAIN_SCENE = "main_scene2",
    }
end


StaticVector3 = {
    vector3Zero = Vector3.zero,           --(0,0,0)
    vector3Z180 = Vector3.New(0,0,180),  --全局资源z轴旋转
    scaleXYZ80 = Vector3.New(80,80,80),  --全局资源放大倍数
    vector3X60 = Vector3.New(60,0,0),    --全局资源x轴旋转
    petHeadH = Vector3.New(0,-80,0),
    playerHeadH = Vector3.New(0,-95,0),
    monsterHeadH = Vector3.New(0,-70,0),
    diaoxiangRole = Vector3.New(0,330,0),--人物雕像角度
    diaoxiangPet = Vector3.New(0,330,0),--灵童雕像角度
    home = Vector3.New(0,-0.7,1),
}
gameVolume = 0.5--游戏默认音量
--游戏公共资源名称 - 对应UI编辑器的包名
UICommonRes = {
    "_components",
    "_buttons",
    "_panels",
    "_numfonts",
    "head",
    "_imgfonts",
    "_icons",
    "_others",
    "root",
    "_audios",
    "main",
    "_movie",
    "login",
    "loading",
    "_share",
}

UICommonResIos = "mainios"

PreLoadEct = {
    4030117,
    4040130,
    4030119,
    4030118
}

ViewOpenTween = {
    scale = 1,
    move = 2
}

--事物类型
ThingType = {
    thing = 2,
    npc = 3,
    monster = 4,
    pet= 5,
    player = 6,
    role = 7,
    transfer = 8,
    produce = 9,
    ui = 10,
    total = 10,
    dropItem = 11,
    movie = 12,
    widgets = 13,
}

--激活坐骑10%加成
ZUOQIINDEX = 1013

--怪物类型
MonsterType = {
    small = 1,
    boss = 2,
}
--场景类型
SceneKind = {
    mainCity = 1,  --主城
    field = 2,     --野外
    fuben = 3,     --副本
    xinshou = 4,   --新手
    lianjigu = 5 ,--练级谷
    jingJiChang = 7, --竞技场
    eliteBoss = 8,--精英boss
    worldBoss = 9,--世界boss
    huangling = 10,--皇陵
    wending = 11,--问鼎
    gangWar = 12,--仙盟战
    kuafueliteBoss = 13,--跨服精英boss
    kuafueZudui = 14,--跨服精英boss
    qinyuanfuben = 15 ,--情愿副本
    dujie = 16,--渡劫副本
    kuafuwar = 17,--跨服三界争霸
    xianmoWar = 18,--仙魔战
    awakenBoss = 19,--剑神殿
    xianzunBoss = 20,--仙尊boss
    bossHome = 21,--boss之家
    XianmengZhudi = 22,--仙盟驻地
    xianyulingta = 3 , --仙域灵塔
    hjzy = 25,--幻境镇妖
    jianshengshouhu = 23,--剑神守护
    xianyuBoss = 24,--仙域禁地
    home = 26,--仙域禁地
    wedding = 27,--婚宴场景
    xdzz = 28,--雪地大作战
    beach = 29,--魅力沙滩
    rankmatching = 30,--排位赛
    kuafuworld = 31,--宠物岛
    teammatching = 32,--组队排位赛
    playoff = 33,--排位季后赛
    lantern = 34,--元宵
    kuafuXianyu = 35,--丛林遗迹
    citywar = 36,--跨服城战
    kuafuXianyu2 = 37,--跨服丛林遗迹
    kfpet = 38,--跨服宠物岛
    sgsj = 39,--上古神迹
    wxsd = 40,--五行神殿
    kfxianyuBoss = 41,--跨服仙域禁地
    diwang = 42,--帝王将相
    kfsgsj = 43,--跨服上古神迹
    xianLvPKhxs = 44,--仙侣pk海选赛
    xianLvPKzbs = 45,--仙侣pk争霸赛
    collect = 46,--天晶洞窟（采集探宝）
    feisheng = 47,--飞升
    feisheng1 = 48,--飞升
    shenshou = 49,--神兽岛
    kuafushenshou = 50,--跨服神兽岛
    xianLvPKhxs_2 = 51,--仙侣pk2海选赛全服
    xianLvPKzbs_2 = 52,--仙侣pk2争霸赛全服
    wanshendian = 53,--万神殿（五行圣殿）
    wanshendianCross = 54,--跨服万神殿（五行圣殿）
    shenshoushengyu = 55,--神兽圣域
    wsjChuMo = 56,--万圣节除魔
    taiguXuanJing = 57,--太古玄境
    taiguXuanJing1 = 58,--太古玄境(跨服)
    keju = 59,--科举答题
    crosskeju = 60,--科举答题(跨服)
    yjts = 61,--遗迹探索
}

UICacheType = {
    cacheDisabled = 0,  --不缓存
    cacheForever = 1,  --永久缓存
    cacheTime = 120,  --定时缓存-2分钟
}

--主角AI状态 0-待机 1-战斗 2-死亡 3-打坐 4-采集 5-移动 6-跳跃
RoleAI = {
    idle = 0,
    fight = 1,
    dead = 2,
    sit = 3,
    produce = 4,
    move = 5,
    jump = 6,
    fly = 12,
}
--玩家模式 | 511
PKState = {
    peace = 0,  --和平
    kill = 1, --杀戮
    team = 2, --帮派
    server = 3, --跨服
    camp = 4,--阵营pk模式
    invalid = 5, --无敌状态
}
--特殊怪物（采集物,宝箱,boss技能）
MonsterKind = {
    smallmonster = 1,
    chest = 4,--宝箱
    collection = 5,--采集物
    skill = 8,--boss技能
    sjchest = 12,--三界争霸箱子
    sjmonster = 13,--三界的车子
    tcollection = 14,--瞬间采集物（无拾取进度条）
    crystal = 16,--水晶
    homedog = 6,--家园里面的狗
    ssjtcsm = 21,--麒麟传送门
}

PlayerKind = {
    statue = 7,--雕像
    statue_new = 17,--可点击雕像
}

WidgetKind = {
    mb = 10,--墓碑
    tree = 11,--树
    home = 15 ,--家园组件
}

Audios = {
    [1] = "huodewupin",--获得物品
    [2] = "qianghuashengjie",--强化升阶
    [3] = "wanchengrenwu",--完成任务
    [4] = "shengji_juesse",--升級成功
    [5] = "nanjuesezhanshi",--男角色展示
    [6] = "nvjuesezhanshi",--女角色展示
    [7] = "nanbianshen",--男变身
    [8] = "nvbianshen",--女变身
}
GNPC = {
    ----跨服日常任务NPc
    kfrc = {
        [1] = 3060265,
        [2] = 3060268,
        [3] = 3060271,
    },
    --跨服护送任务
    kfhs = {
        [1] = 3060266,
        [2] = 3060269,
        [3] = 3060272,
    },
    --跨服寻宝任务
    kfxb = {
        [1] = 3060267,
        [2] = 3060270,
        [3] = 3060273,
    },
    --万圣节降妖除魔
    xycm = {
        [1] = 3060278,
        [2] = 3060279,
        [3] = 3060280,
        [4] = 3060281,
        [5] = 3060282,
        [6] = 3060283,
    }

}
--弹框任务限制
TaskId = 1121--新手任务结束
ZuoqiTask = 1046--坐骑弹框
StrenTask = 1052--强化弹框
--进阶道具弹框任务限制
AdvProsTask = {
    [221031001] = 1086,--升星弹框任务限制
}

RiseProTipJie = 3--获得进阶丹可提示阶数
PickUseTime = 3--拾取宝箱时间,采集时间（副本场景）
CollectTime = 2 --采集进度条时间
TipsTime = 4 --单批飘字维持时间
ItemTipsTime = 5--单批飘道具维持时间
HorseTime = 2--跑马灯移动时间（速度）
BossDistance = 100--boss距离
PickDistance = 60--宝物拾取距离
StatuePosX = 255--城主雕像宠物偏移X轴
StatuePosY = 50--城主雕像宠物偏移Y轴
FubenTipLv1 = 60--副本提示等级（经验等）
FubenTipLv2 = 70--副本提示等级（进阶等）
EquipTipTime = 10--装备提示时间
SkinTipTime = 30--外观提示时间
AdvanceTipTime = 30--进阶提示界面时间
QuickUseTime = 30--快捷使用道具提示界面时间
PlayerHpTipTime = 10--玩家血条弹窗维持时间
BossTiredTipTime = 20--boss疲劳提示倒计时
HpAdvTime = 0.15
GemMaxLv = 15--宝石的最大等级
ProsRareColor = 5--品质大于等于这个的道具都是稀有
BloodBggTipLv = 65--血包购买提示等级
BossDeleyTime1 = 0.04
BossDeleyTime2 = 0.02
RoleDeleyTime1 = 0.06
RoleDeleyTime2 = 0.03
--外观类型
-- id 1 衣服 ，2 武器 3仙羽 4.坐骑 ,5 神兵 ， 6 法宝
--7 仙器 8 伙伴 9 伙伴仙羽 10 伙伴神兵 11 伙伴法宝 12伙伴仙器
-- 13.称号 14.修仙称号
Skins = {
    clothes = 1,--外观
    wuqi = 2,
    xianyu = 3,
    zuoqi = 4,
    shenbing = 5,
    fabao = 6,
    xianqi = 7,
    huoban = 8,
    huobanxianyu = 9,
    huobanshenbing = 10,
    huobanfabao = 11,
    huobanxianqi = 12,
    title = 13,--称号
    activeTitle = 14,--修仙活跃称号
    huobanteshu = 15,--特殊伙伴皮肤
    jiansheng = 16,--剑神皮肤id
    newpet = 17,--宠物系统皮肤
    qilinbi = 18,--麒麟臂
    halo = 19,--光环
    xiantong = 20,--仙童
    hunjie = 21,--婚戒
    fsz = 22 ,--飞升等级
    headwear = 23, -- 头饰
    mianju = 24, -- 面具
    qibing = 25,     -- 奇兵
}

--模型放大背数
SkinsScale = {
    --[3040301] = 110, --指定模型ID
    [Skins.zuoqi] = 130,--4.坐骑
    [Skins.xianyu] = 200, --3仙羽
    [Skins.wuqi] = 220, --武器
    [Skins.huoban] = 180, --伙伴
    [Skins.newpet] = 180, --宠物
}
--固定显示模型ID
GuDingmodel = {
    [1] = 3010999,--仙羽
    [2] = 3050999,--伙伴黑影
    [3] = 3020101,--武器
    [4] = 3050101,--伙伴
    [5] = "3010999_yd" ,--黑影仙羽
    [6] = 4041401, --男面具模型
    [7] = 4041402, --女面具模型
}

Team = {
    normalType = 1,--来自别人的申请
    capType = 2,--来自别人的邀请
    maxNum = 3,--队伍最大人数

    fubenType1 = 1,--可打开查看或者退出队伍但不可以组队
    fubenType2 = 2,--可以打开组队但不可以退队
    fubenType3 = 3,--什么都可以
}

PassLimit = 999--关卡数上限（针对场景不同的战役）
--副本类型
Fuben = {
    advaned = 211001,--进阶
    tower = 209001,--爬塔
    copper = 203001,--铜钱
    vip = 210000,--vip
    exp = 205001,--经验
    plot = 208001,--剧情
    gang = 207001,--帮派
    level = 212001,--练级谷
    juqing = 218001,--特殊剧情副本
    kuafuteam = 222001,--跨服组队副本
    marry = 223001,--情缘副本
    dujie = 224001,--渡劫副本
    kuafuwar = 225001,--跨服三界争霸跨服
    xianyulingta = 231001,--仙域灵塔
    mjxl = 233001,--秘境修炼
    hjzy = 234001,--幻境镇妖
    jianshengshouhu = 232001 , --剑神守护
    mainTask = 237001,--主线任务副本
    home = 236001,--家园
    wedding = 238001,--婚宴场景
    zhixianTask = 239001,--支线副本
    dayTask = 240001,--支线副本
    beach = 242001,--魅力沙滩
    runetower = 248001,--符文塔
    collect = 263001,--天晶洞窟（采集探宝）
    keju = 276001,--科举
    crosskeju = 277001,--科举（跨服）
    yjts = 278001,--遗迹探索
    ydts = 279001,--元旦秘境探索01
    sxsl = 280001,--生肖试炼01
}

ArenaScene = 214001--竞技场
HuangLingScene = 217001--皇陵之战
WenDingScene = 219001--问鼎之战
GangWarScene = 220000--仙盟战
XianMoScene = 226001--仙魔战
AwakenScene = 227001--剑神殿
XdzzScene = 241001--雪人
LanternScene = 247001--元宵
DiWangScene = 259001--帝王将相战斗场景
YiJiScene = 278001--遗迹探索战斗场景
WJSScene = 273001--降妖除魔1层
--boss类型
BossScene = {
    personal = 213001,--个人boss
    elite = 215001,--精英boss
    world = 216001,--世界boss
    kuafuelite = 221001,--跨服精英boss
    xianzun = 228001,--仙尊boss
    bosshome = 229001,--boss之家
    xianyuBoss = 235001,--仙域禁地
    kuafuworld = 244001,--宠物岛
    kfpet = 255001,--跨服宠物岛
    kuafuXianyu = 252001,--丛林遗迹
    kuafuXianyu2 = 254001,--丛林遗迹2
    sgsj = 256001,--上古神迹
    kfsgsj = 260002,--跨服上古神迹
    wxsd = 257001,--五行神殿
    tgxj = 274001,--太古玄境
}
--每一个章节的关卡数
FuebenLevelNum = {
    exp = 5,--经验副本的
    plot = 3,
    tower = 5,
    advaned = 3,
}

--背包类型
Pack = {
    packGridNum = 56,--背包未开启的格子数
    iconNum  = 16,--每一页指定的icon
    ware = 100000,--仓库索引
    pack = 200000,--背包索引
    equip = 300000,--已穿戴装备
    limit = 400000,--临时背包
    JianLing = 600000,--剑灵
    gang = 900000,--仙盟仓库
    -- equipawaken = 500000,--剑神已穿戴装备
    equipxian = 700000,--仙装备
    shengYinPack = 1000000,--圣印背包
    shengYinEquip = 1100000,--装备圣印
    shengZhuangPack = 1200000,--圣装背包
    shengZhuangEquip = 500000, --圣装装备
    elementPack = 1300000,--元素背包
    elementEquip = 1400000,--装备八门元素
    dihun = 1500000,--帝魂背包
    shengXiao = 1600000,--生肖背包


    equipIndex = 1,--
    shopIndex = 2,
    wareIndex = 3,--打开仓库的标记
    splitIndex = 4,--打开分解的标记
    gangWareIndex = 5,--打开仙盟仓库标记

    prosType = 2,--消耗品大类
    equipType = 1,--装备大类
    gemType = 3,--宝石大类
    redBagType = 4,--红包类
    equipawkenType = 5,--剑神装备大类
    equippetType = 6,--宠物装备类
    runeType = 7,--符文
    wuxing = 8,--五行装备
    xianzhuang = 9,--仙装备
    shenshouEquipType = 11,--神兽装备
    shengYinType = 12,--圣印
    elementType = 13,--元素
    dihunType = 14,--帝魂
    shengXiaoType = 15,--生肖

    color = 4,--要播放特效的道具以上星级
}
--背包道具小类
Pros = {
    chest = 207,--宝箱类型
    ordinary = 1,--普通
    gift = 2,--礼包
    material = 3,--材料
    skillbook = 4,--技能书
    money = 5,--金钱
    resnumerical = 6,--数值资源
    scenechest = 7,--场景宝箱
    advanced = 8,--进阶丹
    quickuse = 9,--快捷使用道具
    squickuse = 10,--特殊快捷使用道具（成长丹）
    neidanPros = 12,--内丹
    bossRefreshCard = 14,--BOSS刷新卡
    promote = 206,--升阶丹
}

--金钱
MoneyType = {
    gold = 1,--元宝
    bindGold = 2,--绑定元宝
    copper = 3,--铜钱
    bindCopper = 4,--绑定铜钱
    gx = 5, --帮派贡献
    ry = 6,--荣誉
    gongxun = 7,--功勋
    pt = 8,--爬塔
    ckl = 9,--仓库令牌
    sw = 10 ,-- 声望
    wm = 11 ,-- 威名
    home = 12,--家园币
    ylxw = 13 ,
    lj = 14,--灵核结晶
    syjh = 15,--圣印精华
    ysjh = 16,--元素精华
    dh1 = 17,--帝魂强化一
    dh2 = 18,--帝魂强化二
    dh3 = 19,--帝魂强化三
    dh4 = 20,--帝魂强化四
    sxss = 21, --生肖神石
}
--购买金钱类型
BuyMoneyType = {
    [1] = {MoneyType.gold},--只消耗元宝
    [2] = {MoneyType.bindGold},--只消耗元宝
    [3] = {MoneyType.bindGold,MoneyType.gold},--消耗元宝或非绑定元宝
    [4] = {MoneyType.bindGold,MoneyType.gold},--消耗元宝和非绑定元宝
    [5] = {MoneyType.bindCopper},--只消耗铜钱
    [6] = {MoneyType.bindCopper},--只消耗绑定铜钱
    [7] = {MoneyType.bindCopper},--消耗铜钱或非绑定铜钱
    [8] = {MoneyType.bindCopper},--消耗铜钱和非绑定铜钱
    [9] = {MoneyType.ry},--只消耗元宝
    [10] = {MoneyType.pt},--只消耗元宝
    [11] = {MoneyType.gongxun},--只消耗元宝
    --[14] = {MoneyType.lj},-- 灵核结晶
}

MoneyPro = {
    [221051001] = MoneyType.gold,
    [221051002] = MoneyType.bindGold,
    [221051003] = MoneyType.copper,
    [221051004] = MoneyType.bindCopper,
    [221051006] = MoneyType.gx,
    [221051005] = MoneyType.ry,
    [221051010] = MoneyType.gongxun,
    [221051007] = MoneyType.pt,
    [221051012] = MoneyType.ckl,
    [221051014] = MoneyType.sw,
    [221041727] = MoneyType.wm,
    [221042608] = MoneyType.ylxw,
}

MoneyPro2 = {
    [MoneyType.gold] = 221051001,
    [MoneyType.bindGold] = 221051002,
    [MoneyType.copper] = 221051003,
    [MoneyType.bindCopper] = 221051004,
    [MoneyType.gx] = 221051006,
    [MoneyType.ry] = 221051005,
    [MoneyType.gongxun] = 221051010, --弃用的
    [MoneyType.pt] = 221051007,
    [MoneyType.ckl] = 221051012,
    [MoneyType.sw] = 221051014,
    [MoneyType.wm] = 221041727,
    [MoneyType.home] = 221051015,
}

--购买类型对应消耗的
MoneyBuy = {
    [1] = MoneyType.gold,
    [2] = MoneyType.bindGold,
    [5] = MoneyType.copper,
    [6] = MoneyType.bindCopper,
    [7] = MoneyType.gongxun,
}
--mid
PackMid = {
    xiuwei = 221061003,--修为
    exp = 221061001, --经验
    gold = 221051001,--元宝
    bindGold = 221051002,
    copper = 221051003,
    bindCopper = 221051004,
    huobanexp = 221051002,--伙伴经验道具
    feixie = 221011002,--小飞泻
    bangpaiexp = 221051009,
    bangpaigx = 221051006,
    zuoqi = 221041040 ,--坐骑飞升丹
    xianyu = 221041041,--仙羽升阶丹
    shengbing = 221041042,--神兵升阶丹
    xianqi = 221041043,--仙器升阶丹
    fabao = 221041044,--法宝升阶丹
    lingyu = 221041046,--灵羽升阶丹
    lingbing = 221041047,--灵兵升阶丹
    lingqi = 221041048,--灵器升阶丹
    lingbao = 221041049,--灵宝升阶丹
    lingtong = 221011026,--灵童经验丹 中
    lingtong1 = 221011027,--灵童经验丹 低
    lingtong2 = 221011028,--灵童经验丹 高
    hua3 = 221041703,--3级花
    hua4 = 221041704,--3级花
    zhuxinshijiezi = 221042076,--戒指铸星晶石
    zhuxinshishouzuo = 221042077,--手镯铸星晶石

    zuoqi1 = 221041754,--坐骑高级进阶丹
    xianyu1 = 221041755,--仙羽高级进阶丹
    shengbing1 = 221041756,
    xianqi1 = 221041757 ,--仙器高级进阶丹
    fabao1 = 221041758,--法宝高级进阶丹
    lingyu1 = 221041759,--灵羽高级进阶丹
    lingbing1 = 221041760,--灵兵高级进阶丹
    lingqi1 = 221041761,--灵器高级进阶丹
    lingbao1 = 221041762,--灵宝高级进阶丹
    zuoqi2 = 221041763,--坐骑高级进阶丹
    xianyu2 =  221041764,--仙羽高级进阶丹
    shengbing2 = 221041765,--神兵高级进阶丹
    xianqi2 = 221041766,--仙器高级进阶丹
    fabao2 = 221041767,--法宝高级进阶丹
    lingyu2 = 221041768,--灵羽高级进阶丹
    lingbing2 = 221041769,--灵兵高级进阶丹
    lingqi2 = 221041770,--灵器高级进阶丹
    lingbao2 = 221041771,--灵宝高级进阶丹

    qlb = 221042811,--普通
    qlb1 = 221042812,--7阶
    qlb2 = 221042813,--10阶
    qlb3 = 221042817,--飞升

    zuoqi3 = 221042736,--坐骑高级进阶丹
    xianyu3 =  221042737,--仙羽高级进阶丹
    shengbing3 = 221042738,--神兵高级进阶丹
    xianqi3 = 221042739,--仙器高级进阶丹
    fabao3 = 221042740,--法宝高级进阶丹
    lingyu3 = 221042741,--灵羽高级进阶丹
    lingbing3 = 221042742,--灵兵高级进阶丹
    lingqi3 = 221042743,--灵器高级进阶丹
    lingbao3 = 221042744,--灵宝高级进阶丹

    xiaohuangya = 221042160,--小黄鸭
    feizhao = 221042161,-- 肥皂

    bianxingka = 221041799,--变性卡
    nianshou = 221042301,--年兽卡


    xiantong_nan = 221042929,--仙童男
    xiantong_nv = 221042930,--仙童女
}

BuffSysId = {
    jump = 6999901,--跳跃cdbuff
}
--宠物技能对应
SkillSysId = {
    petskill = 50301
}

--男女模型
RoleSexModel = {
    [1] = {id = 3010101,angle = 150},--id,初始角度
    [2] = {id = 3010201,angle = 160},
}
--创号界面男女模型
RoleSexMode2 = {
    [1] = 3010997,
    [2] = 3010998,
}

--聊天系统
ChatType = {
    phizNum = 35,--表情数目
    history = 20,--聊天历史存量
    chatNum = 10,--主界面聊天可存储数目
    systemChannelNum = 30,--系统频道消息数目
    worldChannelNum = 40,--世界频道+附近频道消息数目
    gangChannelNum = 30,--仙盟频道消息数目
    teamChannelNum = 30,--队伍频道消息数目
    friendChannelNum = 20,--好友频道聊天数目
    priveteChannelNum = 50,--私聊频道总消息数目
    degree = 0.8,--相似度
    degreeNum = 2,--相似度大于几条不发给别的玩家看
    degreeLv = 100,--多少级以上不匹配了
    voice = 0,
    system = 1,--系统
    world = 2,--世界
    horn = 3,--喇叭
    near = 4,--附近
    private = 5,--私聊
    gang = 6,--幫派
    gangRecruit = 7,--帮派招聘
    ganghelp = 8,--帮派求助
    horseLamp = 9,--跑马灯
    team = 10,--队伍
    friend = 11,--好友
    boss = 12,--boss广播
    kuafueTeam = 14,--跨服邀请入队
    kuafuBoss = 15,--跨服精英boss
    sjzbSepc = 17,--三界争霸广播
    sjzbBoss = 18,--三界争霸boss刷新广播
    sjzbCar = 19,--三界争霸护送高级镖车
    gangHd = 20,--仙盟互动
    sjzbBossDead = 21,--三界争霸boss死亡广播
    worldBossSystem = 22,--世界boss仙盟招募
    xmshDice = 23,--仙盟圣火骰子
    fubenTeam = 24,--副本组队公告
    xmFlame = 25,--仙盟圣火添柴系统提示
    gangWarehouse = 26,--帮派仓库存取类型
    kuafuSystem = 27,--跨服系统
    jiyiDanMu = 28,--记忆饺宴(弹幕)
}
--一些
SHUZI = {
    teamfuben = 150,
}

--解析后的超链接关键字识别
ChatHerts = {}
ChatHerts.PROINFOHERT = "@"--道具查看
ChatHerts.PLAYINFOHERT = "@@"--查看玩家信息
ChatHerts.GANGHERT = "*"--仙盟盟主喊话
ChatHerts.GANGHELPHERT = "="--仙盟求助
ChatHerts.POSHERT = "+"--坐标
ChatHerts.KUAFUTEAM = "-"--跨服组队
ChatHerts.KUASEPC = "%"--三界争霸
ChatHerts.SYSTEMPRO = "|"--系统广播的道具查看
ChatHerts.SYSTEMTEAM = "_"--系统广播的副本组队公告
ChatHerts.SYSTEWORLDBOSS = ","--世界boss仙盟招募
ChatHerts.PETHERT = "/msg/"
ChatHerts.PETHERTCHAT = "pet"
--坐骑伙伴系统充值跳转常量
--   键值对应开服天数，变量值对应模块索引index
SkipType = {
    [1] = 0,     --坐骑
    [2] = 3,     --仙羽      index 3
    [3] = 1,     --神兵      index 1
    [4] = 4,     --仙器      index 4
    [5] = 2,     --法宝      index 2
    [6] = {11,12},    --伙伴灵羽  index 11 伙伴灵兵  index 12
    [7] = {13,14},    --伙伴灵宝  index 13 伙伴灵器  index 14
}


--颜色设置
TextColors = {
    [0] = "#FFFFFF",
    [1] = "#83f3ff",--浅蓝
    [2] = "#acdee7",--淡蓝
    [3] = "#f7b71e",--黄
    [4] = "#5fe03d",--绿
    [5] = "#f7fafa",
    [6] = "#532226",--棕
    [7] = "#0b8109",--绿
    [8] = "#444034",--灰
    [9] = "#5D6E7B",--灰
    [10] = "#7df130",--绿
    [11] = "#25180c",--黑
    [12] = "#a2501e",--棕
    [13] = "#612d0e",--棕
    [14] = "#da1a27",--红
    [15] = "#ba03fe",--紫
    [16] = "#d2d2d2",
    [17] = "#38e2f3",--亮蓝
    [18] = "#da2d1c",--红
    [19] = "#E2AAAF",--淡粉
    [20] = "#33FF33",--绿
    [21] = "#00FF00",--绿
    [22] = "#FF9900",--橙
    [23] = "#FF66CC",--粉
    [24] = "#33CCFF",--淡蓝
    [25] = "#55F13F",
    [26] = "#FFEE2C",
    [27] = "#FFFFFF",
    [28] = "#ffdf5d",--shi黄
    [29] = "#45f05b",--浅绿

}
--品质颜色1
Quality1 = {
    [1] = "#86827e",--白
    [2] = "#15a100",--绿
    [3] = "#118fee",--蓝
    [4] = "#c227bd",--紫
    [5] = "#e76a20",--橙
    [6] = "#db2c2c",--红
    [7] = "#ff00ea",--粉
}

--品质颜色2
Quality2 = {
    [1] = "#e3eff1",--白
    [2] = "#55fe3f",--绿
    [3] = "#3bbeff",--蓝
    [4] = "#e922e3",--紫
    [5] = "#f47f3a",--橙
    [6] = "#db2c2c",--红
    [7] = "#ff00ea",--粉
}
--品质颜色3(只为武炼符文品质色)
Quality3 = {
    [1] = "#FFFFFF",--白
    [2] = "#19b002",--绿
    [3] = "#3bbeff",--蓝
    [4] = "#f321ed",--紫
    [5] = "#f47f3a",--橙
    [6] = "#fc3737",--红
    [7] = "#ff00ea",--粉
}
--极品属性顏色
QualityAtti = {
    [1] = "#0a5791",--蓝
    [3] = "#6a0891",--紫
    [4] = "#db2c2c",--红
    [6] = "#db2c2c",--红
    [5] = "#f1d863",--金
}

--UI资源路径"ui://"  变量：右键资源复制URl    注释：右键复制名称
UIItemRes = UIItemUrl or {}
UIItemRes.gonggong01 = "ui://_imgfonts/gonggongsucai_139"
UIItemRes.beibao_001 = "ui://zas42vfpyezy1d" --"pack" , "baibao_001"
UIItemRes.moneyIcons = {
    [MoneyType.gold] = "ui://zacz9sn2bmp21m",--"_icons" , "gonggongsucai_103"
    [MoneyType.bindGold] = "ui://_icons/gonggongsucai_108",--"_icons" , "gonggongsucai_108"
    [MoneyType.copper] = "ui://zacz9sn2bmp21k",--"_icons" , "gonggongsucai_109"
    [MoneyType.bindCopper] = "ui://zacz9sn2bmp21j",--"_icons" , "gonggongsucai_110"
    [MoneyType.ry] = "ui://zacz9sn2muh0sr",--"_icons" , "jingjichang_012" 荣誉
    [MoneyType.pt] = "ui://zacz9sn2muh0ss",--爬塔 （历练）
    [MoneyType.gongxun] = "ui://zacz9sn2muh0st",--功勋
    [MoneyType.wm] = "ui://zacz9sn2a8pjud",--威名(战功)
    [MoneyType.sw] = "ui://zacz9sn2a8pjue",--声望
    [MoneyType.gx] = "ui://zacz9sn2bmp21j",--"_icons" , "gonggongsucai_110"
    [MoneyType.ckl] = "ui://zacz9sn2q943t0",--仓库令
    [MoneyType.home] = "ui://zacz9sn2rtxdy4",--EVE 家园币
}
--资源大图
UIItemRes.moneyIcons2 = {
    [MoneyType.gold] = "221051001",--元宝
    [MoneyType.bindGold] = "221051002",--绑定元宝
    [MoneyType.copper] = "221051003",--铜钱
    [MoneyType.bindCopper] = "221051004",--绑定铜钱
    [MoneyType.ry] = "221051005",--荣誉
    [MoneyType.pt] = "221051007",--爬塔 （历练）
    [MoneyType.gongxun] = "221051010",--功勋
    [MoneyType.wm] = "221041727",--威名(战功)
    [MoneyType.sw] = "221051014",--声望
    [MoneyType.gx] = "221051003",--"_icons" , "gonggongsucai_110"
    [MoneyType.ckl] = "221051003",--仓库令
}
UIItemRes.beibaokuang = {
    "ui://zacz9sn2slpij",--品质框1--"_icons" , "beibaokuang_001"
    "ui://zacz9sn2slpik",--品质框2--"_icons" , "beibaokuang_002"
    "ui://zacz9sn2slpil",--品质框3--"_icons" , "beibaokuang_003"
    "ui://zacz9sn2slpim",--品质框4--"_icons" , "beibaokuang_004"
    "ui://zacz9sn2slpin"--品质框5--"_icons" , "beibaokuang_005"
}
--login
UIItemRes.denlufuwuqi_016 = "ui://zoutn1bxn0ow2u" --"login","denlufuwuqi_016" --背景
UIItemRes.denlufuwuqi_statue_img = {
    "ui://z88qwbpcis3h9",--"login","denlufuwuqi_010"--绿色的圆点
    "ui://z88qwbpcis3ha",--"login","denlufuwuqi_009"--红色的圆点
    "ui://z88qwbpcsomb1k",--"login","denlufuwuqi_020"--灰色的圆点
}
UIItemRes.denlufuwuqi_statue_font = {
    "ui://z88qwbpcg2lg1e",--"login","denlufuwuqi_007"--新服
    "ui://z88qwbpcg2lg1h",--"login","denlufuwuqi_006"--合服
}
--createrole
UIItemRes.chuangjianjuese_014 = "ui://zoutn1bxm6es2q" --"createrole","chuangjianjuese_014" --背景
UIItemRes.chuangjianjuese_015 = {
    [1] = "ui://zoutn1bxit9f26",    --剑仙
    [2] = "ui://zoutn1bxit9f1l",    --剑姬
}
UIItemRes.chuangjianjuese_016 = {
    [1] = "ui://zoutn1bxit9f29",    --剑仙职业描述
    [2] = "ui://zoutn1bxit9f28",    --剑姬职业描述
}


--main
UIItemRes.maintaskinfo = {
    [1] = "ui://zzo0ozilier9jug8",--"main","zhujiemian_048" 主线
    [2] = "ui://main/zhujiemian_215",--"main","zhujiemian_038" 日环
    [3] = "ui://zzo0ozilier9jug6",--"main","zhujiemian_038" 直线
    [4] = "ui://zzo0ozilier9jug6",--"main","zhujiemian_038" 日常
    [5] = "ui://zzo0ozilier9jug7",--"main","zhujiemian_038" 帮派
    [6] = "ui://zzo0ozilier9jug5",--商户
    [7] = "ui://zzo0ozilm9mrjuec",--"main" , "lianjigu_009"练级谷
}
UIItemRes.main01 = {
    [PKState.peace] = "zhujiemian_053",--"main","zhujiemian_053" 和
    [PKState.kill] = "zhujiemian_051",--"main","zhujiemian_051" 杀
    [PKState.team] = "zhujiemian_052",--"main","zhujiemian_051" 仙
    [PKState.server] = "zhujiemian_054",--"main","zhujiemian_054" 跨
    [PKState.camp] = "zhujiemian_052",--"main","zhujiemian_054" 跨
}
--任务
UIItemRes.main02 = {
    "ui://main/zhujiemian_213",
    "ui://main/zhujiemian_181",
}
UIItemRes.main03 = {
    "ui://main/zhujiemian_129",--男"main" , "zhujiemian_129"
    "ui://main/zhujiemian_036",--女"main" , "zhujiemian_036"
}

UIItemRes.main04 = {
    "ui://zzo0ozilier9jug4",--音效开"main" , "zhujiemian_032"
    "ui://zzo0ozilier9jug3",--音效关"main" , "zhujiemian_141"
}
UIItemRes.main05 = {
    [0] = "ui://zzo0ozilp4e7jud7",--无网络"main" , "zhujiemian_164"
    [1] = "ui://zzo0ozilp4e7jud6",--3/4G"main" , "zhujiemian_163"
    [2] = "ui://zzo0oziligzz7m",--wifi"main" , "zhujiemian_039"
}
--屏蔽眼睛
UIItemRes.main06 = {
    "ui://zzo0ozilier9jug1",--"main" , "zhujiemian_045"--开
    "ui://zzo0ozilier9jug2",--"main" , "zhujiemian_140"--屏蔽
}
--练级谷
UIItemRes.main07 = {
    "ui://main/lianjigu_010",
    "ui://main/lianjigu_011",
}
UIItemRes.chatType = {
    [ChatType.system] = "ui://zaf8qqa7fzar1d",--系统--"_other" , "liaotian_042"
    [ChatType.world] = "ui://zaf8qqa7fzar1a",--世界--"_other" , "liaotian_030"
    [ChatType.horn] = "ui://zaf8qqa7fzar1a",--喇叭--"_other" , "liaotian_030"
    [ChatType.near] = "ui://zaf8qqa7fzar19",--附近--"_other" , "liaotian_027"
    [ChatType.private] = "ui://zaf8qqa7fzar1c",--私人--"_other" , "liaotian_041"
    [ChatType.gang] = "ui://zaf8qqa7fzar1b",--帮派--"_other" , "liaotian_034"
    [ChatType.gangRecruit] = "ui://zaf8qqa7fzar1a",--帮派招聘--"_other" , "liaotian_030"
    [ChatType.ganghelp] = "ui://zaf8qqa7fzar1b",--帮派求助--"_other" , "liaotian_034"
    [ChatType.horseLamp] = "ui://zaf8qqa7fzar1d",--跑马灯--"_other" , "liaotian_042"
    [ChatType.team] = "ui://zaf8qqa7on0f1i",--队伍--"_other" , "liaotian_039"
    [ChatType.friend] = "ui://zaf8qqa7do9s1j",--好友--"_other" , "liaotian_091"
    [ChatType.boss] = "ui://zaf8qqa7fzar1d",--精英boss求助--"_other" , "liaotian_091"
    [ChatType.kuafueTeam] = "ui://zaf8qqa7kztp3e",--跨服邀请入队--"_other" , "liaotian_113"
    [ChatType.kuafuBoss] = "ui://zaf8qqa7kztp3e",--跨服精英boss
    [ChatType.sjzbSepc] = "ui://zaf8qqa7fzar1d",--三界争霸
    [ChatType.sjzbBoss] = "ui://zaf8qqa7fzar1d",--三界争霸boss刷新
    [ChatType.sjzbCar] = "ui://zaf8qqa7fzar1d",--三界争霸护送高级镖车
    [ChatType.gangHd] = "ui://zaf8qqa7fzar1b",--仙盟互动
    [ChatType.sjzbBossDead] = "ui://zaf8qqa7fzar1d",--三界争霸boss死亡
    [ChatType.worldBossSystem] = "ui://zaf8qqa7fzar1b",--世界boss仙盟招募
    [ChatType.xmshDice] = "ui://zaf8qqa7fzar1b",--仙盟圣火骰子
    [ChatType.fubenTeam] = "ui://zaf8qqa7fzar1d",--副本组队公告
    [ChatType.xmFlame] = "ui://zaf8qqa7fzar1b",--仙盟圣火添柴
    [ChatType.kuafuSystem] = "ui://zaf8qqa7kztp3e",--跨服邀请入队--"_other" , "liaotian_113"
}
UIItemRes.chatVoice = {
    "ui://kezio0zpgtmj1l",--语音"chat" , "liaotian_001"
    "ui://kezio0zpv10d5w",--键盘"chat" , "liaotian_092"
}

UIItemRes.mailType = {
    "ui://kezio0zpib422w",--"chat" , "liaotian_022"
    "ui://kezio0zpib422z",--"chat" , "youjian_006"
}
--聊天战力前十图
UIItemRes.chatRank = {
    [0] = "",--"chat" , "liaotian_066"战力前十
    [1] = "ui://kezio0zpozqm4s",--"chat" , "liaotian_065"战力第一
    [2] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [3] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [4] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [5] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [6] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [7] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [8] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [9] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
    [10] = "ui://kezio0zpozqm4r",--"chat" , "liaotian_066"战力前十
}
--聊天头像
UIItemRes.chatIcon = {
    "ui://kezio0zpozqm4n",--"chat" , "liaotian_070"--男
    "ui://kezio0zpexc24y",--"chat" , "liaotian_088"--女
}
--聊天显示的特权
UIItemRes.chatPrivilege = {
    [0] = "",--"chat" , "liaotian_067"
    [1] = "ui://kezio0zpozqm4q",--"chat" , "liaotian_067"
    [2] = "ui://kezio0zpozqm4p",--"chat" , "liaotian_068"
    [3] = "ui://kezio0zpozqm4o",--"chat" , "liaotian_069"
}
UIItemRes.chatGang = {
    [4] = "ui://kezio0zpexc250",--"chat" , "liaotian_060"--帮主
    [3] = "ui://kezio0zpexc251",--"chat" , "liaotian_061"--副帮
    [2] = "ui://kezio0zpexc252",--"chat" , "liaotian_061"--长老
    [1] = "ui://kezio0zpexc24z",--"chat" , "liaotian_059"--精英
    [0] = "",--普通成员
}

UIItemRes.chatSex = {
    [1] = "ui://chat/liaotian_064",--男
    [2] = "ui://chat/liaotian_063",--女
}
--魅力图章
UIItemRes.meili = {
    [1] = "ui://friend/meili_013",--魅力--"friend" , "meili_002"
    [2] = "ui://friend/meili_014",--魅力--"friend" , "meili_002"
    [3] = "ui://friend/meili_015",--魅力--"friend" , "meili_002"
    [4] = "ui://friend/meili_016",--魅力--"friend" , "meili_002"
    [5] = "ui://friend/meili_017",--魅力--"friend" , "meili_002"
    [6] = "ui://friend/meili_018",--魅力--"friend" , "meili_002"
    [7] = "ui://friend/meili_019",--魅力--"friend" , "meili_002"
    [8] = "ui://friend/meili_020",--魅力--"friend" , "meili_002"
    [9] = "ui://friend/meili_021",--魅力--"friend" , "meili_002"
    [10]= "ui://friend/meili_022",--魅力--"friend" , "meili_002"
}
--阶数
UIItemRes.jieshu = {
    [1] = "ui://zpttr8iqcqoh9",----"_imgfonts" , "meili_002"
    [2] = "ui://zpttr8iqn9s0d",----"_imgfonts" , "meili_002"
    [3] = "ui://zpttr8iqn9s0c",----"_imgfonts" , "meili_002"
    [4] = "ui://zpttr8iqn9s0b",----"_imgfonts" , "meili_002"
    [5] = "ui://zpttr8iqn9s0a",----"_imgfonts" , "meili_002"
    [6] = "ui://zpttr8iqn9s0j",----"_imgfonts" , "meili_002"
    [7] = "ui://zpttr8iqn9s0i",----"_imgfonts" , "meili_002"
    [8] = "ui://zpttr8iqn9s0h",----"_imgfonts" , "meili_002"
    [9] = "ui://zpttr8iqn9s0g",----"_imgfonts" , "meili_002"
    [10] = "ui://zpttr8iqn9s0f",----"_imgfonts" , "meili_002"
    [11] = "ui://zpttr8iqbnhra53",----"_imgfonts" , "meili_002"
    [12] = "ui://zpttr8iqbnhra54",----"_imgfonts" , "meili_002"
    [13] = "ui://zpttr8iqwl6sa55",----"_imgfonts" , "meili_002"
    [14] = "ui://zpttr8iqdetza56",----"_imgfonts" , "meili_002"
    [15] = "ui://zpttr8iqeojla5f",----"_imgfonts" , "meili_002"
    [16] = "ui://zpttr8iqeojla5g",----"_imgfonts" , "meili_002"
    [17] = "ui://zpttr8iqeojla57",----"_imgfonts" , "meili_002"
    [18] = "ui://zpttr8iqeojla58",----"_imgfonts" , "meili_002"
    [19] = "ui://zpttr8iqeojla59",----"_imgfonts" , "meili_002"
    [20] = "ui://zpttr8iqeojla5a",----"_imgfonts" , "meili_002"
    [21] = "ui://zpttr8iqeojla5b",----"_imgfonts" , "meili_002"
    [22] = "ui://zpttr8iqeojla5c",----"_imgfonts" , "meili_002"
    [23] = "ui://zpttr8iqeojla5d",----"_imgfonts" , "meili_002"
    [24] = "ui://zpttr8iqeojla5e",----"_imgfonts" , "meili_002"
}
--装备部位
UIItemRes.part = {
    [1] = "ui://forging/baoshi_001",
    [2] = "ui://forging/baoshi_002",
    [3] = "ui://forging/baoshi_003",
    [4] = "ui://forging/baoshi_007",
    [5] = "ui://forging/baoshi_005",
    [6] = "ui://forging/baoshi_006",
    [7] = "ui://forging/baoshi_032",
    [8] = "ui://forging/baoshi_009",
    [9] = "ui://forging/baoshi_004",
    [10] = "ui://forging/baoshi_010",
    [11] = "ui://forging/baoshi_008",
    [12] = "ui://forging/baoshi_033",
}
--查看别人玩家的部位图标
UIItemRes.partSee = {
[1] = "ui://see/baoshi_001",
    [2] = "ui://see/baoshi_002",
    [3] = "ui://see/baoshi_003",
    [4] = "ui://see/baoshi_007",
    [5] = "ui://see/baoshi_005",
    [6] = "ui://see/baoshi_006",
    [7] = "ui://see/baoshi_032",
    [8] = "ui://see/baoshi_009",
    [9] = "ui://see/baoshi_004",
    [10] = "ui://see/baoshi_010",
    [11] = "ui://see/baoshi_008",
    [12] = "ui://see/baoshi_033",
}
--套装图
UIItemRes.makeImg = {
    [1] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [2] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [3] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [4] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [5] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [6] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [7] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [8] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [9] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
    [10] = "ui://waudrevmmflz2r",----"juese" , "shizhuangchenghao_006"
}
--打造标题
UIItemRes.makeDekaron = {
    [1] = "wendingzhizhan_039",--"forging" , "wendingzhizhan_039"--打造成功
    [0] = "wendingzhizhan_040",--"forging" , "wendingzhizhan_040"--打造失败
}
--好友
UIItemRes.friend = {
    [1] = "ui://dsowofrrpfjs2e",
    [2] = "ui://dsowofrrpfjs2f",
    [3] = "ui://dsowofrrpfjs2g",
    [4] = "ui://dsowofrrpfjs2i",
    [5] = "ui://dsowofrrpfjs2h"
}
--坐骑
UIItemRes.zuoqi1 = {
    [1] = "ui://gd7hotr5xam63",
    [2] = "ui://gd7hotr5xam63",
    [3] = "ui://gd7hotr5xam63",
    [4] = "ui://gd7hotr5xam63",
    [5] = "ui://gd7hotr5xam63"
}
UIItemRes.zuoqi2 = "ui://gd7hotr5xam6i" --"zuoqi","zuoqi_001"
UIItemRes.zuoqi3 = "ui://gd7hotr5xam64" --"zuoqi","zuoqi_015"

UIItemRes.starFont = "ui://dkp1ae996oh42y"--"forging" , "shengxing_009"
UIItemRes.cameoFont = "ui://dkp1ae996oh42w"--"forging" , "shengxing_007"
UIItemRes.cameoSuit = "ui://dkp1ae996oh42t"--"forging" , "baoshi_026"
UIItemRes.starSuit = "ui://dkp1ae996oh42x"--"forging" , "shengxing_008"
UIItemRes.strengFont = "ui://forging/qianghua_017"
--合成
UIItemRes.fuseIcon = {
    [0] = "ui://forging/hecheng_010",--打造石
    [1] = "ui://forging/hecheng_011",--打造石
    [2] = "ui://forging/hecheng_004",--宝石精华
    [3] = "ui://forging/hecheng_006",--种子
    [4] = "ui://forging/hecheng_012",--诛仙套装石
    [5] = "ui://forging/hecheng_013",--诸神套装石
    [6] = "ui://forging/hecheng_014",--项链护符
    [7] = "ui://forging/hecheng_0015",--戒指手镯
    [8] = "ui://forging/hecheng_0016",--修仙材料
    [9] = "ui://forging/hecheng_0017",--家园种子
    [10] = "ui://forging/hecheng_0018",--2星宠物红
    [11] = "ui://forging/hecheng_0019",--3星宠物红
    [12] = "ui://forging/hecheng_0020",--天外宝箱
    [13] = "ui://forging/hecheng_0021",--神器合成
    [14] = "ui://forging/hecheng_0022",--五行合成
    [16] = "ui://forging/hecheng_0023",--hecheng_0023
    [17] = "ui://forging/hecheng_0024",--时装幻化
    [18] = "ui://forging/hecheng_0025",--飞升仙装
    [19] = "ui://forging/hecheng_0029",--五行圣印
    [20] = "ui://forging/hecheng_0030",--剑神神装
    [21] = "ui://forging/hecheng_0035",--神装合成
    [22] = "ui://forging/hecheng_0036",--神兽神装
    [23] = "ui://forging/hecheng_0037",--三星神兽红装
    [24] = "ui://forging/hecheng_0040",--元素合成
    [25] = "ui://forging/hecheng_0041",--飞升神装
    [26] = "ui://forging/hecheng_0042",--面具合成

}

UIItemRes.kageeIcon = {
    [1001] = "ui://p0ap6e73eofci",--"kagee" , "yingwei_003"鼠肖
    [1002] = "ui://p0ap6e73eofch",--"kagee" , "yingwei_004"牛肖
    [1003] = "ui://p0ap6e73eofcj",--"kagee" , "yingwei_002"虎肖
    [1004] = "ui://p0ap6e73eofcg",--"kagee" , "yingwei_005"兔肖
    [1005] = "ui://p0ap6e73eofcf",--"kagee" , "yingwei_006"龙肖
    [1006] = "ui://p0ap6e73eofce",--"kagee" , "yingwei_007"蛇肖
    [1007] = "ui://p0ap6e73eofcb",--"kagee" , "yingwei_010"马肖
    [1008] = "ui://p0ap6e73eofc9",--"kagee" , "yingwei_012"羊肖
    [1009] = "ui://p0ap6e73eofcd",--"kagee" , "yingwei_008"猴肖
    [1010] = "ui://p0ap6e73eofcc",--"kagee" , "yingwei_009"鸡肖
    [1011] = "ui://p0ap6e73eofca",--"kagee" , "yingwei_011"狗肖
    [1012] = "ui://p0ap6e73eofc8",--"kagee" , "yingwei_013"猪肖

    [1] = "shengxiaobaozang_003",   -- 生肖宝藏背景1
    [2] = "shengxiaobaozang_019",   -- 生肖宝藏背景2
    [3] = "shengxiaobaozang_020",   -- 生肖宝藏背景3
    [4] = "shengxiaobaozang_021",   -- 生肖宝藏背景4
    [5] = "shengxiaobaozang_022",   -- 生肖宝藏背景5
}
UIItemRes.kageeImg = "res/bgs/kagee/"
UIItemRes.activeIcons = "res/bgs/actives/"
--资质丹
UIItemRes.zzd = "ui://gd7hotr5vw101k" ----"zuoqi" , "huobanxianyu_010"
--潜力丹
UIItemRes.qld = "ui://gd7hotr5g0zk1w" ----"zuoqi" , "huobanxianyu_014"
--属性加成
UIItemRes.syjc = "ui://gd7hotr5xam610"----"zuoqi" , "huobanxianyu_014"
--坐骑进阶
UIItemRes.zqjj = "ui://gd7hotr5xam63"----"zuoqi" , "huobanxianyu_014"
--神兵进阶
UIItemRes.sbjj = "ui://gd7hotr5o1py21"----"zuoqi" , "shenbin_003"
--法宝进阶
UIItemRes.fbjj = "ui://gd7hotr5o1py1z"----"zuoqi" , "fabao_001"
--仙羽进阶
UIItemRes.xyjj = "ui://gd7hotr5o1py29"----"zuoqi" , "xianyu_001"
--仙器进阶
UIItemRes.xqjj = "ui://gd7hotr5o1py26"----"zuoqi" , "xianqi_001"
--麒麟臂进阶
UIItemRes.xlbjj =  "ui://zuoqi/qilinbi_002"--bangpai_084----"zuoqi" , "xianqi_001"

UIItemRes.qlbzzd =  "ui://zuoqi/qilinbi_004"

UIItemRes.qlbqld =  "ui://zuoqi/qilinbi_005"
----------------------huoban
UIItemRes.huoban01 = {
    "ui://_imgfonts/huoban_035",  --huoban_035 攻击
    "ui://_imgfonts/huoban_036",  --huoban_036 防御
    "ui://_imgfonts/huoban_037"   --huoban_037 富足
}
UIItemRes.huoban02 = {
    "ui://9o4puo04s5qfl",  --huoban_035 攻击
    "ui://9o4puo04s5qfm",  --huoban_036 防御
    "ui://9o4puo04s5qfn"   --huoban_037 富足
}


--宝箱名字
UIItemRes.bangpai01 = {
    "ui://qto2qq31pe1s2p",--bangpai_084
    "ui://qto2qq31pe1s2o",--bangpai_085
    "ui://qto2qq31pe1s2n",--bangpai_086
    "ui://qto2qq31pe1s2m",--bangpai_087
    "ui://qto2qq31pe1s2l"--bangpai_088

}
--宝箱形象
UIItemRes.bangpai02 = {
    "ui://bangpai/bangpai_104",--bangpai_084
    "ui://bangpai/bangpai_105",--bangpai_085
    "ui://bangpai/bangpai_106",--bangpai_086
    "ui://bangpai/bangpai_107",--bangpai_087
    "ui://bangpai/bangpai_112"--bangpai_088

}

UIItemRes.bangpai03 = "res/bgs/bangpai/xianmengzhengba_017"
UIItemRes.bangpai04 = "res/bgs/bangpai/xianmengzhengba_030"
UIItemRes.bangpai05 = "res/bgs/bangpai/bangpai_157"

UIItemRes.pack01 = {
    "ui://zacz9sn2fr3edu",--"_icons" , "gonggongsucai_115"--限时
    "ui://zacz9sn2fr3edv",--"_icons" , "gonggongsucai_116"--过时
}

UIItemRes.fashionTitle01 = {
    [1] = "ui://waudrevmmflz2w",--"juese" , "shizhuangchenghao_001"
    [2] = "ui://waudrevmsjkj3a",--"juese" , "shizhuangchenghao_016"
    [3] = "ui://waudrevmsjkj39",--"juese" , "shizhuangchenghao_017"
}

UIItemRes.fashionTitle02 = {
    [1] = "ui://waudrevmnr3p3i",--"juese" , "shizhuangchenghao_018"--卸下
    [2] = "ui://waudrevmmflz2q",--"juese" , "shizhuangchenghao_07"--佩戴
}

UIItemRes.alert01 = "ui://alert/shengxing_006"--横箭头
---icons
UIItemRes.icon01 = {
    [MoneyType.gold] = "ui://zacz9sn2lk9f3",
    -- MoneyType.bindGold
    -- MoneyType.copper
    -- MoneyType.bindCopper
    -- MoneyType.gx

}
-----imagefons
UIItemRes.imagefons01 = "ui://_imgfonts/juesexinxishuxin_013" --juesexinxishuxin_013 --确认
UIItemRes.imagefons02 = "ui://_imgfonts/juesexinxishuxin_014" --juesexinxishuxin_014 --取消
UIItemRes.imagefons03 = {
    "ui://zpttr8iqj8uea25",  --huoban_035 攻击
    "ui://zpttr8iqj8uea26",  --huoban_036 防御
    "ui://zpttr8iqj8uea27"   --huoban_037 辅助
}
UIItemRes.imagefons04 = "ui://_imgfonts/huobanxianyu_012"--购买
UIItemRes.imagefons05 = "ui://_imgfonts/bosszhijia_017"--激活仙尊
UIItemRes.imagefons06 = "ui://_share/chongzhivip_043"--前往
UIItemRes.imagefons07 = "ui://_share/bosszhijia_019"--提升vip
---_other
--绿色 的箭头
UIItemRes.other01 = "ui://zaf8qqa7pa7b10" --jineng_017
--NPC头顶问好
UIItemRes.head01 = "ui://49w3z4y5ip1m9" --renwu_001

--副本
UIItemRes.fuben01 = "ui://_imgfonts/patafuben_014"--"fuben" , "patafuben_014"--挑战成功
UIItemRes.fuben02 = "ui://xdze9islfhca31"--"fuben" , "patafuben_016"--挑战失败
UIItemRes.fuben03 = "ui://xdze9islu8ax14"--"fuben" , "tongqianfuben_002"--挑战
UIItemRes.fuben04 = "ui://xdze9islu8ax25"--"fuben" , "jinjiefuben_002"--重置
UIItemRes.fuben05 = "ui://fuben/mijingxiulian_001"--秘境修炼标题
UIItemRes.fuben06 = "ui://fuben/xianyulingta001"--仙域灵塔标题
UIItemRes.fuben07 = "ui://fuben/huanjingzhenyao_011"--幻境镇妖标题
UIItemRes.fuben08 = "ui://_imgfonts/huanjingzhenyao_007"--挑战成功标题
UIItemRes.fuben09 = "ui://_imgfonts/vipfuben_011"--副本扫荡
UIItemRes.fuben10 = "ui://_imgfonts/xianyulingta_007"--扫荡奖励
UIItemRes.fuben11 = "ui://fuben/xianyulingta_010"--双倍奖励
UIItemRes.plotFuben02 = {
    [1] = "ui://xdze9islu8ax1s",--"fuben" , "juqingfuben_004"
    [2] = "ui://xdze9islu8ax1u",--"fuben" , "juqingfuben_002"
}
UIItemRes.towerFuben01 = {
    [1] = "ui://xdze9islfhca2z",--"fuben" , "patafuben_018"
    [2] = "ui://xdze9islfhca2y",--"fuben" , "patafuben_019"
    [3] = "ui://xdze9islfhca2x",--"fuben" , "patafuben_020"
}

UIItemRes.towerFuben03 = {
    [1] = "ui://fuben/patafuben_035",--正常底盘
    [2] = "ui://_others/lingyuangou_022",--特殊底盘
}

UIItemRes.towerFuben04 = {
    [1] = "ui://fuben/patafuben_033",--获得新形象
    [2] = "ui://fuben/patafuben_034",--获得新装备
}

UIItemRes.star01 = {
    [1] = "ui://zacz9sn2k9qj8f",--"_icons" , "beibao_072"
    [2] = "ui://zacz9sn2k9qj8e",--"_icons" , "beibao_073"
    [3] = "ui://zacz9sn2k9qj8d",--"_icons" , "beibao_074"
    [4] = "ui://zacz9sn2k9qj8c",--"_icons" , "beibao_075"
    [5] = "ui://zacz9sn2k9qj8b",--"_icons" , "beibao_076"
    [6] = "ui://zacz9sn2k9qj8a",--"_icons" , "beibao_077"
    [7] = "ui://zacz9sn2k9qj89",--"_icons" , "beibao_078"
    [8] = "ui://zacz9sn2k9qj88",--"_icons" , "beibao_079"
    [9] = "ui://zacz9sn2k9qj87",--"_icons" , "beibao_080"
    [10] = "ui://zacz9sn2k9qj86",--"_icons" , "beibao_081"
}

UIItemRes.fuebenImg = "res/bgs/fuben/"
--铜钱副本背景图
UIItemRes.copperFuben01 = UIItemRes.fuebenImg.."tongqianfuben_001"
-- UIItemRes.vipFuben01 = "ui://xdze9isldu4143"--"fuben" , "vipfuben_005"
UIItemRes.vipFuben02 = {
    [1] = "ui://xdze9isldu4146",--"fuben" , "vipfuben_002"
    [2] = "ui://xdze9islt4vf50",--"fuben" , "vipfuben_006"
}
UIItemRes.advFuben01 = {
    [1] = "ui://xdze9islu8ax22",--"fuben" , "jinjiefuben_005"
    [2] = "ui://xdze9islu8ax20",--"fuben" , "jinjiefuben_007"
    [3] = "ui://xdze9islu8ax1z",--"fuben" , "jinjiefuben_008"
}

UIItemRes.advFuben02 = {
    [1] = UIItemRes.fuebenImg.."jinjiefuben_009",--"fuben" , "jinjiefuben_009"
    [2] = UIItemRes.fuebenImg.."jinjiefuben_010",--"fuben" , "jinjiefuben_010"
    [3] = UIItemRes.fuebenImg.."jinjiefuben_011",--"fuben" , "jinjiefuben_011"
}

-- UIItemRes.advFuben03 = {
--     [1] = "jinjiefuben_003",--首通奖励
--     [2] = "jinjiefuben_020",--通关奖励
-- }

UIItemRes.mjxlBg = UIItemRes.fuebenImg.."mijingxiulian_002"--秘境修炼背景图
UIItemRes.hjzyBg = UIItemRes.fuebenImg.."huanjingzhenyao_015"--幻境镇妖背景图
--爬塔副本背景图
UIItemRes.towerFuben02 = UIItemRes.fuebenImg.."patafuben_032"

UIItemRes.fueben01 = {
    "ui://xdze9islh6su3t",--"fuben" , "zuoqi_010"
    "ui://xdze9islfhca2s",--"fuben" , "patafuben_025"
}
--练级谷背景图
UIItemRes.levelFuben01 = UIItemRes.fuebenImg.."lianjigu_008"

UIItemRes.eliteBoss01 = "bossdating_031"--精英boss结算标题

UIItemRes.gxhd01 = "gonggongsucai_107"--恭喜获得标题

UIItemRes.team01 = "ui://xymgi995g85q9"--创建队伍"team" , "zudui_006"
UIItemRes.team02 = "ui://xymgi995fykr12"--退出队伍"team" , "zudui_013"
UIItemRes.team03 = "ui://team/dujie_001"--已准备
UIItemRes.team04 = "ui://team/dujie_002"--未准备
UIItemRes.team05 = {
    [Team.capType] = "ui://team/huanjingzhenyao_010",--组队邀请
    [Team.normalType] = "ui://team/zudui_027",--组队申请
}
--特权icon
UIItemRes.temp01 = {
    "ui://4ye4b9qgumj815",--白银--"_panels" , "gonggongsucai_042"
    "ui://4ye4b9qgumj82m",--黄金--"_panels" , "gonggongsucai_043"
    "ui://4ye4b9qgumj82l",--钻石--"_panels" , "gonggongsucai_044"
}

UIItemRes.warning01 = "ui://zaf8qqa7o35xm"--感叹号"_others" , "liaotian_021"
--boss血条颜色
UIItemRes.boss01 = {
    "ui://v4pyi3guqgg7v",--"boss" , "Bossdatin_002"
    "ui://v4pyi3guqgg7w",--"boss" , "Bossdatin_003"
    "ui://v4pyi3guqgg7x",--"boss" , "Bossdatin_004"
    "ui://v4pyi3guqgg7y",--"boss" , "Bossdatin_005"
    "ui://v4pyi3guqgg7z",--"boss" , "Bossdatin_006"
}--boss血条颜色
UIItemRes.bossImg = "res/bgs/boss/"
UIItemRes.bossWorld = UIItemRes.bossImg.."bossdating_015"
--道具特效
UIItemRes.effect01 = {
    [4] = "ui://zacz9sn2mi9n98",--道具特效2"_icons" , "MovieClip2"
    [5] = "ui://zacz9sn2mi9n97",--道具特效1"_icons" , "MovieClip1"
}
--加载背景图
UIItemRes.loading01 = "res/bgs/loading/"

--元宝类型logo
UIItemRes.ingotType = {
    [1] = "ui://ih202jfarxz618", --绑定元宝
    [2] = "ui://ih202jfarxz617", --元宝
}

UIItemRes.hook01 = {
    "ui://main/zhujiemian_012",--挂机"main" , "zhujiemian_012"
    "ui://main/zhujiemian_132",--取消挂机"main" , "zhujiemian_132"
    "ui://main/zhujiemian_253",--临时手动"main" , "zhujiemian_253"
}

UIItemRes.huangling01 = "ui://bohk2z5ulebp2q"--皇陵夺宝"zhanchang" , "huanglingzhizhan_008"
UIItemRes.wending01 = "ui://bohk2z5uii6n23"--问鼎奖励"zhanchang" , "wendingzhizhan_007"
UIItemRes.wending02 = "shizhuangchenghao_049"--战旗持有者称号
UIItemRes.zhangchang01 = {
    "ui://bohk2z5uosy32",--"zhanchang" , "jingjichang_024"
    "ui://bohk2z5uosy3q",--"zhanchang" , "jingjichang_025"
    "ui://bohk2z5uosy33",--"zhanchang" , "jingjichang_023"
}
UIItemRes.gangwar01 = "ui://bohk2z5ueknu46"--仙盟奖励"zhanchang" , "wendingzhizhan_007"
UIItemRes.xianmoWar01 = "ui://zhanchang/xianmozhanchang_017"--仙魔奖励"zhanchang" , "wendingzhizhan_007"
UIItemRes.tips01 = {
    [Skins.huoban] = "ui://62dyt40gpvb6a",--"tips" , "youxiajiaotishi_004"
    [Skins.clothes] = "ui://62dyt40gpvb6b",--"tips" , "youxiajiaotishi_005"
    [Skins.title] = "ui://62dyt40gpvb6c",--"tips" , "youxiajiaotishi_006"
    [Skins.wuqi] = "ui://62dyt40gpvb6b",--"tips" , "youxiajiaotishi_005"
}

UIItemRes.download01 = "ui://7qbv4wx4jeqe3"--"download" , "fenbaoxiazai_003"--果断下载
UIItemRes.download02 = "ui://7qbv4wx4ijtsc"--"download" , "fenbaoxiazai_009"暂停
UIItemRes.download03 = "ui://zpttr8iqpa6na1z"--"_imgfonts" , "fulidating_108"领取奖励

UIItemRes.advtip01 = {
    [1001] = "woyaobianqiang_036",--"_icons" , "woyaobianqiang_036"--坐骑
    [1002] = "woyaobianqiang_035",--"_icons" , "woyaobianqiang_035"--仙羽
    [1003] = "woyaobianqiang_043",--"_icons" , "woyaobianqiang_043"--神兵
    [1004] = "woyaobianqiang_037",--"_icons" , "woyaobianqiang_037"--仙器
    [1005] = "woyaobianqiang_038",--"_icons" , "woyaobianqiang_038"--法宝
    [1006] = "woyaobianqiang_031",--"_icons" , "woyaobianqiang_031"--灵童
    [1007] = "woyaobianqiang_039",--"_icons" , "woyaobianqiang_039"--灵羽
    [1008] = "woyaobianqiang_040",--"_icons" , "woyaobianqiang_040"--灵兵
    [1009] = "woyaobianqiang_041",--"_icons" , "woyaobianqiang_041"--灵器
    [1010] = "woyaobianqiang_042",--"_icons" , "woyaobianqiang_042"--灵宝
    [1029] = "woyaobianqiang_046",--"_icons" , "woyaobianqiang_046"--强化
    [1030] = "woyaobianqiang_047",--"_icons" , "woyaobianqiang_047"--升星
    [1031] = "woyaobianqiang_032",--"_icons" , "woyaobianqiang_032"--宝石
    [1062] = "woyaobianqiang_034",--"_icons" , "woyaobianqiang_034"--剑神
}

UIItemRes.playerIcon = {
    "ui://zacz9sn2kkl0tk",--"_icons" , "100"男
    "ui://zacz9sn2kkl0tj",--"_icons" , "100"女
}

UIItemRes.plus01 = "ui://dkp1ae99llxx33"--"forging" , "baoshi_028"+号

UIItemRes.zhanchang = "res/bgs/zhanchang/"

UIItemRes.kuafu = "res/bgs/kuafu/"
--微信二维码图片
UIItemRes.qrcode = "ui://chat/lianxikefu_001"

UIItemRes.marrybg = "res/bgs/marry/jiehun_081"--情缘副本界面背景图

UIItemRes.marryTreeBg = "res/bgs/marry/jiehun_122"--情缘副本界面背景图1
UIItemRes.marryRankBg = "res/bgs/marry/hunlipaihengbang_019"--山盟海誓背景图1
UIItemRes.marryxiantong= "res/bgs/marry/xiantong_007"--情缘副本界面背景图1

UIItemRes.thqg01 = {
    [3] = "tehuiqianggou_008",--"panicbuy", "tehuiqianggou_008"
    [2] = "tehuiqianggou_007",--"panicbuy", "tehuiqianggou_007"
    [1] = "tehuiqianggou_006",--"panicbuy", "tehuiqianggou_006"
}

UIItemRes.lingyuan01 = {
    [1] = "ui://lingyuan/lingyuangou_0010",
    [2] = "ui://lingyuan/lingyuangou_009",
    [3] = "ui://lingyuan/lingyuangou_008",
    [4] = "ui://lingyuan/lingyuangou_007"
}
UIItemRes.lingyuan02 = {
    [1] = "ui://lingyuan/lingyuangou_014",
    [2] = "ui://lingyuan/lingyuangou_013",
    [3] = "ui://lingyuan/lingyuangou_012",
    [4] = "ui://lingyuan/lingyuangou_0011"
}
UIItemRes.rank123 = {
    [1] = "ui://_panels/meili_008",
    [2] = "ui://_panels/meili_009",
    [3] = "ui://_panels/meili_010",
}
UIItemRes.rank123yuan = {
    [1] = "ui://_others/meili_003",
    [2] = "ui://_others/meili_004",
    [3] = "ui://_others/meili_005",
}


UIItemRes.shios01 = "res/bgs/shios/"

UIItemRes.dian01 = "ui://_panels/beibao_058"--点
UIItemRes.dian02 = "ui://_panels/feisheng_044"--点

UIItemRes.home = "res/bgs/home/"

UIItemRes.home1 = {
    [1] = "ui://home/jiayuan_055",
    [2] = "ui://home/jiayuan_056",
    [3] = "ui://home/jiayuan_057",
    [4] = "ui://home/jiayuan_058",
    [5] = "ui://home/jiayuan_059",
    [6] = "ui://home/jiayuan_060",
    [7] = "ui://home/jiayuan_061",
    [8] = "ui://home/jiayuan_062",
}

UIItemRes.home2 = "ui://home/"

UIItemRes.home3 = {
    [1] = "ui://home/jiayuan_057",
    [2] = "ui://home/jiayuan_058",
    [3] = "ui://home/jiayuan_060",
    [4] = "ui://home/jiayuan_062",
}

UIItemRes.xmhd01 = {
    [0] = "",
    [1] = "ui://_imgfonts/xianmengzhengba_020",--胜
    [2] = "",
    -- [2] = "ui://_imgfonts/xianmengzhengba_019",--负
}
UIItemRes.xmhd02 = {
    [1] = "ui://_imgfonts/xianmengzhengba_034",--分配
    [2] = "ui://_imgfonts/xianmengzhengba_013",--已分配
}
--资源点
UIItemRes.xmhd03 = {
    [1] = "ui://_others/xianmengzhengba_040",--蓝色
    [2] = "ui://_others/xianmengzhengba_041",--红色
    [0] = "ui://_others/xianmengzhengba_042",--黄色
}
--阵营屋子
UIItemRes.xmhd04 = {
    [1] = "ui://_others/xianmengzhengba_037",--蓝色
    [2] = "ui://_others/xianmengzhengba_036",--红色
}
--玩家点
UIItemRes.xmhd05 = {
    [1] = "ui://_others/xianmengzhengba_039",--蓝色
    [2] = "ui://_others/xianmengzhengba_038",--红色
}
UIItemRes.xmhd06 = {
    [1] = "ui://_imgfonts/xianmengzhengba_044",--胜利标题
    [2] = "ui://_imgfonts/xianmengzhengba_046",--失败标题
}
UIItemRes.xmhd07 = {
    [1] = "ui://_imgfonts/xianmengzhengba_052",--排名1字
    [2] = "ui://_imgfonts/xianmengzhengba_053",--排名2字
    [3] = "ui://_imgfonts/xianmengzhengba_054",--排名3字
}
UIItemRes.xmhd08 = {
    [1] = "ui://_panels/xianmengzhengba_048",--排名1底图
    [2] = "ui://_panels/xianmengzhengba_049",--排名2底图
    [3] = "ui://_panels/xianmengzhengba_050",--排名3底图
    [0] = "ui://_panels/xianmengzhengba_051",--排名4 - 无限
}
UIItemRes.xmhd09 = "ui://bangpai/xianmengzhengba_022"
UIItemRes.xmhd10 = {
    [0] = "ui://bangpai/xianmengzhengba_031",
    [1] = "ui://bangpai/xianmengzhengba_032",
}
UIItemRes.xmhd11 = {
    "ui://_others/gonggongsucai_102",
    "ui://_panels/xianmengzhengba_015",
}

UIItemRes.map01 = {
    "ui://map/paihangbang_013",--放大
    "ui://map/xianmengzhengba_060",--缩小
}

UIItemRes.week01 = {
    [1] = "ui://weekend/zhoumokuanghuan_009",--抽一次
    [2] = "ui://weekend/zhoumokuanghuan_010",--抽十次
}
UIItemRes.iosMainIossh = "ui://mainios/"
UIItemRes.iosMainIossh01 = {
    [0] = UIItemRes.iosMainIossh.."zhujiemian_039",--无网络"main" , "zhujiemian_164"
    [1] = UIItemRes.iosMainIossh.."zhujiemian_039",--3/4G"main" , "zhujiemian_163"
    [2] = UIItemRes.iosMainIossh.."zhujiemian_039",--wifi"main" , "zhujiemian_039"
}
UIItemRes.iosMainIossh02 = {
    [1] = UIItemRes.iosMainIossh.."zhujiemian_048",--"main","zhujiemian_048" 主线
    [2] = UIItemRes.iosMainIossh.."zhujiemian_038",--"main","zhujiemian_038" 日环
    [3] = UIItemRes.iosMainIossh.."zhujiemian_038",--"main","zhujiemian_038" 直线
    [4] = UIItemRes.iosMainIossh.."zhujiemian_038",--"main","zhujiemian_038" 日常
    [5] = UIItemRes.iosMainIossh.."zhujiemian_038",--"main","zhujiemian_038" 帮派
    [6] = UIItemRes.iosMainIossh.."zhujiemian_197",--商户
    [7] = UIItemRes.iosMainIossh.."lianjigu_009",--"main" , "lianjigu_009"练级谷
}
UIItemRes.iosMainIossh03 = {
    [ChatType.system] = UIItemRes.iosMainIossh.."liaotian_042",--系统--"_other" , "liaotian_042"
    [ChatType.world] = UIItemRes.iosMainIossh.."liaotian_030",--世界--"_other" , "liaotian_030"
    [ChatType.horn] = UIItemRes.iosMainIossh.."liaotian_030",--喇叭--"_other" , "liaotian_030"
    [ChatType.near] = UIItemRes.iosMainIossh.."liaotian_027",--附近--"_other" , "liaotian_027"
    [ChatType.private] = UIItemRes.iosMainIossh.."liaotian_041",--私人--"_other" , "liaotian_041"
    [ChatType.gang] = UIItemRes.iosMainIossh.."liaotian_034",--帮派--"_other" , "liaotian_034"
    [ChatType.gangRecruit] = UIItemRes.iosMainIossh.."liaotian_030",--帮派招聘--"_other" , "liaotian_030"
    [ChatType.ganghelp] = UIItemRes.iosMainIossh.."liaotian_034",--帮派求助--"_other" , "liaotian_034"
    [ChatType.horseLamp] = UIItemRes.iosMainIossh.."liaotian_042",--跑马灯--"_other" , "liaotian_042"
    [ChatType.team] = UIItemRes.iosMainIossh.."liaotian_039",--队伍--"_other" , "liaotian_039"
    [ChatType.friend] = UIItemRes.iosMainIossh.."liaotian_091",--好友--"_other" , "liaotian_091"
    [ChatType.boss] = UIItemRes.iosMainIossh.."liaotian_042",--精英boss求助--"_other" , "liaotian_042"
    [ChatType.kuafueTeam] = UIItemRes.iosMainIossh.."liaotian_042",--跨服邀请入队--"_other" , "liaotian_042"
    [ChatType.kuafuBoss] = UIItemRes.iosMainIossh.."liaotian_042",--跨服精英boss
    [ChatType.sjzbSepc] = UIItemRes.iosMainIossh.."liaotian_042",--三界争霸
    [ChatType.sjzbBoss] = UIItemRes.iosMainIossh.."liaotian_042",--三界争霸boss刷新
    [ChatType.sjzbCar] = UIItemRes.iosMainIossh.."liaotian_042",--三界争霸护送高级镖车
    [ChatType.gangHd] = UIItemRes.iosMainIossh.."liaotian_034",--仙盟互动
    [ChatType.sjzbBossDead] = UIItemRes.iosMainIossh.."liaotian_042",--三界争霸boss死亡
    [ChatType.worldBossSystem] = UIItemRes.iosMainIossh.."liaotian_034",--世界boss仙盟招募
    [ChatType.xmshDice] = UIItemRes.iosMainIossh.."liaotian_034",--仙盟圣火骰子
    [ChatType.fubenTeam] = UIItemRes.iosMainIossh.."liaotian_042",--副本组队公告
    [ChatType.xmFlame] = UIItemRes.iosMainIossh.."liaotian_034",--仙盟圣火添柴
}
UIItemRes.iosMainIossh04 = {
    UIItemRes.iosMainIossh.."zhujiemian_012",--挂机"zhujiemian_012"
    UIItemRes.iosMainIossh.."zhujiemian_012",--取消挂机"zhujiemian_132"
}
UIItemRes.iosMainIossh05 = {
    UIItemRes.iosMainIossh..g_var.packId.."100",--男头像
    UIItemRes.iosMainIossh..g_var.packId.."200",--女头像
}

UIItemRes.pet01 = {
    "ui://pet/chongwu_011",--部位1
    "ui://pet/chongwu_012",--部位2
    "ui://pet/chongwu_013",--部位3
    "ui://pet/chongwu_014",--部位4
    "ui://pet/chongwu_015",--部位5
    "ui://pet/chongwu_016",--部位6
}
UIItemRes.pet02 = {
    "ui://pet/chongwu_047",--部位1
    "ui://pet/chongwu_050",--部位2
    "ui://pet/chongwu_051",--部位3
    "ui://pet/chongwu_054",--部位4
    "ui://pet/chongwu_048",--部位5
    "ui://pet/chongwu_053",--部位6
    "ui://pet/chongwu_052",--部位7
    "ui://pet/chongwu_049",--部位8

}
UIItemRes.pet03 = "ui://pet/chongwu_045"--+
UIItemRes.juese01 = {
    "ui://juese/juesexinxishuxin_001",--
    "ui://juese/chongwu_026",
    "ui://juese/xiantong_031",--
}


--领取奖励的宝箱状态
UIItemRes.boxClose = {
    [1] = "kuafupaiweisai_091",
    [2] = "kuafupaiweisai_090",
    [3] = "sanjiezhengba_026",
}
UIItemRes.boxOpen = {
    [1] = "kuafupaiweisai_094",
    [2] = "kuafupaiweisai_093",
    [3] = "kuafupaiweisai_092",
}

UIItemRes.chunjie01 = "ui://chunjie/chunjiehuodong_001"--

UIItemRes.rune01 = "res/bgs/rune/fuwen_022"--符文寻宝界面背景图
UIItemRes.rune02 = "res/bgs/rune/fuwen_001"--符文塔界面背景图

--城战城池图片
UIItemRes.cityWar = {
    [253001] = "chengzhan_022",
    [253002] = "chengzhan_025",
    [253003] = "chengzhan_023",
    [253004] = "chengzhan_024",
}
--城战城门美术字
UIItemRes.cityWarDoors = {
    [3077600] = "chengzhan_018",
    [3077601] = "chengzhan_019",
    [3077602] = "chengzhan_020",
}
--鲜花榜排名
UIItemRes.flowerRank = {
    [1] = "xianhua_013",
    [2] = "xianhua_014",
    [3] = "xianhua_015",
}
UIItemRes.xunXian = {
    [1] = "ui://xunxian/xunxiantanbao_008",--探索此山
    [2] = "ui://xunxian/xunxiantanbao_007",--全部探索
}
UIItemRes.awaken01 = {
    [1] = "ui://awaken/jianling_020",--探索此山
    [2] = "ui://awaken/jianling_021",--全部探索
    [3] = "ui://awaken/jianling_022",--全部探索
    [4] = "ui://awaken/jianling_023",--全部探索
    [5] = "ui://awaken/jianling_024",--全部探索
}
--恶魔时装
UIItemRes.devilFashion = {
    [1] = "ui://devilfashion/shenyuanjitan_008",--献祭一次
    [2] = "ui://devilfashion/shenyuanjitan_009",--献祭十次
}

UIItemRes.xianlv01 = {
    [1] = "ui://xianlvpk/xianlvpk_003",--确认投注
    [2] = "ui://xianlvpk/xianlvpk_006",--领取奖金
    [3] = "ui://xianlvpk/xianlvpk_010",--前往参赛
    [4] = "ui://xianlvpk/xianlvpk_020",--前往结婚
    [5] = "ui://xianlvpk/xianlvpk_021",--报名参赛
    [6] = "ui://xianlvpk/xianlvpk_032",--参与匹配
}
UIItemRes.xianlv02 = {
    [1] = "ui://xianlvpk/xianlvpk_027",--海选赛
    [2] = "ui://xianlvpk/xianlvpk_041",--争霸赛第一场
    [3] = "ui://xianlvpk/xianlvpk_042",--争霸赛第二场
    [4] = "ui://xianlvpk/xianlvpk_043",--争霸赛第三场
}
UIItemRes.xianlv03 = {
    [1] = "ui://xunxian/xunxiantanbao_010",--白银未开
    [2] = "ui://xunxian/xunxiantanbao_011",--白银已开
    [3] = "ui://xunxian/xunxiantanbao_012",--黄金未开
    [4] = "ui://xunxian/xunxiantanbao_013",--黄金已开
}
--领取奖励的宝箱状态
UIItemRes.xianlvBoxClose = {
    [1] = "ui://xianlvpk/kuafupaiweisai_090",--蓝
    [2] = "ui://xianlvpk/xianlvpk_058",      --紫
    [3] = "ui://xianlvpk/kuafupaiweisai_091",--黄
    [4] = "ui://xianlvpk/xianlvpk_057",      --红

}
UIItemRes.xianlvBoxOpen = {
    [1] = "ui://xianlvpk/kuafupaiweisai_093",--蓝
    [2] = "ui://xianlvpk/xianlvpk_059",      --紫
    [3] = "ui://xianlvpk/kuafupaiweisai_094",--黄
    [4] = "ui://xianlvpk/kuafupaiweisai_092",--红
}
UIItemRes.chongzhiDanBi = {
    [1] = "ui://czdb/chaozhidanbi_007",--88
    [2] = "ui://czdb/chaozhidanbi_008",      --288
    [3] = "ui://czdb/chaozhidanbi_009",--888
    [4] = "ui://czdb/chaozhidanbi_003",--马上领取
    [5] = "ui://czdb/chongzhihuikui003",--前往充值

}
--今日累充
UIItemRes.jinrileichong = {
    [1] = "ui://jinrileichong/chongzhihuikui004",--领取
    [2] = "ui://jinrileichong/jinrileichong_005",--充值
}
--圣印部位
UIItemRes.shengyin = {
    [1] = "ui://awaken/shengyin_002",--剑
    [2] = "ui://awaken/shengyin_028",--甲
    [3] = "ui://awaken/shengyin_029",--腕
    [4] = "ui://awaken/shengyin_030",--腿
    [5] = "ui://awaken/shengyin_031",--履
    [6] = "ui://awaken/shengyin_032",--盔
    [7] = "ui://awaken/shengyin_033",--坠
    [8] = "ui://awaken/shengyin_034",--戒
    [9] = "ui://awaken/shengyin_035",--镯
    [10] = "ui://awaken/shengyin_036",--符
    [11] = "ui://awaken/shengyin_037",--翼
}
UIItemRes.shengyin02 = {
    [1] = "ui://awaken/shengyin_023",--剑
    [2] = "ui://awaken/shengyin_048",--甲
    [3] = "ui://awaken/shengyin_038",--腕
    [4] = "ui://awaken/shengyin_039",--腿
    [5] = "ui://awaken/shengyin_040",--履
    [6] = "ui://awaken/shengyin_041",--盔
    [7] = "ui://awaken/shengyin_042",--坠
    [8] = "ui://awaken/shengyin_043",--戒
    [9] = "ui://awaken/shengyin_044",--镯
    [10] = "ui://awaken/shengyin_045",--符
    [11] = "ui://awaken/shengyin_046",--翼
}

UIItemRes.jieIcon = {
    [1] = "ui://_imgfonts/bamenxitong_038",--1阶
    [2] = "ui://_imgfonts/bamenxitong_039",--2阶
    [3] = "ui://_imgfonts/bamenxitong_040",--3阶
    [4] = "ui://_imgfonts/bamenxitong_041",--4阶
    [5] = "ui://_imgfonts/bamenxitong_042",--5阶
    [6] = "ui://_imgfonts/bamenxitong_043",--6阶
    [7] = "ui://_imgfonts/bamenxitong_044",--7阶
    [8] = "ui://_imgfonts/bamenxitong_045",--8阶
    [9] = "ui://_imgfonts/bamenxitong_046",--9阶
    [10] = "ui://_imgfonts/bamenxitong_047",--10阶
}
UIItemRes.shuiguo = {
    [1] = "ui://fruit/shuiguodaxiaochu_011",--橙
    [2] = "ui://fruit/shuiguodaxiaochu_012",--葡萄
    [3] = "ui://fruit/shuiguodaxiaochu_013",--草莓
    [4] = "ui://fruit/shuiguodaxiaochu_005",--普通宝箱
    [5] = "ui://fruit/shuiguodaxiaochu_006",--稀有宝箱
    [6] = "ui://fruit/shuiguodaxiaochu_007",--珍稀宝箱
    [7] = "ui://fruit/shuiguodaxiaochu_014",--普通水果宝箱
    [8] = "ui://fruit/shuiguodaxiaochu_015",--稀有水果宝箱
    [9] = "ui://fruit/shuiguodaxiaochu_016",--珍稀水果宝箱
}
--双十二
UIItemRes.shaungshier = {
    "ui://shuangshier/tehuishuangshier_006",
    "ui://shuangshier/tehuishuangshier_007",
}

--冬至
UIItemRes.dongzhi = {
    [1] = "ui://dongzhi/dongzhihuodong_028",
    [2] = "ui://dongzhi/dongzhihuodong_029",
    [3] = "ui://dongzhi/dongzhihuodong_030",
}
--面具
UIItemRes.mainju = {
    [1] = "ui://shenqi/mianju_022",
    [2] = "ui://shenqi/mianju_023",
    [3] = "ui://shenqi/mianju_024",
    [4] = "ui://shenqi/mianju_025",
    [5] = "ui://shenqi/mianju_026",
    [6] = "ui://shenqi/mianju_027",
    [7] = "ui://shenqi/mianju_028",
    [8] = "ui://shenqi/mianju_029",
    [9] = "ui://shenqi/mianju_030",
}
--面具标题
UIItemRes.mainjutitle = {
    [1] = "ui://shenqi/mianju_033",
    [2] = "ui://shenqi/mianju_036",
    [3] = "ui://shenqi/mianju_013",
    [4] = "ui://shenqi/mianju_034",
    [5] = "ui://shenqi/mianju_037",
    [6] = "ui://shenqi/mianju_031",
    [7] = "ui://shenqi/mianju_035",
    [8] = "ui://shenqi/mianju_038",
    [9] = "ui://shenqi/mianju_032",
}

--春节2019
UIItemRes.chunjie2019_01 = {
    [1] = "ui://chunjie2019/chunjierihuodong_085",
    [2] = "ui://chunjie2019/chunjierihuodong_086",
    [3] = "ui://chunjie2019/chunjierihuodong_087",
    [4] = "ui://chunjie2019/chunjierihuodong_088",
    [5] = "ui://chunjie2019/chunjierihuodong_089",
    [6] = "ui://chunjie2019/chunjierihuodong_090",
    [7] = "ui://chunjie2019/chunjierihuodong_091",
    [8] = "ui://chunjie2019/chunjierihuodong_092",
}