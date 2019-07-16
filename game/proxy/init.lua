--[[
    网络的使用，
    所有以proxy.xxxxProxy使用
--]]

local proxy = {}

proxy.LoginProxy = import(".LoginProxy").new()--登录
proxy.PackProxy = import(".PackProxy").new()--背包
proxy.TaskProxy = import(".TaskProxy").new()--任务
proxy.PlayerProxy = import(".PlayerProxy").new()--玩家信息
proxy.ChatProxy = import(".ChatProxy").new()--聊天信息
proxy.FriendProxy = import(".FriendProxy").new()--好友信息
proxy.ThingProxy = import(".ThingProxy").new()--事物
proxy.ShopProxy = import(".ShopProxy").new()--商店系统
--技能系统
proxy.SkillProxy = import(".SkillProxy").new()
proxy.ForgingProxy = import(".ForgingProxy").new()--锻造系统
--
proxy.VipChargeProxy = import(".VipChargeProxy").new()--vip充值系统
proxy.ZuoQiProxy = import(".ZuoQiProxy").new() 
proxy.TalentProxy = import(".TalentProxy").new()
proxy.KageeProxy = import(".KageeProxy").new()--影卫系统
proxy.AwakenProxy = import(".AwakenProxy").new()--剑神系统
--
proxy.HuobanProxy = import(".HuobanProxy").new() --huoban
--帮派系统
proxy.BangPaiProxy = import(".BangPaiProxy").new() --huoban
proxy.MarketProxy = import(".MarketProxy").new() --市场系统

proxy.GrowthProxy = import(".GrowthProxy").new() --我要变强

proxy.FubenProxy = import(".FubenProxy").new()--副本系统

proxy.RedBagProxy = import(".RedBagProxy").new()--红包

proxy.RankProxy = import(".RankProxy").new() --排行榜

proxy.ImmortalityProxy = import(".ImmortalityProxy").new() --修仙

proxy.TradeProxy = import(".TradeProxy").new() --交易

proxy.ActivityProxy = import(".ActivityProxy").new()--活动

proxy.TeamProxy = import(".TeamProxy").new()--组队

proxy.ArenaProxy = import(".ArenaProxy").new()--竞技场 

proxy.WangcaiProxy = import(".WangcaiProxy").new()--旺财

proxy.HuanglingProxy = import(".HuanglingProxy").new()--皇陵之战

proxy.WenDingProxy = import(".WenDingProxy").new()--问鼎之战

proxy.GangWarProxy = import(".GangWarProxy").new()--仙盟战

proxy.SeeOtherMsgProxy = import(".SeeOtherMsgProxy").new()--查看信息

proxy.KuaFuProxy = import(".KuaFuProxy").new()--跨服战场

proxy.MarryProxy = import(".MarryProxy").new()--结婚系统

proxy.XianMoProxy = import(".XianMoProxy").new()--仙魔战
--家园系统
proxy.HomeProxy = import(".HomeProxy").new()

proxy.XmhdProxy = import(".XmhdProxy").new()--仙盟活动

proxy.ActivityWarProxy = import(".ActivityWarProxy").new()--活动玩法

proxy.BeachProxy = import(".BeachProxy").new()--魅力温泉

proxy.QualifierProxy = import(".QualifierProxy").new()--排位赛

proxy.PetProxy = import(".PetProxy").new()--宠物系统

proxy.RuneProxy = import(".RuneProxy").new()--符文系统

proxy.CityWarProxy = import(".CityWarProxy").new()--跨服城战

proxy.ShenQiProxy = import(".ShenQiProxy").new()--神器

proxy.DiWangProxy = import(".DiWangProxy").new()--帝王将相

proxy.XianLvProxy = import(".XianLvProxy").new()--仙侣Pk

proxy.FeiShengProxy = import(".FeiShengProxy").new()--飞升

proxy.ShenShouProxy = import(".ShenShouProxy").new()--神兽

proxy.YouXunProxy = import(".YouXunProxy").new()--神兽

proxy.ZhongqiuProxy = import(".ZhongqiuProxy").new()--中秋活动

proxy.WanShenDianProxy = import(".WanShenDianProxy").new()--万神殿

proxy.GuoQingProxy = import(".GuoQingProxy").new()--国庆活动

proxy.WSJProxy = import(".WSJProxy").new()--万圣节

proxy.TaiGuXuanJingProxy = import(".TaiGuXuanJingProxy").new()--太古玄境

proxy.GanEnProxy = import(".GanEnProxy").new()--感恩有你活动

proxy.DiHunProxy = import(".DiHunProxy").new()--帝魂

proxy.MianJuProxy = import(".MianJuProxy").new()--面具

proxy.ShuangShiErProxy = import(".ShuangShiErProxy").new()--双十二活动

proxy.ShengDanProxy = import(".ShengDanProxy").new()--2018圣诞节

proxy.DongZhiProxy = import(".DongZhiProxy").new()--冬至

proxy.YiJiTanSuoProxy = import(".YiJiTanSuoProxy").new()--遗迹探索

proxy.YuanDanProxy = import(".YuanDanProxy").new()--2018元旦
-- 奇兵
proxy.QiBingProxy = import(".QiBingProxy").new()
-- 腊八
proxy.LaBaProxy2019 = import(".LaBaProxy2019").new()
-- 生肖、生肖宝藏
proxy.ShengXiaoProxy = import(".ShengXiaoProxy").new()
-- 小年
proxy.XiaoNianProxy = import(".XiaoNianProxy").new()
--冰雪
proxy.BingXueProxy = import(".BingXueProxy").new()
--春节2019
proxy.ChunJieProxy2019 = import(".ChunJieProxy2019").new()
return proxy