--
-- Author: ohf
-- Date: 2017-05-03 11:38:04
--
--问鼎之战
local WenDingProxy = class("WenDingProxy",base.BaseProxy)

function WenDingProxy:init()
    self:add(5350101,self.add5350101)--请求问鼎之战信息
    self:add(5350102,self.add5350102)--请求战场日志
    self:add(5350103,self.add5350103)--请求条件信息
    self:add(5350104,self.add5350104)--请求排行信息
    self:add(5350105,self.add5350105)--请求场景玩家位置
    self:add(5810105,self.add5810105)--请求问鼎活动场景切换

    self:add(8130101,self.add8130101)--问鼎之战击杀完成广播
    self:add(8130102,self.add8130102)--问鼎之战击杀数广播
    self:add(8130103,self.add8130103)--问鼎之战战旗持有者
end
--请求问鼎之战信息
function WenDingProxy:add5350101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求战场日志
function WenDingProxy:add5350102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangLog)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求条件信息
function WenDingProxy:add5350103(data)
    if data.status == 0 then
        if gRole then
            gRole:updateRoleName(gRole.data.roleName)
            gRole:hitChenghao(false)
        end
        cache.FubenCache:setFubenModular(1079)
        cache.WenDingCache:setIsGotAwards(data.isGotAwards)
        --printt("问鼎条件信息请求返回",data.conds)
        cache.WenDingCache:setConds(data.conds)
        cache.WenDingCache:setScore(data.myScore)
        cache.WenDingCache:setTop20AvgLev(data.top20AvgLev)--本服排名前20的平均等级
        self:openFlagHoldView(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setWenDingTrack()
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 2})
        end
        local wendSId = cache.WenDingCache:getWendingSid()
        local rise = false
        if cache.PlayerCache:getSId() >= wendSId then
            rise = true
        end
        mgr.ViewMgr:openView2(ViewName.WenDingBegin, {rise = rise})
        cache.WenDingCache:setflagHoldRoleId(data.holdFlagRoleId)
        if data.holdFlagRoleId then--查看有没有战旗持有者
            local view = mgr.ViewMgr:get(ViewName.TrackView)
            if view then
                view:setFlagHold(data.holdFlagRoleId)
            end
        end
        cache.WenDingCache:setWendingSid()
        mgr.HookMgr:enterHook()

        local sceneId = cache.PlayerCache:getSId()
        local sceneNum = tonumber(string.sub(sceneId,6,6))
            local floorData = conf.WenDingConf:getFloorData(sceneNum + 1)
            local killNum = floorData and floorData.kill_num or 0
            local condNum = data.conds[sceneNum] or 0
            if killNum > 0 then
                if condNum >= killNum then
                    if gRole then
                        gRole:idleBehaviour()
                        gRole:stopAI()
                        mgr.HookMgr:cancelHook()
                        mgr.TimerMgr:addTimer(0.6, 1, function( ... )
                            -- plog("飞层")
                            gRole:flyUp(function()
                                -- mgr.TimerMgr:addTimer(0.2, 1, function()
                                --     plog("切换场景")
                                --     proxy.WenDingProxy:send(1810105,{sceneId = cache.PlayerCache:getSId() + 1})
                                -- end)
                            end) 
                            mgr.TimerMgr:addTimer(0.25, 1, function()
                                -- plog("问鼎切换场景",cache.PlayerCache:getSId()+1,condNum,killNum)
                                proxy.WenDingProxy:send(1810105,{sceneId = cache.PlayerCache:getSId() + 1})
                            end)
                        end)
                    end
                end
            end
    else
        GComErrorMsg(data.status)
    end
end
--请求排行信息
function WenDingProxy:add5350104(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WendingTipView)
        if view then
            view:setData(data)
        end
        if data.reqType == 4 then--前往抢夺
            mgr.HookMgr:setHookData({code=2, info=data})
            --[[local pox,poy = data.pox,data.poy
            local distance = 100
            if pox == 0 and poy == 0 then
                local warFlag = conf.NpcConf:getNpcById(3090201)
                if warFlag then
                    pox,poy = warFlag.pos[1],warFlag.pos[2]
                    local p = Vector3.New(pox, gRolePoz, poy)
                    gRole:moveToPoint(p, distance, function()
                        proxy.FubenProxy:send(1810302,{tarPox = pox,tarPoy = poy})--拾取
                    end)
                end
            else
                local p = Vector3.New(pox, gRolePoz, poy)
                -- print("战旗持有者坐标1",pox,poy)
                gRole:moveToPoint(p, distance, function()
                    mgr.HookMgr:playerCheckHook()
                end)
            end]]
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求场景玩家位置
function WenDingProxy:add5350105(data)
    -- body
    if data.status == 0 then
        -- print("战旗持有者坐标2",data.pos.pox,data.pos.poy)
        mgr.HookMgr:WendingHook(data)
    else
        GComErrorMsg(data.status)
    end
end

function WenDingProxy:add5810105(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
--问鼎之战击杀完成广播
function WenDingProxy:add8130101(data)
    -- printt("问鼎之战击杀完成广播",data)
    if data.status == 0 then
        data["titleUrl"] = UIItemRes.wending01
        data["type"] = 2
        local amount = 0
        local expCoefs = conf.WenDingConf:getValue("wending_exp_coef")
        local expXA,expXB = expCoefs[1],expCoefs[2]--经验系数A,B
        local scoreData = conf.WenDingConf:getScoreAward(data.myScore)
        if scoreData then
            local exp = expXA * cache.PlayerCache:getRoleLevel() + expXB--公式
            local coef = scoreData.coef or 0
            amount = amount + math.floor(exp * (coef / 10000))
        end
        local rankData = conf.WenDingConf:getRankAward(data.ranking)
        if rankData then
            local top20AvgLev = cache.WenDingCache:getTop20AvgLev()--本服排名前20的平均等级
            local exp = expXA * top20AvgLev + expXB--公式
            local coef = rankData and rankData.coef or 0
            amount = amount + math.floor(exp * (coef / 10000))
        end
        local expData = {mid = PackMid.exp,amount = amount,bind = 1}
        local scoreAwards = {}
        scoreAwards[1] = expData--获得的经验
        local awards = data.items or {}
        for k,v in pairs(awards) do
            table.insert(scoreAwards, v)
        end
        data.items = scoreAwards
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView,data)
        cache.WenDingCache:setWendingOver(true)
    else
        GComErrorMsg(data.status)
    end
end
--问鼎之战击杀数广播
function WenDingProxy:add8130102(data)
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        if sId == data.sceneId then
            cache.WenDingCache:setConds(data.conds)
            cache.WenDingCache:setScore(data.myScore)
            local sceneNum = tonumber(string.sub(data.sceneId,6,6))
            local floorData = conf.WenDingConf:getFloorData(sceneNum + 1)
            local killNum = floorData and floorData.kill_num or 0
            local condNum = data.conds[sceneNum] or 0
            if killNum > 0 then
                if condNum >= killNum then
                    if gRole then
                        gRole:idleBehaviour()
                        gRole:stopAI()
                        mgr.HookMgr:cancelHook()
                        mgr.TimerMgr:addTimer(0.6, 1, function( ... )
                            -- plog("飞层")
                            gRole:flyUp(function()
                                -- mgr.TimerMgr:addTimer(0.2, 1, function()
                                --     plog("切换场景")
                                --     proxy.WenDingProxy:send(1810105,{sceneId = cache.PlayerCache:getSId() + 1})
                                -- end)
                            end) 
                            mgr.TimerMgr:addTimer(0.25, 1, function()
                                -- plog("问鼎切换场景",cache.PlayerCache:getSId()+1,condNum,killNum)
                                proxy.WenDingProxy:send(1810105,{sceneId = cache.PlayerCache:getSId() + 1})
                            end)
                        end)
                    end
                end
            end
        end
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setWendingData()
        end
    else
        GComErrorMsg(data.status)
    end
end

function WenDingProxy:sendMsg(msgId,param)
    -- print("bbbbbbbbbbbbbbbbbb")
    -- print(debug.traceback())
    self:send(msgId,param)
end

--问鼎之战战旗持有者
function WenDingProxy:add8130103(data)
    if data.status == 0 then
        local fbId = cache.PlayerCache:getSId()
        if data.flagHoldRoleId == "0" then
            mgr.HookMgr:setHookData({code=2, info={pox = 0,poy = 0}})
        else
            mgr.TimerMgr:addTimer(0.5, 1, function()       
                self:sendMsg(1350105,{sceneId = fbId})
            end)
        end
        cache.WenDingCache:setflagHoldRoleId(data.flagHoldRoleId)
        local sceneNum = tonumber(string.sub(fbId,6,6))
        if mgr.FubenMgr:isWenDing(fbId) and sceneNum == 9 then
            self:openFlagHoldView(data)
        end
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setFlagHold(data.flagHoldRoleId)
        end
    else
        GComErrorMsg(data.status)
    end
end
--打开守旗倒计时界面
function WenDingProxy:openFlagHoldView(data)
    local view = mgr.ViewMgr:get(ViewName.FlagHoldView)
    if view then
        if data.leftTime > 0 then
            view:setData(data)
        else
            view:closeView()
        end
    else
        if data.leftTime > 0 then
            mgr.ViewMgr:openView2(ViewName.FlagHoldView,data)
        end
    end
end

return WenDingProxy