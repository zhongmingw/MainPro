--
-- Author: ohf
-- Date: 2017-03-09 19:28:48
--
--副本协议
local FubenProxy = class("FubenProxy",base.BaseProxy)

local BOSSDEKARONTIME = 6

function FubenProxy:init()
    self:add(5023101,self.add5023101)--请求副本信息(通用)
    self:add(5024101,self.add5024101)--请求经验副本信息
    self:add(5027106,self.add5027106)--请求铜钱副本扫荡
    self:add(5024102,self.add5024102)--请求经验副本首通奖励领取
    self:add(5024103,self.add5024103)--请求副本条件信息
    self:add(5024201,self.add5024201)--请求剧情副本信息
    self:add(5024301,self.add5024301)--请求爬塔副本信息
    self:add(5024311,self.add5024311)--请求vip副本信息
    self:add(5027107,self.add5027107)--请求铜钱副本扫荡
    self:add(5024401,self.add5024401)--请求进阶副本信息
    self:add(5024402,self.add5024402)--请求重置进阶副本
    self:add(5024403,self.add5024403)--请求进阶副本扫荡
    self:add(5020103,self.add5020103)--请求退出异空间场景
    self:add(5020104,self.add5020104)--请求切换副本关卡
    self:add(5024501,self.add5024501)--请求帮派副本显示
    self:add(5024502,self.add5024502)--请求帮派副本目标奖励领取
    self:add(5024503,self.add5024503)--请求帮派副本扫荡
    self:add(5024104,self.add5024104)--请求经验副本扫荡
    self:add(5024202,self.add5024202)--请求剧情副本扫荡
    self:add(5024302,self.add5024302)--请求爬塔副本扫荡
    -- self:add(5025101,self.add5025101)--请求练级谷信息
    -- self:add(5025102,self.add5025102)--请求练级谷时间购买
    -- self:add(5025103,self.add5025103)--请求练级谷加成时间购买
    -- self:add(5025104,self.add5025104)--请求练级谷场景信息
    -- self:add(5025105,self.add5025105)--请求练级谷扫荡
    self:add(5026101,self.add5026101)--请求个人boss信息
    self:add(5330101,self.add5330101)--请求精英boss信息
    self:add(5330102,self.add5330102)--请求精英boss场景信息
    self:add(5330103,self.add5330103)--请求精英boss次数购买
    self:add(5330104,self.add5330104)--请求精英boss弹窗提示设置
    self:add(5330201,self.add5330201)--请求世界boss信息
    self:add(5330202,self.add5330202)--请求世界boss场景信息
    self:add(5810301,self.add5810301)--请求场景道具拾取
    self:add(5810302,self.add5810302)--请求副本采集物拾取
    self:add(5330304,self.add5330304)--请求世界Boss抽奖
    self:add(5330204,self.add5330204)--请求世界BOSS帮派招募
    self:add(5440101,self.add5440101)--请求仙尊boss信息
    self:add(5440102,self.add5440102)--请求购买仙尊Boss次数
    self:add(5440103,self.add5440103)--请求仙尊boss场景信息
    self:add(5450101,self.add5450101)--请求BOSS之家信息
    self:add(5450102,self.add5450102)--请求BOSS之家场景信息
    self:add(5450103,self.add5450103)--请求BOSS之家关注
    self:add(5027201,self.add5027201)--请求仙域灵塔副本信息
    self:add(5027202,self.add5027202)--请求仙域灵塔次数购买
    self:add(5027203,self.add5027203)--请求仙域灵塔任务追中信息
    self:add(5027301,self.add5027301)--请求秘境修炼副本信息
    self:add(5027302,self.add5027302)--请求秘境修炼次数购买
    self:add(5027303,self.add5027303)--请求秘境修炼任务追踪信息
    self:add(5027304,self.add5027304)--请求秘境修炼buff加成购买
    self:add(5027305,self.add5027305)--请求幻境镇妖副本挑战
    self:add(5027401,self.add5027401)--请求剑神守护副本信息
    self:add(5027402,self.add5027402)--请求剑神守护排行榜信息
    self:add(5027403,self.add5027403)--请求剑神守护次数购买
    self:add(5027404,self.add5027404)--请求剑神守护任务追踪信息
    self:add(5027306,self.add5027306)--请求幻境镇妖副本挑战
    self:add(5027307,self.add5027307)--请求幻境镇妖副本挑战
    self:add(5027308,self.add5027308)--请求幻境镇妖副本追踪信息
    self:add(5027309,self.add5027309)--请求幻境镇妖副本信息
    self:add(5330401,self.add5330401)--请求仙域禁地boss信息
    self:add(5330402,self.add5330402)--请求仙域禁地BOSS关注
    self:add(5330403,self.add5330403)--请求仙域禁地场景信息
    self:add(5330404,self.add5330404)--请求Boss掉落记录
    self:add(5027405,self.add5027405)--请求扫荡仙域灵塔
    -- self:add(xxxxxxxxxx,self.addXXXXX)--请求仙域灵塔扫荡 --EVE 等待后端
    self:add(5330501,self.add5330501)--请求宠物岛Boss信息
    self:add(5330502,self.add5330502)--请求跨服世界BOSS场景信息
    self:add(5330503,self.add5330503)--请求跨服世界Boss关注
    self:add(5027406,self.add5027406)--请求副本消耗次数获得奖励

    self:add(5330801,self.add5330801)--请求上古神迹boss信息
    self:add(5330802,self.add5330802)--请求上古神迹BOSS关注
    self:add(5330803,self.add5330803)--请求上古神迹场景信息
    
    self:add(5027205,self.add5027205)--请求仙域灵塔设置

    self:add(5024320,self.add5024320)--请求符文塔信息

    self:add(5330601,self.add5330601)--请求跨服仙域禁地boss信息
    self:add(5330602,self.add5330602)--请求跨服仙域禁地BOSS关注
    self:add(5330603,self.add5330603)--请求跨服仙域禁地场景信息
    
    self:add(5330702,self.add5330702)--请求击杀记录

    self:add(5027310,self.add5027310)--请求秘境修炼移除冷却时间
    self:add(5330305,self.add5330305)--请求boss次数购买

    self:add(8050101,self.add8050101)--副本结束通知广播
    self:add(8050201,self.add8050201)--副本怪物死亡广播
    self:add(8090101,self.add8090101)--练级谷收益变化广播
    self:add(8110101,self.add8110101)--精英boss排行榜刷新广播
    self:add(8110102,self.add8110102)--精英boss攻击伤害广播
    self:add(8110103,self.add8110103)--精英boss血条变化广播
    self:add(8110111,self.add8110111)--通用boss血条变化广播
    self:add(8110112,self.add8110112)--世界boss血量参与奖励
    self:add(8110113,self.add8110113)--精英boss1分钟提示广播
    self:add(8110114,self.add8110114)--精英boss结束广播
    self:add(8120101,self.add8120101)--皇陵奇遇任务信息广播
    self:add(8120102,self.add8120102)--皇陵BOSS血条变化广播
    self:add(8120103,self.add8120103)--皇陵结束奖励预览广播
    self:add(8120104,self.add8120104)--皇陵boss剩余时间刷新
    self:add(8050301,self.add8050301)--提示玩家打副本广播
    self:add(8180202,self.add8180202)--渡劫副本结束广播
    self:add(8110115,self.add8110115)--世界BOSS仇恨排名广播
    self:add(8110116,self.add8110116)--世界BOSS血量变化广播
    self:add(8110117,self.add8110117)--世界BOSS疲劳值退出广播
    self:add(8110201,self.add8110201)--BOSS之家BOSS血量广播
    self:add(8110202,self.add8110202)--BOSS之家结算广播
    self:add(8180601,self.add8180601)--仙域灵塔结算广播
    self:add(8180602,self.add8180602)--请求仙域灵塔任务追中信息
    self:add(8180701,self.add8180701)--秘境修炼任务追踪广播
    self:add(8180702,self.add8180702)--秘境修炼结算广播
    self:add(8180901,self.add8180901)-- 组队副本倒计时广播
    self:add(8180703,self.add8180703)--幻境镇妖结算广播
    --self:add(8180802,self.add8180802)-- 剑神守护任务追踪广播
    self:add(8180801,self.add8180801)--  剑神守护结算广播
    self:add(8110301,self.add8110301)--仙域禁地boss血量广播
    self:add(8110302,self.add8110302)--仙域禁地结算广播
    self:add(8110303,self.add8110303)--仙域禁地怒气值广播
    self:add(8110401,self.add8110401)--跨服世界BOSS血量变化广播
    self:add(8110402,self.add8110402)--跨服世界Boss结算广播
    self:add(8230401,self.add8230401)--BOSS刷新令使用广播
    self:add(8110601,self.add8110601)--上古神迹boss血量广播
    self:add(8110602,self.add8110602)--上古神迹结算广播
    self:add(8110603,self.add8110603)--上古神迹怒气值广播
    self:add(8230601,self.add8230601)--广播采集物每日剩余次数
    self:add(8230603,self.add8230603)--广播神兽岛采集物信息
    self:add(8230604,self.add8230604)--广播神兽岛次数用尽
    self:add(8240206,self.add8240206)-- 元旦探索结算广播


    self:add(5330901,self.add5330901)--五行神殿boss信息
    self:add(5330902,self.add5330902)--五行神殿boss关注
    self:add(5330903,self.add5330903)--五行神殿场景信息

    self:add(5331101,self.add5331101)--请求飞升BOSS信息
    self:add(5331102,self.add5331102)--请求飞升BOSS关注
    self:add(5331103,self.add5331103)--请求飞升BOSS场景信息

    self:add(5028101,self.add5028101)--请求天晶洞窟场景信息
    self:add(8190301,self.add8190301)--天晶洞窟采集广播
    self:add(8190302,self.add8190302)--天晶洞窟水晶刷新广播

    self:add(8110118,self.add8110118)-- BOSS血量广播
    self:add(8230605,self.add8230605)-- 中秋BOSS血量广播

    self:add(5331201,self.add5331201)--神兽岛boss信息
    self:add(5331202,self.add5331202)--神兽岛boss关注
    self:add(5331203,self.add5331203)--神兽岛场景信息

    --兽神祭坛
    self:add(5331401,self.add5331401)
    self:add(5331402,self.add5331402)
    self:add(5331403,self.add5331403)
    self:add(8230606,self.add8230606)-- 兽神祭坛奖励获得弹窗

    --生肖试炼副本
    self:add(5028301,self.add5028301)--请求生肖试炼信息
    self:add(5028302,self.add5028302)--请求生肖试炼次数购买


end
--请求副本信息(通用)
function FubenProxy:add5023101(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求铜钱副本扫荡
function FubenProxy:add5027106(data)
    if data.status == 0 then
        GOpenAlert3(data.items)
        cache.FubenCache:setCopperLastTime(nil)
        local redNum = cache.PlayerCache:getRedPointById(attConst.A50103) or 0
        mgr.GuiMgr:redpointByID(attConst.A50103,redNum)
        self:send(1023101,{sceneId = Fuben.copper})
    else
        GComErrorMsg(data.status)
    end
end
-- 请求经验副本信息
function FubenProxy:add5024101(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end

--请求经验副本首通奖励领取
function FubenProxy:add5024102(data)
    if data.status == 0 then
        GOpenAlert3(data.items)
        local sId = cache.PlayerCache:getSId()
        local passId = data.passId
        cache.FubenCache:setFirstData(passId,2)
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setFirstData(data)
        end
        local scenePex = string.sub(passId,1,6)
        local pass = tonumber(string.sub(passId,7,10))
        local max = conf.SceneConf:getSceneById(scenePex).max_pass

        if pass < max and mgr.FubenMgr:isFuben(sId) then
            -- local view = mgr.ViewMgr:get(ViewName.MainView)
            -- if view then
            --     view:setFirstAward()
            -- end
            mgr.FubenMgr:sendTrack()
            self.isGetFirst = true
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求副本条件信息
function FubenProxy:add5024103(data)
    if data.status == 0 then
        cache.FubenCache:setExpMonsters(data.conMap)
        local sId = cache.PlayerCache:getSId()
        cache.FubenCache:setFirstTime(data.firstTime)
        cache.FubenCache:setCurrPass(sId,data.passId)
        cache.FubenCache:setDayKey(sId,data.sid)
        cache.FubenCache:setCurBo(sId,data.curBo)
        -- plog("首通奖励首通奖励首通奖励首通奖励",data.firstCanAwardPassId)
        cache.FubenCache:setIsFrist(data.isFrist)
        --plog("data.isFrist",data.isFrist)
        if data.firstCanAwardPassId > 0 then
            cache.FubenCache:setFirstData(data.firstCanAwardPassId,1)
        end
        local modular = mgr.FubenMgr:getSIdModular(sId)
        if mgr.FubenMgr:isDujieFuben(sId) then--渡劫副本
            self:refreshTrack(5)
            mgr.HookMgr:enterHook()
            local roleId = cache.PlayerCache:getRoleId()
            local isCaptain = cache.TeamCache:getIsCaptain(roleId)
            if isCaptain then--如果我是队长
                cache.FubenCache:setFubenModular(language.fuben13[modular])
            end
        else
            if mgr.FubenMgr:isBossFuben(sId) then
                self:refreshTrack(1)
            else
                self:refreshTrack(0)
            end
            if mgr.FubenMgr:isShengXiao(sId) then--生肖试炼
                cache.FubenCache:setFubenModular(1448)
            else
                cache.FubenCache:setFubenModular(language.fuben13[modular])
            end
        end
        
        --剧情副本弹出剧情对话
        if mgr.FubenMgr:isPlotFuben(sId) then
            -- mgr.ViewMgr:openView(ViewName.PlotDialogView,function(view)
            --     view:setData(data.passId)
            -- end)
        end
        if mgr.FubenMgr:isTower(sId) then--爬塔
            cache.FubenCache:setTowerFirst(data.passId)
        end
        if mgr.FubenMgr:isJuqingFuben(sId) then
            --特殊剑神副本
            --mgr.HookMgr:stopHook()
            mgr.TimerMgr:addTimer(1,1,function()
                -- body --4001
                mgr.XinShouMgr:checkXinshou(conf.XinShouConf:getOpenModule(2003))
            end) 
        else
            --开始挂机
            if not self.isGetFirst then
                if mgr.FubenMgr:isExpFuben(sId) or mgr.FubenMgr:isTower(sId) then--经验关和通天塔要有剧情对话
                    local confData = conf.FubenConf:getPassDatabyId(data.passId)
                    if confData and confData.guide_dialog_id then
                        if cache.GuideCache:getGuide() then 
                            mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = confData.guide_dialog_id,callback = function()
                                mgr.HookMgr:enterHook()
                            end})
                        else
                            mgr.HookMgr:enterHook()
                        end
                    else
                        mgr.HookMgr:enterHook()
                    end
                else
                    mgr.HookMgr:enterHook()
                end
            end
            self.isGetFirst = nil
        end
        
    else
        GComErrorMsg(data.status)
    end
end
--请求剧情副本信息
function FubenProxy:add5024201(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求爬塔副本信息
function FubenProxy:add5024301(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求vip副本信息
function FubenProxy:add5024311(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求vip副本扫荡
function FubenProxy:add5027107(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        self:send(1024311)
    else
        GComErrorMsg(data.status)
    end
end
--请求扫荡仙域灵塔
function FubenProxy:add5027405(data)
    if data.status == 0 then
        GOpenAlert3(data.items,true)
        self:send(1027201)
    else
        GComErrorMsg(data.status)
    end
end

--请求宠物岛Boss信息
function FubenProxy:add5330501(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求跨服世界BOSS场景信息
function FubenProxy:add5330502(data)
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1191)
        cache.FubenCache:setKuafuBossData(data)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        if cache.FubenCache:getKuafuBossTired() <= 0 and not cache.FubenCache:getKuafuBossNotTip() then
            local text = language.fuben213
            local param = {type = 8,richtext = mgr.TextMgr:getTextColorStr(text, 6),richtext1 = language.tip12,sureIcon = UIItemRes.imagefons01,sure = function(isNotTip)
                cache.FubenCache:setKuafuBossNotTip(isNotTip)
            end}
            GComAlter(param)
        else
            cache.FubenCache:setKuafuBossNotTip(nil)
        end
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end
--请求跨服世界Boss关注
function FubenProxy:add5330503(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
--请求进阶副本信息
function FubenProxy:add5024401(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求重置进阶副本
function FubenProxy:add5024402(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:resetAdvanced(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求进阶副本扫荡
function FubenProxy:add5024403(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:refreshAdv()
        end
        GOpenAlert3(data.items,true)
    else
        GComErrorMsg(data.status)
    end
end
--请求退出异空间场景
function FubenProxy:add5020103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenDekaronView)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求切换副本关卡
function FubenProxy:add5020104(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenDekaronView)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求副本消耗次数获得奖励
function FubenProxy:add5027406(data)
    if data.status == 0 then 
        -- local view = mgr.ViewMgr:get(ViewName.GetAgainView) --啥都屏蔽了
        -- view:setData(data)
        GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end 

function FubenProxy:add5027205(data)
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then 
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文塔信息
function FubenProxy:add5024320(data)
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then 
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--副本结束通知广播
function FubenProxy:add8050101(data)
    -- print("副本结束通知广播~~~~~~~~~~~~~~~~")
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        local passId = sId * 1000 + data.pass
        local function refresh()
            local isGuide = false--是否走剧情情节
            if cache.GuideCache:getGuide() then
                if mgr.FubenMgr:isExpFuben(sId) or mgr.FubenMgr:isTower(sId) then
                    if mgr.FubenMgr:isTower(sId) then--爬塔副本投一个宝箱
                        -- local bindNpc = thing.Npc.new()
                        -- bindNpc:setData({id = 4000001})
                        -- if bindNpc.character then
                        --     -- UnityObjMgr:AddThing(ThingType.npc,bindNpc.character)
                        --     -- cache.FubenCache:setTowerChest(bindNpc)
                        -- end
                    end
                    local confData = conf.FubenConf:getPassDatabyId(passId)
                    if confData and confData.end_guide_dialog_id then--配了剧情对话的要先对话
                        mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = confData.end_guide_dialog_id,callback = function()
                                mgr.FubenMgr:quitFuben(isGuide,data)
                            end})
                        isGuide = true
                    end
                else
                    isGuide = false
                end
            end
            if not isGuide then
                gRole:stopAI()
                if mgr.FubenMgr:isXianzunBoss(sId) then--仙尊boss结算弹窗
                    mgr.TimerMgr:addTimer(BOSSDEKARONTIME, 1, function()
                        if mgr.FubenMgr:isXianzunBoss(sId) then
                            mgr.ViewMgr:openView(ViewName.FubenDekaronView, function(view)
                                view:setData(data)
                            end,{})
                        elseif not mgr.FubenMgr:checkScene() then
                            local view = mgr.ViewMgr:get(ViewName.BossDekaronView)
                            if view then
                                view:onClickClose()
                            end
                        end
                    end)
                else
                    mgr.ViewMgr:openView(ViewName.FubenDekaronView, function(view)
                        view:setData(data)
                    end,{})
                end
            end
            cache.FubenCache:cleanMonsters()
        end
        if mgr.FubenMgr:isExpFuben(sId) and data.pass % FuebenLevelNum.exp ~= 0 then--如果是经验副本
            local nextPassId = passId + 1
            cache.FubenCache:setCurrPass(sId,nextPassId)
            cache.FubenCache:cleanMonsters()
            local view = mgr.ViewMgr:get(ViewName.TrackView)
            if view then
                cache.FubenCache:setFirstTime(mgr.NetMgr:getServerTime())
                view:setFubenTrack()
            end
            if data.state >= 2 then
                refresh()
            else
                proxy.FubenProxy:send(1020104,{sceneId = sId})--下一关
                mgr.HookMgr:enterHook()
            end
        elseif mgr.FubenMgr:isJuqingFuben(sId) then --不需要结束弹窗
            --剑神引导副本杀完BOSS强制变回原型，再飘一次对话，然后出来
            --停止攻击行为
            mgr.HookMgr:cancelHook()

            local data = cache.PlayerCache:getData()
            local skins = data.skins
            gRole.skins = skins
            gRole:setSkins(skins[1], skins[2], skins[3])
            gRole.isChangeBody = false

            mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = 1007,callback = function()
                -- body
                mgr.FubenMgr:quitFuben()
                cache.FubenCache:cleanMonsters()
                local view = mgr.ViewMgr:get(ViewName.TrackView)
                if view then
                    if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
                        view:clear()
                    end
                end
            end})  
        elseif mgr.FubenMgr:isMainTaskFuben(sId) then
            mgr.TimerMgr:addTimer(3, 1, function( ... )
                -- body
                mgr.FubenMgr:quitFuben()
            end)
        elseif mgr.FubenMgr:isDayTaskFuben(sId) then
            mgr.FubenMgr:quitFuben()
        elseif mgr.FubenMgr:isKuaFuTeamFuben(sId) then
            if data.doubleCost == 1 then
                local param = {}
                param.items = data.items
                param.type = 5
                param.richtext = language.kuafu174
                param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
                mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
            else
                refresh()
            end
        else
            refresh()
        end
    else
        GComErrorMsg(data.status)
    end
end

--副本条件变化广播
function FubenProxy:add8050201(data)
    if data.status == 0 then
        -- printt(data)
        cache.FubenCache:setExpMonsters(data.conMap)
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isFuben(sId) then
            cache.FubenCache:setCurrPass(sId,data.passId)
            local view = mgr.ViewMgr:get(ViewName.TrackView)
            if view then
                if mgr.FubenMgr:isBossFuben(sId) then
                    view:setBossData()
                else
                    view:setFubenData()
                end
            end
        elseif mgr.FubenMgr:isKuaFuTeamFuben(sId) then
            local view = mgr.ViewMgr:get(ViewName.TrackView)
            if view then
                view:setKuaFuPassData(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--练级谷收益变化广播
function FubenProxy:add8090101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:add8090101(data.incomeMap)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求经验副本扫荡
function FubenProxy:add5024104(data)
    if data.status == 0 then
        GOpenAlert3(data.items)
        self:send(1024101,{sceneId = Fuben.exp})
    else
        GComErrorMsg(data.status)
    end
end
--请求剧情副本扫荡
function FubenProxy:add5024202(data)
    if data.status == 0 then
        GOpenAlert3(data.items)
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            self:send(1024201)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5024302(data)
    if data.status == 0 then
        GOpenAlert3(data.items)
        self:send(1024301)
    else
        GComErrorMsg(data.status)
    end
end
-- --请求练级谷信息
-- function FubenProxy:add5025101(data)
--     if data.status == 0 then
--         self:refreshView(data)
--     else
--         GComErrorMsg(data.status)
--     end
-- end
-- --请求练级谷时间购买
-- function FubenProxy:add5025102(data)
--     if data.status == 0 then
--         local levelData = cache.FubenCache:getLevelData()
--         if levelData then
--             cache.FubenCache:setLevelLeftTime(levelData.leftTime + data.hour * 3600)
--             local view = mgr.ViewMgr:get(ViewName.MainView)
--             if view then
--                 view:setLevelData()
--             end
--         end
--         self:refreshLevelView()
--     else
--         GComErrorMsg(data.status)
--     end
-- end
-- --请求练级谷加成时间购买
-- function FubenProxy:add5025103(data)
--     if data.status == 0 then
--         local levelData = cache.FubenCache:getLevelData()
--         if levelData then
--             cache.FubenCache:setExpPlusLeftTime(levelData.expPlusLeftTime + data.hour * 3600)
--             local view = mgr.ViewMgr:get(ViewName.MainView)
--             if view then
--                 view:setLevelData()
--             end
--         end
--         self:refreshLevelView()
--     else
--         GComErrorMsg(data.status)
--     end
-- end

-- function FubenProxy:refreshLevelView()
--     local view = mgr.ViewMgr:get(ViewName.FubenView)
--     if view and view.mainController.selectedIndex == 6 then
--         proxy.FubenProxy:send(1025101)
--     end
-- end
-- --请求练级谷场景信息
-- function FubenProxy:add5025104(data)
--     if data.status == 0 then
--         local sId = cache.PlayerCache:getSId()
--         local modular = sId
--         if mgr.FubenMgr:isLevel(sId) then
--             modular = Fuben.level
--         end 
--         cache.FubenCache:setFubenModular(language.fuben13[modular])
--         cache.FubenCache:setLevelData(data)
--         local view = mgr.ViewMgr:get(ViewName.MainView)
--         if view then
--             view:setLevelData()
--         end
--         --进入练级谷开始挂机
--         mgr.HookMgr:enterHook()
--     else
--         GComErrorMsg(data.status)
--     end
-- end
-- --请求练级谷扫荡
-- function FubenProxy:add5025105(data)
--     if data.status == 0 then
--         GComAlter(language.fuben66)
--         GOpenAlert3(data.items)
--         self:send(1025101)
--     else
--         GComErrorMsg(data.status)
--     end
-- end
--请求个人boss信息
function FubenProxy:add5026101(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求精英boss信息
function FubenProxy:add5330101(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求精英boss场景信息
function FubenProxy:add5330102(data)
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        local modular = 0
        if mgr.FubenMgr:isEliteBoss(sId) then--
            modular = BossScene.elite
        end
        cache.FubenCache:setEliteData(data)
        cache.FubenCache:setFubenModular(language.fuben13[modular])
        self:refreshTrack(1)
    else
        GComErrorMsg(data.status)
    end
end
--请求精英boss次数购买
function FubenProxy:add5330103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            view:setBuyCout(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求精英boss弹窗提示设置
function FubenProxy:add5330104(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            view:setTipScene(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--精英boss排行榜刷新广播
function FubenProxy:add8110101(data)
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isKuaFuBoss(sId) then
            cache.KuaFuCache:setEliteRank(data)
        else
            cache.FubenCache:setEliteRank(data)
        end
        
        self:refreshBossData()
    else
        GComErrorMsg(data.status)
    end
end
--精英boss攻击伤害广播
function FubenProxy:add8110102(data)
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isKuaFuBoss(sId) then
            cache.KuaFuCache:setEliteHurt(data)
        else
            cache.FubenCache:setEliteHurt(data)
        end
        
        self:refreshBossData()
    else
        GComErrorMsg(data.status)
    end
end
--精英boss血条变化广播
function FubenProxy:add8110103(data)
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isKuaFuBoss(sId) then
            cache.KuaFuCache:setEliteHp(data)
        else
            cache.FubenCache:setEliteHp(data)
        end
        
        self:refresBossHphView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求世界boss信息
function FubenProxy:add5330201(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求世界boss场景信息
function FubenProxy:add5330202(data)
     if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        local modular = sId
        if mgr.FubenMgr:isWorldBoss(sId) then--
            modular = BossScene.world
        end
        cache.FubenCache:setFubenModular(language.fuben13[modular])
        cache.FubenCache:setWorldHateName(nil)
        cache.FubenCache:setWorldData(data)
        --第一次进入世界boss bxp
        if data.first and data.first == 1 then
            local data = {}
            data.cancel = function ()
                mgr.HookMgr:enterHook()
            end 
            mgr.ViewMgr:openView2(ViewName.WorldBossExplainView,data)
        else
            mgr.HookMgr:enterHook()
        end
        self:refreshTrack(1)
    else
        GComErrorMsg(data.status)
    end
end
--通用boss血条变化广播
function FubenProxy:add8110111(data)
    if data.status == 0 then
        cache.FubenCache:setWorldHp(data)
        self:refreshBossData()
        self:refresBossHphView(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setWorldBossHate(data.hateRoleName)
        end

        local flameView = mgr.ViewMgr:get(ViewName.FlameView) --EVE 用于判断BOSS状态
        if flameView then 
            flameView:setFlameBossData(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end
--世界boss血量参与奖励
function FubenProxy:add8110112(data)
    if data.status == 0 then
        mgr.TimerMgr:addTimer(BOSSDEKARONTIME, 1, function()
            if mgr.FubenMgr:isWorldBoss(cache.PlayerCache:getSId()) then
                mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
                    view:setData(data,2)
                end)
            else
                local view = mgr.ViewMgr:get(ViewName.BossDekaronView)
                if view then
                    view:onClickClose()
                end
            end
        end)
    else
        GComErrorMsg(data.status)
    end
end
--精英boss1分钟提示广播
function FubenProxy:add8110113(data)
    --printt(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.EliteBossTipView)
        if mgr.FubenMgr:checkScene() then
            if view then
                view:releaseTimer()
                view:closeView()
            end
            return
        end
        if view then
            view:setData(data)
        else
            mgr.ViewMgr:openView2(ViewName.EliteBossTipView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--精英boss结束广播
function FubenProxy:add8110114(data)
    if data.status == 0 then
        mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
            view:setData(data,3)
        end)
    else
        GComErrorMsg(data.status)
    end
end
--追踪信息
function FubenProxy:refreshTrack(index)
    local t = {index = index}
    local view = mgr.ViewMgr:get(ViewName.TrackView)
    if view then
        view:setData(t)
    else
        mgr.ViewMgr:openView2(ViewName.TrackView, t)
    end
end
--刷新副本界面
function FubenProxy:refreshView(data)
    local view = mgr.ViewMgr:get(ViewName.FubenView)
    if view then
        view:setData(data)
    end
end
--刷新Boss界面
function FubenProxy:refreshBossView(data)
    local view = mgr.ViewMgr:get(ViewName.BossView)
    if view then
        view:setData(data)
    end
end
--刷新boss追踪和血条界面
function FubenProxy:refresBossHphView(data)
    local view = mgr.ViewMgr:get(ViewName.BossHpView)
    cache.FubenCache:setWorldHateName(data.hateRoleName)
    if view then
        view:setHateRoleName(data.hateRoleName)
        view:setBossRoleId(data.roleId)
        -- printt("boss血量刷新>>>>>>>>",data.attris)
        view:setAttisData(data.attris)
    else
        if data.curHpPercent > 0 then
            mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                view:setHateRoleName(data.hateRoleName)
                view:setBossRoleId(data.roleId)
                view:setAttisData(data.attris)
            end,data)
        end 
    end
end
--boss条件变化
function FubenProxy:refreshBossData()
    local view = mgr.ViewMgr:get(ViewName.TrackView)
    if view then
        view:setBossData()
    end
end

function FubenProxy:add5024501( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 请求帮派副本目标奖励领取
function FubenProxy:add5024502(data)
    -- body
    if data.status == 0 then
        --红点扣除
        if data.reqType == 2 then
            mgr.GuiMgr:redpointByID(50110,cache.PlayerCache:getRedPointById(50110))
        else
            mgr.GuiMgr:redpointByID(50110)
        end

        GOpenAlert3(data.items)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function FubenProxy:add5024503(data)
    -- body
    if data.status == 0 then
        --plog("add5024503 扫荡返回" )
        GOpenAlert3(data.items)
        --扫荡完成重新请求副本信息
        self:send(1024501)
        --[[local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end]]--
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5810301(data)
    if data.status == 0 then
    else
        GComErrorMsg(data.status)
    end
end

--副本采集物拾取
function FubenProxy:add5810302( data )
    -- body
    if data.status == 0 then
        -- local view = mgr.ViewMgr:get(ViewName.PickAwardsView)
        -- if view then
        --     view:clear()
        -- end
    else
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isHuangLing(sId) then--皇陵采集特殊
            if data.status == 2208008 or data.status == 2208009 then
                local posTab = {}
                local objs = mgr.ThingMgr:objsByType(ThingType.monster)
                for k,v in pairs(objs) do
                    if v.data.kind == MonsterKind.collection then
                        local pos = {v:getPosition().x,v:getPosition().z}
                        table.insert(posTab,pos)
                    end
                end
                local len = #posTab
                if len > 0 then
                    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
                    local point = posTab[math.random(1,#posTab)]
                    gRole:idleBehaviour()
                    mgr.TimerMgr:addTimer(0.5, 1, function()
                        local p = Vector3.New(point[1], gRolePoz, point[2])
                        gRole:moveToPoint(p, PickDistance, function()
                            gRole:idleBehaviour()
                            local roleId = 0
                            local objs = mgr.ThingMgr:objsByType(ThingType.monster)
                            for k,v in pairs(objs) do
                                if v.data.kind == MonsterKind.collection then
                                    if v:getPosition().x == point[1] and v:getPosition().z == point[2] then
                                        roleId = v.data.roleId
                                        break
                                    end
                                end
                            end
                            proxy.FubenProxy:send(1810302,{roleId = roleId,reqType = 1})--拾取
                        end)
                    end)
                end
            end
        else
            GComErrorMsg(data.status)
        end
    end
end
-- 请求世界Boss抽奖
function FubenProxy:add5330304(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossIndianaView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求世界BOSS帮派招募
function FubenProxy:add5330204(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
--请求仙尊boss信息
function FubenProxy:add5440101(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求购买仙尊Boss次数
function FubenProxy:add5440102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            view:setLeftTimes(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙尊boss场景信息
function FubenProxy:add5440103(data)
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1125)
        cache.FubenCache:setXianzunBossData(data)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end
--请求BOSS之家信息
function FubenProxy:add5450101(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求BOSS之家场景信息
function FubenProxy:add5450102(data)
    if data.status == 0 then
        -- self:refreshBossView(data)
        cache.FubenCache:setFubenModular(1128)
        cache.FubenCache:setBossHomeData(data)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end
--请求BOSS之家关注
function FubenProxy:add5450103(data)
    if data.status == 0 then
        -- self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end

--皇陵奇遇任务信息广播
function FubenProxy:add8120101(data)
    -- body
    if data.status == 0 then
        --更新任务缓存
        --print("任务广播")
        -- mgr.TimerMgr:addTimer(0.5, 1, function()
            local taskList = cache.HuanglingCache:getTaskCache()
            local target = nil
            local caijiId = nil
            local isFinish = false
            -- printt(data.changes)
            -- printt("111",taskList)
            for k,v in pairs(data.changes) do
                for k1,v1 in pairs(taskList) do
                    if v.taskId == v1.taskId then
                        taskList[k1] = v
                        if v.taskFlag == 1 then--已完成任务
                            mgr.HookMgr:cancelHook()
                            gRole:idleBehaviour()
                            isFinish = true
                            --print("该任务已完成")
                        else --未完成任务
                            local taskData = conf.HuanglingConf:getTaskAwardsById(v.taskId)
                            --print("未完成任务",taskData.type,v.taskId)
                            if taskData.type == 1 then--采集任务
                                local fbId = cache.PlayerCache:getSId()
                                local fbConf = conf.SceneConf:getSceneById(fbId)
                                target = fbConf["pendant"]
                                caijiId = taskData.tar_con[1][1]
                            end
                        end
                    end
                end
            end

            if target and caijiId then--连续采集 中间时间间隔2s
                --获取当前采集物的所有坐标
                mgr.TimerMgr:addTimer(0.5, 1, function()
                    local posTab = {}
                    local objs = mgr.ThingMgr:objsByType(ThingType.monster)
                    for k,v in pairs(target) do
                        if v[1] == caijiId then
                            for k1,obj in pairs(objs) do
                                if obj.data.kind == MonsterKind.collection then
                                    if obj:getPosition().x == v[2] and obj:getPosition().z == v[3] then
                                        -- roleId = v.data.roleId
                                    -- print("坐标",k,v,v[1],v[2],v[3])
                                        local pos = {v[2],v[3]}
                                        table.insert(posTab,pos)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    local len = #posTab
                    if len > 0 then
                        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
                        local point = posTab[math.random(1,#posTab)]
                        gRole:idleBehaviour()
                        mgr.TimerMgr:addTimer(0.5, 1, function()
                            local p = Vector3.New(point[1], gRolePoz, point[2])
                            gRole:moveToPoint(p, PickDistance, function()
                                gRole:idleBehaviour()
                                local roleId = 0
                                local objs = mgr.ThingMgr:objsByType(ThingType.monster)
                                for k,v in pairs(objs) do
                                    if v.data.kind == MonsterKind.collection then
                                        if v:getPosition().x == point[1] and v:getPosition().z == point[2] then
                                            roleId = v.data.roleId
                                            break
                                        end
                                    end
                                end
                                proxy.FubenProxy:send(1810302,{roleId = roleId,reqType = 1})--拾取
                                -- proxy.FubenProxy:send(1810302,{tarPox = point[1],tarPoy = point[2]})--拾取
                            end)
                        end)
                    else
                        GComAlter("找不到采集物")
                    end
                end)
            end
            cache.HuanglingCache:setTaskCache(taskList)
            --刷新任务面板
            local view = mgr.ViewMgr:get(ViewName.HuanglingTask)
            if view then
                if view:getTaskPanelVisible() then
                    view:initTaskPanel()
                end
            end
        -- end)
        --[[挂机单个任务结束后不再继续下一个
        if isFinish then
            -- print("进行剩下的未完成任务")
            local len = 0
            for k,v in pairs(taskList) do
                if v.taskFlag ~= 1 then
                -- print("剩下的未完成任务id",v.taskId)
                    local taskData = conf.HuanglingConf:getTaskAwardsById(v.taskId)
                    mgr.HookMgr:HuanglingTaskHook(taskData)
                    break
                else
                    len = len + 1
                end
            end
            if len == #taskList then --任务全部完成
                local bossData = cache.HuanglingCache:getBossCache()
                local bossNum = cache.HuanglingCache:getBossNum()
                
                if bossNum > 0 and bossData[bossNum].curHpPercent > 0 then
                    mgr.HookMgr:HuanglingHook(2)
                else
                    mgr.HookMgr:HuanglingHook(1)
                end
            end
        end
        ]]--
    else
        GComErrorMsg(data.status)
    end
end
-- hpPercent   
-- hateRoleName
--皇陵Boss血条信息广播
function FubenProxy:add8120102(data)
    -- body
    if data.status == 0 then
        --更新缓存
        local bossData = cache.HuanglingCache:getBossCache()
        local num = data.refreshBossNum
        if num == 0 or num == 1 then num = 1 end
        bossData[num].curHpPercent = data.curHpPercent
        bossData[num].attris = data.attris
        bossData[num].hateRoleName = data.hateRoleName
        -- print("boss广播",data.curHpPercent,bossData.curHpPercent)
        cache.HuanglingCache:setBossCache(bossData)
        cache.HuanglingCache:setBossNum(data.refreshBossNum)
        if num > 0 and bossData[num].curHpPercent > 0 then--任务完成时优先杀boss
            local taskList = cache.HuanglingCache:getTaskCache()
            local len = 0
            for k,v in pairs(taskList) do
                if v.taskFlag == 1 then
                    len = len + 1
                end
            end
            local isBossFight = cache.HuanglingCache:getBossFightState()
            if len == #taskList and not isBossFight then
                cache.HuanglingCache:BossFightState(true)
                local presentTaskId = cache.HuanglingCache:getPresentTaskId()
                if presentTaskId == 2 then
                    mgr.HookMgr:HuanglingHook(presentTaskId)
                else
                    mgr.HookMgr:HuanglingHook(1)
                end
            end
        end
        --刷新boos面板
        local view = mgr.ViewMgr:get(ViewName.HuanglingTask)
        if view then
            view:initBossPanel()
        end

        --刷新血条
        
        local view = mgr.ViewMgr:get(ViewName.BossHpView)
        if data.curHpPercent > 0 and data.attris[104] > 0 then
            if view then
                view:setBossRoleId(data.roleId)
                view:setHateRoleName(data.hateRoleName)
                view:setAttisData(data.attris)
            else
                mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                    view:setBossRoleId(data.roleId)
                    view:setHateRoleName(data.hateRoleName)
                    view:setAttisData(data.attris)
                end,{})
            end
        else
            if view then
                view:close()
            end
            cache.HuanglingCache:BossFightState(false)
            mgr.HookMgr:cancelHook()
            -- proxy.HuanglingProxy:sendMsg(1340102)
        end
        -- end
    else
        GComErrorMsg(data.status)
    end
end
--皇陵结束奖励预览广播
function FubenProxy:add8120103(data)
    -- body
    if data.status == 0 then
        cache.HuanglingCache:refreshCache()
        if data.items and #data.items > 0 then
            local t = {items = data.items,titleUrl = UIItemRes.huangling01}
            mgr.ViewMgr:openView2(ViewName.AwardsCaseView,t)
        else
            mgr.FubenMgr:quitFuben()
        end
    else
        GComErrorMsg(data.status)
    end
end
--皇陵boss剩余刷新时间
function FubenProxy:add8120104(data)
    -- body
    if data.status == 0 then
        -- print("下次刷新时间",data.nextBossRefreshTime)
        cache.HuanglingCache:setBossTimeCache(data.nextBossRefreshTime)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8050301(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            mgr.FubenMgr:openWarTip(data.minCanFubenId)
        else
            cache.FubenCache:setFubenCanList(data.minCanFubenId)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8180202( data )
    if data.status == 0 then
        if data.state == 1 then
            if data.manType == 1 then
                cache.PlayerCache:setAttribute(20139,1)
                gRole:stopAI()
                mgr.ViewMgr:openView2(ViewName.UpgradeView,{level = data.level,items = data.items})
            else
                gRole:stopAI()
                mgr.ViewMgr:openView(ViewName.FubenDujieView, function(view)
                    view:setData(data)
                end,{})
            end
            local TrackView = mgr.ViewMgr:get(ViewName.TrackView)
            if TrackView then
                TrackView.dujieTrack:setFubenData(true)
            end
        else
            gRole:stopAI()
            mgr.ViewMgr:openView(ViewName.FubenDujieView, function(view)
                view:setData(data)
            end,{})
        end
    else
        GComErrorMsg(data.status)
    end
end
--世界BOSS仇恨排名广播
function FubenProxy:add8110115(data)
    if data.status == 0 then
        -- cache.FubenCache:setWorldData(data)
        -- self:refreshBossData()
    else
        GComErrorMsg(data.status)
    end
end
--世界BOSS血量变化广播
function FubenProxy:add8110116(data)
    if data.status == 0 then
        cache.FubenCache:updateWorldData(data)
        self:refreshBossData()
    else
        GComErrorMsg(data.status)
    end
end
--世界BOSS疲劳值退出广播
function FubenProxy:add8110117(data)
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.BossTiredTipView, {})
    else
        GComErrorMsg(data.status)
    end
end
--BOSS之家BOSS血量广播
function FubenProxy:add8110201(data)
    if data.status == 0 then
        -- printt("BOSS之家BOSS血量广播",data)
        cache.FubenCache:updateHomeData(data)
        self:refreshBossData()
    else
        GComErrorMsg(data.status)
    end
end
--BOSS之家结算广播
function FubenProxy:add8110202(data)
    if data.status == 0 then
        mgr.TimerMgr:addTimer(BOSSDEKARONTIME, 1, function()
            if mgr.FubenMgr:isBossHome(cache.PlayerCache:getSId()) then
                mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
                    view:setData(data,2)
                end)
            else
                local view = mgr.ViewMgr:get(ViewName.BossDekaronView)
                if view then
                    view:onClickClose()
                end
            end
        end)
    else
        GComErrorMsg(data.status)
    end
end
--跨服世界BOSS血量变化广播
function FubenProxy:add8110401(data)
    if data.status == 0 then
        -- printt("跨服世界BOSS血量变化广播",data)
        cache.FubenCache:updateKuafuBoss(data)
        cache.FubenCache:updateWuXingBossData(data)
        cache.FubenCache:updateFsBossData(data)
        cache.FubenCache:updateShenShowData(data)
        cache.FubenCache:updateSSSYData(data)
        self:refreshBossData()        

    else
        GComErrorMsg(data.status)
    end
end
--跨服世界Boss结算广播
function FubenProxy:add8110402(data)
    if data.status == 0 then
        -- print("跨服世界boss结算广播")
        local sId = cache.PlayerCache:getSId()
        mgr.TimerMgr:addTimer(BOSSDEKARONTIME, 1, function()
            if mgr.FubenMgr:isKuafuWorld(sId)
            or mgr.FubenMgr:isWuXingShenDian(sId) 
            or mgr.FubenMgr:isFsFuben(sId)
            or mgr.FubenMgr:isShenShou(sId) then
                mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
                    view:setData(data,2)
                end)
            else
                local view = mgr.ViewMgr:get(ViewName.BossDekaronView)
                if view then
                    view:onClickClose()
                end
            end
        end)
    else
        GComErrorMsg(data.status)
    end
end
--BOSS刷新令使用广播
function FubenProxy:add8230401(data)
    if data.status == 0 then 
        local view = mgr.ViewMgr:get(ViewName.BossRefreshCard)
        if view then
            view:setData(data)
        end
    else 
        GComErrorMsg(data.status)
    end 
end

function FubenProxy:add5027201(data)
    -- body
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5027202(data)
    -- body
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5027203(data)
    -- body
    if data.status == 0 then
        --任务追踪信息
        cache.FubenCache:setFubenModular(1130)
        cache.FubenCache:setsceneTaskMsg(1130,data)
        --printt("设置扫荡奖励缓存",data.items)
        cache.FubenCache:setAwardsData(data.items)  --设置扫荡奖励缓存 
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setSingle(data)
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 10,data = data})
        end
        if data.reqType == 1 then
            mgr.ViewMgr:openView2(ViewName.Alert19, data)
            --printt(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求秘境修炼副本信息
function FubenProxy:add5027301(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求秘境修炼次数购买
function FubenProxy:add5027302(data)
    if data.status == 0 then
        GComAlter(language.gonggong99)
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求秘境修炼任务追踪信息
function FubenProxy:add5027303(data)
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1132)
        local sId = cache.PlayerCache:getSId()
        cache.FubenCache:setCurrPass(sId,data.curPassId)
        cache.FubenCache:setMjxlData(data)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 11})--打开任务追踪
        mgr.ViewMgr:openView2(ViewName.StartGoView,{opaque = 1})--开始倒计时
        local param = {--临时引导
            opaque = 1,
            time = 3,
            pos = {x = 999,y = 166 },
            starTipText = language.fuben189,
            func = function( ... )
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()--开始挂机
                end
            end
        }
        mgr.ViewMgr:openView2(ViewName.GuideLayer,param)
        --bxp双倍奖励
        local flag = data.isDouble == 1
        cache.FubenCache:setMjxlDouble(flag)
    else
        GComErrorMsg(data.status)
    end
end
--请求秘境修炼buff加成购买
function FubenProxy:add5027304(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LirenTipView)
        if data.buyType == 0 then--购买信息 
            if view then
                view:setSelect(data)
            end
        elseif data.buyType == 1 then--利刃
            cache.FubenCache:setMjxlAtkAdd(data.atkAdd)
            if view then
                local atkBuyMax = conf.FubenConf:getValue("fam_atk_buy_max")
                if data.atkAdd == atkBuyMax then--利刃满了就消失
                    GComAlter(message.errorID[2208022])
                    view:closeView()
                else
                    view:setSelect(data)
                end
            end
        end
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setMjxlData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求幻境镇妖副本挑战
function FubenProxy:add5027305(data)
    --printt("请求幻境镇妖副本挑战",data)
    if data.status == 0 then
    else
        GComErrorMsg(data.status)
    end
end
--请求幻境镇妖副本次数购买
function FubenProxy:add5027306(data)
    if data.status == 0 then
        GComAlter(language.gonggong99)
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求幻境镇妖buff加成购买
function FubenProxy:add5027307(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LirenTipView)
        if data.buyType == 0 then--购买信息
            if view then
                view:setSelect(data)
            end
        elseif data.buyType == 1 then--利刃
            cache.FubenCache:setHjzyAtkAdd(data.atkAdd)
            if view then
                local atkBuyMax = conf.FubenConf:getValue("hjzy_atk_buy_max")
                if data.atkAdd == atkBuyMax then--利刃满了就消失
                    GComAlter(message.errorID[2208022])
                    view:closeView()
                else
                    view:setSelect(data)
                end
            end
        end
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setMjxlData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求幻境镇妖副本追踪信息
function FubenProxy:add5027308(data)
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1133)
        local sId = cache.PlayerCache:getSId()
        cache.FubenCache:setCurrPass(sId,data.curPassId)
        cache.FubenCache:setHjzyData(data)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 11})--打开任务追踪
        mgr.ViewMgr:openView2(ViewName.StartGoView,{opaque = 1})--开始倒计时
        local param = {--临时引导
            opaque = 1,
            time = 3,
            pos = {x = 999,y = 166 },
            starTipText = language.fuben189,
            func = function( ... )
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()--开始挂机
                end
            end
        }
        mgr.ViewMgr:openView2(ViewName.GuideLayer,param)
    else
        GComErrorMsg(data.status)
    end
end
--请求幻境镇妖副本信息
function FubenProxy:add5027309(data)
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8180601(data)
        if data.status == 0 then
        mgr.TimerMgr:addTimer(1, 1,function()
            -- body
            local param = {}
            param.items = data.items
            param.msgId = data.msgId
            param.type = 5
            if data.doubleCost == 1 then
                param.richtext = language.fuben208
            else
                param.richtext = string.format(language.fuben145,data.passBo,GTotimeString3(data.passSec))
            end
            param.titleUrl = "ui://_imgfonts/jianshengshouhu_004" 
            mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
        end) 
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8180801( data )
    -- body
    if data.status == 0 then
        mgr.TimerMgr:addTimer(1, 1,function()
            -- body
            -- local cost = conf.FubenConf:getValue("jssh_cost_buy_once")-- bxp
            -- local openLv = conf.FubenConf:getValue("jssh_openLv")
            local param = {}
            -- param.type = 7 
            param.items = data.items
            param.msgId = data.msgId
            -- param.cost = cost
            -- param.sceneId = data.sceneId
            param.leftCount = data.leftCount
            -- param.openLv = openLv
            -- print("组队仙域修炼剩余次数>>>>>>>>>>>>",data.leftCount)
            -- print("组队仙域副本id>>>>>>>>>>>>",data.sceneId)     
            param.type = 5
            param.titleUrl = "ui://_imgfonts/jianshengshouhu_004" 
            param.richtext = string.format(language.fuben145,data.passBo,GTotimeString3(data.passSec))
            mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
        end) 
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8180602( data )
    if data.status == 0 then
        local _id 
        if mgr.FubenMgr:isXianyu(data.sceneId)  then
            _id = 1130
        elseif mgr.FubenMgr:isJianShengshouhu(data.sceneId)  then
            _id = 1131
        elseif mgr.FubenMgr:isDayTaskFuben(data.sceneId) then
            cache.FubenCache:setCurBo(data.sceneId,data.curBo)
            local view = mgr.ViewMgr:get(ViewName.TrackView)
            if view then
                view:dayFubenTrack()
            end
            return
        end
        if not _id then
            return
        end
        local param = cache.FubenCache:getsceneTaskMsg(_id)
        if not param then --curBo boLeftSec killBo
            param = {}  
            param.drops = {}
        end
        param.curBo = data.curBo 
        param.boLeftSec = data.boLeftSec 
        param.killBo = data.killBo 
        if table.nums(data.drops)>0 then
            param.drops = data.drops
        end

        cache.FubenCache:setsceneTaskMsg(_id,param)

        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view and view.shoutaTrack then
            view.shoutaTrack:initMsg()
        end
    else
        GComErrorMsg(data.status)
    end
end
function FubenProxy:add8180802( data )
    -- body
    if data.status == 0 then
        local param = cache.FubenCache:getsceneTaskMsg(1131)
        if not param then --curBo boLeftSec killBo
             param = {}  
        end
        param.curBo = data.curBo 
        param.boLeftSec = data.boLeftSec 
        param.killBo = data.killBo 
        cache.FubenCache:getsceneTaskMsg(1131,param)

        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view and view.shoutaTrack then
            view.shoutaTrack:initMsg()
        end
    else
        GComErrorMsg(data.status)
    end
end
--秘境修炼任务追踪广播
function FubenProxy:add8180701(data)
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isMjxlScene(sId) then--秘境修炼
            cache.FubenCache:setMjxlCurBo(data.curBo)
            cache.FubenCache:setMjxlExp(data.exp)
            cache.FubenCache:setMjxlExpDrup(data.expDrup)
        elseif mgr.FubenMgr:isHjzyScene(sId) then
            cache.FubenCache:setHjzyCurBo(data.curBo)
            cache.FubenCache:setHjzyExp(data.exp)
            cache.FubenCache:setHjzyExpDrup(data.expDrup)
        end
        cache.FubenCache:setMjDieNum(data.dieNum)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setMjxlData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--秘境修炼结算广播
function FubenProxy:add8180702(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:endMjxl()
        end
        -- local cost = conf.FubenConf:getValue("fam_cost_buy_once")--添加再次获取按钮bxp
        -- local openLv = conf.FubenConf:getValue("fam_openLv")
        local param = {}
        param.items = data.items
        param.type = 5
        -- param.type = 7 
        param.titleUrl = UIItemRes.fuben08
        -- param.cost = cost
        -- param.sceneId = data.sceneId
        -- param.leftCount = data.leftCount
        -- param.sceneId = data.sceneId
        -- param.openLv = openLv

        -- local str1 = clone(language.fuben156)
        -- str1[2].text = string.format(str1[2].text, data.curBo)
        -- local text1 = mgr.TextMgr:getTextByTable(str1)

        -- local str2 = clone(language.fuben157)
        -- str2[2].text = string.format(str2[2].text, GTotimeString5(data.useTime))
        -- local text2 = mgr.TextMgr:getTextByTable(str2)
        if cache.FubenCache:getMjxlDouble() then 
            param.richtext = language.fuben208
        end
        param.msgId = data.msgId
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)

        proxy.FubenProxy:send(1027301)--结算之后就刷新单人谧静
    else
        GComErrorMsg(data.status)
    end
end
--幻境镇妖结算广播
function FubenProxy:add8180703(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:endMjxl()
        end
        -- local cost = conf.FubenConf:getValue("hjzy_cost_buy_once")--添加再次获取按钮bxp
        -- local openLv = conf.FubenConf:getValue("hjzy_openLv")
        local param = {}
        param.items = data.items
        param.type = 5
        -- param.type = 7 --屏蔽再次获取bxp
        param.titleUrl = UIItemRes.fuben08
        -- param.cost = cost
        -- param.sceneId = data.sceneId
        -- param.leftCount = data.leftCount
        -- param.openLv = openLv
        -- local str1 = clone(language.fuben156)
        -- str1[2].text = string.format(str1[2].text, data.curBo)
        -- local text1 = mgr.TextMgr:getTextByTable(str1)

        -- local str2 = clone(language.fuben157)
        -- str2[2].text = string.format(str2[2].text, GTotimeString5(data.useTime))
        -- local text2 = mgr.TextMgr:getTextByTable(str2)
        param.richtext = ""
        param.msgId = data.msgId
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5027401(data)
    -- body
    if data.status == 0 then
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5027402(data)
    -- body
    if data.status == 0 then
        local param = {}
        param.module_id = 1131 
        param.data = data
        --printt("data",data)
        mgr.ViewMgr:openView2(ViewName.TowerRankView, param)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5027403(data)
    -- body
    if data.status == 0 then
        GComAlter(language.gonggong99)
        self:refreshView(data)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5027404(data)
    -- body
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1131)
        cache.FubenCache:setsceneTaskMsg(1131,data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setSingle(data)
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 12,data = data})
        end
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8180901(data)
    -- body
    if data.status == 0 then
        local param = {}
        param.sceneId = data.sceneId
        param.teamKind = data.teamKind
        mgr.ViewMgr:openView2(ViewName.StartGoView, param)
    else
        GComErrorMsg(data.status)
    end
end

--请求仙域禁地boss信息
function FubenProxy:add5330401(data)
    if data.status == 0 then
        -- print("仙域禁地",data)
        -- printt(data)
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end

--请求仙域禁地BOSS关注
function FubenProxy:add5330402(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end

--请求仙域禁地场景信息
function FubenProxy:add5330403(data)
    if data.status == 0 then
        cache.FubenCache:setXianYuJinDiData(data)
        cache.FubenCache:setFubenModular(1135)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        self:refreshTrack(1)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end

--请求跨服仙域禁地boss信息
function FubenProxy:add5330601(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求跨服仙域禁地BOSS关注
function FubenProxy:add5330602(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
--请求跨服仙域禁地场景信息
function FubenProxy:add5330603(data)
    if data.status == 0 then
        cache.FubenCache:setXianYuJinDiData(data)
        cache.FubenCache:setFubenModular(1221)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        self:refreshTrack(1)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end

--请求上古神迹boss信息
function FubenProxy:add5330801(data)
    if data.status == 0 then
        -- print("上古神迹",data)
        -- printt(data)
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end

--请求上古神迹BOSS关注
function FubenProxy:add5330802(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end

--请求上古神迹场景信息
function FubenProxy:add5330803(data)
    if data.status == 0 then
        cache.FubenCache:setShangGuData(data)
        cache.FubenCache:setFubenModular(1242)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        self:refreshTrack(1)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end
--请求击杀记录
function FubenProxy:add5330702(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossNewsView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求秘境修炼移除冷却时间
function FubenProxy:add5027310(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
--请求Boss掉落记录
function FubenProxy:add5330404(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end
--请求boss购买次数（世界boss，宠物岛）
function FubenProxy:add5330305(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            if data.sceneKind == 9 then--世界boss
                proxy.FubenProxy:send(1330201)
            elseif data.sceneKind == 31 then --宠物岛
                proxy.FubenProxy:send(1330501)
            elseif data.sceneKind == 49 then --神兽岛
                proxy.FubenProxy:send(1331201)
            elseif data.sceneKind == 47 then --飞升之地
                proxy.FubenProxy:send(1331101)
            end

            view:setBossLeftTimes(data)
        end
    else
        GComErrorMsg(data.status)
    end

end

-- --请求仙域灵塔扫荡
-- function FubenProxy:addXXXXX(data)
--     if data.status == 0 then
--         if data and data.items
--             GOpenAlert3(data.items)
--         end 

--         self:send(1027201) --请求仙域灵塔信息
--     else
--         GComErrorMsg(data.status)
--     end
-- end

--仙域禁地boss血量广播
function FubenProxy:add8110301(data)
    if data.status == 0 then
        -- printt("仙域禁地BOSS血量广播",data)
        cache.FubenCache:updateXianYuBossData(data)
        self:refreshBossData()
    else
        GComErrorMsg(data.status)
    end
end
--仙域禁地结算广播
function FubenProxy:add8110302(data)
    if data.status == 0 then
        -- printt("仙域禁地结算广播",data)
        mgr.TimerMgr:addTimer(BOSSDEKARONTIME, 1, function()
            if mgr.FubenMgr:isXianyuJinDi(cache.PlayerCache:getSId()) or mgr.FubenMgr:isKuafuXianyu(cache.PlayerCache:getSId()) then
                mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
                    view:setData(data,2)
                end)
            else
                local view = mgr.ViewMgr:get(ViewName.BossDekaronView)
                if view then
                    view:onClickClose()
                end
            end
        end)
    else
        GComErrorMsg(data.status)
    end
end
--仙域禁地怒气值广播
function FubenProxy:add8110303(data)
    if data.status == 0 then
        -- printt("仙域禁地怒气值广播",data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setRage(data.anger)
        end
    else
        GComErrorMsg(data.status)
    end
end

--上古神迹boss血量广播
function FubenProxy:add8110601(data)
    if data.status == 0 then
        -- printt("上古神迹BOSS血量广播",data)
        cache.FubenCache:updateShangGuBossData(data)
        self:refreshBossData()
    else
        GComErrorMsg(data.status)
    end
end
--上古神迹结算广播
function FubenProxy:add8110602(data)
    if data.status == 0 then
        -- printt("上古神迹结算广播",data)
        mgr.TimerMgr:addTimer(BOSSDEKARONTIME, 1, function()
            if mgr.FubenMgr:isShangGuShenJi(cache.PlayerCache:getSId()) then
                mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
                    view:setData(data,2)
                end)
            else
                local view = mgr.ViewMgr:get(ViewName.BossDekaronView)
                if view then
                    view:onClickClose()
                end
            end
        end)
    else
        GComErrorMsg(data.status)
    end
end
--上古神迹怒气值广播
function FubenProxy:add8110603(data)
    if data.status == 0 then
        -- printt("上古神迹怒气值广播",data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setRage(data.anger)
        end
    else
        GComErrorMsg(data.status)
    end
end

--五行神殿boss信息
function FubenProxy:add5330901(data)
    if data.status == 0 then
        -- printt("五行神殿boss信息",data)
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end

--五行神殿boss关注
function FubenProxy:add5330902(data)
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

--五行神殿场景信息
function FubenProxy:add5330903(data)
    if data.status == 0 then
        -- printt("五行神殿场景信息",data)
        cache.FubenCache:setWuXingData(data)
        cache.FubenCache:setFubenModular(1266)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        self:refreshTrack(1)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end

--天晶洞窟场景信息
function FubenProxy:add5028101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TjdkTrackView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.TjdkTrackView, data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--天晶洞窟采集广播
function FubenProxy:add8190301(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TjdkTrackView)
        if view then
            view:refreshInfo(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--天晶洞窟水晶刷新广播
function FubenProxy:add8190302(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TjdkTrackView)
        if view then
            view:refreshNextRefreshTime(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--
function FubenProxy:add8110118( data )
    -- body
    cache.FubenCache:setXycmBossData(data)
    if mgr.FubenMgr:isWSJChuMo(cache.PlayerCache:getSId()) then
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:xycmBossData()
        end
    else
        for k ,v in pairs(data.bossList) do
            self:refresBossHphView(v)
        end
    end
end

function FubenProxy:add8230605( data )
    -- body
    --printt("8230605",data)
    for k ,v in pairs(data.boosInfo) do
        self:refresBossHphView(v)
    end
end


--飞升
function FubenProxy:add5331101(data)
    if data.status == 0 then
         --printt("飞升boss信息",data)
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5331102(data)
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5331103(data)
    if data.status == 0 then
        cache.FubenCache:setFSData(data)
        cache.FubenCache:setFubenModular(1324)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        self:refreshTrack(1)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end

--神兽岛boss信息
function FubenProxy:add5331201(data)
    if data.status == 0 then
        self:refreshBossView(data)
    else
        GComErrorMsg(data.status)
    end
end

--神兽岛boss关注
function FubenProxy:add5331202(data)
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

--神兽岛场景信息
function FubenProxy:add5331203(data)
    if data.status == 0 then
        -- printt("神兽岛场景信息",data)

        local lhjpId = conf.FubenConf:getBossValue("ssd_lhjp")--龙魂精魄配置id
        
        local ljswId = conf.FubenConf:getBossValue("ssd_ljsw")--龙景守卫配置id
        for k,v in pairs(data.bossList) do
            v.type = 2
        end
        self.otherInfos = {}
        for k,v in pairs(data.otherInfos) do
            local lhjpInfo = {
                mapNum = v.lhjpMapNum,--龙魂晶魄地图数量
                nextRefreshTime = v.lhjpNextRefTime,--龙魂晶魄下次刷新时间
                sceneId = v.sceneId,
                monsterId = lhjpId,
                type = 1,
            }
            local ljswInfo = {
                mapNum = v.ljswMapNum,--龙晶守卫地图数量
                nextRefreshTime = v.ljswNextRefTime,--龙晶守卫下次刷新时间
                sceneId = v.sceneId,
                monsterId = ljswId,
                type = 1,
            }
            table.insert(self.otherInfos,lhjpInfo)
            table.insert(self.otherInfos,ljswInfo)
        end

        for k,v in pairs(self.otherInfos) do
            table.insert(data.bossList,v)
        end
        table.sort(data.bossList,function(a,b)
            if a.type ~= b.type then
                return a.type < b.type
            end
        end)
        -- printt("修改后场景信息",data)
        cache.FubenCache:setShenShouData(data)
        cache.FubenCache:setFubenModular(1337)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        self:refreshTrack(1)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8230601(data)
    if data.status == 0 then
        -- printt("广播采集物每日剩余次数",data)
        local mConf = conf.NpcConf:getNpcById(data.mId)
        local name = mConf and mConf.name or ""
        GComAlter(string.format(language.fuben237,name,data.leftCount))
    else
        GComErrorMsg(data.status)
    end
end
--广播神兽岛采集物信息
function FubenProxy:add8230603(data)
    if data.status == 0 then
        -- printt("广播神兽岛采集物递减信息>>>>>>>>>>>>>>",data)
        cache.FubenCache:updateShenShowOtherData(data.mId)
        self:refreshBossData()        
    else
        GComErrorMsg(data.status)
    end
end
--广播神兽岛次数用尽
function FubenProxy:add8230604(data)
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.BossTiredTipView, {isShenShouOver = true})
    else
        GComErrorMsg(data.status)
    end
end


--
function FubenProxy:add5331401(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5331402(data)
    if data.status == 0 then
        cache.FubenCache:setSSdata(data)
        cache.FubenCache:setFubenModular(1353)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        self:refreshTrack(1)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add5331403(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShouShenHurtRank)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FubenProxy:add8230606(data)
    -- body
    if data.status == 0 then
        GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end
-- 元旦探索结算广播
function FubenProxy:add8240206(data)
    print("元旦探索结算广播~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    if data.status == 0 then
        mgr.ViewMgr:openView(ViewName.FubenDekaronView, function(view)
            view:setData(data)
        end,{})
    else
        GComErrorMsg(data.status)
    end
end

--请求生肖试炼信息返回
function FubenProxy:add5028301(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求生肖试炼次数购买
function FubenProxy:add5028302(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:refreshShengXiao(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


return FubenProxy