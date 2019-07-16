local conf = {}

--技能配置
conf.FightConf       = import(".FightConf").new()
--效果配置
conf.EffectConf      = import(".EffectConf").new()
--场景配置
conf.SceneConf       = import(".SceneConf").new()
--npc配置
conf.NpcConf         = import(".NpcConf").new()
--任务配置
conf.TaskConf        = import(".TaskConf").new()
--道具配置
conf.ItemConf        = import(".ItemConf").new()
--随机名字
conf.RoleConf      = import(".RoleConf").new()
--对话配置
conf.DialogConf  = import(".DialogConf").new()
--怪物
conf.MonsterConf = import(".MonsterConf").new()
--怪物
conf.RedPointConf = import(".RedPointConf").new()
--商店
conf.ShopConf = import(".ShopConf").new()
--技能
conf.SkillConf = import(".SkillConf").new()
--好友魅力
conf.FriendConf = import(".FriendConf").new()
--锻造
conf.ForgingConf = import(".ForgingConf").new()
--系统配置
conf.SysConf = import(".SysConf").new()
--道具属性表
conf.ItemArriConf = import(".ItemArriConf").new()
--坐骑
conf.ZuoQiConf = import(".ZuoQiConf").new()
--地图
conf.MapConf = import(".MapConf").new()
--天赋
conf.TalentConf = import(".TalentConf").new()
--背包
conf.PackConf = import(".PackConf").new()
--VIP充值配置
conf.VipChargeConf = import(".VipChargeConf").new()
--影卫
conf.KageeConf = import(".KageeConf").new()
--剑神
conf.AwakenConf = import(".AwakenConf").new()
--规则
conf.RuleConf = import(".RuleConf").new()
--伙伴配置
conf.HuobanConf = import(".HuobanConf").new()
--buff配置
conf.BuffConf = import(".BuffConf").new()
--帮派配置
conf.BangPaiConf = import(".BangPaiConf").new() 
--市场配置
conf.MarketConf = import(".MarketConf").new()
--我要变强
conf.GrowthConf = import(".GrowthConf").new()
--副本配置
conf.FubenConf = import(".FubenConf").new()
--排行榜
conf.RankConf = import(".RankConf").new()
--成就配置
conf.AchieveConf = import(".AchieveConf").new()
--修仙配置
conf.ImmortalityConf = import(".ImmortalityConf").new()
--交易配置
conf.TradeConf = import(".TradeConf").new()
--活动配置
conf.ActivityConf = import(".ActivityConf").new()
--竞技场配置
conf.ArenaConf = import(".ArenaConf").new()
--聊天配置
conf.ChatConf = import(".ChatConf").new()
--新手配置
conf.XinShouConf = import(".XinShouConf").new()
--旺财配置
conf.WangcaiConf = import(".WangcaiConf").new()
--血条配置
conf.HpConf = import(".HpConf").new()
--性能
conf.XingNengConf = import(".XingNengConf").new()
--皇陵之战配置
conf.HuanglingConf = import(".HuanglingConf").new()
--问鼎之战配置
conf.WenDingConf = import(".WenDingConf").new()
--后台资源
conf.DownloadConf = import(".DownloadConf").new()
--仙盟战配置
conf.GangWarConf = import(".GangWarConf").new()
--活动预告配置
conf.ActivityShowConf = import(".ActivityShowConf").new()
--跨服战场配置
conf.KuaFuConf = import(".KuaFuConf").new()

--结婚系统
conf.MarryConf = import(".MarryConf").new()

--世界等级配置
conf.WorldLevConf = import(".WorldLevConf").new()
--活动大厅配置
conf.ActivityHallConf = import(".ActivityHallConf").new()
--仙魔战配置
conf.XianMoConf = import(".XianMoConf").new()
--组队配置
conf.TeamConf = import(".TeamConf").new()
--家园系统
conf.HomeConf = import(".HomeConf").new() 
--仙盟活动
conf.XmhdConf = import(".XmhdConf").new()
--活动玩法
conf.ActivityWarConf = import(".ActivityWarConf").new()
--魅力沙滩
conf.BeachConf = import(".BeachConf").new()
--跨服排位
conf.QualifierConf = import(".QualifierConf").new()
--宠物系统
conf.PetConf = import(".PetConf").new() 
--符文系统
conf.RuneConf = import(".RuneConf").new()
--城战系统
conf.CityWarConf = import(".CityWarConf").new()
--神器系统
conf.ShenQiConf = import(".ShenQiConf").new()
--世界杯
conf.WorldCupConf = import(".WorldCupConf").new()
--五行
conf.WuxingConf = import(".WuxingConf").new()
--帝王将相
conf.DiWangConf = import(".DiWangConf").new()
--仙侣
conf.XianLvConf = import(".XianLvConf").new()
--刮刮乐
conf.ScratchConf = import(".ScratchConf").new()
--飞升
conf.FeiShengConf = import(".FeiShengConf").new()
--神兽
conf.ShenShouConf = import(".ShenShouConf").new()
--游讯
conf.YouXunConf = import(".YouXunConf").new()
--中秋活动
conf.ZhongQiuConf = import(".ZhongQiuConf").new()
--圣印
conf.ShengYinConf = import(".ShengYinConf").new()
--万神殿
conf.WanShenDianConf = import(".WanShenDianConf").new()
--国庆活动
conf.GuoQingConf = import(".GuoQingConf").new()
--万圣节
conf.WSJConf = import(".WSJConf").new()
--八门
conf.EightGatesConf = import(".EightGatesConf").new()
--感恩有你活动
conf.GanEnConf = import(".GanEnConf").new()
--帝魂
conf.DiHunConf = import(".DiHunConf").new()
--双十二后欧东
conf.ShuangShiErConf = import(".ShuangShiErConf").new()
--2018圣诞
conf.ShengDanConf = import(".ShengDanConf").new()
--面具
conf.MianJuConf = import(".MianJuConf").new()

--冬至
conf.DongZhiConf = import(".DongZhiConf").new()
--遗迹探索
conf.YiJiTanSuoConf = import(".YiJiTanSuoConf").new()
--元旦2018
conf.YuanDanConf = import(".YuanDanConf").new()

-- 奇兵
conf.QiBingConf = import(".QiBingConf").new()
-- 腊八2019
conf.LaBaConf2019 = import(".LaBaConf2019").new()
-- 生肖、生肖宝藏
conf.ShengXiaoConf = import(".ShengXiaoConf").new()
-- 小年
conf.XiaoNianConf = import(".XiaoNianConf").new()
--冰雪节活动
conf.BingXueConf = import(".BingXueConf").new()
--春节2019
conf.ChunJieConf2019 = import(".ChunJieConf2019").new()
return conf