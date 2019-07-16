--
-- Author: ohf
-- Date: 2017-02-22 17:08:05
--
--活动
local ActivityProxy = class("ActivityProxy",base.BaseProxy)

function ActivityProxy:init()
    self:add(5130102,self.add5130102)--在线送首冲
    --福利大厅
    self:add(5030101,self.add5030101)--使用礼包码
    self:add(5030102,self.add5030102)--请求在线时间福利
    self:add(5030103,self.add5030103)--请求签到信息
    self:add(5030104,self.add5030104)--请求领取离线经验
    self:add(5030105,self.add5030105)--请求vip专享特权
    self:add(5030107,self.add5030107)--请求vip礼包显示
    self:add(5030108,self.add5030108)--请求vip礼包领取
    self:add(5030113,self.add5030113)--请求资源找回列表信息
    self:add(5030130,self.add5030130)--请求离线挂机信息
    self:add(5030131,self.add5030131)--请求离线挂机日志
    self:add(5030132,self.add5030132)--请求掠夺信息列表
    self:add(5030133,self.add5030133)--请求离线挂机抢夺
    self:add(5030134,self.add5030134)--请求离线挂机奖励
    self:add(5030135,self.add5030135)--请求离线挂机战斗跳过
    self:add(5030318,self.add5030318)--请求限时特卖活动        --EVE 待添加

    self:add(5030106,self.add5030106)--30天登录奖励
    self:add(5030109,self.add5030109)--请求开服进阶大比拼排行榜信息
    self:add(5030110,self.add5030110)--请求开服进阶日领取信息
    self:add(5030112,self.add5030112)--请求连续充值活动
    self:add(5030114,self.add5030114)--请求首充团购
    self:add(5030115,self.add5030115)--请求百倍礼包信息
    self:add(5030116,self.add5030116)--请求每日特惠礼包信息
    self:add(5030117,self.add5030117)-- 开服任务信息
    self:add(5030118,self.add5030118)--请求开服投资计划信息
    self:add(5030119,self.add5030119)--请求等级投资计划信息
    self:add(5030214,self.add5030214)--请求物品投资计划信息
    self:add(5030120,self.add5030120)--请求每日累充信息
    self:add(5030121,self.add5030121)--请求每日首充信息
    self:add(5030122,self.add5030122)--请求元宝复制活动   --请求聚宝盆
    self:add(5030123,self.add5030123)--请求再充献礼信息
    self:add(5030124,self.add5030124)--请求每日一元
    self:add(5030140,self.add5030140)--请求等级礼包
    self:add(5030141,self.add5030141)--请求等级特卖
    self:add(5030201,self.add5030201)--请求意见反馈
    self:add(5030202,self.add5030202)--请求下载礼包
    self:add(5030125,self.add5030125)--请求在线送首充剩余份数
    self:add(5030203,self.add5030203)--请求特惠抢购
    self:add(5050403,self.add5050403)--请求隐藏任务
    self:add(5030204,self.add5030204)--请求活跃红包
    self:add(5030205,self.add5030205)--请求夏日活动
    self:add(5030212,self.add5030212)--请求天书活动
    self:add(5030152,self.add5030152)--请求装备寻宝信息
    self:add(5030153,self.add5030153)--请求天书寻宝积分商城
    self:add(5030154,self.add5030154)--请求临时仓库
    self:add(5030155,self.add5030155)--请求装备寻宝
    self:add(5030156,self.add5030156)--请求进阶寻宝信息
    self:add(5030158,self.add5030158)--请求铸星寻宝信息
    self:add(5030160,self.add5030160)--请求进阶寻宝
    self:add(5030161,self.add5030161)--请求铸星寻宝
    self:add(5030157,self.add5030157)--请求进阶寻宝积分商城
    self:add(5030159,self.add5030159)--请求铸星寻宝积分商城
    self:add(5030683,self.add5030683)--请求奇兵寻宝信息
    self:add(5030684,self.add5030684)--请求奇兵寻宝积分商城
    self:add(5030685,self.add5030685)--请求奇兵寻宝
    --宠物寻宝
    self:add(5030170,self.add5030170)--请求宠物寻宝信息
    self:add(5030171,self.add5030171)--请求宠物 寻宝积分商城
    self:add(5030172,self.add5030172)--请求宠物寻宝
    --神器寻宝
    self:add(5030189,self.add5030189)--请求神器寻宝信息
    self:add(5030190,self.add5030190)--请求神器寻宝积分商城
    self:add(5030191,self.add5030191)--请求神器寻宝
    --洪荒寻宝
    self:add(5030192,self.add5030192)--请求洪荒寻宝信息
    self:add(5030193,self.add5030193)--请求洪荒寻宝积分商城
    self:add(5030194,self.add5030194)--请求洪荒寻宝
    --剑灵寻宝
    self:add(5030195,self.add5030195)--请求剑灵寻宝信息
    self:add(5030196,self.add5030196)--请求剑灵寻宝积分商城
    self:add(5030197,self.add5030197)--请求剑灵寻宝
     --仙装寻宝
    self:add(5030246,self.add5030246)--请求仙装寻宝信息
    self:add(5030247,self.add5030247)--请求仙装寻宝积分商城
    self:add(5030248,self.add5030248)--请求仙装寻宝
    --圣印寻宝
    self:add(5030622,self.add5030622)--请求圣印寻宝信息
    self:add(5030623,self.add5030623)--请求圣印寻宝积分商城
    self:add(5030624,self.add5030624)--请求圣印寻宝
    --剑神寻宝
    self:add(5030630,self.add5030630)--请求剑神寻宝信息
    self:add(5030631,self.add5030631)--请求剑神寻宝积分商城
    self:add(5030632,self.add5030632)--请求剑神寻宝
    --鸿蒙寻宝
    self:add(5030693,self.add5030693)--请求鸿蒙寻宝信息
    self:add(5030694,self.add5030694)--请求鸿蒙寻宝积分商城
    self:add(5030695,self.add5030695)--请求鸿蒙寻宝


    --圣诞活动
    self:add(5030162,self.add5030162)--请求圣诞活动登录好礼
    self:add(5030163,self.add5030163)--请求圣诞活动许愿袜
    self:add(5030164,self.add5030164)--请求圣诞活动圣诞树
    self:add(5030165,self.add5030165)--请求圣诞活动排行

    --周末狂欢
    self:add(5030166,self.add5030166)--请求每周登录奖励
    self:add(5030167,self.add5030167)--请求每周活动副本双倍信息
    self:add(5030168,self.add5030168)--请求双倍活动副本信息
    self:add(5030169,self.add5030169)

    self:add(5030142,self.add5030142)-- 请求坐骑技能书特卖
    self:add(5030143,self.add5030142)-- 请求灵童技能书特卖
    self:add(5030126,self.add5030126)--请求仙盟排行
    self:add(5030207,self.add5030207)--请求冲级排行
    self:add(5030208,self.add5030208)--请求等级冲锋
    self:add(5030146,self.add5030146)--请求点石成金
    self:add(5030147,self.add5030147)--请求7天登陆
    self:add(5030209,self.add5030209)--请求疯狂砸蛋

    self:add(5030206,self.add5030206)-- 请求零元购
    self:add(5030151,self.add5030151)-- 集字活动
    self:add(5030210,self.add5030210)-- BOSS有奖

    self:add(5030211,self.add5030211)--请求封测返还
    --请求开服活动开关
    self:add(5030111,self.add5030111)
    self:add(5030145,self.add5030145)--请求七宝妙树
    self:add(5030148,self.add5030148)--请求战力排行
    self:add(5030149,self.add5030149)--请求跨服战力排行
    self:add(5030150,self.add5030150)--请求跨服战力排行
    self:add(5030301,self.add5030301)--请求云购活动
    self:add(5030401,self.add5030401)--请求(开服)云购活动
    self:add(5030183,self.add5030183)--请求宠物战力排行
    self:add(5030184,self.add5030184)--请求开服累充活动
    self:add(5030185,self.add5030185)--请求开服单笔充值活动
    self:add(5030187,self.add5030187)--请求合服投资计划
    self:add(5030403,self.add5030403)--请求合服红包返还
    self:add(5030404,self.add5030404)--请求开服红包返还

    --元旦消息系列
    self:add(5030303,self.add5030303)--请求兑换年货
    self:add(5030302,self.add5030302)--请求元旦登录奖励

    --腊八活动
    self:add(5030304,self.add5030304)--请求腊八登录奖励
    self:add(5030305,self.add5030305)--请求腊八活跃奖励
    self:add(5030307,self.add5030307)--请求腊八有礼
    self:add(5030306,self.add5030306)--请求腊八粥烹调
    self:add(5030308,self.add5030308)--请求腊八排行
    self:add(5030309,self.add5030309)--请求腊八副本双倍
    --转盘活动
    self:add(5030310,self.add5030310)-- 请求幸运转盘
    self:add(5030402,self.add5030402)-- 请求开服幸运转盘

    self:add(5030311,self.add5030311)--请求邀请码

    --情人节活动
    self:add(5030313,self.add5030313)--请求情侣抽奖
    self:add(5030314,self.add5030314)--请求情人节活跃

    --活动登录好礼活动(统一)
    self:add(5030175,self.add5030175)--请求登录豪礼（同一版本，多个活动共用）

    --春节活动
    self:add(5030315,self.add5030315)--   请求幸运灵签
    self:add(5030176,self.add5030176)--  请求全服红包信息
    self:add(5030177,self.add5030177)--  请求天降红包信息
    self:add(5030178,self.add5030178)--  请求天降红包抢红包

    --元宵灯会
    self:add(5030316,self.add5030316)--请求花灯兑奖
    self:add(5030317,self.add5030317)--元宵活跃活动

    self:add(5030312,self.add5030312)--请求烹调饺子
    
    self:add(5030186,self.add5030186)--充值消费排行活动

    self:add(5030188,self.add5030188)--请求充值夺宝活动

    --精彩活动
    self:add(5030405,self.add5030405)--超值返还
    self:add(5030406,self.add5030406)--超值兑换

    self:add(5030407,self.add5030407)--超值返还2
    self:add(5030408,self.add5030408)--超值兑换2
    self:add(5030320,self.add5030320)--鲜花榜
    self:add(5030327,self.add5030327)--鲜花榜
    
    self:add(5030411,self.add5030411)--合服折扣礼包
    
    self:add(5030409,self.add5030409)--开服神器排行
    self:add(5030410,self.add5030410)--限时神器排行
    self:add(5030413,self.add5030413)--神器寻宝返还

    self:add(5030501,self.add5030501)-- 请求世界杯信息
    self:add(5030502,self.add5030502)-- 请求世界杯兑换信息
    self:add(5030503,self.add5030503)-- 神炉炼宝

    self:add(5030412,self.add5030412)-- 充值翻牌活动
    self:add(5030321,self.add5030321)-- 充值返利活动
    self:add(5030322,self.add5030322)-- 婚礼排行榜
    self:add(5030323,self.add5030323)-- 三生三世(结婚称号)
    -- 射门好礼
    self:add(5030324, self.add5030324) --
    self:add(5030325, self.add5030325) --合服基金
    self:add(5030326, self.add5030326) --合服基金2
    self:add(5030504, self.add5030504) --摇钱树
    self:add(5030213, self.add5030213) --寻仙探宝

    self:add(5030217, self.add5030217) --神器寻主
    self:add(5030218, self.add5030218) --法老秘宝

    self:add(5030215, self.add5030215) --请求剑灵出世排行活动
    self:add(5030216, self.add5030216) -- 请求剑灵寻宝返还

    --充值回馈
    self:add(5030505,self.add5030505)

    self:add(5030222,self.add5030222)--充值豪礼
    self:add(5030223,self.add5030223)--恶魔时装
    self:add(5030224,self.add5030224)--机甲剑神活动

    self:add(5030220,self.add5030220)-- 请求宠物寻宝排行活动
    self:add(5030221,self.add5030221)-- 请求宠物寻宝返还活动\



    self:add(5030225,self.add5030225)--  请求单笔豪礼活动
   
    self:add(5030226, self.add5030226) -- 请求神臂擎天排行榜
    self:add(5030227, self.add5030227) -- 请求神臂擎天返回活动
    self:add(5030228, self.add5030228) -- 聚划算
    self:add(5030506, self.add5030506) -- 请求趣味挖矿
    self:add(5030508, self.add5030508) --  请求连充特惠
    self:add(5030507, self.add5030507) --   请求多开累冲特惠
    self:add(5030229, self.add5030229) --   请求消费兑换活动
    self:add(5030230, self.add5030230) -- 请求猴王除妖活动
	self:add(5030509, self.add5030509) -- 请求新摇钱树
    self:add(5030510, self.add5030510) --  请求欢乐购    
    self:add(5030511, self.add5030511) --  请求疯狂充值返利
    self:add(5030231, self.add5030231) --  请求冲战达人
    self:add(5030232, self.add5030232) --  请求超值单笔
    self:add(5030233, self.add5030233) -- 请求充值抽抽乐活动
    self:add(5030234, self.add5030234) -- 请求百发百中活动
    self:add(5030235, self.add5030235) -- 请求跨服充值排行
    self:add(5030236, self.add5030236) -- 请求仙娃排行
    self:add(5030237, self.add5030237) -- 请求洞房返还
    self:add(5030219, self.add5030219) -- 请求刮刮乐活动
    self:add(5030238, self.add5030238) -- 请求聚宝盆
    self:add(5030512, self.add5030512) --请求月卡
    self:add(5030239, self.add5030239) -- 请求秘境寻宝
    self:add(5030240, self.add5030240) -- 请求今日累充奖励
    self:add(5030513, self.add5030513) --  请求连续消费
    self:add(5030241, self.add5030241) --  请求天命卜卦活动信息
    self:add(5030242, self.add5030242) --请求老师请点名活动
    self:add(5030514, self.add5030514) --请求步步高升
    self:add(5030515, self.add5030515) -- 请求限时礼包
    self:add(5030243, self.add5030243) -- 无敌幸运星
    self:add(5030516, self.add5030516) --请求灵虚宝藏
    self:add(5030517, self.add5030517) -- 请求限时连充
    self:add(5030518, self.add5030518) --双倍返回
    self:add(5030519, self.add5030519) --我要转转
    self:add(5030520, self.add5030520) --双倍返回
	self:add(5030249, self.add5030249) -- 请求寻宝排行活动
    self:add(5030245, self.add5030245) --洞房排行
    self:add(5030522, self.add5030522) -- 请求元宝兑换
    self:add(5030521, self.add5030521) -- 合服连续充值
    self:add(5030250, self.add5030250) --仙装排行
	self:add(5030244, self.add5030244) --神兽排行
    self:add(5030607, self.add5030607) --中秋豪礼
    self:add(5030251, self.add5030251) --好运灵签
	
	--全民备战
	self:add(5030614, self.addMsgCallBackQMBZ) --好运灵签
	self:add(5030615, self.addMsgCallBackQMBZ) --好运灵签
	self:add(5030616, self.addMsgCallBackQMBZ) --好运灵签
	
	self:add(5030252, self.add5030252) --圣印排行
    self:add(5030625, self.add5030625) --圣印返还
    self:add(5030626, self.add5030626) -- 珍稀乾坤
    self:add(5030633, self.add5030633) -- 剑神装备寻宝返还
    self:add(5030253, self.add5030253) -- 剑神装备寻宝排行
    self:add(5030635, self.add5030635) -- 烟花庆典
    self:add(5030636, self.add5030636) -- 累计消费 
	self:add(5030637, self.add5030637) -- 幸运鉴宝
    self:add(5030639, self.add5030639) -- 万圣节累充活动
    self:add(5030640, self.add5030640) -- 捣蛋南瓜田活动
    self:add(5030645, self.add5030645) -- 双色球
    self:add(5030646, self.add5030646) -- 真假雪人    
    self:add(5030647, self.add5030647) -- 满减活动
    self:add(5030254, self.add5030254) -- 脱单领称号
    self:add(5030255, self.add5030255) -- 情侣充值排行榜    
    self:add(5030648, self.add5030648) -- 请求圣装寻宝返还（元素）    
    self:add(5030649, self.add5030649) -- 请求八门战力排行    
    self:add(5030650, self.add5030650) -- 请求天天返利活动   
    self:add(5030651, self.add5030651) -- 请求水果消除活动  
    self:add(5030655, self.add5030655) --  请求幸运锦鲤   
    self:add(5030656, self.add5030656) --  请求天降礼包 
    self:add(5030657,self.add5030657)--请求科举排行信息
    self:add(5030658,self.add5030658)--请求科举答题信息
    self:add(8240201,self.add8240201)--科举答题刷新广播
    self:add(8240202,self.add8240202)--科举答题排行刷新广播
    self:add(5030328,self.add5030328)-- 请求充值双倍活动（月末狂欢）

    self:add(5030414, self.add5030414) --  请求神器排行榜（合服）
    self:add(5030415,self.add5030415)--请求神器寻宝返还(合服)
    self:add(5030416,self.add5030416)-- 请求剑灵寻宝返还(合服)
    self:add(5030417,self.add5030417)--请求圣印寻宝返还(合服)
    self:add(5030418,self.add5030418)-- 请求剑灵出世排行活动(合服-跨服)
    self:add(5030419,self.add5030419)-- 请求圣印排行（合服-跨服）
    self:add(5030659,self.add5030659)-- 请求帝魂召唤

    self:add(5030666,self.add5030666)--  请求冬至抽奖活动
    self:add(5030667,self.add5030667)--  请求冬至连充活动

    self:add(5030687,self.add5030687)-- 请求奇兵战力排行
    self:add(5030686,self.add5030686)--  请求冬至连充活动
    self:add(5030692,self.add5030692)--  请求腊八累抽

    --腊八活动（2019）
    self:add(5030691,self.add5030691)--请求腊八消费排行榜
end
--设置前往活动 --为跳转预留
function ActivityProxy:setActiveID(var)
    -- body
    self.activeid = var
end

function ActivityProxy:getActiveID()
    -- body
    return self.activeid
end

function ActivityProxy:sendMsg(msgId, param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function ActivityProxy:addMsgCallBackQMBZ(data)
	if data.status == 0 then
		printt("addMsgCallBackQMBZ.",data)
		local view = mgr.ViewMgr:get(ViewName.QuanMingView)
		if view then
			view:addMsgCallBack(data)
		end
	else
		GComErrorMsg(data.status)
		
		if data.status == 21070029 then
			local view = mgr.ViewMgr:get(ViewName.QuanMingView)
			if view then
				self:sendMsg(1030616,{reqType = 0,cid = 0})
			end
		end
	end
end

function ActivityProxy:send1130102()
    self:send(1130102)
end
--在线送首冲
function ActivityProxy:add5130102(data)
    if data.status == 0 then
        -- printt(data)
        cache.PlayerCache:setAttribute(30104,0)
        local mainview = mgr.ViewMgr:get(ViewName.MainView)
        if mainview then
            mainview.TopActive:checkActive()
        end
        local view = mgr.ViewMgr:get(ViewName.FirstChargeView)
        if view then
            view:add5130102(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--使用礼包码
function ActivityProxy:add5030101(data)
    if data.status == 0 then
        if data.items and #data.items>0 then
            GOpenAlert3(data.items)
        end
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updatelvLbM(data)
        end
        -- self:refreshWelView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求在线时间福利
function ActivityProxy:add5030102(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateOnline(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求签到信息
function ActivityProxy:add5030103(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateSign(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求领取离线经验
function ActivityProxy:add5030104(data)
    if data.status == 0 then
        self:refreshWelView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求vip专享特权
function ActivityProxy:add5030105(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateXianzhun(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--30天登录奖励
function ActivityProxy:add5030106(data)
    if data.status == 0 then
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20120)
            cache.PlayerCache:setRedpoint(attConst.A20120,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end

        local view = mgr.ViewMgr:get(ViewName.LoginAwardView)
        if view then
            view:add5030106(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求vip礼包显示
function ActivityProxy:add5030107(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateVip(data)
        end
        local view = mgr.ViewMgr:get(ViewName.PanicBuyView)
        if view then
            view:updateVip(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求vip礼包领取
function ActivityProxy:add5030108(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateVip(data)
        end
        local view = mgr.ViewMgr:get(ViewName.PanicBuyView)
        if view then
            view:updateVip(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求资源找回列表信息
function ActivityProxy:add5030113(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateResData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求离线挂机信息返回
function ActivityProxy:add5030130(data)
    -- body
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateOffHook(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求离线挂机日志返回
function ActivityProxy:add5030131(data)
    -- body
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateOffHook(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求掠夺信息列表返回
function ActivityProxy:add5030132(data)
    -- body
    if data.status == 0 then
        -- self:refreshWelView(data)
        if data.leftTimes == 0 then
            cache.PlayerCache:setRedpoint(20137,0)
        end
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateOffHook(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求离线挂机抢夺返回
function ActivityProxy:add5030133(data)
    -- body
    if data.status == 0 then
        local var = cache.PlayerCache:getRedPointById(20137)
        cache.PlayerCache:setRedpoint(20137,var-1)
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view.classObj[3]:canClick()
        end
        if data.items and #data.items>0 then
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end
end
--离线挂机奖励
function ActivityProxy:add5030134(data)
    -- body
    if data.status == 0 and not g_ios_test then   --EVE ios版属屏蔽
        mgr.ViewMgr:openView(ViewName.HookAwardsView,function(view)
            view:setData(data)
        end)


    else
        mgr.XinShouMgr:checkModuleOpen()
        -- GComErrorMsg(data.status)
    end
end
--离线挂机跳过战斗
function ActivityProxy:add5030135(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:initData({index = 3,childIndex = 2})
        end
    else
        GComErrorMsg(data.status)
    end
end
--限时特卖
function ActivityProxy:add5030318(data)
    if data.status == 0 then
        --if data.reqType == 1 then
         --   local var = cache.PlayerCache:getRedPointById(10256)
         --   cache.PlayerCache:setRedpoint(10256,var-1)
         --   local mainview = mgr.ViewMgr:get(ViewName.MainView)
         --   if mainview then
         --       mainview:refreshRed()
         --   end
        --end

        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateFlashSalePanel(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--活动开关
function ActivityProxy:add5030111(data)
    -- body
    if data.status == 0 then
        -- printt(data.acts)
        -- for k,v in pairs(data.acts) do
        --     print(k,v)
        -- end
        -- plog("shuchengnidaddfasdfafasdfs")
        cache.ActivityCache:set5030111(data)
        --中秋
        local view = mgr.ViewMgr:get(ViewName.ZhongQiuView)
        if view then 
            local param = {id = view.param.showId}
            view:initData(param)
        end
		--全服备战
		local view = mgr.ViewMgr:get(ViewName.QuanMingView)
        if view then 
            local param = {id = view.param.showId}
            view:initData(param)
        end


        local view = mgr.ViewMgr:get(ViewName.KaiFuRank)
        if view then
            view:closeView()
        end
        if table.nums(data.acts) >0 then --开服活动
            local view  = mgr.ViewMgr:get(ViewName.KaiFuMainView)
            if view then
                --设置活动
                view:setData(data)
                --活动跳转
                local param = {id = self:getActiveID()}
                view:nextStep(param)
                --清理
                self:setActiveID()
            end
            --百倍礼包活动
            local view = mgr.ViewMgr:get(ViewName.BaibeiGiftView)
            if view then
                if data.acts[1027] and data.acts[1027] == 1 then
                    view:sendMsg()
                else
                    GComErrorMsg(2030114)
                    view:closeView()
                end
            end
            --投资计划
            local view = mgr.ViewMgr:get(ViewName.InvestView)
            if view then
                if data.acts[1029] and data.acts[1029] == 1 then
                    view:onController()
                else
                    view:hideOpenInvest()
                end
            end
            --幸运进阶日
            local view = mgr.ViewMgr:get(ViewName.LuckyAdvanceView)
            if view then
                view:setData(data)
            end
            --特惠抢购
            local view = mgr.ViewMgr:get(ViewName.PanicBuyView)
            if view then
                view:initData({})
            end
        else
            local view  = mgr.ViewMgr:get(ViewName.KaiFuMainView)
            if view then
                GComAlter(language.kaifu05)
                view:onBtnClose()
            end
        end
        local view2 = mgr.ViewMgr:get(ViewName.DayActiveView)
        if view2 then
            local flag = false
            for i=1009,1016 do
                if data.acts[i] and data.acts[i] == 1 then
                    flag = true
                    break
                end
            end
            -- print("当前活动是否还存在",flag)
            if flag then
                view2:setData(data)
            else
                GComAlter(language.vip11)
                view2:onBtnClose()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:checkOpen({btnfight = true})
        end
        local summerPush = cache.ActivityCache:getSummerPush()
        local var = cache.PlayerCache:getAttribute(10322) or 0
        -- print("抽奖活动首次登陆",summerPush)

        if var == 1 and summerPush == 1 and data.acts[1038] and data.acts[1038] == 1 and mgr.ModuleMgr:CheckView(1111) then
            cache.ActivityCache:setSummerPush(0)
            if cache.PlayerCache:getAttribute(30114) < 12 then
                mgr.ViewMgr:openView2(ViewName.GuideActive, {id = 1111})
            end
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            -- view:initRedPoint()
        end


    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030109(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KaiFuRank)
        if view then
            view:add1030109(data)
            return
        end

        local view = mgr.ViewMgr:get(ViewName.JinJieRankMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


function ActivityProxy:add5030110(data)
    -- body
    if data.status == 0 then
        if data.reqType == 1 or data.reqType == 2 then
            local confdata = conf.ActivityConf:getActiveById(self.param.actId)
            if confdata.redid then
                local var = cache.PlayerCache:getRedPointById(confdata.redid)
                if data.reqType == 2 then
                    cache.PlayerCache:setRedpoint(confdata.redid,0)
                else
                    cache.PlayerCache:setRedpoint(confdata.redid,var-1)
                end
                mgr.GuiMgr:updateRedPointPanels(confdata.redid)
                -- print("刷新主界面红点",var-1,confdata.redid)
                local mainview = mgr.ViewMgr:get(ViewName.MainView)
                if mainview then
                    mainview:refreshRed()
                end
            end
            if data.items and #data.items>0 then
                GOpenAlert3(data.items)
            end
        end

        local view = mgr.ViewMgr:get(ViewName.DayActiveView)
        if view then
            view:addMsgCallBack(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.LuckyAdvanceView)
        if view2 then
            view2:setMsg5030110(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030112(data)
    -- body
    if data.status == 0 then
        if data.reqType == 1 then
            local confdata = conf.ActivityConf:getActiveById(1024)
            if confdata.redid then
                local var = cache.PlayerCache:getRedPointById(confdata.redid)
                cache.PlayerCache:setRedpoint(confdata.redid,var-1)
                mgr.GuiMgr:updateRedPointPanels(confdata.redid)
            end
        end

        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030114( data)
    -- body
    if data.status == 0 then
        if data.reqType == 1 then
            local confdata = conf.ActivityConf:getActiveById(1025)
            if confdata.redid then
                local var = cache.PlayerCache:getRedPointById(confdata.redid)
                cache.PlayerCache:setRedpoint(confdata.redid,var-1)
                mgr.GuiMgr:updateRedPointPanels(confdata.redid)
            end
        end
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030115( data )
    -- body
    -- print("百倍返回",data.status)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BaibeiGiftView)
        if view then
            view:setData(data)
        end
        if data.items and #data.items>0 then
            GOpenAlert3(data.items)
        end
    elseif data.status == 2030114 then
        local view = mgr.ViewMgr:get(ViewName.BaibeiGiftView)
        if view then
            GComErrorMsg(data.status)
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030116( data )
    -- body
    if data.status == 0 then
        -- printt(data)
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.DayActiveView)
        if view2 then
            view2:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.PanicBuyView)
        if view then
            view:updateOddsGift(data)
        end

        --保存购买记录
        local key = g_var.accountId.."1026buy"
        local _t = {}
        for k , v in pairs(data.leftCountMap) do
            if v == 0 then
                table.insert(_t,k)
            end
        end
        UPlayerPrefs.SetString(key,json.encode(_t))
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030118( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.InvestView)
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20118)
            cache.PlayerCache:setRedpoint(attConst.A20118,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        if view then
            view.KaifuInvest:setData(data)
            view:refreshRed()
            if data.items then
                GOpenAlert3(data.items)
            end
        end
    elseif data.status == 2030114 then

    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030119( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.InvestView)
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20119)
            cache.PlayerCache:setRedpoint(attConst.A20119,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        if view then
            view.LevelInvest:setData(data)
            view:refreshRed()
            if data.items then
                GOpenAlert3(data.items)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--开服物品投资
function ActivityProxy:add5030214(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.InvestView)
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20187)
            cache.PlayerCache:setRedpoint(attConst.A20187,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        if view and view.GoodsInvest then
            view.GoodsInvest:setData(data)
            view:refreshRed()
            if data.items then
                GOpenAlert3(data.items)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030120( data )
    -- body
    if data.status == 0 then
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20125)
            -- print("9999999001",var)
            if data.activityId == 1028 then
                cache.PlayerCache:setRedpoint(attConst.A20125,var-1)
                mgr.GuiMgr:updateRedPointPanels(attConst.A20125)
            else
                var = cache.PlayerCache:getRedPointById(20135)
                cache.PlayerCache:setRedpoint(20135,var-1)
                mgr.GuiMgr:updateRedPointPanels(20135)
                -- print("9999999002",var)
            end
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:refreshRedTop()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.DayActiveView)
        if view2 then
            view2:addMsgCallBack(data)
        end
        if data.items and #data.items>0 then
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030121( data )
    -- body
    if data.status == 0 then
        cache.ActivityCache:set5030121(data)
        local view = mgr.ViewMgr:get(ViewName.DayFirstChargeView)
        local actData = cache.ActivityCache:get5030111()
        if actData and actData.openDay > 7 then
            view = mgr.ViewMgr:get(ViewName.DayFirstChargeOther)
        end
        -- printt("开服前九天",data)
        if view then
            view:add5030121(data)
            view:skipToNextPage(data)
        end

        if data.reqType == 1 then
            --检测是否还有可领取的
            local flag = false
            for k ,v in pairs(data.ItemStatus) do
                if v ~= 2 then
                    flag = true
                    break
                end
            end

            -- if not flag then
            --     --已经全部领取完成
            --     if view then
            --         view:onClickClose()
            --     end
            --     cache.PlayerCache:setRedpoint(30115,0)
            --     local mainview = mgr.ViewMgr:get(ViewName.MainView)
            --     if mainview and mainview.TopActive then
            --         mainview.TopActive:checkActive(30115)
            --     end
            --     return
            -- end
            local var = cache.PlayerCache:getRedPointById(attConst.A20124)
            -- print("领取减一",var)
            cache.PlayerCache:setRedpoint(attConst.A20124,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20124)
            -- print("领取累积减一",var)
            cache.PlayerCache:setRedpoint(attConst.A20124,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030117( data )
    -- body
    if data.status == 0 then
        if data.reqType == 1 then
            local confdata = conf.ActivityConf:getActiveById(1017)
            if confdata.redid then
                local var = cache.PlayerCache:getRedPointById(confdata.redid)
                cache.PlayerCache:setRedpoint(confdata.redid,var-1)
                mgr.GuiMgr:updateRedPointPanels(confdata.redid)
                mgr.GuiMgr:refreshRedTop()
            end
            --printt(data.items)
            GOpenAlert3(data.items)
        end

        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end


    else
        GComErrorMsg(data.status)
    end
end

--聚宝盆
function ActivityProxy:add5030122( data )
    if data.status == 0 then
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20121)
            -- var = var-1>0 and var-1 or 0
            cache.PlayerCache:setRedpoint(attConst.A20121,var)
            -- mgr.GuiMgr:updateRedPointPanels(attConst.A20121)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        if data.curCopyType == 5 then  --活动结束，关闭入口
           --活动结束
            cache.PlayerCache:setAttribute(30101, 0)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview.TopActive:checkActive()
            end
        end

        local view = mgr.ViewMgr:get(ViewName.IngotCopy)
        if view then
            view:setData(data)
            if data.items and #data.items>0 then
                mgr.TimerMgr:addTimer(3, 1, function()
                    local view02 = mgr.ViewMgr:get(ViewName.IngotCopy)
                    if view02 then
                        view:resetPointer()  --指针回位
                        view:setBtnTouchable() --设置下注按钮可用
                    end
                    GOpenAlert3(data.items)   -- 恭喜获得~~

                    --取消隐藏任务
                    -- cache.ActivityCache:set5030122(data.items)
                    -- local over1104 = UPlayerPrefs.GetString(g_var.accountId.."over1104")
                    -- local time1104 = UPlayerPrefs.GetString(g_var.accountId .. "1104")
                    -- local flag = true
                    -- if time1104 and time1104~="" then
                    -- local pass = mgr.NetMgr:getServerTime() - tonumber(time1104)
                    --     if pass >= 20*60 then
                    --         --超时了
                    --         flag = false
                    --     end
                    -- end

                    -- if not over1104 or over1104 == "" and flag then
                    --     -- plog("你是猪！")
                    --     proxy.ActivityProxy:sendMsg(1050403,{reqType = 2})
                    --     UPlayerPrefs.SetString(g_var.accountId.."over1104", mgr.NetMgr:getServerTime().."")
                    --     local checkView = mgr.ViewMgr:get(ViewName.MainView)
                    --     if checkView and checkView.TopActive then
                    --         checkView.TopActive:check1104(true, true)
                    --     end
                    -- else
                    --     GOpenAlert3(data.items)   -- 恭喜获得~~
                    -- end
                end)
             end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030123( data )

    if data.status == 0 then
        --登陆时充值状态缓存到PlayerCache
        cache.ActivityCache:set5030123(data.gotList)
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20123)
            cache.PlayerCache:setRedpoint(attConst.A20123,var-1)
            -- mgr.GuiMgr:updateRedPointPanels(attConst.A20123)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end

        local view = mgr.ViewMgr:get(ViewName.RechargeAgain)
        if view then
            view:add5030123(data)
            -- if data.reqType == 1 then
            view:skipToNextPage(data)
            -- end
            -- view:setData(data)
            if data.items and #data.items>0 then
                local mainview = mgr.ViewMgr:get(ViewName.MainView)
                if mainview then
                    mainview.TopActive:check1054()
                end
                GOpenAlert3(data.items)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--每日一元
function ActivityProxy:add5030124( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DayOneRmbView)
        if view then
            view:setData(data)
        end

        if data.reqType == 1 then
            -- local var = cache.PlayerCache:getRedPointById(attConst.A20122)
            -- cache.PlayerCache:setRedpoint(attConst.A20122,var-1)
            -- local mainview = mgr.ViewMgr:get(ViewName.MainView)
            -- if mainview then
            --     mainview:refreshRed()
            -- end
            cache.PlayerCache:setAttribute(30103,0)

            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview and mainview.TopActive then
                mainview.TopActive:checkActive(1057)
            end
            if view then
                view:onClickClose()
            end
            return
        end

    else
        GComErrorMsg(data.status)
    end
end

--福利大厅
function ActivityProxy:refreshWelView(data)
    local view = mgr.ViewMgr:get(ViewName.WelfareView)
    if view then
        view:setData(data)
    end
end

--等级礼包
function ActivityProxy:add5030140(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        -- local condata = conf.ActivityConf:getGradePackageData()
        -- if #condata == #data.signs then
        --     --全部领取完成
        --     -- cache.PlayerCache:setRedpoint(attConst.A20153,0)

        --     local view = mgr.ViewMgr:get(ViewName.MainView)
        --     if view then
        --         view:refreshGradePackge()
        --     end
        -- else
        --     for k , v in pairs(condata) do
        --         local falg = false
        --         for i , j in pairs(data.signs) do
        --             if v.id == j then
        --                 falg = true
        --                 break
        --             end
        --         end

        --         if not falg then
        --             -- cache.PlayerCache:setRedpoint(attConst.A20153,v.id)

        --             local view = mgr.ViewMgr:get(ViewName.MainView)
        --             if view then
        --                 -- print("领取完，变一次")
        --                 view:refreshGradePackge()
        --             end
        --             break
        --         end
        --     end
        -- end
        -- local view = mgr.ViewMgr:get(ViewName.MainView)
        -- if view and view.taskorTeam then
        --     view.taskorTeam:setItemMsg()
        -- end

        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateGradePackage(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--等级特卖
function ActivityProxy:add5030141(data)
    if data.status == 0 then
        -- self:refreshWelView(data)
        local view = mgr.ViewMgr:get(ViewName.PanicBuyView)
        if view then
            view:updatelvBuy(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求意见反馈
function ActivityProxy:add5030201(data)
    if data.status == 0 then
        -- --领取弹窗
        -- if data.items and #data.items>0 then
        --     GOpenAlert3(data.items)
        -- end
        -- local view = mgr.ViewMgr:get(ViewName.SiteView)   --意见反馈调整到设置面板
        -- if view then
        --     view:setDataOfFeedBack(data)    --这里从setData()函数变更
        -- end
    else
        GComErrorMsg(data.status)
    end
end
--请求下载礼包
function ActivityProxy:add5030202(data)
    if data.status == 0 then
        local downView = mgr.ViewMgr:get(ViewName.DownLoadView)
        if downView then
            downView:setData(data)
        end
        if data.reqType == 2 then
            if downView then
                downView:onClickClose()
            end
            mgr.ViewMgr:openView2(ViewName.DownLoadFinish, data)
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view.TopActive:checkBackDown()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求在线送首充剩余份数返回
function ActivityProxy:add5030125(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FirstChargeView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求特惠抢购
function ActivityProxy:add5030203(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PanicBuyView)
        if view then
            view:updatePanic(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求隐藏任务
function ActivityProxy:add5050403(data)
    if data.status == 0 then
        --领取弹窗
        if data.items and #data.items>0 then
            local items = cache.ActivityCache:get5030122()
            if items then
                for k,v in pairs(data.items) do
                    table.insert(items,v)
                end
                GOpenAlert3(items)   -- 恭喜获得(加入了隐藏任务奖励)~~
            end
        end
    else
        plog("data.status",data.status)
        GComErrorMsg(data.status)
    end
end

-- 请求坐骑技能书特卖
function ActivityProxy:add5030142(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PanicBuyView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙盟排行
function ActivityProxy:add5030126(data)
    if data.status == 0 then
        -- plog("??5030126")
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求冲级排行
function ActivityProxy:add5030207(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JinJieRankMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求等级冲锋
function ActivityProxy:add5030208(data)
    if data.status == 0 then
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(30116)
            cache.PlayerCache:setRedpoint(30116,var-1)
            mgr.GuiMgr:updateRedPointPanels(30116)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030204( data )
    if data.status == 0 then
        if data.reqType == 2 then
            -- print("领取时装")
            local var = cache.PlayerCache:getRedPointById(30113)
            cache.PlayerCache:setRedpoint(30113,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            if data.items and #data.items > 0 then
                GOpenAlert3(data.items)
            end
        end
        local view = mgr.ViewMgr:get(ViewName.ActiveRedBag)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030205( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SummerActsView)
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(30110)
            cache.PlayerCache:setRedpoint(30110,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求天书活动
function ActivityProxy:add5030212(data)
    if data.status == 0 then
        -- print("消息返回成功：")
        if data.reqType == 1 or data.reqType == 2 then
            local curSetRedPoint
            if data.reqType == 1 then
                curSetRedPoint = 30124
            else
                curSetRedPoint = 30126
            end

            local var = cache.PlayerCache:getRedPointById(curSetRedPoint)
            cache.PlayerCache:setRedpoint(curSetRedPoint, var-1)

            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRedTop()
            end
        else
            -- print("不做处理时的红点值", cache.PlayerCache:getRedPointById(30124))
            -- print("BUFFFFFFFF",cache.PlayerCache:getRedPointById(30124))
        end

        local view = mgr.ViewMgr:get(ViewName.HighGradePackageView)
        if view then
            view:setData(data)
        end

    else
        GComErrorMsg(data.status)
		cache.GuideCache:setGuide(nil)
    end
end

--请求装备寻宝信息
function ActivityProxy:add5030152(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求进阶寻宝信息
function ActivityProxy:add5030156(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求铸星寻宝信息
function ActivityProxy:add5030158(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setZhuXingData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求神器寻宝信息
function ActivityProxy:add5030189(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end

--请求洪荒寻宝信息
function ActivityProxy:add5030192(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求剑灵寻宝信息
function ActivityProxy:add5030195(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end
-- 请求仙装寻宝
function ActivityProxy:add5030246( data )
    -- body
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求圣印寻宝信息
function ActivityProxy:add5030622(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end

--请求圣印寻宝信息（合服）
function ActivityProxy:add5030417(data)
    if data.status == 0 then
         local view = mgr.ViewMgr:get(ViewName.ShengYinReturn)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求剑神寻宝信息
function ActivityProxy:add5030630(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end

--请求鸿蒙寻宝信息
function ActivityProxy:add5030693(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end

--刷新寻宝界面
function ActivityProxy:refreshXunBaoView(data)
    -- body
    local view = mgr.ViewMgr:get(ViewName.XunBaoView)
    if view then
        view:setData(data)
    end
end

--请求装备寻宝积分商城
function ActivityProxy:add5030153(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  --刷新积分
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求进阶寻宝积分商城
function ActivityProxy:add5030157(data)
     if data.status == 0 then
        -- proxy.ActivityProxy:sendMsg(1030152)
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  --刷新进阶积分
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求铸星寻宝积分商城
function ActivityProxy:add5030159(data)
    if data.status == 0 then
        -- proxy.ActivityProxy:sendMsg(1030152)
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  --刷新铸星积分
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求神器寻宝积分商城
function ActivityProxy:add5030190(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求洪荒寻宝积分商城
function ActivityProxy:add5030193(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙装积分商城
function ActivityProxy:add5030247(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑灵寻宝积分商城
function ActivityProxy:add5030196(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求圣印寻宝积分商城
function ActivityProxy:add5030623(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑神寻宝积分商城
function ActivityProxy:add5030631(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求鸿蒙寻宝积分商城
function ActivityProxy:add5030694(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求临时仓库
function ActivityProxy:add5030154(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LimitWareView)
        if view then
            view:setData(data)
        end
        if data.reqType == 2 then
            local var1 = cache.PlayerCache:getRedPointById(attConst.A30125)
            cache.PlayerCache:setRedpoint(30125,var1-1)  --刷新顶部按钮的红点
            -- cache.PlayerCache:setRedpoint(30128,var1-1)  --刷新顶部按钮的红点
            -- cache.PlayerCache:setRedpoint(30129,var1-1)  --刷新顶部按钮的红点
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            local view = mgr.ViewMgr:get(ViewName.XunBaoView)
            if view then
                view:refreshLimitWare()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求装备寻宝
function ActivityProxy:add5030155(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030152)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求进阶寻宝
function ActivityProxy:add5030160(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030156)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求铸星寻宝
function ActivityProxy:add5030161(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030158)  --再请求一次铸星信息
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setZhuXingData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神器寻宝
function ActivityProxy:add5030191(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030189)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求洪荒寻宝
function ActivityProxy:add5030194(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030192)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙装寻宝
function ActivityProxy:add5030248(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030246)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑灵寻宝
function ActivityProxy:add5030197(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030195)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求圣印寻宝
function ActivityProxy:add5030624(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030622)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑神寻宝
function ActivityProxy:add5030632(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030630)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求鸿蒙寻宝
function ActivityProxy:add5030695(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030693)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求宠物寻宝信息
function ActivityProxy:add5030170(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end

--请求宠物寻宝积分商城
function ActivityProxy:add5030171(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)  --刷新积分
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求宠物寻宝
function ActivityProxy:add5030172(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        proxy.ActivityProxy:sendMsg(1030170)
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData()  --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030206(data)
    -- body
    if data.status == 0 then
        --清除跳转
        -- print("第几天",data.openDay)
        local id = self:getActiveID()
        self:setActiveID(nil)

        local key = g_var.accountId.."3010buy"
        local _t = {}
        for k ,v in pairs(data.signMap) do
            if v == 1 then
                table.insert(_t,k)
            end
        end
        UPlayerPrefs.SetString(key,json.encode(_t))
        --如果是购买要记录
        if data.reqType == 1 then


            -- local key = g_var.accountId.."3010buy"
            -- local _localbuy = UPlayerPrefs.GetString(key)
            -- local _t = {}
            -- if _localbuy ~= "" then
            --     _t = json.decode(_localbuy)
            --     local flag = true
            --     for k , v in pairs(_t) do
            --         if tonumber(v) == tonumber(data.cId) then
            --             flag = false
            --             break
            --         end
            --     end
            --     if flag then
            --         table.insert(_t,data.cId)
            --     end
            -- else
            --     table.insert(_t,data.cId)
            -- end
            -- UPlayerPrefs.SetString(key,json.encode(_t))

            --恭喜获得
            GOpenAlert3(data.items)
            --红点扣除
            local _condata = conf.ActivityConf:getZerobuyItem(data.cId)
            if _condata and _condata.price and _condata.price[1] == 0 then
                local redid = 30112
                local var = cache.PlayerCache:getRedPointById(redid) - 1
                cache.PlayerCache:setRedpoint(redid, var)
                mgr.GuiMgr:refreshRedTop()
            end
        end
        local _view = mgr.ViewMgr:get(ViewName.LingyuanView)
        --按天数获取按钮
        local condata =  conf.ActivityConf:getZerobuy(data)
        local number = #condata
        if number == 0 then --没有可购买的
            GComAlter(language.vip11)
            if _view then
                _view:closeView()
            end
            cache.PlayerCache:setRedpoint(30111,0)
            local _mainView = mgr.ViewMgr:get(ViewName.MainView)
            if _mainView and _mainView.TopActive then
                _mainView.TopActive:checkActive()
            end
            return
        end
        if data.reqType == 0 then
            local info = {_condata = condata, index = id,param = data}
            if not _view then
                mgr.ViewMgr:openView2(ViewName.LingyuanView,info)
            else
                _view:initData(info)
            end
        else
            if _view then
                --_view:setBtndata(condata)
                _view:add5030206(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求七宝妙树
function ActivityProxy:add5030145(data)
    if data.status == 0 then
        if (data.reqType == 2 or data.reqType == 3) and data.leftTimes == 0 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20147)
            --plog("宝树红点减减减",var)
            cache.PlayerCache:setRedpoint(attConst.A20147,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end

        if (data.reqType == 2 or data.reqType == 3) and data.items then
            GOpenAlert3(data.items)
        end

        local view = mgr.ViewMgr:get(ViewName.ActiveTree)
        if view then
            view:setData(data)
        end

        if data.reqType == 4 then
            -- plog("记录记录~~~~~~~~~~~~~~~")
            local tipsView = mgr.ViewMgr:get(ViewName.ActiveTreePopupView)
            if not tipsView then
                mgr.ViewMgr:openView2(ViewName.ActiveTreePopupView, data)
            end
        end

        if data.reqType == 5 and data.items then
            local var = cache.PlayerCache:getRedPointById(attConst.A20147)
            --plog("宝树红点减减减---------",var)
            cache.PlayerCache:setRedpoint(attConst.A20147,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求点石成金返回
function ActivityProxy:add5030146(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MidasTouchView)
        if view then
            view:setData(data)
        end
        if data.itemInfos and #data.itemInfos > 0 then
            GOpenAlert3(data.itemInfos)
        end
        if data.reqType == 3 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20149)
            cache.PlayerCache:setRedpoint(attConst.A20149,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求7天登陆返回
function ActivityProxy:add5030147(data)
    if data.status == 0 then
        if data.reqType == 0 then
            -- print("显示",data)
            -- printt(data)
        else
            -- print("领取",data)
            -- printt(data)refreshRed
            local num = 0
            for k,v in pairs(data.gotAwardIdList) do
                num = num + 1
            end
            local var = cache.PlayerCache:getRedPointById(attConst.A20148)
            cache.PlayerCache:setRedpoint(attConst.A20148,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
                if num == 7 then
                    cache.PlayerCache:setRedpoint(30117,0)
                    mainview.TopActive:checkActive()
                end
            end
            if data.items and #data.items > 0 then
                -- print("奖励")
                -- printt(data.items)
                local mId = data.items[1].mid
                local modelType = conf.ItemConf:getAutoUseType(mId)
                local id = conf.ItemConf:getItemExt(mId)
                local index = nil
                if not modelType then
                    local itemType = conf.ItemConf:getType(mId)
                    if itemType == Pack.equipType then
                        GOpenAlert3(data.items)
                    end
                else
                    if modelType == 10 then--伙伴
                        index = 5
                    elseif modelType == 27 then--时装
                        local fashData = conf.RoleConf:getFashData(id)
                        -- print("服务器返回id",mId,id,fashData.model)
                        local _type = fashData.type
                        if _type == 1 then
                            id = fashData.model
                            index = 12
                        else
                            index = 13
                        end
                    elseif modelType == 9 then--称号
                        index = 14
                    end
                    local data = {id = id,index = index,isQitian = true}
                    mgr.ViewMgr:openView2(ViewName.GuideZuoqi, data)
                end
            end
        end
        local view = mgr.ViewMgr:get(ViewName.SevenDaysView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求疯狂砸蛋返回
function ActivityProxy:add5030209( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SmashEggsView)
        if view then
            view:setData(data)
        end
        if data.items and #data.items > 0 then
            GOpenAlert3(data.items)
        end
        local view2 = mgr.ViewMgr:get(ViewName.CheckAwardsView)
        if view2 then
            view2:refreshView(data)
        end
        if data.reqType == 2 or data.reqType == 6 then
            local var = cache.PlayerCache:getRedPointById(30118)
            cache.PlayerCache:setRedpoint(30118,var-1)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求战力排行
function ActivityProxy:add5030148(data)
    if data.status == 0 then
        -- plog("data.lastTime",data.lastTime)
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求跨服战力排行
function ActivityProxy:add5030149(data)
    if data.status == 0 then
        -- plog("data.lastTime",data.lastTime)
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求开服装备战力排行
function ActivityProxy:add5030150(data)
    -- body
    if data.status == 0 then
        plog("data.lastTime",data.lastTime)
        local view = mgr.ViewMgr:get(ViewName.JinJieRankMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求宠物战力排行
function ActivityProxy:add5030183(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JinJieRankMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求开服累充活动
function ActivityProxy:add5030184(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end 

        local view2 = mgr.ViewMgr:get(ViewName.HeFuMainView)
        if view2 then
            view2:addMsgCallBack(data)
        end 

        local view3 = mgr.ViewMgr:get(ViewName.KaiFuLeiji)
        if view3 then
            view3:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--请求开服单笔充值活动
function ActivityProxy:add5030185(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end 

        local view2 = mgr.ViewMgr:get(ViewName.HeFuMainView)
        if view2 then
            view2:addMsgCallBack(data)
        end 
        local view3 = mgr.ViewMgr:get(ViewName.KaiFuLeiji)
        if view3 then
            view3:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--请求合服投资计划
function ActivityProxy:add5030187(data)
    if data.status == 0 then
        if data.reqType == 2 then--领取
            local var = cache.PlayerCache:getRedPointById(20175)
            cache.PlayerCache:setRedpoint(20175,var-1)
            mgr.GuiMgr:updateRedPointPanels(20175)

            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.HeFuMainView)
        if view then
            view:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--请求合服红包返还
function ActivityProxy:add5030403(data)
    if data.status == 0 then
        if data.reqType == 1 then--领取
            local var = cache.PlayerCache:getRedPointById(30146)
            cache.PlayerCache:setRedpoint(30146,var-1)
            mgr.GuiMgr:updateRedPointPanels(30146)

            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.HeFuMainView)
        if view then
            view:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--请求开服红包返还
function ActivityProxy:add5030404(data)
    if data.status == 0 then
        if data.reqType == 1 then--领取
            local var = cache.PlayerCache:getRedPointById(30147)
            cache.PlayerCache:setRedpoint(30147,var-1)
            mgr.GuiMgr:updateRedPointPanels(30147)

            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--集字活动
function ActivityProxy:add5030151(data)
    if data.status == 0 then
        printt("集字活动",data)
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 2 then
            if data.items and #data.items>0 then
                GOpenAlert3(data.items)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--BOSS有奖
function ActivityProxy:add5030210(data)
    if data.status == 0 then
        -- printt("BOSS有奖",data)
        local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            if data.items and #data.items>0 then
                GOpenAlert3(data.items)
            end
            local var = cache.PlayerCache:getRedPointById(20152)
            cache.PlayerCache:setRedpoint(20152,var-1)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--封测返还
function ActivityProxy:add5030211(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.CloseTestView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end

end

--圣诞活动登录好礼
function ActivityProxy:add5030162(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChristmasActView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(attConst.A20156)
            cache.PlayerCache:setRedpoint(attConst.A20156,var-1)
            mgr.GuiMgr:updateRedPointPanels(attConst.A20156)

            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--圣诞活动许愿袜
function ActivityProxy:add5030163(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChristmasActView)
        if view then
            view:addMsgCallBack(data)
        end
        -- if data.reqType == 2 then
        --     local socksMid = conf.ActivityConf:getChristmasGlobal("socks_mid")
        --     local socksAmount = cache.PackCache:getPackDataById(socksMid).amount
        --     if socksAmount == 0 then
        --         local var = cache.PlayerCache:getRedPointById(attConst.A20157)
        --         cache.PlayerCache:setRedpoint(attConst.A20157,var-1)
        --         mgr.GuiMgr:updateRedPointPanels(attConst.A20157)
        --         local mainview = mgr.ViewMgr:get(ViewName.MainView)
        --         if mainview then
        --             mainview:refreshRed()
        --         end
        --     end
        -- elseif data.reqType == 3 then
        --     local var = cache.PlayerCache:getRedPointById(attConst.A20157)
        --     cache.PlayerCache:setRedpoint(attConst.A20157,var-1)
        --     mgr.GuiMgr:updateRedPointPanels(attConst.A20157)
        --     local mainview = mgr.ViewMgr:get(ViewName.MainView)
        --     if mainview then
        --         mainview:refreshRed()
        --     end
        -- end
    else
        GComErrorMsg(data.status)
    end
end
--圣诞活动圣诞树
function ActivityProxy:add5030164(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChristmasActView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--圣诞活动排行
function ActivityProxy:add5030165(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChristmasActView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求每周登录奖励
function ActivityProxy:add5030166(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WeekendView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求每周活动副本双倍信息
function ActivityProxy:add5030167(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WeekendView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求双倍活动副本信息
function ActivityProxy:add5030168(data)
    if data.status == 0 then
        cache.ActivityCache:set5030168(data)
        mgr.GuiMgr:refreshDoubleFuben()
        local view = mgr.ViewMgr:get(ViewName.WeekendView)
        if view then
            view:refresh()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求每周挂机双倍活动
function ActivityProxy:add5030169(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WeekendView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求云购活动
function ActivityProxy:add5030301(data)
    if data.status == 0 then
        -- print("消息返回~~~~~~~~~~~~~")
        if data.reqType == 2 then  --上期中奖记录
            local view = mgr.ViewMgr:get(ViewName.ProRecordPanel)
            if view then
                view:setData(data)
            end
        else
            local view = mgr.ViewMgr:get(ViewName.BuyCloudView)
            if view then
                view:setData(data)
            end
        end
    elseif data.status == -1 then  --已被买完时，重新请求刷新下
        proxy.ActivityProxy:sendMsg(1030301, {reqType = 0})
        GComErrorMsg(data.status)
    else
        -- print("飘错误号~~~~~~~~~~~~~~~",data.status)
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030401(data)
    if data.status == 0 then
        -- print("消息返回~~~~~~~~~~~~~")
        if data.reqType == 2 then  --上期中奖记录
            local view = mgr.ViewMgr:get(ViewName.ProRecordPanel)
            if view then
                view:setData(data)
            end
        else
            local view = mgr.ViewMgr:get(ViewName.BuyCloudView)
            if view then
                view:setData(data)
            end
        end
    elseif data.status == -1 then  --已被买完时，重新请求刷新下
        proxy.ActivityProxy:sendMsg(1030401, {reqType = 0})
        GComErrorMsg(data.status)
    else
        -- print("飘错误号~~~~~~~~~~~~~~~",data.status)
        GComErrorMsg(data.status)
    end
end
--元旦活动登录奖励
function ActivityProxy:add5030302(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YdactMainView)
        if view then
            view:addServerCallback(data)
        end
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(attConst.A10253)
            cache.PlayerCache:setRedpoint(attConst.A10253,var-1)
            mgr.GuiMgr:updateRedPointPanels(attConst.A10253)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--元旦：请求兑换年货
function ActivityProxy:add5030303(data)
    if data.status == 0 then
        -- print("兑换年货消息返回在这个里~~~~~~~~~~~")
        local view = mgr.ViewMgr:get(ViewName.YdactMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--腊八活动请求登录
function ActivityProxy:add5030304(data)
   if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LabaMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(attConst.A30132)
            cache.PlayerCache:setRedpoint(attConst.A30132,var-1)
            mgr.GuiMgr:updateRedPointPanels(attConst.A30132)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--腊八活跃奖励
function ActivityProxy:add5030305(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LabaMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            local var = cache.PlayerCache:getRedPointById(attConst.A30133)
            cache.PlayerCache:setRedpoint(attConst.A30133,var-1)
            mgr.GuiMgr:updateRedPointPanels(attConst.A30133)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--腊八有礼
function ActivityProxy:add5030307(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LabaMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            local var = cache.PlayerCache:getRedPointById(attConst.A30134)
            cache.PlayerCache:setRedpoint(attConst.A30134,var-1)
            mgr.GuiMgr:updateRedPointPanels(attConst.A30134)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--腊八粥烹调
function ActivityProxy:add5030306(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        local view = mgr.ViewMgr:get(ViewName.LabaZhouView)
        if view then
            view:refreshAmount()
        end
    else
        GComErrorMsg(data.status)
    end
end

--腊八排行
function ActivityProxy:add5030308(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LabaRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--腊八副本双倍
function ActivityProxy:add5030309(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LabaMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030310(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TurntableView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030402(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TurntableView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求邀请码
function ActivityProxy:add5030311(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateInviteCode(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求情侣抽奖
function ActivityProxy:add5030313(data)
    if data.status == 0 then
        if data.reqType == 2 then
            GOpenAlert3(data.items)
            local var = cache.PlayerCache:getRedPointById(attConst.A30136)
            cache.PlayerCache:setRedpoint(attConst.A30136,var-1)
            mgr.GuiMgr:updateRedPointPanels(attConst.A30136)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.CoupleSuitsView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--情人节活跃奖励
function ActivityProxy:add5030314(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ValentinesMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(attConst.A30137)
            cache.PlayerCache:setRedpoint(attConst.A30137,var-1)
            mgr.GuiMgr:updateRedPointPanels(attConst.A30137)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求登录豪礼（公共）
function ActivityProxy:add5030175(data)
    if data.status == 0 then
        --小年活动登录豪礼
        if data.actId == 3045 then
            if data.reqType == 2 then
                local var = cache.PlayerCache:getRedPointById(20160)
                cache.PlayerCache:setRedpoint(20160,var-1)
                mgr.GuiMgr:updateRedPointPanels(20160)
            end
            local view = mgr.ViewMgr:get(ViewName.LunarYearMainView)
            if view then
                view:addMsgCallBack(data)
            end
        end
        --情人节活动
        if data.actId == 3046 then
            if data.reqType == 2 then
                local var = cache.PlayerCache:getRedPointById(attConst.A20161)
                cache.PlayerCache:setRedpoint(attConst.A20161,var-1)
                mgr.GuiMgr:updateRedPointPanels(attConst.A20161)
            end
            local view = mgr.ViewMgr:get(ViewName.ValentinesMainView)
            if view then
                view:addMsgCallBack(data)
            end
        end
        if 3047  == data.actId  then
            --春节活动登录豪礼
            local view = mgr.ViewMgr:get(ViewName.ChunJieMainView)
            if view then
                view:addMsgCallBack(data)
            end
        end
        --元宵灯会
        local view = mgr.ViewMgr:get(ViewName.LanternMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求小年煮饺子
function ActivityProxy:add5030312(data)
    if data.status == 0 then
        if data.items then
            GOpenAlert3(data.items)

            local view = mgr.ViewMgr:get(ViewName.DumplingsView)
            if view then
                view:refreshAmount()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030176( data )
    -- body
    if data.status == 0 then
        --春节活动
        local view = mgr.ViewMgr:get(ViewName.ChunJieMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030177( data )
    -- body
    if data.status == 0 then
        --春节活动
        local view = mgr.ViewMgr:get(ViewName.ChunJieMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030178( data )
    -- body
    if data.status == 0 then
        --春节活动
        local view = mgr.ViewMgr:get(ViewName.ChunJieMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030315( data )
    -- body
    if data.status == 0 then
        -- --春节活动
        -- local _view = mgr.ViewMgr:get(ViewName.ChunJieMainView)
        -- if _view then
        --     _view:addMsgCallBack(data)
        -- end
        --开服好运灵签
        local view = mgr.ViewMgr:get(ViewName.ChouQianView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--花灯兑奖
function ActivityProxy:add5030316(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LanternMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--元宵活跃活动
function ActivityProxy:add5030317(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LanternMainView)
        if view then
            view:addServerCallback(data)
        end
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(attConst.A30139)
            mgr.GuiMgr:redpointByVar(attConst.A30139,var - 1)
        end
    else
        GComErrorMsg(data.status)
    end
end

--充值消费排行活动
function ActivityProxy:add5030186(data)
    if data.status == 0 then
        if data.reqType == 1 then
            local view = mgr.ViewMgr:get(ViewName.LastRechargeRank)
            if view then
                view:initData(data)
            else
                mgr.ViewMgr:openView2(ViewName.LastRechargeRank, data)
            end
        else
            local view = mgr.ViewMgr:get(ViewName.RechargeRankView)
            if view then
                view:initData(data)
            else
                mgr.ViewMgr:openView2(ViewName.RechargeRankView, data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--
function ActivityProxy:add5030188(data)
    if data.status == 0 then
        printt("夺宝奇兵数据>>>>>>>",data)
        if data.reqType == 1 then--红点变化
            local var = cache.PlayerCache:getRedPointById(20176)
            cache.PlayerCache:setRedpoint(20176,var-data.times)
            mgr.GuiMgr:updateRedPointPanels(20176)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.RobTreasureView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--超值返还
function ActivityProxy:add5030405(data)
    -- body
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.DailyActivityView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            -- local var = cache.PlayerCache:getRedPointById(30148)
            -- cache.PlayerCache:setRedpoint(30148,var-1)
            -- mgr.GuiMgr:updateRedPointPanels(30148)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--超值兑换
function ActivityProxy:add5030406(data)
    -- body
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.DailyActivityView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--超值返还2
function ActivityProxy:add5030407(data)
    -- body
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.DailyActivityView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            -- local var = cache.PlayerCache:getRedPointById(30151)
            -- cache.PlayerCache:setRedpoint(30151,var-1)
            -- mgr.GuiMgr:updateRedPointPanels(30151)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--超值兑换2
function ActivityProxy:add5030408(data)
    -- body
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.DailyActivityView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--鲜花榜
function ActivityProxy:add5030320(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FlowerRank)
        if view then 
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--全服鲜花榜
function ActivityProxy:add5030327(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FlowerRank)
        if view then 
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--合服折扣礼包
function ActivityProxy:add5030411(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HeFuBagView)
        if view then 
            view:setData(data)
        end
        if data.reqType == 1 then 
            GOpenAlert3(data.items,true)
        end
    else
        GComErrorMsg(data.status)
    end
end

--开服神器排行
function ActivityProxy:add5030409(data)
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.JinJieRankMain)
        if view then
            view:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--限时神器排行
function ActivityProxy:add5030410(data)
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.ShenQiRankMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--合服神器排行
function ActivityProxy:add5030414(data)
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.ShenQiRankMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求世界杯信息
function ActivityProxy:add5030501( data )
    if data.status == 0 then 
        if data.reqType == 0 then 
            local view = mgr.ViewMgr:get(ViewName.WorldCupView)
            if view then
                view:addMsgCallBack(data)
            end
        else
            local view = mgr.ViewMgr:get(ViewName.YaZhuView)
            if view then
                view:setData(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end


--请求世界杯兑换信息
function ActivityProxy:add5030502( data )
    if data.status == 0 then 
        if data.reqType == 0 then 
            local view = mgr.ViewMgr:get(ViewName.WorldCupView)
            if view then
                view:addMsgCallBack(data)
            end
        elseif data.reqType == 1 then
            if data.items and #data.items>0 then
                GOpenAlert3(data.items)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030503( data )
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.ShenLuView)
        if view then
            view:setData(data)
        end
        -- if data.reqType == 0 then 
        -- elseif data.reqType == 1 then
        --     if data.items and #data.items>0 then
        --         GOpenAlert3(data.items)
        --     end
        -- end
    else
        GComErrorMsg(data.status)
    end
end


--神器寻宝返还
function ActivityProxy:add5030413(data)
    -- body
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.ShenQiRankMain)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(20177)

            cache.PlayerCache:setRedpoint(20177,var)
            mgr.GuiMgr:updateRedPointPanels(20177)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--神器寻宝返还（合服）
function ActivityProxy:add5030415(data)
    -- body
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.ShenQiRankMain)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(20211)

            cache.PlayerCache:setRedpoint(20211,var)
            mgr.GuiMgr:updateRedPointPanels(20211)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--充值翻牌活动
function ActivityProxy:add5030412(data)
    if data.status == 0 then
        printt("充值翻牌活动>>>>",data)
        local view = mgr.ViewMgr:get(ViewName.RechargeDrawView)
        if view then
            view:setData(data)
        end
        if data.reqType == 1 or data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(30155)

            cache.PlayerCache:setRedpoint(30155,var)
            mgr.GuiMgr:updateRedPointPanels(30155)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--充值返利活动
function ActivityProxy:add5030321(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RechargeRebate)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--婚礼排行榜
function ActivityProxy:add5030322(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryRank)
        if view then 
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--结婚称号
function ActivityProxy:add5030323(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryChengHao)
        if view then 
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

-- 射门好礼
function ActivityProxy:add5030324(data)
    if data.status == 0 then
        if data.reqType == 3 then
            if data.actId == 1109 then
                cache.PlayerCache:setRedpoint(20182, cache.PlayerCache:getRedPointById(20182)-1)
            else
                cache.PlayerCache:setRedpoint(20183, cache.PlayerCache:getRedPointById(20183)-1)
            end
            local view = mgr.ViewMgr:get(ViewName.SheQiuAwardView)
            if view then
                view:refreshView(data)
            end
            if data.items and #data.items > 0 then
                GOpenAlert3(data.items)
            end
        end
        local view = mgr.ViewMgr:get(ViewName.SheQiuView)
        if view then 
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--合服基金
function ActivityProxy:add5030325(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HeFuFundView)
        if view then 
            view:setData(data)
        end
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(20184)
            cache.PlayerCache:setRedpoint(20184,var-1)
            mgr.GuiMgr:updateRedPointPanels(20184)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--合服基金2
function ActivityProxy:add5030326(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HeFuFundView)
        if view then 
            view:setData(data)
        end
        if data.reqType == 2 then
            local var = cache.PlayerCache:getRedPointById(20193)
            cache.PlayerCache:setRedpoint(20193,var-1)
            mgr.GuiMgr:updateRedPointPanels(20193)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end 
end

--摇钱树
function ActivityProxy:add5030504(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.GoldTreeView)
        if view then 
            view:setData(data)
        end
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(20185)
            cache.PlayerCache:setRedpoint(20185,var-1)
            mgr.GuiMgr:updateRedPointPanels(20185)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end 
end

--寻仙探宝
function ActivityProxy:add5030213(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XunXianView)
        if view then 
            view:setData(data)
        end
        if data.reqType ~= 0 then
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end 
end

--剑灵出事排行
function ActivityProxy:add5030215(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.JianLingBorn)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--剑灵出事排行（合服）
function ActivityProxy:add5030418(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.JianLingBorn)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--剑灵寻宝返还
function ActivityProxy:add5030216(data)
    -- body
    if data.status == 0 then 
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(20188)

            cache.PlayerCache:setRedpoint(20188,var-1)
            mgr.GuiMgr:updateRedPointPanels(20188)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.JianLingBorn)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--剑灵寻宝返还(合服)
function ActivityProxy:add5030416(data)
    -- body
    if data.status == 0 then 
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(20212)

            cache.PlayerCache:setRedpoint(20212,var-1)
            mgr.GuiMgr:updateRedPointPanels(20212)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.JianLingBorn)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--法老秘宝
function ActivityProxy:add5030218(data)
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.FaLaoView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030505( data )
    -- body
    if data.status == 0 then 
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.RechargeBack,data)
        else
            local view = mgr.ViewMgr:get(ViewName.RechargeBack)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 神器寻主
function ActivityProxy:add5030217(data)
    if data.status == 0 then 
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(20189)
            cache.PlayerCache:setRedpoint(20189,var-1)
            mgr.GuiMgr:updateRedPointPanels(20189)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
            GOpenAlert3(data.items)
        end
        local view = mgr.ViewMgr:get(ViewName.ShenQiFindMaster)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--充值豪礼
function ActivityProxy:add5030222(data)
    if data.status == 0 then
        if data.reqType == 1 then
            if data.items and #data.items > 0 then
                GOpenAlert3(data.items)
            end
            local var = cache.PlayerCache:getRedPointById(20192)
            mgr.GuiMgr:redpointByVar(20192,var - 1,1)
        end
        local view = mgr.ViewMgr:get(ViewName.RechargeGiftView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--机甲剑神活动
function ActivityProxy:add5030224(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JiJiaActiveView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--恶魔限时
function ActivityProxy:add5030223(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DevilFashionView)
        if view then
      
            view:setData(data)
          
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030220(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PetHelpActive)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030221(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PetHelpActive)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030225( data )
    -- body
    if data.status == 0 then
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.DanbiView,data)
        else
            local view = mgr.ViewMgr:get(ViewName.DanbiView)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--神臂擎天排行
function ActivityProxy:add5030226(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.ShenBiActive)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--神臂升阶返还
function ActivityProxy:add5030227(data)
    -- body
    if data.status == 0 then 
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(20195)

            cache.PlayerCache:setRedpoint(20195,var-1)
            mgr.GuiMgr:updateRedPointPanels(20195)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.ShenBiActive)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求趣味挖矿
function ActivityProxy:add5030506(data)
    if data.status == 0 then 
        if data.reqType == 1 or data.reqType == 3 or data.reqType == 4 then
            if data.items and #data.items > 0 then
                GOpenAlert3(data.items)
            end
        end
        if data.reqType == 4 or data.reqType == 3 then
            if data.reqType == 4 then
                local var = cache.PlayerCache:getRedPointById(30160)
                cache.PlayerCache:setRedpoint(30160,var-1)
            end
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRedTop()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.ActWaKuangView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--聚划算
function ActivityProxy:add5030228(data)
    if data.status == 0 then 
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.JuHuaSuanView,data)
        else
            local view = mgr.ViewMgr:get(ViewName.JuHuaSuanView)
            if view then
                view:initData(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求连充特惠
function ActivityProxy:add5030508(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ContinueCharge)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030507( data )
    -- body
    if data.status == 0 then 
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.RechargeSum,data)
        else
            local view = mgr.ViewMgr:get(ViewName.RechargeSum)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--消费兑换
function ActivityProxy:add5030229(data)
    
    -- print("data.status= "..data.status)
    if data.status == 0 then  
        local view = mgr.ViewMgr:get(ViewName.ConsumeChange)
        if view then
            view:setData(data)
        end
     else if data.status == -1   then
        GComAlter(language.xunbao02)
    else
        
        GComErrorMsg(data.status)
    end
    end
end

--请求猴王除妖活动
function ActivityProxy:add5030230(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HouWangView)
        if view then
            view:setData(data)
        end
        if data.reqType == 1 or data.reqType == 2 then
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030509( data )
    -- body
    if data.status == 0 then 
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.YaoQianView,data)
        else
            local view = mgr.ViewMgr:get(ViewName.YaoQianView)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030511( data )
    -- body
    if data.status == 0 then 
        mgr.ViewMgr:openView2(ViewName.RachargeCrazy,data)
    else
        GComErrorMsg(data.status)
    end
    
end

function ActivityProxy:add5030231(data)
    if data.status == 0 then 
        mgr.ViewMgr:openView2(ViewName.ActWarExpertView,data)
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030232(data) --超值单笔
    if data.status == 0 then 
       -- mgr.ViewMgr:openView2(ViewName.ChongZhiDanBiView,data)
        local view = mgr.ViewMgr:get(ViewName.ChongZhiDanBiView)
        if view then

            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求欢乐购 
function ActivityProxy:add5030510(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KuangHuanMainView)
        if view then
            view:setData(data)
        end
        if data.reqType == 1 then
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求充值抽抽乐活动
function ActivityProxy:add5030233(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChargePumpView)
        if view then
            view:setData(data)
        end
        local temp = 0
        if data.reqType == 1 then
            temp = 0
        elseif data.reqType == 2 then
            temp = 1
        end
        if data.reqType == 1 or data.reqType == 2 then
            GOpenAlert3(data.items)
            local var = cache.PlayerCache:getRedPointById(20198)
            cache.PlayerCache:setRedpoint(20198,var-temp)
            mgr.GuiMgr:updateRedPointPanels(20198)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end

    else
        GComErrorMsg(data.status)
    end
end

--请求百发百中活动
function ActivityProxy:add5030234(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ActShootingView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 请求跨服充值排行
function ActivityProxy:add5030235(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KuaFuChargeMain)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030236(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianWaDaBiPing)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ActivityProxy:add5030237(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianWaDaBiPing)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--刮刮乐
function ActivityProxy:add5030219(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScratchActive)
        if view then
            view:setData(data)
        end
        if data.reqType == 1 and data.arg ~= 1 then
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030238(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JuBaoPen)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030512(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.VipChargeView)
        if view then
            view:add5030512(data)
            view:monthCardRedPoint()
        end
        if data.reqType == 2 then
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview.TopActive:checkActive()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030239( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MiJinTaoView)
        if view then
            view:addMsgCallBack(data)
        else
            if data.reqType == 0 then
                mgr.ViewMgr:openView2(ViewName.MiJinTaoView,data) 
            end
        end
        
    else
        GComErrorMsg(data.status)
    end
end
--请求连消特惠
function ActivityProxy:add5030513(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ContinueCost)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030240(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JinRiLeiChong)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030241(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TianMingBuGua)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--老师请点名
function ActivityProxy:add5030242(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SignInTeacher)
        if view then
            view:setData(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030514(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BuBuGaoSheng)
        if view then 
            view:addMsg(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030515(data)
    -- body
    if data.status == 0 then
        --printt("data",data)     
        local view = mgr.ViewMgr:get(ViewName.XianShiLiBaoView)
        if view then
            view:addMsgCallBack(data)
        else
            if data.reqType == 0 then
                mgr.ViewMgr:openView2(ViewName.XianShiLiBaoView,data) 
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030243(data)--无敌幸运星
    -- body
    
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WuDiXinYunXing)
        if view then
            view:setData(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end


function ActivityProxy:add5030516(data)--灵虚宝藏
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LingXuBaoZangView)
        if view then
            view:setData(data) 
        end
        --红点刷新
        mgr.GuiMgr:redpointByVar(30173,data.freeCount,1)
        cache.PlayerCache:setRedpoint(30176,data.freeLeftTime)
    else
        GComErrorMsg(data.status)
    end
end

--请求限时连充
function ActivityProxy:add5030517(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianShiLianChong)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


function ActivityProxy:add5030518( data )
    -- body
    if data.status == 0 then

        mgr.ViewMgr:openView2(ViewName.DoubelBackView, data)
    else
        GComErrorMsg(data.status)
    end
end

--请求我要转转
function ActivityProxy:add5030519(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AroundView)
        if view then
            view:setData(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030520(data)
    if data.status == 0 then
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.QiFuView, data)
        else
            local view = mgr.ViewMgr:get(ViewName.QiFuView)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030249(data)
	if data.status == 0 then
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.ActXunBaoRank, data)
        else
            local view = mgr.ViewMgr:get(ViewName.ActXunBaoRank)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030245(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DongFangRank)
        if view then
            view:setData(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030522(data)
	if data.status == 0 then
        if data.reqType == 0 then
            mgr.ViewMgr:openView2(ViewName.YbDuihuan, data)
        else
            local view = mgr.ViewMgr:get(ViewName.YbDuihuan)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030521(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HeFuLianChong)
        if view then
            view:setData(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030250(data)
    if data.status == 0 then
        --printt("add5030250",data)
        local view = mgr.ViewMgr:get(ViewName.XzphView)
        if view then
            view:setData(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030244(data)
	if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.ShenShouRank,data)
    else
        GComErrorMsg(data.status)
    end
	
end

function ActivityProxy:add5030607(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MidAuTumnView)
        if view then
            view:setData(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030251( data )
    -- body
    if data.status == 0 then
        --好运灵签
        local view = mgr.ViewMgr:get(ViewName.ChouQianView)
        if view then
            view:setData(data)
        end

    else
        GComErrorMsg(data.status)
    end
end

--圣印排行
function ActivityProxy:add5030252( data )
	 if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShengYinRank)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--圣印排行（合服）
function ActivityProxy:add5030419( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShengYinRank)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ActivityProxy:add5030625( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShengYinReturn)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--珍稀乾坤
function ActivityProxy:add5030626( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhenXiQianKun)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--剑神返还
function ActivityProxy:add5030633( data )
     if data.status == 0 then
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(30219)
            cache.PlayerCache:setRedpoint(30219,var-1)
            mgr.GuiMgr:updateRedPointPanels(30219)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.JianShenMain)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 剑神排行
function ActivityProxy:add5030253( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JianShenMain)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 烟花庆典
function ActivityProxy:add5030635( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YanHuaAct)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 累计消费
function ActivityProxy:add5030636( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.Cumulative)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 幸运鉴宝
function ActivityProxy:add5030637( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LuckyTreasureView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 万圣节累充活动
function ActivityProxy:add5030639( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HalloweenRecharge)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 捣蛋南瓜田活动
function ActivityProxy:add5030640( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DaoDanNanGuaTian)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 双色球
function ActivityProxy:add5030645( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DoubleBall)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 真假雪人
function ActivityProxy:add5030646( data )
     if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SnowMan)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 满减活动
function ActivityProxy:add5030647( data )
     if data.status == 0 then
		if data.reqType == 0 then
			local view = mgr.ViewMgr:get(ViewName.FullReduction)
			if view then
				view:initData(data)
			else
				mgr.ViewMgr:openView2(ViewName.FullReduction,data)
			end
		else
            local view = mgr.ViewMgr:get(ViewName.FullReduction)
            if view then
                view:initData(data)
            end
		end
	 
        
    else
        GComErrorMsg(data.status)
    end
end
-- 脱单领称号
function ActivityProxy:add5030254( data )
     if data.status == 0 then
        -- if data.reqType == 1 then
        --     local var = cache.PlayerCache:getRedPointById(20209)
        --     cache.PlayerCache:setRedpoint(20209,var)
        --     mgr.GuiMgr:updateRedPointPanels(20209)
        --     local mainview = mgr.ViewMgr:get(ViewName.MainView)
        --     if mainview then
        --         mainview:refreshRed()
        --     end
        -- end
        local view = mgr.ViewMgr:get(ViewName.TuoDanMain)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 情侣充值排行榜
function ActivityProxy:add5030255( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TuoDanRank)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--奇门遁甲战力排行
function ActivityProxy:add5030649(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.QiMenDunJiaMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end



--奇门遁甲圣装寻宝返还
function ActivityProxy:add5030648(data)
    -- body
    if data.status == 0 then 
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(30266)
            cache.PlayerCache:setRedpoint(30266,var-1)
            mgr.GuiMgr:updateRedPointPanels(30266)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.QiMenDunJiaMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--天天返利
function ActivityProxy:add5030650(data)
    printt(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.TianTianFanLiView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--水果消除
function ActivityProxy:add5030651(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.FruitView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--幸运锦鲤
function ActivityProxy:add5030655(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.XinYunLiJin)
     
        if view then
             
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--天降礼包
function ActivityProxy:add5030656(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.TianJiangLiBao)
        if view then
            printt(data,"**********")
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求科举排行信息
function ActivityProxy:add5030657(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LanternRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求科举答题信息
function ActivityProxy:add5030658(data)
    if data.status == 0 then
        if data.reqType == 2 then--答题
            local confData = conf.ActivityConf:getGuessQuestion(data.subjectId)
            if confData.answer == data.answer then
                local cacaheData = cache.ActivityCache:getCdmhData()
                local score = data.myScore - cacaheData.myScore
                GComAlter(string.format(language.lantern14, score))
            else
                GComAlter(language.lantern15)
            end
        end
        cache.ActivityCache:updateCdmhData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setCdmhData(true)
        else
            cache.ActivityCache:setCdmhData(data)
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 15})
        end
        mgr.TimerMgr:addTimer(1, 1, function()
            if gRole then
                gRole:setGangName(cache.PlayerCache:getGangName())--调用一下仙盟，让其可以隐藏
                gRole:createHead()
                gRole:refreshScore({[516] = data.myScore})
            end
        end)
        local view = mgr.ViewMgr:get(ViewName.DaTiView)
        if view then
            view:setData(data)
        else
            mgr.ViewMgr:openView2(ViewName.DaTiView, data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--科举答题刷新广播
function ActivityProxy:add8240201(data)
    if data.status == 0 then
        cache.ActivityCache:updateCdmhData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setCdmhData()
        end
        local view = mgr.ViewMgr:get(ViewName.DaTiView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--科举答题排行刷新广播
function ActivityProxy:add8240202(data)
    if data.status == 0 then
        cache.ActivityCache:updateRankData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setCdmhData(true)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求充值双倍活动（月末狂欢）
function ActivityProxy:add5030328( data )
    -- body
    if data.status == 0 then

        mgr.ViewMgr:openView2(ViewName.YueMoKuangHuan, data)
    else
        GComErrorMsg(data.status)
    end
end

--请求帝魂召唤
function ActivityProxy:add5030659( data )
    -- body
    if data.status == 0 then
    local view = mgr.ViewMgr:get(ViewName.DiHunZhaoHuanView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求冬至抽奖活动
function ActivityProxy:add5030666( data )
    -- body
    if data.status == 0 then
    local view = mgr.ViewMgr:get(ViewName.DongZhiJiaoYan)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求冬至连冲活动
function ActivityProxy:add5030667( data )
    -- body
    if data.status == 0 then
    local view = mgr.ViewMgr:get(ViewName.DongZhiLianChong)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


--请求奇兵寻宝信息
function ActivityProxy:add5030683(data)
    if data.status == 0 then
        self:refreshXunBaoView(data)
    else
        GComErrorMsg(data.status)
    end
end


--请求奇兵寻宝积分商城
function ActivityProxy:add5030684(data)
    -- body
    if data.status == 0 then
        local view =mgr.ViewMgr:get(ViewName.ScoreStroeView)
        if view then
            view:setData(data)
        end
        local view =mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:refreshScore(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求奇兵寻宝
function ActivityProxy:add5030685(data)
    -- body
    if data.status == 0 then
        GOpenAlert3(data.items, true)
        proxy.ActivityProxy:sendMsg(1030683)
        local view =mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setData() --刷新元宝和钥匙
        end
    else
        GComErrorMsg(data.status)
    end
end

--奇兵战力排行
function ActivityProxy:add5030687(data)
     if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.QiBingActive)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end



--奇兵圣装寻宝返还
function ActivityProxy:add5030686(data)
    -- body
    if data.status == 0 then 
        if data.reqType == 1 then
            local var = cache.PlayerCache:getRedPointById(30252)
            cache.PlayerCache:setRedpoint(30252,var-1)
            mgr.GuiMgr:updateRedPointPanels(30252)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRed()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.QiBingActive)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--腊八累抽2019
function ActivityProxy:add5030692(data)
    -- body
    if data.status == 0 then

        local view = mgr.ViewMgr:get(ViewName.LaBaLeiChou)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--腊八活动排行榜（2019）
function ActivityProxy:add5030691( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LaBaRankView2019)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end



return ActivityProxy
