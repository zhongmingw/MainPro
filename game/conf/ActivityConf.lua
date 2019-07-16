--
-- Author: 
-- Date: 2017-03-27 14:35:05
--
--活动配置
local ActivityConf = class("ActivityConf",base.BaseConf)
local pairs = pairs
function ActivityConf:init()
    ---福利大厅
    self:addConf("activity_global")--连续充值
    
    self:addConf("welfare_global")--福利大厅global
    self:addConf("welfare_type")--福利大厅类型
    self:addConf("sign_award")--签到奖励
    self:addConf("sum_sign_award")--签到天数奖励
    self:addConf("vip_privilege_award")--仙尊特权
    self:addConf("online_award")--在线奖励
    self:addConf("outline_exp_times")--离线经验
    self:addConf("vip_gift_type")--vip礼包类型
    self:addConf("vip_gift")--vip礼包
    self:addConf("resource_type")--资源找回类型
    self:addConf("resource_recovery")--资源找回列表
    self:addConf("update_notice")--更新公告
    self:addConf("limit_time_sale")--限时特卖
    ---开服活动
    self:addConf("active") --A-活动配置
    self:addConf("open_rank_award")--开服排行
    self:addConf("open_jinjie_award")--开服进阶日
    self:addConf("series_cz_awards")--连续充值
    self:addConf("firstcz_group_purchase")--开服充值团购
    self:addConf("open_task")--开服任务

    self:addConf("login_award")--30天登录奖励
    self:addConf("fairy_card_gift")--百倍礼包奖励
    self:addConf("day_perferential_gift")--开服特惠礼包
    self:addConf("mrlc_activity")--开服活动每日累充
    self:addConf("investment_plan_open")--开服投资
    self:addConf("open_investment_item")--开服物品投资
    self:addConf("investment_plan_lvl")--升级投资
    self:addConf("daily_single_recharge")--每日首充
    self:addConf("daily_lctimes_awards")--每日首充累积奖励
    self:addConf("yb_copy")--元宝复制   (变更为聚宝盆)
    self:addConf("daily_cz_one_yuan")--每日一元
    self:addConf("first_cz_gift")--再充献礼
    self:addConf("lev_gift")--等级礼包
    self:addConf("lev_sell")--等级特卖
    self:addConf("gang_rank_awards")--仙盟排行
    self:addConf("open_level_rank_award")--开服冲级排行

    ---主界面顶部按钮
    self:addConf("topbtn")
    self:addConf("bottombtn")
    self:addConf("hide_topbtn")

    self:addConf("special_panic_buy")--限时抢购活动
    self:addConf("horse_skill_sale")--坐骑技能书
    self:addConf("partner_skill_sale")--伙伴技能书
    self:addConf("summer_flame_active")--夏日活动
    --0元购
    self:addConf("zero_buy")--0元购

    self:addConf("act_upchannel_list")--活动快速升级途径：
    --宝树活动配置
    self:addConf("treasures_tree")
    self:addConf("treasures_tree_fruit")
    self:addConf("treasures_tree_model")

    self:addConf("level_charge")--等级冲锋活动配置
    self:addConf("login_award_sevenday_act")--7天登陆
    self:addConf("act_lucky_awards_pool")--点石成金活动
    self:addConf("smash_egg")--疯狂砸蛋活动
    self:addConf("smash_egg_cumulate")--疯狂砸蛋累积奖励
    self:addConf("open_power_rank_award")--战力排行
    self:addConf("cross_power_rank_award")--跨服战力排行
    self:addConf("equip_power_rank_award")--装备战力排行
    self:addConf("open_pet_rank_award")--宠物战力排行
    self:addConf("boss_price")--BOSS有奖
    self:addConf("open_word_collection")--BOSS有奖
    self:addConf("beta_back")--封测奖励
    self:addConf("pyjq_buff")--天书活动 buff
    self:addConf("pyjq_award")--天书活动 奖励

    self:addConf("treasure_book_cost")--装备寻宝活动消耗
    self:addConf("treasure_book_shop")--装备寻宝活动积分商城道具
    self:addConf("treasure_equip_pool")--装备寻宝装备库
    self:addConf("theasure_book_item")--装备寻宝奖励

    self:addConf("treasure_jinjie_cost")--进阶寻宝消耗
    self:addConf("treasure_jinjie_shop")--进阶寻宝活动积分商城道具
    self:addConf("treasure_jinjie_pool")--进阶寻宝装备库
    self:addConf("theasure_jinjie_item")--进阶寻宝奖励

    self:addConf("treasure_qibing_cost")--奇兵寻宝消耗
    self:addConf("treasure_qibing_shop")--奇兵寻宝活动积分商城道具
    self:addConf("treasure_qibing_item")--奇兵寻宝奖励

    self:addConf("treasure_zhuxing_cost")--铸星寻宝消耗
    self:addConf("treasure_zhuxing_shop")--铸星寻宝活动积分商城道具
    self:addConf("treasure_zhuxing_pool")--铸星寻宝装备库
    self:addConf("theasure_zhuxing_item")--铸星寻宝奖励

    self:addConf("treasure_pet_cost")--宠物寻宝消耗
    self:addConf("treasure_pet_shop")--宠物寻宝活动积分商城道具
    self:addConf("theasure_pet_item")--宠物寻宝奖励

    self:addConf("treasure_shenqi_cost")--神器寻宝消耗
    self:addConf("treasure_shenqi_shop")--神器寻宝活动积分商城道具
    self:addConf("theasure_shenqi_item")--神器寻宝奖励

    self:addConf("treasure_honghuang_cost")--洪荒寻宝消耗
    self:addConf("treasure_honghuang_shop")--洪荒寻宝活动积分商城道具
    self:addConf("theasure_honghuang_item")--洪荒寻宝奖励

    self:addConf("treasure_jianling_cost")--剑灵寻宝消耗
    self:addConf("treasure_jianling_shop")--剑灵寻宝活动积分商城道具
    self:addConf("theasure_jianling_item")--剑灵寻宝奖励

    self:addConf("treasure_xian_equip_cost")--仙装寻宝消耗
    self:addConf("treasure_xian_equip_shop")--仙装寻宝活动积分商城道具
    self:addConf("theasure_xian_equip_item")--仙装寻宝奖励
    self:addConf("treasure_xian_equip_pool")--仙装寻宝奖励

    self:addConf("treasure_shengyin_cost")--圣印寻宝消耗
    self:addConf("treasure_shengyin_shop")--圣印寻宝活动积分商城道具
    self:addConf("theasure_shengyin_item")--圣印寻宝奖励

    self:addConf("treasure_jianshen_cost")--剑神装备寻宝消耗
    self:addConf("treasure_jianshen_shop")--剑神装备寻宝活动积分商城道具
    self:addConf("treasure_jianshen_item")--剑神装备寻宝奖励


    self:addConf("treasure_hm_cost")--鸿蒙寻宝消耗
    self:addConf("treasure_hm_shop")--鸿蒙寻宝活动积分商城道具
    self:addConf("treasure_hm_item")--鸿蒙寻宝奖励


    self:addConf("christmas_global")--圣诞活动
    self:addConf("christmas_signed_award")--圣诞活动登陆奖励
    self:addConf("christmas_tree_level")--圣诞活圣诞树配置
    self:addConf("christmas_socks_award")--许愿袜配置
    self:addConf("christmas_ranking_award")--圣诞活动个人排行榜奖励配置
    self:addConf("christmas_gang_ranking_award")--圣诞活动仙盟排行榜奖励配置

    self:addConf("lucky_buy00")--幸运云购
    self:addConf("lucky_buy01")--额外装备
    self:addConf("lucky02_buy00")--开服幸运云购
    self:addConf("lucky02_buy01")--开服额外装备

    self:addConf("annual_goods")--元旦兑换年货
    self:addConf("newyear_signed_award")--元旦登录豪礼
    self:addConf("holiday_global")--节日
    self:addConf("emo_fashion_award_pool")--惡魔時裝

    self:addConf("week_login_award")--周末登录豪礼
    self:addConf("week_fuben_doubel")--周末副本双倍

    self:addConf("laba_signed_award") --腊八登录豪礼
    self:addConf("laba_active_award") --腊八活跃奖励
    self:addConf("laba_gift")--腊八有礼
    self:addConf("laba_consumption_rank")--腊八排行奖励
    self:addConf("laba_active_task")--腊八活跃任务
    
    self:addConf("xyzp_00")--幸运转盘
    self:addConf("xyzp_01")--幸运转盘装备库
    self:addConf("xyzp02_00")--开服幸运转盘
    self:addConf("xyzp02_01")--开服幸运转盘装备库

    self:addConf("invite_key")--邀请码等级奖励

    self:addConf("valentine_raffle_award")--情侣抽奖奖励
    self:addConf("valentine_integral_award")--情侣抽奖积分奖励
    self:addConf("valentine_active_award")--情人节活跃奖励
    self:addConf("valentine_active_task")--情人节活跃任务

    self:addConf("activity_login_award")--活动登录奖励

    self:addConf("newyear_redbag_award")--春节活动 全服红包

    --元宵灯会
    self:addConf("yx_rank_award")
    self:addConf("lantern_exchange")
    self:addConf("lantern_active_task")--元宵活跃情人节
    self:addConf("lantern_active_award")--元宵活跃情人节

    self:addConf("open_lc_act") --开服累充活动
    self:addConf("open_dbcz_act") --开服单笔充值活动
    self:addConf("act_cz_cost_rank") --开服单笔充值活动
    self:addConf("investment_plan_merge") --合服投资计划
    self:addConf("czfh_day") --超值返还
    self:addConf("czfh") --超值返还
    self:addConf("czdh_day") --超值兑换
    self:addConf("czdh") --超值兑换

    self:addConf("czfh_day2") --超值返还2
    self:addConf("czfh2") --超值返还2
    self:addConf("czdh_day2") --超值兑换2
    self:addConf("czdh2") --超值兑换2
    self:addConf("act_czdb_grid_award") --夺宝奇兵

    self:addConf("flower_rank_award") --鲜花榜
    self:addConf("hf_zklb") --合服折扣礼包

    self:addConf("shenqi_rank_award01") --开服神器战力排行
    self:addConf("shenqi_rank_award02") --限时神器战力排行

    self:addConf("sqxb_back") --神器寻宝返还
    self:addConf("czfp") --充值翻牌
    self:addConf("czfp_awards") --充值翻牌奖励
    self:addConf("cz_reback_act") --充值返利
    self:addConf("marry_hot_award") --婚礼热度奖励

    self:addConf("shoot_award_pool")--射门好礼奖励  
    self:addConf("shoot_cumular_award")--射门好礼累计奖励
    self:addConf("fund_merge_award")--合服基金
    self:addConf("fund_merge02_award")--合服基金2
    self:addConf("sllb")--神炉炼宝
    self:addConf("hefu_item")--合服活动入口配置
    
    self:addConf("splendid_item")--精彩活动入口配置
    self:addConf("xxtb_award")--寻仙探宝
    self:addConf("jianling_rank_award")--剑灵寻宝排行奖励
    self:addConf("jianling_reback_award")--剑灵寻宝返还奖励
    self:addConf("dbcz_sqxz")--单笔充值(神器寻主)
    self:addConf("pyramid_award")--法老
    self:addConf("jjjs_award")--机甲剑神

    self:addConf("czhk_item")--充值回馈

    self:addConf("pet_rank_award")--寻宝排行
    self:addConf("pet_reback_award")--寻宝返回

    self:addConf("sbqt_rank_award")--神臂升阶排行
    self:addConf("sbqt_reback_award")--神臂升阶返回

    self:addConf("qwwk_item")--趣味挖矿
    self:addConf("jhs_buy_item")--聚划算
     self:addConf("jhs_gift_award")--聚划算礼物
    self:addConf("con_czth")--连冲特惠

    self:addConf("kaifu_item")--开服活动入口配置
    self:addConf("kaifu_lcrk")--开服累充
    self:addConf("kaifu_dbrk")--开服单笔

    self:addConf("mul_ljcz")
    self:addConf("money_tree")
    self:addConf("mul_active")--多开活动配置
    self:addConf("happy_buy")--狂欢大乐购
    self:addConf("cost_exchange_item")--消费兑换活动
    self:addConf("czdr_act_award")--冲战达人
    self:addConf("czdb_act_award")--超值累充
    self:addConf("recharge_lucky_whole_award")--充值抽抽乐
    self:addConf("bfbz_award")--百发百中
    self:addConf("kf_cz_ranking")--跨服充值榜
    self:addConf("xiantong_power_rank")--仙童寻宝排行
    self:addConf("dongfang_reback_award")--洞房返还
    self:addConf("jbp_award")--聚宝盆
    self:addConf("month_card")--月卡
    
    self:addConf("mjxb_award_pool")--秘境
    self:addConf("mjxb_cost")--秘境
    self:addConf("daily_lc_award")--今日累充
    self:addConf("con_cost")--连消特惠
    self:addConf("tmbg_award_pool")--卜卦奖励
    self:addConf("tmbg_amount_cost")--卜卦消耗
    self:addConf("bbgs_item")--步步高升
    self:addConf("dbhl_cz_award")--单笔豪礼
    self:addConf("lsqdm_cost")--老师请点名消耗
    self:addConf("lsqdm_award")--老师请点名奖励

    self:addConf("mul_active_show")--多开活动奖励
    self:addConf("mul_xslb")--限时礼包
    self:addConf("wdxyx_award")--限时礼包
    self:addConf("lxbz_item")--灵虚宝藏
    self:addConf("xslc_item")--限时连充
    self:addConf("wyzz_item")--我要转转
	 self:addConf("lqqf_cost")--灵泉祈福
    self:addConf("lqqf")--灵泉祈福

    self:addConf("xunbao_rank_award")--寻宝排行奖励
    self:addConf("xunbao_whole_award")--寻宝排行
    self:addConf("dongfang_rank_award")--洞房排行奖励
    self:addConf("dongfang_whole_award")--洞房排行
    self:addConf("ybdh")--元宝兑换
    self:addConf("hf_lxcz")--合服连续充值
    self:addConf("xian_equip_rank_award")--仙装排行
	self:addConf("shenshou_rank_award")--神兽排行
    self:addConf("zqhl")--中秋豪礼
    self:addConf("hylq_normal") -- 好运灵签
	
	--全民备战
	self:addConf("qm_limit_gift")--
    self:addConf("qm_cost_rebate")--
    self:addConf("qm_snatch") -- 
	self:addConf("qm_global") -- 
	
	self:addConf("shengyin_rank_award")--圣印排行
    self:addConf("shengyin_treasure_back")--圣印返还
    self:addConf("zxqk")-- 珍稀乾坤
    self:addConf("jianshen_treasure_back") -- 剑神装备寻宝返还
    self:addConf("js_equip_rank_award") -- 剑神装备寻宝排行
    self:addConf("fireworks_celebration") -- 烟花庆典  
    self:addConf("lucky_identification") -- 幸运鉴宝
    self:addConf("cumulativ_cost") -- 连续消费
    self:addConf("ball_lottery") -- 双色球
    self:addConf("snowman") -- 真假雪人
    self:addConf("mjzc") -- 满减活动
    self:addConf("qlcz_rank_award") -- 情侣充值    
    self:addConf("shengzhuang_treasure_back") -- 盛装寻宝返还   
    self:addConf("ttfl") -- 天天返利
    self:addConf("fruit_eliminate") -- 水果消除
    self:addConf("lucky_koi") -- 幸运锦鲤
    self:addConf("recharge_gift") -- 天降礼包

    --科举答题配置
    self:addConf("kj_global")
    self:addConf("kj_question_pool")--题库
    self:addConf("kj_rank_award")--排行奖励
    self:addConf("kj_exp")--经验奖励

     --合服奖励配置
    self:addConf("shengyin_rank_merge_award")--合服圣印奖励
    self:addConf("jianling_rank_merge_award")--合服剑灵排行奖励
    self:addConf("find_reback_merge_award")--合服剑灵寻宝奖励
    self:addConf("shenqi_rank_merge_award")--合服神器奖励

    --帝魂召唤
    self:addConf("dhzh")--合服神器奖励
    self:addConf("hdzx_item")--活动中心

    --奇兵排行
    self:addConf("qibing_treasure_back")--奇兵寻宝返还
    self:addConf("qibing_rank_award")--骑兵排行
    
    self:addConf("lb_lottery")--腊八累充
    self:addConf("lb_rank") --腊八2019排行版
    --鲜花榜
    self:addConf("flower_rank_img")



end
--圣印排行奖励
function ActivityConf:getShengyinRankeAward()
	return table.values(self.shengyin_rank_award)
end
--圣印排行奖励（合服）
function ActivityConf:getShengyinRankeAward1()
    return table.values(self.shengyin_rank_merge_award)
end
function ActivityConf:getQMValue(id)
	return self.qm_global[tostring(id)]
end

function ActivityConf:getQmGiftByTime(id,day)
	local t = {}
	for k , v in pairs(self.qm_snatch) do
		if v.time == id and v.day == day  then
			table.insert(t,v)
		end
	end
	return t 
end

function ActivityConf:getQmGiftByDay(id)
	local t = {}
	for k , v in pairs(self.qm_limit_gift) do
		if v.day == id then
			table.insert(t,v)
		end
	end
	return t 
end

function ActivityConf:getCostRebate()
	return table.values(self.qm_cost_rebate)
end


function ActivityConf:getShenshourank()
	return table.values(self.shenshou_rank_award)
end

function ActivityConf:getYbdh(award_pre)
    local data = {}
    for k,v in pairs(self.ybdh) do
        if tostring(award_pre) == string.sub(v.id,1,4) then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
	return data
end
function ActivityConf:getXunBaoRankAwardById( id )
    -- body
    return self.xunbao_rank_award[tostring(id)]
end
function ActivityConf:getXunBaoRankAward()
    -- body
    return table.values(self.xunbao_rank_award)
end
function ActivityConf:getWholeAward()
    -- body
    return table.values(self.xunbao_whole_award)
end

--awardPre:奖励前缀
function ActivityConf:getlqqf(awardPre,_type)
    -- body
    local t = {}
    for k , v  in pairs(self.lqqf) do
        if math.floor(v.id/1000) == awardPre and v.type == _type then
            table.insert(t,v)
        end
    end
    return t 
end

function ActivityConf:getlqqfCost( id )
    -- body
    local t = {}
    local confdata = self:getMulActById(id)
    for k , v in pairs(self.lqqf_cost) do
        if string.sub(v.id,1,4) == tostring(confdata.award_pre) then
            table.insert(t,v)
        end
    end

    table.sort( t, function(a,b)
        -- body
        return a.id < b.id 
    end )

    return t
end
function ActivityConf:getMulXslb(id)
    -- body
    return self.mul_xslb[tostring(id)]
end

function ActivityConf:getMulactiveshow( id )
    -- body
    return self.mul_active_show[tostring(id)]
end

function ActivityConf:getMjxbAward()
    -- body
    return table.values(self.mjxb_award_pool)
end
function ActivityConf:getMjxbCost( id )
    -- body
    local t = {}
    local confdata = self:getMulActById(id)
    for k , v in pairs(self.mjxb_cost) do
        if string.sub(v.id,1,4) == tostring(confdata.award_pre) then
            table.insert(t,v)
        end
    end

    table.sort( t, function(a,b)
        -- body
        return a.id < b.id 
    end )

    return t
end
--awardPre:奖励前缀
function ActivityConf:getMoneytree(awardPre,_type)
    -- body
    local t = {}
    for k , v  in pairs(self.money_tree) do
        if math.floor(v.id/1000) == awardPre and v.type == _type then
            table.insert(t,v)
        end
    end
    return t 
end

function ActivityConf:getMoneytreeById(id)
    -- body
    return self.money_tree[tostring(id)]
end

function ActivityConf:getMulLjcz(id)
    -- bod
    local condata = self.mul_active[tostring(id)]
    local index = condata.award_pre
    local t = {}
    for k ,v in pairs(self.mul_ljcz) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
            table.insert(t,v)
        end
    end
    return t 
end

--多开活动
function ActivityConf:getMulActById(id)
    local data = nil
    for k,v in pairs(self.mul_active) do
        if id == v.id then
            data = v
            break
        end
    end
    return data
end

function ActivityConf:getMulLxcz(id,type)
    -- bod
    local condata = self.mul_active[tostring(id)]
    local index = condata.award_pre
    local t = {}
    for k ,v in pairs(self.con_cost) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
            table.insert(t,v)
        end
    end

    local data = {}
    for k,v in pairs(t) do
        if type == v.type then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data 
end

-- --连消特惠
-- function ActivityConf:getLXTHDataByType2(datas)
--     local data = {}
--     for k,v in pairs(datas) do
--         if type == v.type then
--             table.insert(data,v)
--         end
--     end
--     table.sort(data,function(a,b)
--         if a.id ~= b.id then
--             return a.id < b.id
--         end
--     end)
--     return data
-- end

function ActivityConf:getKaifulcrk()
    -- body
    local t = table.values(self.kaifu_lcrk)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)
    return t 
end

function ActivityConf:getKaifudbrk()
    -- body
    local t = table.values(self.kaifu_dbrk)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)
    return t 
end

function ActivityConf:getPetrebackaward( ... )
    -- body
    return table.values(self.pet_reback_award)
end

function ActivityConf:getPetrankaward( ... )
    -- body
    return table.values(self.pet_rank_award)
end

function ActivityConf:getCzhkItem()
    -- body
    return table.values(self.czhk_item)
end

function ActivityConf:getWelfareGlobal(id)
    return self.welfare_global[tostring(id)]
end

function ActivityConf:getChunjieAllRed()
    -- body
    local t = table.values(self.newyear_redbag_award)
    table.sort(t,function (a,b)
        -- body
        return a.sort < b.sort
    end)
    return t 
end

--春节活动
function ActivityConf:getChunjieActList()
    -- body
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 11 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.sort and b.sort then
            return a.sort < b.sort
        else
            return a.id < b.id
        end
    end)
    return data
end
--元宵活动
function ActivityConf:getLanternActList()
    -- body
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 12 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end

--等级冲锋
function ActivityConf:getLevelChargeById(id)
    local t = {}
    for k,v in pairs(self.level_charge) do
        if math.floor(v.id/10000) == id then
            table.insert(t,v)
        end
    end
    table.sort(t,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return t
end

function ActivityConf:getZerobuyItem(id)
    -- body
    return self.zero_buy[tostring(id)]
end

function ActivityConf:getZerobuy(data)
    -- body
    --按天获取
    local t = {}
    for k , v in pairs(self.zero_buy) do
        --零元购改特惠礼包bxp 2018.5.16
        -- if not data.signMap[tonumber(v.id)] then --如果没有这个挡位没有购买
            if v.ctype == 1 then
                local var = v.id % 1000
                if var == 0 then
                    var = 9
                end
                if var == data.openDay then --天数一致
                    table.insert(t,v)
                end
            -- else --固定挡位
            --     if v.open_day >= data.openDay then
            --         table.insert(t,v)
            --     end
            end
        -- end
    end

    table.sort(t,function(a,b)
        -- body
        if a.ctype == b.ctype then
            return a.id < b.id
        else
            return a.ctype < b.ctype
        end
    end)

    return t
    --return self.zero_buy[tostring(id)]
end

function ActivityConf:getSummerAwardsById( id )
    local data = self.summer_flame_active[tostring(id+10000)]
    if data then
        return data.awards
    end
    return nil
end

function ActivityConf:getHorseSkillSale(id)
    -- body
    local t = {}
    for k ,v in pairs(self.horse_skill_sale) do
        if v.modularid == id then
            table.insert(t,v)
        end
    end

    table.sort( t, function( a,b )
        -- body
        return a.id < b.id
    end )

    return t
end

function ActivityConf:getPartnerSkillSale(id)
    -- body
    local t = {}
    for k ,v in pairs(self.partner_skill_sale) do
        if v.modularid == id then
            table.insert(t,v)
        end
    end

    table.sort( t, function( a,b )
        -- body
        return a.id < b.id
    end )

    return t
end

function ActivityConf:getTopBtn()
    -- body
    return table.values(self.topbtn)
end

function ActivityConf:getHideTopBtn()
    return table.values(self.hide_topbtn)
end

function ActivityConf:getTopBtnDataById(id)
    -- body
    if self.topbtn[tostring(id)] then
        return self.topbtn[tostring(id)]
    end
    return {}
end

function ActivityConf:getBottomBtn()
    -- body
    return table.values(self.bottombtn)
end

function ActivityConf:getBottomByid(id)
    -- body
    return self.bottombtn[id..""]
end

function ActivityConf:getValue(id)
    -- body
    return self.activity_global[id..""]
end

--返回福利大厅
function ActivityConf:getAllWelfare()
    local data = {}
    for k,v in pairs(self.welfare_type) do
        table.insert(data, v)
    end
    table.sort(data, function(a, b)
        return a.sort < b.sort
    end)
    return data
end
--在线奖励
function ActivityConf:getOnlineAward()
    return self:sortOnlineAward()
end

function ActivityConf:sortOnlineAward()
    local data = {}
    local mDay = cache.ActivityCache:getLoopDay()
    for k,v in pairs(self.online_award) do
        local day = tonumber(string.sub(v.id,1,1))
        if mDay == day then
            table.insert(data, v)
        end
    end
    table.sort(data, function(a, b)
        return a.id < b.id
    end)
    return data
end
--离线经验
function ActivityConf:getOfflineAward()
    local data = {}
    for k,v in pairs(self.outline_exp_times) do
        table.insert(data, v)
    end
    table.sort(data, function(a, b)
        return a.id < b.id
    end)
    return data
end
--vip礼包类型
function ActivityConf:getVipGiftTypes()
    local data = {}
    for k,v in pairs(self.vip_gift_type) do
        table.insert(data, v)
    end
    table.sort(data, function(a, b)
        return a.id < b.id
    end)
    return data
end
--vip礼包
function ActivityConf:getAllVipGift()
    local data = {}
    for k,v in pairs(self.vip_gift) do
        table.insert(data, v)
    end
    table.sort(data, function(a, b)
        return a.vip_level < b.vip_level
    end)
    return data
end
--签到天数奖励
function ActivityConf:getSumSignAward()
    local data = {}
    for k,v in pairs(self.sum_sign_award) do
        table.insert(data, v)
    end
    table.sort(data, function(a, b)
        return a.id < b.id
    end)
    return data
end
--签到奖励
function ActivityConf:getSignAward()
    local data = {}
    for k,v in pairs(self.sign_award) do
        table.insert(data, v)
    end
    table.sort(data, function(a, b)
        return a.id < b.id
    end)
    return data
end
--仙尊特权
function ActivityConf:getAllPrivilege(mDay)
    local data = {}
    for k,v in pairs(self.vip_privilege_award) do
        local day = tonumber(string.sub(v.id,1,1))
        if day == mDay then
            table.insert(data, v)
        end
    end
    table.sort(data, function(a, b)
        return a.id < b.id
    end)
    return data
end
--资源找回类型表
function ActivityConf:getResourceTypes()
    local data = {}
    for k,v in pairs(self.resource_type) do
        table.insert(data, v)
    end
    table.sort(data, function(a, b)
        return a.sort < b.sort
    end)
    return data
end
--资源找回数据
function ActivityConf:getResourceData(id)
    return self.resource_recovery[id..""]
end
--更新公告
function ActivityConf:getUpdateNotice()
    return self.update_notice["1"]
end
--时间类型(0无限,1开服,2指定天数,3多开时间,4每天指定时间开启活动)
function ActivityConf:getActiveByTimetype(id)
    -- body
    local t = {}
    if id then
        for k ,v in pairs(self.active) do
            if v.time_type == id then
                table.insert(t,v)
            end
        end
    end

    table.sort(t,function(a,b)
        -- body
        if a.sort == b.sort then
            return a.id < b.id
        else
            local asort = a.sort or 0
            local bsort = b.sort or 0
            return asort < bsort
        end
    end)

    return t 
end

function ActivityConf:getActiveByActPos(id)
    -- body
    local t = {}
    if id then
        for k ,v in pairs(self.active) do
            if v.activity_pos == id then
                table.insert(t,v)
            end
        end
    end

    table.sort(t,function(a,b)
        -- body
        if a.sort == b.sort then
            return a.id < b.id
        else
            return a.sort < b.sort
        end
    end)

    return t 
end
--进阶活动列表
function ActivityConf:getActiveList()
    local t = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 2 then
            table.insert(t,v)
        end
    end
    table.sort(t,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return t
end

--圣诞活动
function ActivityConf:getChristmasList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 6 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ActivityConf:getActiveById(id)
    return self.active[id..""]
end
--按活动ID获取奖励
function ActivityConf:getRandrewardByid(id)
    -- body
    local t = {}
    for k ,v in pairs(self.open_rank_award) do
        local index = math.floor(v.id/100) 
        if tonumber(index) == tonumber(id) then
            table.insert(t,v)
        end
    end

    table.sort(t,function(a,b)
        -- body
        return a.id<b.id
    end)

    return t 
end

--按活动ID获取奖励
function ActivityConf:getOpenJieAwardByid(id)
    -- body
    local t = {}
    for k ,v in pairs(self.open_jinjie_award) do
        local index = math.floor(v.id/100) 
        if tonumber(index) == tonumber(id) then
            table.insert(t,v)
        end
    end
    return t 
end
--series_cz_awards
function ActivityConf:getSeriesCzAwards()
    -- body
    return table.values(self.series_cz_awards)
end

function ActivityConf:getGropPurchase(days)
    -- body
    local t = {}
    for k ,v in pairs(self.firstcz_group_purchase) do
        if math.floor(v.id/1000) == days then
            table.insert(t,v)
        end
    end

    return t 
end

function ActivityConf:getGropNumber()
    -- body
    local t = {}
    for k,v in pairs(self.firstcz_group_purchase) do
        t[v.group_count] = true
    end

    return t 
end
--7天登录奖励
function ActivityConf:getLoginAward()
    local t = {}
    for k,v in pairs(self.login_award_sevenday_act) do
        table.insert(t,v)
    end
    table.sort( t, function(a,b) 
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return t
end
--百倍礼包
function ActivityConf:getBaibeiGiftData(id)
    -- body
    if self.fairy_card_gift[tostring(id)] then
        return self.fairy_card_gift[tostring(id)]
    end
    return nil
end
function ActivityConf:getDayGift(id)
    -- body
    local t ={}
    for k,v in pairs(self.day_perferential_gift) do
        if math.floor(k/1000) == id then
            table.insert(t,v)
        end
    end

    table.sort(t,function(a,b)
        -- body
        return a.id < b.id 
    end)

    return t  
end

--开服每日累充信息
function ActivityConf:getAwardsData(day)
    -- body
    local data = {}
    for k,v in pairs(self.mrlc_activity) do
        if math.floor(tonumber(v.id)/1000) == day then
            table.insert(data,v)
        end
    end
    table.sort( data, function(a,b) 
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--开服累充活动(不是每日累充)
function ActivityConf:getKaifuTotalRecharge(id)
    local data = {}
    for k,v in pairs(self.open_lc_act) do
        if math.floor(tonumber(v.id)/1000) == id then
            table.insert(data,v)
        end
    end

    table.sort(data,function(a,b)
        return a.yb_num < b.yb_num
    end)

    return data
end

--开服单笔充值活动
function ActivityConf:getKaifuOnceRecharge(id)
    local data = {}
    for k,v in pairs(self.open_dbcz_act) do
        if math.floor(tonumber(v.id)/1000) == id then
            table.insert(data,v)
        end
    end

    table.sort(data,function(a,b)
        return a.yb_num < b.yb_num
    end)

    return data
end

--开服投资信息
function ActivityConf:getOpenInvestment()
    -- body
    local data = {}
    for k,v in pairs(self.investment_plan_open) do
        table.insert(data,v)
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

function ActivityConf:getGoodsInvestment()
    local data = {}
    for k,v in pairs(self.open_investment_item) do
        table.insert(data,v)
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

--升级投资信息
function ActivityConf:getLvInvestment()
    -- body
    local data = {}
    for k,v in pairs(self.investment_plan_lvl) do
        table.insert(data,v)
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    local tmpData = {{},{},{}}
    for k,v in pairs(data) do
        if math.floor(v.id/1000) == 2001 then
            table.insert(tmpData[1],v)
        elseif math.floor(v.id/1000) == 2002 then
            table.insert(tmpData[2],v)
        elseif math.floor(v.id/1000) == 2003 then
            table.insert(tmpData[3],v)
        end
    end
    return tmpData
end

--每日首充
function ActivityConf:getDaliyChargeData()
    -- body
    local data = {}
    for k,v in pairs(self.daily_single_recharge) do
        table.insert(data,v)
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

--每日首充累积奖励
function ActivityConf:getDaliyAwardsData(cycle)
    local data = {}
    for k,v in pairs(self.daily_lctimes_awards) do
        if cycle >= v.cycle[1] and cycle <= v.cycle[2] then
            table.insert(data,v)
        end
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

--开服任务
function ActivityConf:getOpenTask(id)
    -- body
    local t = {}
    for k ,v in pairs(self.open_task) do
        if math.floor(k/1000) == id  then
            table.insert(t,v)
        end
    end

    return t 
end

--元宝复制
function ActivityConf:getIngot(id)
    -- body

    return  self.yb_copy[id..""]
end

--每日一元
function ActivityConf:getDayOneYuanData(id)
    -- body
    return self.daily_cz_one_yuan[id..""]
end

--再充献礼
function ActivityConf:getReward(id)
    -- body

    return self.first_cz_gift[id..""]
end
function ActivityConf:getReChargeAwards()
    local data = {}
    for k,v in pairs(self.first_cz_gift) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

--等级礼包
function ActivityConf:getGradePackageData()
    local list = {}

    for k,v in pairs(self.lev_gift) do
        table.insert(list, v)
    end
    table.sort(list, function(a,b)
        return a.id < b.id
    end )

    return list
end

function ActivityConf:getgetGradePackageDataByid( id)
    -- body
    return self.lev_gift[tostring(id)]
end

--等级特卖
function ActivityConf:getGradeSaleData()
    local list = {}

    for k,v in pairs(self.lev_sell) do
        table.insert(list, v)
    end
    table.sort(list, function(a,b)
        return a.id < b.id
    end )

    return list
    -- return self.lev_sell
end

function ActivityConf:getSpecialPanic(id)
    return self.special_panic_buy[tostring(id)]
end

--仙盟排行
function ActivityConf:getGangRankReward()
    return table.values(self.gang_rank_awards)
end
--冲级排行
function ActivityConf:getLevelRankReward(id)
    return self.open_level_rank_award[tostring(id)]
end

function ActivityConf:getUpChannel(actId)
return self.act_upchannel_list[tostring(actId)]
end
--宝树活动配置
function ActivityConf:getTreeConfData()
    local tempList = {}
    
    for _,v in pairs(self.treasures_tree) do
        table.insert(tempList, v)
    end

    table.sort(tempList, function(a,b)
        return a.id < b.id
    end )

    return tempList
end
function ActivityConf:getFruitRewardList()
    local tempList = {}
    
    for _,v in pairs(self.treasures_tree_fruit) do
        table.insert(tempList, v)
    end

    table.sort(tempList, function(a,b)
        return a.id < b.id
    end )
    
    return tempList
end
function ActivityConf:getFreeTimesData()
    return self.activity_global.tree_free_times
end
function ActivityConf:getModel()
    local tempList = {}
    for _,v in pairs(self.treasures_tree_model) do
        table.insert(tempList, v)
    end
    table.sort(tempList, function(a,b)
        return a.id < b.id
    end )
    return tempList
end
--END 宝树

--点石成金配置
function ActivityConf:getAwardsPoolById(id)
    return self.act_lucky_awards_pool[tostring(id)]
end

--疯狂砸蛋配置
function ActivityConf:getEggAwardsData()
    local data = {}
    for _,info in pairs(self.smash_egg) do
        for k,v in pairs(info.rewards) do
            table.insert(data,v)
        end
    end
    -- table.sort(data,function(a,b)
    --     if a.id ~= b.id then
    --         return a.id > b.id
    --     end
    -- end)
     return data
end
--疯狂砸蛋累积奖励配置
function ActivityConf:getAccumulateData()
    local data = {}
    for k,v in pairs(self.smash_egg_cumulate) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--战力排行
function ActivityConf:getPowerRankRaward(id)
    return self.open_power_rank_award[tostring(id)]
end

function ActivityConf:getServerPowerRankRaward(id)
    return self.cross_power_rank_award[tostring(id)]
end
--装备战力排行
function ActivityConf:getEquipRankRaward(id)
    return self.equip_power_rank_award[tostring(id)]
end

--宠物战力排行
function ActivityConf:getPetRankRaward(id)
    return self.open_pet_rank_award[tostring(id)]
end
--BOSS有奖
function ActivityConf:getBossPriceDataById(id)
    return self.boss_price[tostring(id)]
end
function ActivityConf:getPlies()
    local data = {}
    for k,v in pairs(self.boss_price) do
        table.insert(data,v)
    end
    if data then
        return #data
    end
    return 1
end
--集字活动
function ActivityConf:getWoedCollectionData()
    local data = {}
    for k,v in pairs(self.open_word_collection) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--封测奖励
function ActivityConf:getBetaBack(id)
    return self.beta_back[tostring(id)]
end

--天书BUFF配置
function ActivityConf:getHighGradePackgeBuffConf(id)
    return self.pyjq_buff[tostring(id)]
end
--天书奖励配置
function ActivityConf:getHighGradePackgeAwardConf(id)
    -- local data = {}
    -- for _,v in pairs(self.pyjq_award) do
    --     data[v.id] = v
    -- end
    -- return data

    local list = {}

    for k,v in pairs(self.pyjq_award) do
        if v.layer == id then 
            table.insert(list, v)
        end 
    end
    -- table.sort(list, function(a,b)
    --     return a.id < b.id
    -- end )

    return list
end

function ActivityConf:getHighGradePackgeFloor(id)
    local data = {}
    for k,v in pairs(self.pyjq_award) do
        if id == v.layer then
            table.insert(data,v)
        end 
    end
    return #data
end

--根据模块id获取寻宝消耗
function ActivityConf:getXunBaoCostByModule(moduleId,id)
    local condata 
    if moduleId == 1155 then
        condata = self.treasure_book_cost
    elseif moduleId == 1163 then
        condata = self.treasure_jinjie_cost
    elseif moduleId == 1194 then
        condata = self.treasure_pet_cost
    elseif moduleId == 1239 then 
        condata = self.treasure_shenqi_cost
    elseif moduleId == 1240 then 
        condata = self.treasure_honghuang_cost
    elseif moduleId == 1267 then 
        condata = self.treasure_jianling_cost
    elseif moduleId == 1343 then 
        condata = self.treasure_xian_equip_cost
    elseif moduleId == 1358 then 
        condata = self.treasure_shengyin_cost
    elseif moduleId == 1362 then
        condata = self.treasure_jianshen_cost
    elseif moduleId == 1437 then
        condata =self.treasure_qibing_cost
    elseif moduleId == 1450 then
        condata =self.treasure_hm_cost
    end
    return condata[tostring(id)]
end

--装备寻宝活动积分商城道具
function ActivityConf:getScoreStoreItem()
    local data = {}
    for k,v in pairs(self.treasure_book_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--装备寻宝装备
function ActivityConf:getXunBaoEquip()
    -- return self.treasure_equip_pool[tostring(id)]
    local data = {}
    for k,v in pairs(self.treasure_equip_pool) do
        table.insert(data,v)        
    end
    table.sort(data,function ( a,b )
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--装备寻宝奖励设置
function ActivityConf:getZhuangBeiItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_book_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end

-----------------进阶寻宝---------------------
--进阶寻宝活动积分商城道具
function ActivityConf:getJinJieScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_jinjie_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--进阶寻宝装备
function ActivityConf:getJinJieXunBaoEquip(id)
    return self.treasure_jinjie_pool[tostring(id)]
end
--进阶寻宝奖励设置
function ActivityConf:getJinJieItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_jinjie_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
-----------------铸星寻宝---------------------
--铸星寻宝活动消耗
function ActivityConf:getZhuXingXunBaoCost(id)
    return self.treasure_zhuxing_cost[tostring(id)]
end
--铸星寻宝活动积分商城道具
function ActivityConf:getZhuXingScoreStoreItem(id)
    return self.treasure_zhuxing_shop[tostring(id)]
end
--铸星寻宝装备
function ActivityConf:getZhuXingXunBaoEquip(id)
    return self.treasure_zhuxing_pool[tostring(id)]
end
-- --铸星寻宝奖励
-- function ActivityConf:getZhuXingXunBaoItem(id)
--     return self.theasure_zhuxing_item[tostring(id)]
-- end

--铸星寻宝奖励设置
function ActivityConf:getZhuXingItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_zhuxing_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
----------------宠物寻宝-------------------
--宠物寻宝活动积分商城道具
function ActivityConf:getPetScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_pet_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--宠物寻宝奖励设置
function ActivityConf:getPetItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_pet_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
----------------神器寻宝------------------
--神器寻宝活动积分商城道具
function ActivityConf:getShenQiScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_shenqi_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--神器寻宝奖励设置
function ActivityConf:getShenQiItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_shenqi_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
---------------洪荒寻宝---------------
--洪荒寻宝活动积分商城道具
function ActivityConf:getHonghuangScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_honghuang_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--洪荒寻宝奖励设置
function ActivityConf:getHonghuangItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_honghuang_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
---------------仙装寻宝---------------
--仙装寻宝活动积分商城道具
function ActivityConf:getXianZhuangScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_xian_equip_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--仙装寻宝奖励设置
function ActivityConf:getXianZhuangItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_xian_equip_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
--仙装寻宝装备
function ActivityConf:getXianZhuangEquip()
    -- return self.treasure_equip_pool[tostring(id)]
    local data = {}
    for k,v in pairs(self.treasure_xian_equip_pool) do
        table.insert(data,v)        
    end
    table.sort(data,function ( a,b )
         return a.id < b.id
    end)
    return data
end
---------------剑灵寻宝---------------
--剑灵寻宝活动积分商城道具
function ActivityConf:getJianLingScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_jianling_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--剑灵寻宝奖励设置
function ActivityConf:getJianLingItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_jianling_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
---------------圣印寻宝---------------
--圣印寻宝活动积分商城道具
function ActivityConf:getShengYinScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_shengyin_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--圣印寻宝奖励设置
function ActivityConf:getShengYinItem(openDay)
    local t = {}
    for k,v in pairs(self.theasure_shengyin_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end
---------------剑神装备寻宝--------------------
--剑神装备寻宝活动积分商城道具
function ActivityConf:getJianShenScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_jianshen_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--剑神装备寻宝奖励设置
function ActivityConf:getJianShenItem(openDay)
    local t = {}
    for k,v in pairs(self.treasure_jianshen_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end

--------------奇兵寻宝--------------
--奇兵寻宝活动积分商城道具
function ActivityConf:getQiBingScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_qibing_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score)~=tonumber(b.need_score) then
            return tonumber(a.need_score)>tonumber(b.need_score)
        end
    end)
    return data
end 

--奇兵寻宝奖励设置
function ActivityConf:getQiBingItem(openDay)
    local q = {}
    for k,v in pairs(self.treasure_qibing_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id ==openDay then
            table.insert(q,v)
        end
    end
    return q
end

---------------鸿蒙寻宝--------------------
--鸿蒙寻宝活动积分商城道具
function ActivityConf:getHongMengScoreStoreItem(id)
    local data = {}
    for k,v in pairs(self.treasure_hm_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
    if tonumber(a.need_score) ~= tonumber(b.need_score) then
            return tonumber(a.need_score) > tonumber(b.need_score)
        end
    end)
    return data
end
--鸿蒙寻宝奖励设置
function ActivityConf:getHongMengItem(openDay)
    local t = {}
    for k,v in pairs(self.treasure_hm_item) do
        local id = tonumber(string.sub(v.id,4,4))
        if id == 0 or id == openDay then
            table.insert(t,v)
        end
    end
    return t
end

--圣诞节活动
function ActivityConf:getChristmasGlobal(id)
    return self.christmas_global[id ..""]
end

--圣诞活动登陆奖励
function ActivityConf:getChristmasAwards(time)
    local data = {}
    for k,v in pairs(self.christmas_signed_award) do
        if v.date >= time then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--圣诞活动圣诞树配置
function ActivityConf:getChristmasTreeData(lv)
    return self.christmas_tree_level[lv..""]
end
--许愿袜配置
function ActivityConf:getSocksData()
    local data = {}
    for k,v in pairs(self.christmas_socks_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--圣诞活动个人排行榜奖励
function ActivityConf:getChristmasRankingAwards()
    local data = {}
    for k,v in pairs(self.christmas_ranking_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--圣诞活动仙盟排行榜奖励
function ActivityConf:getChristmasGangRankingAwards()
    local data = {}
    for k,v in pairs(self.christmas_gang_ranking_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--幸运云购活动获取客户端显示的物品
function ActivityConf:getShowAward(id,actId)
    if actId == 3017 then
        return self.lucky_buy00[tostring(id)]
    elseif actId == 3054 then
        return self.lucky02_buy00[tostring(id)]
    end
end
--幸运云购次数和花费
function ActivityConf:getSumAndCost()
    local tempList = {}
    table.insert(tempList, self.activity_global.luck_buy_cost)
    table.insert(tempList, self.activity_global.luck_buy_limit_time)
    return tempList
end
--幸运云购额外显示的装备
function ActivityConf:getAdditionalEquip(actId,mulActId)
    local data = {}
    if actId == 3017 then
        --多开活动id mulActId
        local mulActConf = conf.ActivityConf:getMulActById(mulActId)
        for k,v in pairs(self.lucky_buy01) do
            if mulActConf then
                local award_pre = mulActConf.award_pre
                if math.floor(tonumber(v.id)/1000) == award_pre then
                    table.insert(data,v)
                end
            else
                table.insert(data,v)
            end
        end
    elseif actId == 3054 then
        for k,v in pairs(self.lucky02_buy01) do
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--元旦活动
function ActivityConf:getYdActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 7 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end

--元旦：兑换年货
function ActivityConf:getAnnualGoods()
    -- return self.annual_goods
    local data = {}
    for k,v in pairs(self.annual_goods) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ActivityConf:getNewyearSignedAward()
    local data = {}
    for k,v in pairs(self.newyear_signed_award) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    return data
end

function ActivityConf:getHolidayGlobal(id)
    return self.holiday_global[tostring(id)]
end

--惡魔時裝限時
function ActivityConf:getDevilFashionAward()
    local data = {}
    for k,v in pairs(self.emo_fashion_award_pool) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    return data
end

--周末狂欢
function ActivityConf:getWeekActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 8 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end

function ActivityConf:getWeekLoginAward()
    local data = {}
    for k,v in pairs(self.week_login_award) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    return data
end

function ActivityConf:getweekFubenDouble(id)
    local data = {}
    for k,v in pairs(self.week_fuben_doubel) do
        if v.act_id == id then
            table.insert(data, v)
        end
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    return data
end

--转盘活动
function ActivityConf:getTurntableActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 10 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end

--腊八活动
function ActivityConf:getLabaActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 9 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end
--腊八登录
function ActivityConf:getLabaLoginAward()
    local data = {}
    for k,v in pairs(self.laba_signed_award) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    return data
end
--腊八活跃奖励
function ActivityConf:getLabaActiveAward()
    local data = {}
    for k,v in pairs(self.laba_active_award) do
        table.insert(data, v)
    end
    table.sort( data,function (a,b)
        return a.id < b.id 
    end )
    return data
end
--腊八有礼
function ActivityConf:getLabaGift()
    local data = {}
    for k,v in pairs(self.laba_gift) do
        table.insert(data, v)
    end
    table.sort(data,function ( a,b )
        return a.id < b.id
    end)
    return data
end
--腊八排行奖励
function ActivityConf:getRankGiftBySex(sex)
    local data = {}
    for k,v in pairs(self.laba_consumption_rank) do
        if v.sex then
            if v.sex == sex then 
                table.insert(data, v)
            end
        else
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        return a.id < b.id     
    end)
    return data
end
--腊八排行2019奖励
function ActivityConf:getRank2019GiftBySex(sex)
    local data = {}
    for k,v in pairs(self.lb_rank) do
        if v.sex then
            if v.sex == sex then 
                table.insert(data, v)
            end
        else
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        return a.id < b.id     
    end)
    return data
end
--腊八活跃任务
function ActivityConf:getActiveTask()
    local data = {}
    for k,v in pairs(self.laba_active_task) do
        table.insert(data, v)
    end
    table.sort(data,function (a,b)
        return a.sort < b.sort
    end)
    return data
end
--腊八副本双倍
function ActivityConf:getLabaFbsbBymoduleId(module_id)
    for k,v in pairs(self.week_fuben_doubel) do
        if v.act_id == 1065 then --腊八活动id
            if v.module_id == module_id then 
                return v
            end
        end
    end
end

--幸运转盘
function ActivityConf:getXyzp00(id,moduleId)
    if moduleId == 1190 then
        return self.xyzp_00[tostring(id)]
    elseif moduleId == 1233 then
        return self.xyzp02_00[tostring(id)]
    end
end

--幸运转盘装备库
function ActivityConf:getXyzp01(lv)
    for k,v in pairs(self.xyzp_01) do
        local levels = v.level
        if lv >= levels[1] and lv <= levels[2] then
            return v
        end
    end
end
--邀请码奖励
function ActivityConf:getInviteKey(type)
    local data = {}
    for k,v in pairs(self.invite_key) do
        if v.type == type then
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

function ActivityConf:getInviteKey(id)
    return self.invite_key[tostring(id)]
end

--情人节活动
function ActivityConf:getValentineActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.id == 1070 or v.id == 3046 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.module_id < b.module_id
    end)
    return data
end
--情侣抽奖奖励
function ActivityConf:getRallfeAward()
    local data = {}
    for k,v in pairs(self.valentine_raffle_award) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end
--情侣积分奖励
function ActivityConf:getScoreAward(sex)
    local data = {}
    for k,v in pairs(self.valentine_integral_award) do
        if v.sex then
            if v.sex == sex then 
                table.insert(data, v)
            end
        else
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

--情人节活跃奖励
function ActivityConf:getValentineActiveAward()
    local data = {}
    for k,v in pairs(self.valentine_active_award) do
        table.insert(data, v)
    end
    table.sort( data,function (a,b)
        return a.id < b.id 
    end )
    return data
end
--情人节活跃任务
function ActivityConf:getValentineActiveTask()
    local data = {}
    for k,v in pairs(self.valentine_active_task) do
        table.insert(data, v)
    end
    table.sort(data,function (a,b)
        return a.sort < b.sort
    end)
    return data
end
--小年活动列表
function ActivityConf:getLunarYearActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 13 then    --== 1058 or v.id == 1068 or v.id == 3045 then 
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end
--活动登录奖励(公共)
function ActivityConf:getLoginAwardPublic(actId)
    local data = {}
    for k,v in pairs(self.activity_login_award) do
        local id = tonumber(string.sub(v.id,1,4))
        if id == actId then
            table.insert(data,v)
        end
    end

    table.sort(data,function(a,b)
        return a.id < b.id
    end)

    return data
end

function ActivityConf:getLoginAwardById(id)
    -- body
    return self.activity_login_award[tostring(id)]
end
--猜灯谜排名奖励
function ActivityConf:getLanternRankAwards()
    local data = {}
    for k,v in pairs(self.yx_rank_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

--元旦：花灯兑奖
function ActivityConf:getLanternGoods()
    local data = {}
    for k,v in pairs(self.lantern_exchange) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

function ActivityConf:getLanternActiveTask()
    local data = {}
    for k,v in pairs(self.lantern_active_task) do
        table.insert(data, v)
    end
    table.sort(data,function (a,b)
        return a.sort < b.sort
    end)
    return data
end

function ActivityConf:getLanternActiveAward()
    local data = {}
    for k,v in pairs(self.lantern_active_award) do
        table.insert(data, v)
    end
    table.sort( data,function (a,b)
        return a.id < b.id 
    end )
    return data
end

--限时特卖
function ActivityConf:getFlashSaleConf(lv)
    local data = {}
    for k,v in pairs(self.limit_time_sale) do
        table.insert(data, v)
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)

    -- 新逻辑
    local tempData = {}
    for k,v in pairs(data) do
        if v.level <= lv then 
            table.insert(tempData, v)
        else
            table.insert(tempData,v)
            break
        end 
    end

    -- for k,v in pairs(tempData) do
    --     print(k,v.level,"法克111111")
    -- end

    return tempData
end

function ActivityConf:getCostAwardsById(actId,actDay)
    local data = {}
    for k,v in pairs(self.act_cz_cost_rank) do
        if math.floor(v.id/1000) == actId and v.act_day == actDay then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--合服投资信息
function ActivityConf:getMergeInvestment()
    -- body
    local data = {}
    for k,v in pairs(self.investment_plan_merge) do
        table.insert(data,v)
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

--夺宝奇兵
function ActivityConf:getGridData(award_pre)
    local data = {}
    for k,v in pairs(self.act_czdb_grid_award) do
        if math.floor(v.id/1000) == award_pre then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--日常活动列表
function ActivityConf:getDailyList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 16 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end

function ActivityConf:getczfhTypeData(id)
    return self.czfh_day[tostring(id)]
end



function ActivityConf:getczfhInfoByType(type)
    local data = {}
    for k,v in pairs(self.czfh) do
        if type ==  math.floor(tonumber(v.id)/1000) then 
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

--超值兑换
function ActivityConf:getChangeTypeData(id)
    return self.czdh_day[tostring(id)]
end

function ActivityConf:getChangeInfoByType(type)
    local data = {}
    for k,v in pairs(self.czdh) do
        if type ==  math.floor(tonumber(v.id)/1000) then 
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

--超值返还2
function ActivityConf:getczfhTypeData2(id)
    return self.czfh_day2[tostring(id)]
end
function ActivityConf:getczfhInfoByType2(type)
    local data = {}
    for k,v in pairs(self.czfh2) do
        if type == math.floor(tonumber(v.id)/1000) then 
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)

    return data
end
--超值兑换2
function ActivityConf:getChangeTypeData2(id)
    return self.czdh_day2[tostring(id)]
end

function ActivityConf:getChangeInfoByType2(type)
    local data = {}
    for k,v in pairs(self.czdh2) do
        if type == math.floor(tonumber(v.id)/1000) then 
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

function ActivityConf:getRankAwardsByActId(actId,pre)
    local data = {}
    for k,v in pairs(self.flower_rank_award) do
        if pre  then
            if tonumber(pre) == tonumber(string.sub(tostring(v.id),1,5)) then
                table.insert( data,v )
            end
        else
            if actId == tonumber(string.sub(tostring(v.id),1,4)) then
                table.insert( data,v )
            end
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end
function ActivityConf:getFlowerRankImgByActId(actId)
    return self.flower_rank_img[tostring(actId)]
end

function ActivityConf:getConfDataByOpenDay(actId)
    local data = {}
    for k,v in pairs(self.hf_zklb) do
        if actId == math.floor(tonumber(v.id/1000)) then 
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--神器列表
function ActivityConf:getShenQiList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 17 then
            table.insert(data,v)
        end
    end
    -- table.sort(data,function(a,b)
    --     return a.sort < b.sort
    -- end)
    return data
end

--开服神器战力排行
function ActivityConf:getShenQiRankRaward1(id)
    return self.shenqi_rank_award01[tostring(id)]
end
--限时神器战力排行
function ActivityConf:getShenQiRankRaward2(id)
    return self.shenqi_rank_award02[tostring(id)]
end

--合服神器战力排行
function ActivityConf:getShenQiRankRaward3(id)
    return self.shenqi_rank_merge_award[tostring(id)]
end

--神器寻宝返还
function ActivityConf:getSQXBBack()
    local data = {}
    for k,v in pairs(self.sqxb_back) do
        table.insert(data, v)
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)

    return data
end
--充值翻牌
function ActivityConf:getChargeCardsById(id)
    local data = {}
    for k,v in pairs(self.czfp) do
        if v.id == id then
            data = v
        end
    end
    return data
end
--充值翻牌奖励
function ActivityConf:getCardsAwardsById(id)
    for k,v in pairs(self.czfp_awards) do
        if v.id == id then
            return v
        end
    end
    return nil
end
--充值返利
function ActivityConf:getRechargeRebate()
    local data = {}
    for k,v in pairs(self.cz_reback_act) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--婚礼热度排行奖励
function ActivityConf:getMarryRankAwardsByActId(actId)
    local data = {}
    for k,v in pairs(self.marry_hot_award) do
        if actId == tonumber(string.sub(tostring(v.id),1,4)) then 
            table.insert( data,v )
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

--获取射球奖励列表
function ActivityConf:getSheQiuSeeList(actId)
    local data = {}
    for k,v in pairs(self.shoot_award_pool) do
        if actId == math.floor(v.id/1000) then
            table.insert( data,v )
        end
    end
    table.insert(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end
--获取射球奖励列表
function ActivityConf:getSheQiuAwardList(actId)
    local data = {}
    for k,v in pairs(self.shoot_cumular_award) do
        if actId == math.floor(v.id/1000) then
            table.insert( data,v )
        end
    end
    return data
end
--合服基金
function ActivityConf:getFundByType(invType)
    local data = {}
    for k,v in pairs(self.fund_merge_award) do
        if invType == math.floor(tonumber(v.id/1000)) then 
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--合服基金2
function ActivityConf:getFund2ByType(invType)
    local data = {}
    for k,v in pairs(self.fund_merge02_award) do
        if invType == math.floor(tonumber(v.id/1000)) then 
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--神炉炼宝
function ActivityConf:getSllbAwardByType(type)
    local data = {}
    for k,v in pairs(self.sllb) do
        if type == math.floor(tonumber(v.id/1000)) then 
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--神炉炼宝
function ActivityConf:getSllbDataById(id)
    return self.sllb[tostring(id)]
end
--合服活动
function ActivityConf:getHefuActData()
    local data = {}
    for k,v in pairs(self.hefu_item) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end
--开服活动
function ActivityConf:getKaifuActData()
    local data = {}
    for k,v in pairs(self.kaifu_item) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end
--精彩活动
function ActivityConf:getJingCaiActData()
    local data = {}
    for k,v in pairs(self.splendid_item) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end
--寻仙探宝
function ActivityConf:getXXTBAward()
    local data = {}
    for k,v in pairs(self.xxtb_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end
--剑灵排行奖励
function ActivityConf:getJianLingRankAward()
    local data = {}
    for k,v in pairs(self.jianling_rank_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--剑灵寻宝返还奖励
function ActivityConf:getJianLingReturnAward()
    local data = {}
    for k,v in pairs(self.jianling_reback_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--剑灵排行奖励（合服）
function ActivityConf:getJianLingRankAward1()
    local data = {}
    for k,v in pairs(self.jianling_rank_merge_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--寻宝返还奖励（合服）
function ActivityConf:getXunBaoAwardbyactID(actID)
    local data = {}
    for k,v in pairs(self.find_reback_merge_award) do
        if string.sub(v.id,1,4) == tostring(actID) then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--神器寻主
function ActivityConf:getSQXZAward()
    local data = {}
    for k,v in pairs(self.dbcz_sqxz) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--法老秘宝
--awardPre:奖励前缀
function ActivityConf:getFLMBDataByFloor(awardPre,floor)
    local data = {}
    for k,v in pairs(self.pyramid_award) do
        local actId = string.sub(tostring(v.id),1,4)
        if tonumber(actId) == awardPre then
            local id = string.sub(tostring(v.id),5,8)
            if floor == math.floor(tonumber(id)/1000) then
                table.insert(data,v)
            end
        end
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--机甲剑神
function ActivityConf:getJijiaActAwards()
    local data = {}
    for k,v in pairs(self.jjjs_award) do
        
    end
end

--神臂排行奖励
function ActivityConf:getShenBiRankAward()
    local data = {}
    for k,v in pairs(self.sbqt_rank_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--神臂返还奖励
function ActivityConf:getShenBiReturnAward()
    local data = {}
    for k,v in pairs(self.sbqt_reback_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--趣味挖矿
function ActivityConf:getActWaKuangData(id)
    local data = {}
    for k,v in pairs(self.qwwk_item) do
        if v.id == id then
            data = v
        end
    end
    return data
end
--趣味挖矿兑换列表
function ActivityConf:getConversionList(award_pre)
    local data = {}
    for k,v in pairs(self.qwwk_item) do
        if v.type == 2 and math.floor(v.id/10000) == award_pre then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--趣味挖矿vip目标奖励
function ActivityConf:getVipAwardsData(award_pre)
    local data = {}
    for k,v in pairs(self.qwwk_item) do
        if v.type == 3 and math.floor(v.id/10000) == award_pre then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--聚划算
function ActivityConf:getJuHuaSuan()
    return table.values(self.jhs_buy_item)
end

function ActivityConf:getJuHuaSuanGiftAwardById(id)
    local condata = self.mul_active[tostring(id)]
    local index = condata.award_pre
    local t = {}
    for k ,v in pairs(self.jhs_gift_award) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
            printt(v.awards)
            return v.awards
        end
    end
end

function ActivityConf:getJuHuaSuanAwardById(id)
    local condata = self.mul_active[tostring(id)]
    local index = condata.award_pre
    local t = {}
    for k ,v in pairs(self.jhs_buy_item) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
            table.insert(t,v)
        end
    end
     table.sort(t,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return t 
end

--连冲特惠
function ActivityConf:getLCTHConByType(type,awakid)
    local data = {}
    for k,v in pairs(self.con_czth) do
        if type == v.type and math.floor(v.id/10000) == awakid then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--狂欢大乐购
function ActivityConf:getKHDLGByFloor(floor,award_pre)
    local data = {}
    for k,v in pairs(self.happy_buy) do
        if tostring(floor) == string.sub(v.id,5,5) and tostring(award_pre) == string.sub(v.id,1,4) then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ActivityConf:getKHDLGData()
    return self.happy_buy
end

    --消费兑换活动
function ActivityConf:getConsume()
    local data = {}
    for k,v in pairs(self.cost_exchange_item) do
            table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

-- 
--消费根据次数返回兑换积分
function ActivityConf:getConsumeScore(id)
    return self.cost_exchange_item[tostring(id)]
end

--冲战达人奖励配置
function ActivityConf:getCzdrAwards(award_pre)
    local data = {}
    for k,v in pairs(self.czdr_act_award) do
        if math.floor(v.id/1000) == award_pre then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--超值累充
function ActivityConf:getCzdbAwards(id)
    -- local data = {}
    -- for k,v in pairs(self.czdb_act_award) do
    --     table.insert(data,v)
    -- end
    -- table.sort(data,function(a,b)
    --     if a.id ~= b.id then
    --         return a.id < b.id
    --     end
    -- end)
    -- return data
    local condata = self.mul_active[tostring(id)]
    local index = condata.award_pre
    local t = {}
    for k ,v in pairs(self.czdb_act_award) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
             table.insert(t,v)
        end
    end
    table.sort(t,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return t
end

--充值抽抽乐
function ActivityConf:getCzcclBoxAwards(id)
    -- local data = {}
    -- for k,v in pairs(self.recharge_lucky_whole_award) do
    --     table.insert(data,v)
    -- end
    -- table.sort(data,function(a,b)
    --     if a.id ~= b.id then
    --         return a.id < b.id
    --     end
    -- end)
    -- return data

    local mulActData = self.mul_active[tostring(id)]
    local index = mulActData.award_pre
    local t = {}
    for k,v in pairs(self.recharge_lucky_whole_award) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
            table.insert(t, v)
        end
    end
    table.sort(t,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return t 
end

--百发百中奖励
function ActivityConf:getBfbzAwards()
    local data = {}
    for k,v in pairs(self.bfbz_award) do
        for _,award in pairs(v.awards) do
            award.sort = v.id
            table.insert(data,award)
        end
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort > b.sort
        end
    end)
    return data
end

--跨服充值榜
function ActivityConf:getKuafuChargeAward(award_pre)
    local data = {}
    for k,v in pairs(self.kf_cz_ranking) do
        if tostring(award_pre) == string.sub(v.id,1,4) then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--仙童排行
function ActivityConf:getXiantongpowerrank( ... )
    -- body
    return table.values(self.xiantong_power_rank)
end

--洞房返还
function ActivityConf:getDongfangaward( ... )
    -- body
    return table.values(self.dongfang_reback_award)
end

--聚宝盆
function ActivityConf:getJuBaoPengaward(id)
--     local data = {}
--     for k,v in pairs(self.jbp_award) do
--         table.insert(data,v)
--     end
--     table.sort(data,function (a,b)
--         if a.id ~= b.id then
--             return a.id < b.id
--         end
--     end)
--     return data
-- end
    local condata = self.mul_active[tostring(id)]
    local index = condata.award_pre
    local t = {}
    for k ,v in pairs(self.jbp_award) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
             table.insert(t,v)
        end
    end
    table.sort(t,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return t
end
--聚宝盆累充元宝
function ActivityConf:getJuBaoPengawardByQuota(quota)
    for k,v in pairs(self.jbp_award) do
        if quota == v.quota then
            return v.multiple
        end
    end
    return
end
    --月卡
function ActivityConf:getMonthCardByPos(pos)
    local data = {}
    for k,v in pairs(self.month_card) do
        if math.floor(v.id/1000) == pos then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ActivityConf:getMonthCardByDay(day)
    return self.month_card[tostring(day)]
end

-- 今日累充
function ActivityConf:getLeiChongAward()
    local data = {}
    for k,v in pairs(self.daily_lc_award) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--
function ActivityConf:getLeiChongAwardById(id,day)
    local condata = self.mul_active[tostring(id)]
    local index = condata.award_pre
    local t = {}
    for k ,v in pairs(self.daily_lc_award) do
        if string.sub(tostring(v.id),1,4) == tostring(index) then
            table.insert(t,v)
        end
    end
    local m = {}
    for k ,v in pairs(t) do
        if string.sub(tostring(v.id),5,5) == tostring(day) then
            table.insert(m,v)
        end
    end
     table.sort(m,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return m 
end

function ActivityConf:getLeiChongAwardById1(id)
     return self.daily_lc_award[tostring(id)]
end


--连消特惠
function ActivityConf:getLXTHDataByType(type)
    local data = {}
    for k,v in pairs(self.con_cost) do
        if type == v.type then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--天命卜卦
function ActivityConf:getTMBGAwardPoolById(id)
    return self.tmbg_award_pool[tostring(id)]
end
--天命卜卦消耗
function ActivityConf:getTMBGCost()
    local data = {}
    for k,v in pairs(self.tmbg_amount_cost) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--步步高升
function ActivityConf:getBBGSItem()
    local data = {}
    for k,v in pairs(self.bbgs_item) do 
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)    
    return data
end

--awardPre:奖励前缀
function ActivityConf:getDanBiAward(awardPre)
    local t = {}
    for k , v  in pairs(self.dbhl_cz_award) do
        if math.floor(v.id/1000) == awardPre then
            table.insert(t,v)
        end
    end
    return t 
end

function ActivityConf:getTeacherCostByType(pre,type)
    local data = {}
    for k,v in pairs(self.lsqdm_cost) do
        if math.floor(v.id/10000) == pre and math.floor(v.id%10000/1000) == type then
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ActivityConf:getTeacherItemById(id)
    return self.lsqdm_award[tostring(id)]
end

function ActivityConf:getWuDiXinYunXingitem(id)
    return self.wdxyx_award[tostring(id)]
end

--限时连充
function ActivityConf:getXslcConByType(type,Id)
    local data = {}
    for k,v in pairs(self.xslc_item) do
        if type == v.type and  math.floor(v.id/10000) == Id  then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--我要转转
function ActivityConf:getWyzzAward(Id)
    local data = {}
    for k,v in pairs(self.wyzz_item) do
        if math.floor(v.id/10000) == Id then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--洞房排行所有奖励
function ActivityConf:getDongFangWholeAward()
    local data = {}
    for k,v in pairs(self.dongfang_whole_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end


function ActivityConf:getDongFangWholeAwardById(id)
    return self.dongfang_whole_award[tostring(id)]
end

--洞房排行奖励
function ActivityConf:getDongRankFangAward()
    local data = {}
    for k,v in pairs(self.dongfang_rank_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--合服连冲
function ActivityConf:getHeFuLianChong(curday)
    local data = {}
    for k,v in pairs(self.hf_lxcz) do
        if math.floor(v.id/10000) == curday then
            table.insert(data, v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--仙装排行奖励
function ActivityConf:getXzphAward()
    local data = {}
    for k,v in pairs(self.xian_equip_rank_award) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ActivityConf:getZqhlAward()
    return table.values(self.zqhl)
end
-- 好运灵签
function ActivityConf:getHylq(id)
    local data = {}
    for k,v in pairs(self.hylq_normal) do
        if string.sub(v.id,1,4) == tostring(id) then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--圣印返还
function ActivityConf:getSYReturn()
    local data = {}
    for k,v in pairs(self.shengyin_treasure_back) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--珍稀乾坤
function ActivityConf:getZxqk()
    local data = {}
    for k,v in pairs(self.zxqk) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--剑神寻宝返还
function ActivityConf:getJSEquipAward()
    local data = {}
    for k,v in pairs(self.jianshen_treasure_back) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

-- 剑神寻宝排行
function ActivityConf:getJSEquipRank()
    local data = {}
    for k,v in pairs(self.js_equip_rank_award) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

-- 烟花庆典
function ActivityConf:getYHAward(award_pre)
    local data = {}
    for k,v in pairs(self.fireworks_celebration) do
        if v.show and v.show == 1 then
            if string.sub(v.id,1,4) == tostring(award_pre) then
                table.insert(data, v)
            end
        end        
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

-- 累计消费
function ActivityConf:getLJXFAward(mulActId)
    local data = {}
    local mulConf = conf.ActivityConf:getMulActById(mulActId)
    local award_pre = mulConf.award_pre
    for k,v in pairs(self.cumulativ_cost) do
        if math.floor(tonumber(v.id)/1000) == award_pre then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--幸运鉴宝
function ActivityConf:getLuckyTreasure()
    local data = {}
    for k,v in pairs(self.lucky_identification) do
        if v.showtype == 1 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ActivityConf:getWSJActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 20 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end

--幸运鉴宝大奖
function ActivityConf:getLuckyTreasureBigAward(id)
    for k,v in pairs(self.lucky_identification) do
        if v.type == 2 then
            return v.items[id + 1]
        end
    end
end

-- 双色球
function ActivityConf:getDoubleBallAward()
    local data = {}
    for k,v in pairs(self.ball_lottery) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        return a.id < b.id 
    end)
    return data 
end

-- 真假雪人(预览)
function ActivityConf:getSnowManAward()
    local data = {}
    for k,v in pairs(self.snowman) do
        if v.show and v.show == 1 then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id 
    end)
    return data 
end

-- 真假雪人(all)
function ActivityConf:getAllSnowManAward()
    local data = {}
    for k,v in pairs(self.snowman) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        return a.id < b.id 
    end)
    return data 
end

-- 满减物品配置
function ActivityConf:getFullReduction(index,day)
	local var = self:getValue("mjzc_day")
	local cday = day%var
	if cday == 0 then cday = var end
	
    local data = {}
    for k,v in pairs(self.mjzc) do
        if v.type == index and v.day == cday then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id 
    end)
    return data 
end

-- 情侣充值
function ActivityConf:getLoversAward()
    local data = {}
    for k,v in pairs(self.qlcz_rank_award) do
        if v.type == index then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id 
    end)
    return data 
end

--盛装寻宝返还奖励
function ActivityConf:getShengZhuangReturnAward()
    local data = {}
    for k,v in pairs(self.shengzhuang_treasure_back) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end


--天天返利根据轮数读取
function  ActivityConf:getTianTianFanLibyLunShu(lunshu,itemtype)
    local data1 = {}
    for k,v in pairs(self.ttfl) do
        if v.lunshu == lunshu and v.type == itemtype then
            table.insert(data1, v)
        end
    end
     table.sort(data1,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
     return data1
end

--天天返利根据轮数取模型
function ActivityConf:getTianTianFanLiModelByLunShu( lunshu )
    for k,v in pairs(self.ttfl) do
        if v.lunshu == lunshu and v.modle then
            return v.modle
        end 
    end
end
--天天返利根据轮数取特效
function ActivityConf:getTianTianFanLiEffectByLunShu( lunshu )
    for k,v in pairs(self.ttfl) do
        if v.lunshu == lunshu and v.effect then
            return v.effect
        end 
    end
    return nil
end

--天天返利根据轮数取特效
function ActivityConf:getTTFLEffectScale( lunshu )
    for k,v in pairs(self.ttfl) do
        if v.lunshu == lunshu and v.effect_scale then
            return v.effect_scale
        end 
    end
    return nil
end

--天天返利根据轮数取位置
function ActivityConf:getTTFLTransform( lunshu )
    for k,v in pairs(self.ttfl) do
        if v.lunshu == lunshu and v.transfoem then
            return v.transfoem
        end 
    end
    return nil
end



--天天返利根据轮数取载体
function ActivityConf:getTianTianFanLiNeedModuleByLunShu( lunshu )
    for k,v in pairs(self.ttfl) do
        if v.lunshu == lunshu and v.needmodel then
            return v.needmodel
        end 
    end
    return nil
end

--水果消除

function ActivityConf:getFruitAwardById(id)
    return self.fruit_eliminate[tostring(id)]
end

--水果类型奖励展示
function ActivityConf:getFruitShowBytype(typef)
    local data = {}
    for k,v in pairs(self.fruit_eliminate) do
        if v.show and v.sub_type == typef then
            table.insert(data, v.items)
        end
    end
    return data
end
--水果宝箱选择展示
function ActivityConf:getFruitChooseShowBytypes(typef)
    local data = {}
    for k,v in pairs(self.fruit_eliminate) do
        if v.sub_type == typef and v.type == 2 then
            table.insert(data,{items =  v.items,id = v.id})
        end
    end
   
    return data
end

--幸运锦鲤
function ActivityConf:XinYunJinLi(day)
    local data = {}
    for k,v in pairs(self.lucky_koi) do
        if day == math.floor(v.id/1000) then
            table.insert(data,v)
        end
    end
    table.sort( data, function(a,b)
        -- body
        return a.id < b.id 
    end )
    return data
end

--科举global变量
function ActivityConf:getKeJuGlobal(id)
    return self.kj_global[tostring(id)]
end
--科举题目
function ActivityConf:getGuessQuestion(id)
    return self.kj_question_pool[tostring(id)]
end
--科举排行奖励
function ActivityConf:getKeJuRankAwards()
    local data = {}
    for k,v in pairs(self.kj_rank_award) do
        local t = clone(v)
        if v.title then
            table.insert(t.awards,1,v.title)
        end
        table.insert(data,t)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

-- 天降礼包
function ActivityConf:TianJiangLiBao(typef,quota,pre)
    local  data = {}
    for k,v in pairs(self.recharge_gift) do
        if v.type == typef and quota == v.quota and tostring(pre) == string.sub(v.id,1,4) then
            table.insert(data, v.items)
        end
    end
    return data
end

--天降礼包返回根据类型返回充值额度
function ActivityConf:TianJiangLiBaoquata(typef,pre)
    local  data = {}
    for k,v in pairs(self.recharge_gift) do
        if v.type == typef and tostring(pre) == string.sub(v.id,1,4) then
            table.insert(data,v)
        end
    end
     table.sort( data, function(a,b)
        -- body
        return a.quota < b.quota 
    end )
    return data
end

--帝魂召唤
function  ActivityConf:DiHunZhaoHuan(typef)
     local  data = {}
    for k,v in pairs(self.dhzh) do
        if v.type == typef and v.zs then
            table.insert(data,v)
        end
    end
    table.sort( data, function(a,b)
        -- body
        return a.id < b.id 
    end )
    return data
end

--帝魂召唤大奖
function  ActivityConf:DiHunZhaoHuanBigAward()
     local  data = {}
    for k,v in pairs(self.dhzh) do
        if v.id%10 == 8 and v.zs then
            table.insert(data,v)
        end
    end
    table.sort( data, function(a,b)
        -- body
        return a.id < b.id 
    end )
    return data
end

function ActivityConf:getShengDanActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 21 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end
--活动中心
function ActivityConf:gethdzxItem()
    local data = {}
    for k,v in pairs(self.hdzx_item) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end
function ActivityConf:getYuanDanActList()
    local data = {}
    for k,v in pairs(self.active) do
        if v.activity_pos == 22 then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    return data
end


--奇兵寻宝返还奖励
function ActivityConf:getQiBingReturnAward()
    local data = {}
    for k,v in pairs(self.qibing_treasure_back) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--奇兵排行
function ActivityConf:getQiBingRankAward()
    local data = {}
    for k,v in pairs(self.qibing_rank_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end


--腊八累充
function ActivityConf:getLBLCAwardPoolById(id)
    return self.lb_lottery[tostring(id)]
end
return ActivityConf