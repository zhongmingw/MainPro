local cache = {}
--战斗相关缓存
cache.FightCache = import(".FightCache").new()
--背包缓存
cache.PackCache = import(".PackCache").new()
--玩家信息
cache.PlayerCache = import(".PlayerCache").new()
--任务信息
cache.TaskCache = import(".TaskCache").new() 
--聊天信息
cache.ChatCache = import(".ChatCache").new() 
--定时器
cache.TimerCache = import(".TimerCache").new()
--充值信息
cache.VipChargeCache = import(".VipChargeCache").new()
--坐骑信息
cache.ZuoQiCache = import(".ZuoQiCache").new()
--伙伴信息
cache.HuobanCache = import(".HuobanCache").new()
--帮派
cache.BangPaiCache = import(".BangPaiCache").new() 
--副本
cache.FubenCache = import(".FubenCache").new()
--交易
cache.TradeCache = import(".TradeCache").new()
--组队
cache.TeamCache = import(".TeamCache").new()
--竞技场
cache.ArenaCache = import(".ArenaCache").new()
--活动信息
cache.ActivityCache = import(".ActivityCache").new()
--问鼎
cache.WenDingCache = import(".WenDingCache").new()
--皇陵之战
cache.HuanglingCache = import(".HuanglingCache").new()
--仙盟战
cache.GangWarCache = import(".GangWarCache").new()
--引导的
cache.GuideCache = import(".GuideCache").new()
--跨服战场
cache.KuaFuCache = import(".KuaFuCache").new()
--结婚系统
cache.MarryCache = import(".MarryCache").new()
--
cache.ResCache = import(".ResCache").new()
--仙魔战
cache.XianMoCache = import(".XianMoCache").new()
--剑神殿
cache.AwakenCache = import(".AwakenCache").new()
--家园系统
cache.HomeCache = import(".HomeCache").new()
--仙盟争霸
cache.XmzbCache = import(".XmzbCache").new()
--活动玩法缓存
cache.ActivityWarCache = import(".ActivityWarCache").new()
--魅力沙滩
cache.BeachCache = import(".BeachCache").new()

--宠物系统
cache.PetCache = import(".PetCache").new()

--跨服排位缓存
cache.PwsCache = import(".PwsCache").new()
--符文缓存
cache.RuneCache = import(".RuneCache").new()
--城战缓存
cache.CityWarCache = import(".CityWarCache").new()
--神器缓存
cache.ShenQiCache = import(".ShenQiCache").new()
--仙侣PK
cache.XianLvCache = import(".XianLvCache").new()
--仙侣PK
cache.FeiShengCache = import(".FeiShengCache").new()
--神兽系统缓存
cache.ShenShouCache = import(".ShenShouCache").new()
--万神殿缓存
cache.WanShenDianCache = import(".WanShenDianCache").new()
--太古玄境缓存
cache.TaiGuXuanJingCache = import(".TaiGuXuanJingCache").new()
--合成缓存
cache.ComposeCache = import(".ComposeCache").new()
--帝魂缓存
cache.DiHunCache = import(".DiHunCache").new()
--面具缓存
cache.MianJuCache = import(".MianJuCache").new()
--遗迹探索缓存
cache.YiJiTanSuoCache = import(".YiJiTanSuoCache").new()

-- 奇兵
cache.QiBingCache = import(".QiBingCache").new()
-- 生肖、生肖宝藏
cache.ShengXiaoCache = import(".ShengXiaoCache").new()
return cache