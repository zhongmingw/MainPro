--[[--
 lua 脚本模块名常量
]]

ViewName = {
    None = "none",
    --A
    Alert1 = "alert.AlertView1",--公用弹窗1 飘个字
    Alert2 = "alert.AlertView2",--公用弹窗2 有按钮
    Alert3 = "alert.AlertView3",--公用弹窗3 恭喜获得弹窗
    Alert4 = "alert.AlertView4",--公用弹窗4 走马灯
    Alert5 = "alert.AlertView5",--公用弹窗5 就中间有个按钮
    Alert6 = "alert.AlertView6",--购买指定道具的窗口
    Alert7 = "alert.AlertView7",--祝福时间减少
    Alert8 = "alert.AlertView8",--有个复选按钮
    Alert9 = "alert.AlertView9",--就中间有个按钮,小弹窗
    Alert11 = "alert.AlertView11",--展示道具列表的弹窗
    Alert12 = "alert.AlertView12",--展示道具列表的弹窗
    Alert13 = "alert.AlertView13",--竞技场扫荡
    Alert14 = "alert.AlertView14",--无道具的提示弹窗
    Alert15 = "alert.AlertView15",--单纯放特效而已
    Alert16 = "alert.AlertView16",--购买界面
    Alert17 = "alert.AlertView17",--有道具的提示弹窗
    Alert18 = "alert.AlertView18",--内丹兑换资源弹窗
    Alert19 = "alert.AlertView19",--仙域灵塔扫荡弹窗
    Alert20 = "alert.AlertView20",--
    Alert21 = "alert.AlertView21",--
    Alert22 = "alert.AlertView22",--
    Alert23 = "alert.AlertView23",--


    AutoFindView = "path.AutoFindView", --自动寻路
    AwardsTipsView = "paiwei.AwardsTipsView", --排位赛目标奖励弹窗tips
    --
    ArenaSaoDown = "zhanchang.ArenaSaoDown", --竞技场扫荡
    ArenaRank = "zhanchang.ArenaRank", --竞技场排行
    ArenaFightView = "zhanchang.ArenaFightView",--竞技场场战斗界面
    ShouShenHurtRank = "zhanchang.ShouShenHurtRank",--神兽圣域伤害排行

    AwakenTipView = "awaken.AwakenTipView",--剑神技能弹窗
    AwakenView = "awaken.AwakenView",            --剑神
    AwakenSkill = "awaken.AwakenSkill", --剑神技能
    JianLingSuitTips = "awaken.JianLingSuitTips", --伙伴升级经验装备选择弹框
    ShengHunView = "awaken.ShengHunView", --圣魂
    ShengYinResolve = "awaken.ShengYinResolve", --圣印分解
    ShengYinStreng = "awaken.ShengYinStreng", --圣印强化
    ShengYinSuitView = "awaken.ShengYinSuitView", --圣印套装
    ShengYinAttTips = "awaken.ShengYinAttTips", --属性加成
    ShengYinRank = "shengyinrank.ShengYinRank", --圣印排行
    ShengYinReturn = "shengyinrank.ShengYinReturn",--圣印抽奖返还

    ShengZhuangShow = "awaken.ShengZhuangShow", --圣裝屬性
    ShenZhuangAttTips = "awaken.ShenZhuangAttTips", --圣裝套装

    JuBaoPen = "jubaopen.JuBaoPen", --聚宝盆

    AwardsCaseView = "zhanchang.AwardsCaseView",--皇陵结束奖励概况
    AdvancedTipView = "tips.AdvancedTipView",--进阶丹提示界面
    AchieveGetItem = "main.AchieveGetItem", --成就弹框
    ActivityHall = "acthall.ActivityHall", --成就弹框
    ActiveRedBag = "activeredbag.ActiveRedBag", --成就弹框
    ActiveTree = "activetree.ActiveTree", --宝树
    ActiveTreePopupView = "activetree.ActiveTreePopupView", --宝树奖励弹窗
    AwakenBossTipView = "boss.AwakenBossTipView",--剑神殿boss信息
    AwakenBuyFag = "boss.AwakenBuyFag",--剑神殿疲劳购买
    JiJiaActiveView = "actjijia.JiJiaActiveView",--机甲来袭活动
    ActWaKuangView = "rechargedraw.ActWaKuangView",--趣味挖矿
    ActWarExpertView = "rechargedraw.ActWarExpertView",--冲战达人
    ActShootingView = "actshooting.ActShootingView",--百发百中
    AroundView = "woyaozhuanzhuan.AroundView",--我要转转
    ActWSJMainView = "actwsj.ActWSJMainView",--万圣节
    AlertWSJView = "actwsj.AlertWSJView",--万圣节

    --B
    BangPaiMain = "bangpai.BangPaiMain" ,--帮会主界面
    BangPaiFind = "bangpai.BangPaiFind",--加入帮派
    BangPaiCreate = "bangpai.BangPaiCreate",--创建
    BagInOut = "bangpai.BagInOut",--存取  兑换
    BagInOutRecord = "bangpai.BagInOutRecord",--存取记录
    BangPaiSetApply = "bangpai.BangPaiSetApply", --招人设置
    BangPaiApplyList = "bangpai.BangPaiApplyList",--申请列表
    BangPaiSetJob = "bangpai.BangPaiSetJob",--设定职位
    BangPaiNotice = "bangpai.BangPaiNotice",--帮派公告修改
    BangPaiBoxInfo = "bangpai.BangPaiBoxInfo",--
    BangPaiExpInfo = "bangpai.BangPaiExpInfo",--帮派经验获得
    BossDekaronView = "boss.BossDekaronView",--boss结算界面
    BangPlChooseView = "bangpai.BangPlChooseView",--批量删除装备
    BaibeiGiftView = "baibei.BaibeiGiftView",--百倍礼包
    BossView = "boss.BossView",--boss大厅
    BossHpView = "boss.BossHpView",--boss血条
    BossRefreshCard = "boss.BossRefreshCard",--BOSS刷新令

    BuffView  ="main.BuffView",--buff 显示效果
    BlessTipView = "tips.BlessTipView",--祝福值提示
    BossRankAwards = "boss.BossRankAwards",--boss奖励显示

    BloodBuyView = "alert.BloodBuyView",--血包购买弹框
    BossIndianaView = "boss.BossIndianaView",--boss夺宝
    BossTiredTipView = "tips.BossTiredTipView",--boss疲劳提醒
    BuyCloudView = "buycloud.BuyCloudView", --幸运云购
    BossCCAwardsView = "boss.BossCCAwardsView",--boss产出显示
    MonsterLingLiTips = "boss.MonsterLingLiTips",--boss产出显示
    KuaFuLveDuo = "boss.KuaFuLveDuo",--跨服显示
    TaiGuXuanJingBossList = "boss.TaiGuXuanJingBossList",--boss列表


    --魅力沙滩开始
    BeachMainView = "beach.BeachMainView",
    BeachRank = "beach.BeachRank",
    BeachRecord = "beach.BeachRecord",
    BeachReward = "beach.BeachReward",
    BeachSong = "beach.BeachSong",
    BeachTopTips = "beach.BeachTopTips",
    BossNewsView = "boss.BossNewsView",--boss战斗信息
    --魅力沙滩结束
    BuBuGaoSheng = "rechargeback.BuBuGaoSheng",--步步高升活动
    QuanMingView = "rechargeback.QuanMingView",--全民备战

    ProRecordPanel = "buycloud.ProRecordPanel", --幸运云购记录
    --SetMemberPanel = "bangpai.SetMemberPanel",
    --C
    CreateRoleView    = "createrole.CreateRoleView",            --创建角色
    CollectBarView = "task.CollectBarView",--采集精度
    ChatView = "chat.ChatView",--聊天系统
    ChatHornView = "chat.ChatHornView",--聊天喇叭
    CheckAwardsView = "smasheggs.CheckAwardsView",--砸蛋活动奖励查询
    ComposeChooseView = "forging.ComposeChooseView",--
    Cumulative = "rechargedraw.Cumulative", -- 累计消费

    CloseTestView = "activity.CloseTestView", --双倍返还
    ChooseTipView = "bangpai.ChooseTipView",
    ChristmasActView = "christmas.ChristmasActView",--圣诞节活动
    ChristmasRank = "christmas.ChristmasRank",--圣诞节排行
    CityWarAwards = "citywar.CityWarAwards",--城战奖励
    CityWarOverView = "citywar.CityWarOverView",--城战奖励
    --春节活动
    ChunJieMainView = "chunjie.ChunJieMainView",
    ChunjieRewardTips = "chunjie.ChunjieRewardTips",
    CoupleSuitsView = "valentines.CoupleSuitsView", --情侣时装抽奖
    ChouQianView = "chouqian.ChouQianView",--好运灵签
    ContinueCharge = "continue.ContinueCharge",--连充特惠
    ChargePumpView = "continue.ChargePumpView",--充值抽抽乐
    ContinueCost = "continue.ContinueCost",--连消特惠
    TianMingBuGua = "continue.TianMingBuGua",--连消特惠
    BuGuaAlert = "continue.BuGuaAlert",
    SignInTeacher = "continue.SignInTeacher",--老师请点名
    XianShiLianChong = "continue.XianShiLianChong",--限时连冲
    WuDiXinYunXing = "continue.WuDiXinYunXing",--无敌幸运星
    ActXunBaoRank = "continue.ActXunBaoRank",--寻宝排行
    DongFangRank = "continue.DongFangRank",--合服洞房排行
    MarryRankAwardCon = "continue.MarryRankAwardCon",
    LuckyTreasureView = "continue.LuckyTreasureView", --幸运鉴宝

    CombineTipsView = "bangpai.CombineTipsView",--帮派合并消息提示
    ConsumeChange = "consume.ConsumeChange",-- 消费兑换
    ChongZhiDanBiView = "czdb.ChongZhiDanBiView",--超值单笔
    YbDuihuan = "consume.YbDuihuan",--元宝兑换


    DanbiView = "danbi.DanbiView",--单笔充值豪礼
    DoubelBackView = "rechargeback.DoubelBackView",--
    DaoDanNanGuaTian = "ddngt.DaoDanNanGuaTian",-- 捣蛋南瓜田
    DoubleBall = "doubleball.DoubleBall",-- 双色球
    BetPanel = "doubleball.BetPanel",-- 投注选号
    BetedPanel = "doubleball.BetedPanel",-- 已投号码

    --宠物系统
    PetMainView = "pet.PetMainView",
    PetEquipView = "pet.PetEquipView",
    PetSkillMsgTips = "pet.PetSkillMsgTips",
    PetSkillSee = "pet.PetSkillSee",
    PetSkillView = "pet.PetSkillView",
    PetGrowView = "pet.PetGrowView",
    PetMsgView ="alert.PetMsgView",
    PetOpenPos ="pet.PetOpenPos",
    PetOnHelp ="pet.PetOnHelp",
    PetHelpActive = "pethelp.PetHelpActive",
    PetHelpRank = "pethelp.PetHelpRank",
    --D
    DebugView = "main.DebugView",
    DebugTestView     = "main.DebugTestView",            --D-DebugTest调试界面
    DialogView = "task.DialogView",

    DujieView = "immortality.DujieView",  --渡劫弹框

    DayFirstChargeView = "activity.DayFirstChargeView",--每日首充
    DayFirstChargeOther = "activity.DayFirstChargeOther",--每日首充(9天后的)
    DayOneRmbView = "activity.DayOneRmbView",--每日一元
    HeFuFanLi = "activity.HeFuFanLi",--合服返利

    DailyTaskView = "dailytask.DailyTaskView",--日常活跃任务界面
    TaskTipsView = "dailytask.TaskTipsView",--日常活跃任务弹框

    DeadView = "dead.DeadView",  --死亡
    DownLoadView = "download.DownLoadView",--下载有礼
    DownLoadFinish = "download.DownLoadFinish",--下载完成

    DayActiveView = "dayactive.DayActiveView",--开服进阶活动
    DoubleMajorView = "main.DoubleMajorView",--双修
    KaiFuRank = "dayactive.KaiFuRank",--
    DismissTipsView = "paiwei.DismissTipsView",--排位赛战队解散提示
    DailyActivityView = "dailyactivitiy.DailyActivityView",--精彩活动
    DiWangView = "diwang.DiWangView",--帝王将相
    XianWeiDetails = "diwang.XianWeiDetails",--帝王将相仙位详情
    XianWeiAttr = "diwang.XianWeiAttr",--帝王将相仙位称号列表
    DiWangHuiFuTips = "diwang.DiWangHuiFuTips",--帝王将相恢复战意弹窗
    DiWangFightTips = "diwang.DiWangFightTips",--帝王将相挑战弹窗
    DiWangFightEndView = "diwang.DiWangFightEndView",--帝王将相挑战结算
    DiWangLootedTips = "diwang.DiWangLootedTips",--帝王将相仙位被抢提示
    DevilFashionView="devilfashion.DevilFashionView",--恶魔时装限时活动
    DismantleView = "alert.DismantleView",-- 神装拆解
    DiHunMainView = "dihun.DiHunMainView",-- 帝魂主界面
    DiHunPack = "dihun.DiHunPack",-- 帝魂背包
    DiHunTips = "dihun.DiHunTips",-- 帝魂tips
    DiHunSkillView = "dihun.DiHunSkillView",-- 帝魂技能
    DiHunZhaoHuanView = "dihunzhaohuan.DiHunZhaoHuanView",-- 帝魂召唤
    DanMuTipsView = "main.DanMuTipsView",-- 弹幕显示层


    --E
    EquipTipsView = "alert.EquipTipsView",--                  E装备Tips界面
    EquipWearTipView = "tips.EquipWearTipView",--             E装备穿戴提示界面
    EliteBossTipView = "tips.EliteBossTipView",--             精英boss
    EquipawakenTipsView = "alert.EquipawakenTipsView",--                  E装备Tips界面
    ExpdrugTipView = "fuben.ExpdrugTipView",--经验药水
    EquipPetTipsView = "alert.EquipPetTipsView",--宠物装备tips
    EquipWuXing = "alert.EquipWuXing",--五行tips
    EquipXianZhuangTipsView = "alert.EquipXianZhuangTipsView",--五行tips
    EquipShengYin = "alert.EquipShengYin",--圣印tips
    EquipShengZhuang = "alert.EquipShengZhuang", --圣装tips
    EightGatesElementTips = "alert.EightGatesElementTips", --八门元素tips
    ElementRefineView = "awaken.ElementRefineView",--八门元素精炼
    ElementStrengView = "awaken.ElementStrengView",--八门元素强化
    ElemetStepUpView = "awaken.ElemetStepUpView",--元素进阶
    --F
    FriendView = "friend.FriendView",  --好友界面
    FriendTips = "friend.FriendTips",  --邀请组队，查看信息，加入黑名单。。
    ForgingView = "forging.ForgingView",--锻造系统
    ForgingTipsView = "forging.ForgingTipsView",--锻造tips
    FubenView = "fuben.FubenView",--副本系统
    FubenDekaronView = "fuben.FubenDekaronView",--結算界面
    FubenTipView = "alert.FubenTipView",--副本提示攻打界面
    FlagHoldView = "zhanchang.FlagHoldView",--问鼎守旗倒计时
    FubenDujieView = "fuben.FubenDujieView",--渡劫副本结算界面
    FubenSweepView = "fuben.FubenSweepView",--副本扫荡界面
    ShengXiaoAwards = "fuben.ShengXiaoAwards",--生肖副本奖励预览界面
    FirstChargeView = "firstcharge.FirstChargeView",--在线首冲

    FashionTipsView = "alert.FashionTipsView", --时装Tips界面
    FeedBoss = "bangpai.FeedBoss", --喂养boss
    FlameView = "flame.FlameView", --圣火
    FlameAnswer = "flame.FlameAnswer", --圣火答题
    FlameThrow = "flame.FlameThrow", --圣火抛骰子
    FinalWinView = "bangpai.FinalWinView",--终极连胜
    FashionStarView = "alert.FashionStarView",--时装升星
    FlowerRank = "flower.FlowerRank",--鲜花榜
    RankAward = "flower.RankAward",--鲜花榜奖励
    GetProView = "flower.GetProView",--道具获得
    FaLaoView = "falao.FaLaoView",--法老秘宝

    --飞升
    FSFenJieView  = "feisheng.FSFenJieView",
    FSOverView  = "feisheng.FSOverView",
    FSSuccesView  = "feisheng.FSSuccesView",
    FSXianLiView  = "feisheng.FSXianLiView",
    FSXianYuanUp  = "feisheng.FSXianYuanUp",
    FSXianYuanView  = "feisheng.FSXianYuanView",
    FullReduction = "continue.FullReduction", -- 满减活动
    Fullreductips = "continue.Fullreductips", -- 满减活动

    --G
    GrowthView = "growth.GrowthView", --我要变强
    GrowthTips = "growth.GrowthTips", --变强提示
    GuideLayer = "guide.GuideLayer",--引导界面
    GuideDialog = "guide.GuideDialog",--引导对话
    GuideDialog2 = "guide.GuideDialog2",--引导对话
    GuideSkill = "guide.GuideSkill",--获得技能
    GuideZuoqi = "guide.GuideZuoqi",--坐骑伙伴等等功能的激活
    GuideViewOpen = "guide.GuideViewOpen", --新功能开启
    GuideEquip = "guide.GuideEquip",--获得新装备
    GuideEquip2 = "guide.GuideEquip2",--获得新装备
    GuideBianSheng = "guide.GuideBianSheng",--变身
    GuideActive = "guide.GuideActive",--
    XinShouView = "guide.XinShouView", --新手界面
    GangBossInfoView = "zhanchang.GangBossInfoView",--仙盟战信息界面
    GuideWSSB = "guide.GuideWSSB",
    GuideXinshouTips = "guide.GuideXinshouTips",--新手预告提示界面
    GetAgainView = "fuben.GetAgainView",--再次获取提示窗
    GoldTreeView = "goldtree.GoldTreeView",--摇钱树
    ActGuoQingView = "guoqing.ActGuoQingView",--欢乐国庆活动
    GuoQingRankAwards = "guoqing.GuoQingRankAwards",--欢乐国庆排名奖励
    GetDiHunView = "dihun.GetDiHunView",--获得帝魂
    --H
    HuobanView = "huoban.HuobanView", --伙伴主
    HuobanSkillUp = "huoban.HuobanSkillUp",--伙伴 技能升级
    HuobanEquipUp = "huoban.HuobanEquipUp",--伙伴 装备升级
    HuobanItemUse = "huoban.HuobanItemUse",--伙伴 道具使用
    HuobanOtherSkinView = "huoban.HuobanOtherSkinView",-- 特殊皮肤
    HuobanUpView = "huoban.HuobanUpView", --升级成功之后
    HuobanLv = "huoban.HuobanLv",
    HuoBanChange = "huoban.HuoBanChange",
    HuobanExpPop = "huoban.HuobanExpPop", --伙伴升级经验装备选择弹框
    HuanglingTask = "zhanchang.HuanglingTask", --皇陵之战任务弹框
    HookAwardsView = "hookawards.HookAwardsView", --离线挂机奖励
    -- HiddenTasksView = "ingotcopy.HiddenTasksView",--隐藏任务
    HeadChooseView = "juese.HeadChooseView",--自选头像

    HomeMainView = "home.HomeMainView",
    HomeBeginView = "home.HomeBeginView",--家园进入页面
    HomeChangeName = "home.HomeChangeName",--家园改名
    HomeHouse = "home.HomeHouse",--升级住宅
    HomeWeiQiang = "home.HomeWeiQiang",--升级大门围墙
    HomeSpringView = "home.HomeSpringView",--升级温泉
    HomeMonster = "home.HomeMonster",--家园灵兽
    HomePlantingChoose = "home.HomePlantingChoose",--家园种植选择
    HomeRecord = "home.HomeRecord",--家园记录
    HomeSeeOther = "home.HomeSeeOther",--拜访他人
    HomeSet = "home.HomeSet",--家园设置
    HomeWelCome = "home.HomeWelCome",--家园欢迎界面
    HomeOS = "home.HomeOS",--家园细操作
    HighGradePackageView = "highgradepackage.HighGradePackageView", --天书活动
    HintView = "xunbao.HintView", --寻宝活动钥匙不足提示窗
    HeFuMainView = "hefu.HeFuMainView",--合服活动入口(废弃掉)
    HeFuBagView = "hefu.HeFuBagView",--合服折扣礼包
    HeFuFundView = "hefu.HeFuFundView",--合服基金
    HeFuEntrance = "hefu.HeFuEntrance",--合服活动入口
    HeFuLianChong = "hefu.HeFuLianChong",--合服连冲
    HouWangView = "houwang.HouWangView",--猴王除妖
    HalloweenRecharge = "halloweenrecharge.HalloweenRecharge",-- 万圣节累充活动
    HunShiStrengView = "dihun.HunShiStrengView",-- 魂饰强化
    HunShiTipsView = "alert.HunShiTipsView",--
    HunShiSkillView = "dihun.HunShiSkillView",--魂饰技能

    --I
    ImmortalityView = "immortality.ImmortalityView",--修仙

    IngotCopy = "ingotcopy.IngotCopy",--元宝复制

    InvestView = "invest.InvestView",--投资计划

    ItemTipView = "main.ItemTipView",--道具飄界面

    ItemSkillDecView = "track.ItemSkillDecView",--道具技能说明界面

    --J
    JueSeMainView = "juese.JueSeMainView", --角色信息
    JueSeHead = "juese.JueSeHead",--更换头像
    JueSeName = "juese.JueSeName",--改名
    JianLingBorn = "jianling.JianLingBorn",--剑灵出世
    JuHuaSuanView = "juhuasuan.JuHuaSuanView", -- 聚划算
    JinRiLeiChong = "jinrileichong.JinRiLeiChong",--今日累充
    StarAttrView = "juese.StarAttrView",--装备星级属性面板
    JianShenMain = "shengyinrank.JianShenMain", -- 剑神装备寻宝返还
    JiYiHuaDengView = "huadeng.JiYiHuaDengView", -- 记忆花灯
    JiYiRankView = "huadeng.JiYiRankView", -- 记忆花灯排行
    --K
    KageeView = "kagee.KageeView",--影卫系统
    KageeViewNew = "kagee.KageeViewNew", -- 新仙脉
    KageeTipsView1 = "kagee.KageeTipsView1",--影卫弹窗1
    KageeTipsView2 = "kagee.KageeTipsView2",--影卫弹窗1
    ShengXiaoPackView = "kagee.ShengXiaoPackView", -- 生肖背包
    ShengXiaoBaoZangWareView = "kagee.ShengXiaoBaoZangWareView", -- 生肖宝藏仓库
    ShengXiaoExtendView = "kagee.ShengXiaoExtendView", -- 生肖技能扩展
    ShengXiaoJinJieView = "kagee.ShengXiaoJinJieView", -- 生肖进阶
    ShengXiaoStrengthenView = "kagee.ShengXiaoStrengthenView", -- 生肖强化
    ShengXiaoFenJieView = "kagee.ShengXiaoFenJieView", -- 生肖分解
    ShengXiaotipView = "kagee.ShengXiaotipView", -- 生肖属性tip
    ShengXiaoSkillInfoView = "kagee.ShengXiaoSkillInfoView", -- 生肖技能信息
    EquipShengXiaoTipsView = "alert.EquipShengXiaoTipsView", -- 生肖装备TIP信息

    KaiFuMainView = "kaifu.KaiFuMainView", --开服活动主界面
    JinJieRankMain = "kaifu.JinJieRankMain", --进阶排行
    -- KaiFuRank = "kaifu.KaiFuRank",--
    KuaFuMainView = "kuafu.KuaFuMainView",--跨服战场主界面
    KuaFuCreateTeam = "kuafu.KuaFuCreateTeam",--跨服副本创建队伍
    KufuCheView = "kuafu.KufuCheView",--跨服三界 护送任务
    KufuCheViewNew = "kuafu.KufuCheViewNew",
    KuaFuCheHpView = "kuafu.KuaFuCheHpView",--三界镖车 血条
    KuafuBoxView = "kuafu.KuafuBoxView",--跨服寻宝]
    KuaFuChargeMain = "kuafu.KuaFuChargeMain",--跨服充值榜
    KuaFuChargeRank = "kuafu.KuaFuChargeRank",--跨服充值榜排名

    KaiFuLeiji = "kaifuleiji.KaiFuLeiji",--开服7天累冲活动入口
    KuangHuanMainView = "kuanghuan.KuangHuanMainView",--狂欢大乐购
    KuangHuanBuyView = "kuanghuan.KuangHuanBuyView",--狂欢大乐购购买窗
    --L
    LoginView           = "login.LoginView",     --登陆界面
    LoadingView = "loading.LoadingView",         --加载界面
    LoginAwardView = "loginaward.LoginAwardView",  --30天登录奖励
    LevelTipView = "fuben.LevelTipView",--练级谷购买时间弹窗
    LevelTip = "alert.LevelTip",--练级谷入场提示
    LimitPackView = "pack.LimitPackView",--临时背包
    LimitPackTips = "pack.LimitPackTips",--临时背包提示
    LuckyAdvanceView = "luckyadvance.LuckyAdvanceView",--幸运进阶日活动

    LingyuanView = "lingyuan.LingyuanView",--零元购
    LevelSweepView = "fuben.LevelSweepView",--练级谷一键扫荡

    LirenTipView = "fuben.LirenTipView",--利刃
    LimitWareView = "xunbao.LimitWareView",--寻宝临时仓库
    LastCountBuyView = "paiwei.LastCountBuyView",--单人排位购买次数弹窗
    LabaMainView = "laba.LabaMainView",--腊八活动
    LabaRankView = "laba.LabaRankView",--腊八活动排行
    LabaZhouView = "laba.LabaZhouView",--腊八粥
    LaBaView2019 = "laba2019.LaBaView2019",--腊八2019
    LaBaRankView2019 = "laba2019.LaBaRankView2019",--腊八活动排行2019

    LunarYearMainView = "lunaryear.LunarYearMainView",--小年活动主界面
    DumplingsView = "lunaryear.DumplingsView",--饺子团圆

    LanternMainView = "lantern.LanternMainView",--元宵
    LanternAwardsView = "lantern.LanternAwardsView",--元宵预览
    LanternDtView = "lantern.LanternDtView",--元宵答题
    LanternRankView = "lantern.LanternRankView",--元宵排行榜

    LingXuBaoZangView ="lingxubaozang.LingXuBaoZangView",--灵虚宝藏

    --M
    MainView = "main.MainView",                  --Z主界面
    MailView = "chat.MailView",                  --邮件界面
    MapView = "map.MapView",                     --小地图
    MiniMapView = "map.MiniMapView",             --迷你小地图
    MarketMainView = "marketplace.MarketMainView",--寄售行
    MainHurtTips = "main.MainHurtTips",--受到攻击提示
    MatchingView = "paiwei.MatchingView",--排位赛匹配界面
    MidAuTumnView = "zhongqiuhaoli.MidAuTumnView",--中秋豪礼

    MarryMainView = "marry.MarryMainView",-- 结婚系统主界面
    MarrySongHuaView = "marry.MarrySongHuaView",--送花
    MarryLihunTips = "marry.MarryLihunTips",--申请离婚
    MarryFubenRank = "marry.MarryFubenRank",--副本排行详细
    MarryFubenDekaron = "marry.MarryFubenDekaron",--情缘结算界面
    MarryKaiFuReward = "marry.MarryKaiFuReward",--咱们结婚吧 排行奖励
    MarryKaiFuRank = "marry.MarryKaiFuRank",--开服咱们结婚吧
    MarryGuide = "marry.MarryGuide",--结婚引导
    MarryRank = "marry.MarryRank",--婚礼排行榜
    MarryRankAward = "marry.MarryRankAward",--婚礼排行奖励
    MarryChengHao = "marry.MarryChengHao",--结婚称号
    XianTongtfhz = "marry.XianTongtfhz",--洞房花烛
    XianTongchoose = "marry.XianTongchoose",--洞房花烛
    XianTongDelete = "marry.XianTongDelete",--洞房花烛
    XianTongEquipUp = "marry.XianTongEquipUp",--洞房花烛
    XianTongGrowView = "marry.XianTongGrowView",--洞房花烛
    XianTongReward = "marry.XianTongReward",--洞房花烛
    XianTongSkillUp = "marry.XianTongSkillUp",--洞房花烛
    XianTongSkillView = "marry.XianTongSkillView",--洞房花烛
    XianTongTongFang = "marry.XianTongTongFang",--洞房花烛
    XianTongXTSure = "marry.XianTongXTSure",--洞房花烛
    XiantongSkillMsgTips = "pet.XiantongSkillMsgTips",
    XianTongOpenPos = "marry.XianTongOpenPos",--仙童助战孔开启提示
    XianTongOnHelp = "marry.XianTongOnHelp",--仙童助战上阵界面

    GetMarriedView = "marrya.GetMarriedView",--喜结良缘
    MarryApplyView = "marrya.MarryApplyView",--求婚
    MarryAppointment = "marrya.MarryAppointment",--预约婚礼
    MarryInviteView = "marrya.MarryInviteView",--邀请宾客
    MarryStoreView = "marrya.MarryStoreView",--婚礼商店
    MarryWishView = "marrya.MarryWishView",--赠送祝福

    MarryNpcView = "marryb.MarryNpcView",--申请结婚 离婚NPC
    MarryRespons = "marryb.MarryRespons", --求婚回复
    MarryLuckyView = "marryb.MarryLuckyView", --举办婚宴
    WeddingView = "marryb.WeddingView", --婚宴场景
    InvitePeople = "marryb.InvitePeople", --增加邀请人数

    MakeDekaron = "forging.MakeDekaron",--打造结算
    MarryTreeHandle = "marry.MarryTreeHandle",--姻缘树操作
    MajorSelectView = "main.MajorSelectView",--双修邀请列表弹框
    MidasTouchView = "midastouch.MidasTouchView",--点石成金活动
    RankingPower = "kaifu.RankingPower",--战力排行

	MijinguideView = "fuben.MijinguideView",--副本引导
    --N
    NoticeView = "login.NoticeView", --登陆公告
    NearPlayer = "nearplayer.NearPlayer",
    --O
    OfflineTimesBuy = "welfare.OfflineTimesBuy", --离线挂机时间购买界面
    OverdueTipView = "tips.OverdueTipView",--限时道具提示
    OpenAlertView = "awaken.OpenAlertView",--八门开启弹窗
    --P
    PackView            = "pack.PackView",                  --B-背包系统
    PowerChangeView = "main.PowerChangeView",--P战斗力弹窗
    PwsOverView = "paiwei.PwsOverView",--跨服排位结束等级升降弹窗

    PropMsgView            = "pack.PropMsgView",                  --道具信息弹窗
    PutAwayPanel = "marketplace.PutAwayPanel",   --市场上架弹窗
    PasswordView = "marketplace.PasswordView",   --市场密码输入
    PlotDialogView = "fuben.PlotDialogView",--剧情对话
    PrivilegePanel = "xianzun.PrivilegePanel", --仙尊卡特权弹框
    PackChooseView = "pack.PackChooseView",--宝箱选择弹窗
    PickAwardsView = "alert.PickAwardsView",
    PlayerHpView = "boss.PlayerHpView",--玩家血条
    PkStateView = "alert.PkStateView",--pk模式
    PanicBuyView = "panicbuy.PanicBuyView",--特惠抢购
    PlChooseView = "forging.PlChooseView",--批量选择装备
    PwsTeamListView = "paiwei.PwsTeamListView",--排位赛战队列表界面
    PwsTeamInviteList = "paiwei.PwsTeamInviteList",--排位赛战队邀请成员列表
    PwsTeamTipView = "paiwei.PwsTeamTipView",--排位赛战队申请入队在线弹框
    PwsTeamWarSendView = "paiwei.PwsTeamWarSendView",--排位赛战队成员准备界面
    PwsOverAwards = "paiwei.PwsOverAwards",--组队排位结算界面
    PwsTeamApplyView = "paiwei.PwsTeamApplyView",--组队排位队伍申请列表
    PwsMembersList = "paiwei.PwsMembersList",--组队排位队伍成员操作界面
    PayoffRankAwardsView = "paiwei.PayoffRankAwardsView",--组队排位队伍成员操作界面
    PwsDeadTipsView = "paiwei.PwsDeadTipsView",--组队排位队伍成员操作界面
    --Q
    QuickUseView = "tips.QuickUseView",--快捷使用弹窗
    QiFuView = "qifu.QiFuView",--快捷使用弹窗
    ShenShouRank = "qifu.ShenShouRank",--快捷使用弹窗
    QiMenDunJiaMain = "qimendunjia.QiMenDunJiaMain",--奇门遁甲
    QiBingFenJie = "zuoqi.QiBingFenJie",
    QiBingUpStarView = "zuoqi.QiBingUpStarView",

    QiBingActive = "qibingact.QiBingActive",--奇兵排行
    --R
    RuleView              = "rule.RuleView", --规则
    RedBagView            = "redbag.RedBagView", --红包
    ReceiveAwardView      = "redbag.ReceiveAwardView", --领取红包
    RankMainView          = "rank.RankMainView", --排行榜
    ResTipView = "welfare.ResTipView",--资源找回弹窗
    RechargeAgain = "activity.RechargeAgain",  --再充献礼
    ReconnectView = "alert.ReconnectView",  --断线重连
    ResEffectView = "tips.ResEffectView",--获得资源特效
    RobTreasureView = "robtreasure.RobTreasureView",--获得资源特效
    -- RemindCopy = "ingotcopy.RemindCopy",--聚宝盆提醒
    RoleUpgradeView = "alert.RoleUpgradeView",--人物升级弹窗
    RankingTips = "kaifu.RankingTips", --仙盟积分排行榜弹窗
    RankingLevel = "kaifu.RankingLevel",--开服冲级等级排行榜
    ReviveView = "dead.ReviveView",--复活倒计时弹窗
    RecordJsRankView = "bangpai.RecordJsRankView",--结算排行日志
    RareEquipTipsView = "tips.RareEquipTipsView",--稀有装备获得提示
    RankAwardsView = "paiwei.RankAwardsView",--单人跨服排位赛奖励界面
    RankProceedView = "paiwei.RankProceedView",--单人跨服排位计时界面
    RuneMainView = "rune.RuneMainView",--符文主界面
    RunePackView = "rune.RunePackView",--符文背包界面
    RuneOverView = "rune.RuneOverView",--符文总览
    RuneIntroduceView = "rune.RuneIntroduceView",--符文信息
    RuenDekaronView = "rune.RuenDekaronView",--符文结算
    RechargeRankView = "rechargerank.RechargeRankView",--充值消费排行活动
    LastRechargeRank = "rechargerank.LastRechargeRank",--充值消费榜上一个排行
    RechargeDrawView = "rechargedraw.RechargeDrawView",--充值翻牌活动
    RechargeRebate = "rechargedraw.RechargeRebate",--双倍返利
    RechargeGiftView = "rechargedraw.RechargeGiftView",--充值豪礼活动
    RechargeBack = "rechargeback.RechargeBack",
    RechargeSum = "rechargedraw.RechargeSum",
    RachargeCrazy = "rechargedraw.RachargeCrazy",
    MiJinTaoView = "rechargeback.MiJinTaoView",
    --S
    ShopBuyView           = "pack.ShopBuyView",                  --购买弹窗
    SiteView              = "chat.SiteView",                     --设置弹窗
    SkillView = "skill.SkillView",--技能天赋界面
    ShopMainView = "store.ShopMainView", --商城主界面
    SitDownView ="main.SitDownView",--打坐
    ScoreRankView = "zhanchang.ScoreRankView",--仙盟战积分排行
    SkinTipsView = "tips.SkinTipsView",--外观获得提示小窗
    SeeOtherMsg = "see.SeeOtherMsg",--查看玩家信息
    SQuickUseView = "tips.SQuickUseView",----特殊快捷道具使用小窗
    StartGoView = "kuafu.StartGoView",--倒计时开场景
    SummerActsView = "summeracts.SummerActsView",--夏日活动
    SevenDaysView = "sevendays.SevenDaysView",--7天登陆活动

    SjRCTask = "kuafu.SjRCTask", --三界跨服争霸日常任务
    SjXBTask = "kuafu.SjXBTask",--三界争霸寻宝任务
    SjHSTask = "kuafu.SjHSTask",--跨服护送

    SmashEggsView = "smasheggs.SmashEggsView",--疯狂砸蛋活动

    SceneSkillView = "main.SceneSkillView",--场景技能

    ScoreStroeView = "xunbao.ScoreStroeView",--寻宝积分商城
    SetUpTeam = "paiwei.SetUpTeam",--跨服排位创建战队

    ShenQiView = "shenqi.ShenQiView",--神器主界面
    StrengthenView = "shenqi.StrengthenView",--神器强化界面
    ShenQiFenjie = "shenqi.ShenQiFenjie",--神器灵石分解界面
    ShenShouEquip = "shenqi.ShenShouEquip",--神兽装备穿戴界面
    ShenShouStrength = "shenqi.ShenShouStrength",--神兽装备强化界面
    ShenShouTips = "shenqi.ShenShouTips",--神兽助战位置扩展提示
    ShenShouStrengthTips = "shenqi.ShenShouStrengthTips",--神兽双倍强化提示
    ShenShouSkillTips = "shenqi.ShenShouSkillTips",--神兽技能提示
    ShenQiRankMain = "shenqirank.ShenQiRankMain",--神器排行
    MianJuShengXinAndFuMoView = "shenqi.MianJuShengXinAndFuMoView",--面具附魔和升星
    MianJuSkillView = "shenqi.MianJuSkillView",--面具技能tip



    ShenLuView = "shenlu.ShenLuView",--神炉炼宝
    SheQiuView = "actsheqiu.SheQiuView",  -- 射球好礼
    SheQiuAwardView = "actsheqiu.SheQiuAwardView", -- 射球奖励
    ShenQiFindMaster = "shenqifind.ShenQiFindMaster", -- 神器寻主
    ShenBiActive = "shenbi.ShenBiActive", -- 神臂擎天
    ScratchActive = "scratch.ScratchActive", -- 刮刮乐
    ScratchRecordView = "scratch.ScratchRecordView", -- 刮刮乐个人记录
    SeeGodEquipView = "forging.SeeGodEquipView", -- 神装合成预览
    SeeGemPaoguang = "forging.SeeGemPaoguang", -- 宝石抛光
    SkillInfoView = "awaken.SkillInfoView",--技能详情
    ShengDanMainView = "shengdan.ShengDanMainView",--2018圣诞
    ShengDanCharge = "shengdan.ShengDanCharge",--2018圣诞充值

    --T
    TopLockView = "main.TopLockView",--主界面，锁屏挂机
    TaskView = "task.TaskView",  --任务窗口
    TaskViewKuaFu = "task.TaskViewKuaFu",--跨服三界争霸
    TaskAwardView = "task.TaskAwardView",--任务奖励
    TaskOneView ="task.TaskOneView",--完成单次奖励
    TaskOverView = "task.TaskOverView",--完成额外奖励
    TopView = "topview.TopView",--界面特效放置view

    TeamView = "team.TeamView",--组队
    TeamSearchView = "team.TeamSearchView",--队员查找
    TeamTipView = "team.TeamTipView",--邀请申请提示弹窗
    TeamInviteView = "team.TeamInviteView",--副本组队邀请弹窗
    TeamWarTipView = "team.TeamWarTipView",--副本组队提示
    TeamSiteView = "team.TeamSiteView",--组队设定
    TeamWarSendView = "team.TeamWarSendView",--组队准备
    TeamJoinListView = "team.TeamJoinListView",--组队邀请或者申请

    TaskSHView = "task.TaskSHView",--商会任务
    TradeMainView = "trade.TradeMainView",--交易主界面
    TrackView = "track.TrackView",--任务追踪
    TjdkTrackView = "track.TjdkTrackView",--天晶洞窟采集活动
    WsdBuyJingLiTip = "track.WsdBuyJingLiTip",--万神殿精力补充提示
    DaTiView = "track.DaTiView",--答题界面
    TuoDanMain = "tuodan.TuoDanMain", -- 脱单活动
    TuoDanRank = "tuodan.TuoDanRank", -- 情侣充值排行
    TuoDanAward = "tuodan.TuoDanAward", -- 情侣充值奖励



    TipsView = "friend.TipsView",--好友tips弹窗
    TeamTipsView = "alert.TeamTipsView",--组队界面tips弹窗
    TreeTipView = "marry.TreeTipView",--姻缘树弹窗
    TreeExplainView = "marry.TreeExplainView",--种树流程

    TowerRankView = "fuben.TowerRankView",--单人守塔排行榜
    TaskGuide = "task.TaskGuide",--引导断
    TeamIconSelect = "paiwei.TeamIconSelect",--跨服排位战队头像选择
    TeamRankAwardsView = "paiwei.TeamRankAwardsView",--跨服排位战队头像选择
    TurntableView = "weekend.TurntableView",--转盘活动
    TeamInformation = "paiwei.TeamInformation",--跨服排位赛队伍信息界面
    TaskView3 = "task.TaskView3",--EVE 日常任务：进副本的任务，需要找NPC，再进入副本TaskView3
    --U
    UnlockView            = "pack.UnlockView",                  --U-密码锁弹窗
    UpdateView             = "login.UpdateView",     --登陆界面
    UpgradeView   = "immortality.UpgradeView",   --修仙升级界面
    --V
    VipChargeView = "vip.VipChargeView", --VIP充值界面
    MonthCardView = "vip.MonthCardView", --月卡
    VipExperienceView = "vipexperience.VipExperienceView",--白银仙尊体验卡
    VipChargeIOSView = "vipios.VipChargeIOSView", --IOS审核专用：VIP充值界面
    ValentinesMainView = "valentines.ValentinesMainView",--情人节活动主界面

    --W
    WelfareView = "welfare.WelfareView",--福利大厅
    WangcaiView = "wangcai.WangcaiView",--旺财
    WenDingOver = "zhanchang.WenDingOver",--问鼎之战结束
    WendingTipView = "zhanchang.WendingTipView",--问鼎之战排行信息
    WenDingBegin = "zhanchang.WenDingBegin",--问鼎战开始界面
    ZhanChangLog = "zhanchang.ZhanChangLog",--战场日志
    WaitView = "wait.WaitView",  --等等等待
    WinAwardsView = "bangpai.WinAwardsView",--连胜奖励
    WarSkillView = "track.WarSkillView",--特殊场景技能
    WeekendView = "weekend.WeekendView",--周末狂欢
    WorldBossExplainView = "boss.WorldBossExplainView",
    WorldCupView = "worldcup.WorldCupView",--世界杯 活动
    YaZhuView = "worldcup.YaZhuView",--世界杯 活动
    WSJTaskView = "actwsj.WSJTaskView",--万圣节
    WSJDeadView = "actwsj.WSJDeadView",--万圣节死亡

    --X
    XianzunView = "xianzun.XianzunView",--仙尊卡
    XianMoFightView = "zhanchang.XianMoFightView",--仙魔战战斗
    XianMoTipView = "zhanchang.XianMoTipView",--
    XianYuJinDiTips = "alert.XianYuJinDiTips",--仙域禁地入场提示弹窗
    XmzbMapView = "bangpai.XmzbMapView",--仙盟争霸地图
    XunBaoView = "xunbao.XunBaoView",--寻宝
    XdzzTipView = "track.XdzzTipView",--
    XunXianView = "xunxian.XunXianView",--寻仙探宝
    XianLvPKMainView = "xianlvpk.XianLvPKMainView",--仙侣PK
    XianLvPKTouZhuView = "xianlvpk.XianLvPKTouZhuView",--仙侣PK投注
    XianLvRankView = "xianlvpk.XianLvRankView",--仙侣PK排行榜
    JoinView = "xianlvpk.JoinView",--仙侣报名
    TeamInfoView = "xianlvpk.TeamInfoView",--队伍详情
    XianLvPKRankAward = "xianlvpk.XianLvPKRankAward",--仙侣奖励
    XianLvPKMatchingView = "xianlvpk.XianLvPKMatchingView",--仙侣匹配
    XianLvPKOverView = "xianlvpk.XianLvPKOverView",--仙侣结算
    XianLvPKProceedView = "xianlvpk.XianLvPKProceedView",
    XianLvTipsView = "xianlvpk.XianLvTipsView",
    XianLvPKRewardView = "xianlvpk.XianLvPKRewardView",
    XianWaDaBiPing = "xianwadabiping.XianWaDaBiPing",
    XianWaRankBang = "xianwadabiping.XianWaRankBang",
    XianShiLiBaoView = "xianshilibao.XianShiLiBaoView",
    XzphView = "xianzhuangrank.XzphView",--仙装排行
    XuYuanShengDanShu = "continue.XuYuanShengDanShu",--许愿圣诞树
    LaBaLeiChou = "continue.LaBaLeiChou",--腊八累抽
    XiaoNianJiZhao = "continue.XiaoNianJiZhao",--小年祭灶
    XiaoNianView = "xiaonian.XiaoNianView",--小年活动
    XiaoNianRank = "xiaonian.XiaoNianRank",--小年排行
    XiaoNianGuide = "xiaonian.XiaoNianGuide",--小年规则
    XiaoNianHaoLi = "xiaonian.XiaoNianHaoLi",--小年豪礼

    --Y
    YdactMainView = "ydact.YdactMainView",--元旦快乐
    YdXdzzRankView = "ydact.YdXdzzRankView",--元旦个人排行
    YouXunView = "youxun.YouXunView",
    YanHuaAct = "yanhuaact.YanHuaAct", -- 烟花庆典
    YueMoKuangHuan = "rechargeback.YueMoKuangHuan", -- 月末狂欢（充值双倍）
    YiJiTanSuoView = "yiji.YiJiTanSuoView", -- 遗迹探索主界面
    YiJiTanSuoCity = "yiji.YiJiTanSuoCity", -- 遗迹探索城池选择
    YiJiCityInfoView = "yiji.YiJiCityInfoView", -- 遗迹探索城池信息
    YiJiTanSuoTips = "yiji.YiJiTanSuoTips", -- 遗迹探索提示弹框
    YiJiFightEndView = "yiji.YiJiFightEndView", -- 遗迹探索结算弹框
    YiJiTanSuoLogView = "yiji.YiJiTanSuoLogView", -- 遗迹探索日志
    --摇钱树
    YaoQianView = "yaoqianshu.YaoQianView",
    RewardView = "yaoqianshu.RewardView",
    YuanDanQiFuView = "yuandan.YuanDanQiFuView",--元旦祈福
    YuanDanMainView = "yuandan.YuanDanMainView",--元旦2018
    YuanDanZhuanPan = "yuandan.YuanDanZhuanPan",--元旦转盘

    --Z
    ZuoQiMain = "zuoqi.ZuoQiMain",--坐骑
    ZuoQiUpView = "zuoqi.ZuoQiUpView",--坐骑进阶成功
    ZuoQiSkillUp = "zuoqi.ZuoQiSkillUp",--坐骑技能升级
    ZuoQiEquipUp = "zuoqi.ZuoQiEquipUp",--坐骑装备升级
    ZuoQiItemUse = "zuoqi.ZuoQiItemUse",--丹药使用
    ZuoQiOtherSkinView = "zuoqi.ZuoQiOtherSkinView",--坐骑特殊皮肤

    ZhanChangMian ="zhanchang.ZhanChangMian", --战场主界面
    ZhanChangTipView = "tips.ZhanChangTipView",--战场开启提示
    ZuoqiTipView = "tips.ZuoqiTipView",--坐骑提示
    --ArenaView = "arena.ArenaView",--竞技场主界面
    ZhuXinChoosseView =  "forging.ZhuXinChoosseView",--
    ZhuiShaView = "zhuisha.ZhuiShaView",-- 追杀令界面
    ZhuiShaTipsView = "zhuisha.ZhuiShaTipsView",-- 追杀令弹窗

    ZhongQiuView = "zhongqiu.ZhongQiuView",--中秋活动
    ZhenXiQianKun = "continue.ZhenXiQianKun",-- 珍稀乾坤
    SnowMan = "continue.SnowMan", -- 真假雪人

    GanEnView = "ganen.GanEnView",--感恩有你
    FruitView = "fruit.FruitView",--水果消除
    ChooseView = "fruit.ChooseView",--水果消除选择界面
    TianTianFanLiView = "continue.TianTianFanLiView", --天天返利
    XinYunLiJin = "continue.XinYunLiJin",--幸运锦鲤
    TianJiangLiBao = "tianjianglibao.TianJiangLiBao",--天降礼包
    ShuangShiErView = "shuangshier.ShuangShiErView",--双十二
    TehuiView = "shuangshier.TehuiView", --双十二优惠券
    DongZhiView = "dongzhi.DongZhiView", --冬至活动
    DongZhiJiaoYan = "dongzhi.DongZhiJiaoYan", --冬至抽奖
    JiYJiaoYanView = "dongzhi.JiYJiaoYanView", --记忆饺宴
    JiYiJiaoYanRank = "dongzhi.JiYiJiaoYanRank", --冬至饺宴排行
    DongZhiLianChong = "dongzhi.DongZhiLianChong", --冬至连充
    JiYijiaoyanTip = "dongzhi.JiYijiaoyanTip",--记忆饺宴tip
    BiaoQingView = "dongzhi.BiaoQingView",--记忆饺宴表情

    BingXueMainView ="bingxue.BingXueMainView",--冰雪节活动
    XiaoFeiView = "bingxue.XiaoFeiView",--消费抽抽乐活动

    ChunJieView2019 ="chunjie2019.ChunJieView2019"--春节2019
}

UILevel = {
    level0     = 0,  --最底层UI，eg.自动挂机
    level1     = 1,  --最底层UI，eg.主界面
    level2     = 2,  --模块窗口层级，通用的层级，大部分的窗口都用此层级
    level3     = 3,  --顶层，eg.加载页
    level4     = 4,  --顶层，eg.加载页
    level5     = 5,  --顶层，eg.加载页
}