--
-- Author: 
-- Date: 2018-07-23 21:14:07
--

local XianLvProxy = class("XianLvProxy",base.BaseProxy)

function XianLvProxy:init()
    self:add(8230501,self.add8230501)--仙侣pk匹配操作广播
    self:add(8230502,self.add8230502)--仙侣pk血量广播
    self:add(8230503,self.add8230503)--仙侣pk海选赛结算广播
    self:add(8230504,self.add8230504)--仙侣pk争霸赛每场开始广播
    self:add(8230505,self.add8230505)--仙侣pk争霸赛切换场景广播
    self:add(8230506,self.add8230506)--仙侣pk活动预告广播


    self:add(5540101,self.add5540101)--请求仙侣pk活动信息
    self:add(5540102,self.add5540102)--请求仙侣pk队伍操作
    self:add(5540103,self.add5540103)--请求仙侣pk排行榜
    self:add(5540104,self.add5540104)--请求仙侣pk奖励
    self:add(5540105,self.add5540105)--请求仙侣pk押注
    self:add(5540106,self.add5540106)--请求仙侣pk鼓舞
    self:add(5540107,self.add5540107)--请求仙侣pk匹配
    self:add(5540108,self.add5540108)--请求仙侣pk详细信息
    self:add(5540109,self.add5540109)--请求仙侣pk海选赛场景信息
    self:add(5540110,self.add5540110)--请求仙侣pk场景位置信息
    self:add(5540111,self.add5540111)--请求仙侣pk争霸赛场景信息

    ------------------全服-----------------------------
    self:add(5540201,self.add5540201)--请求仙侣pk活动信息
    self:add(5540202,self.add5540202)--请求仙侣pk队伍操作
    self:add(5540203,self.add5540203)--请求仙侣pk排行榜
    self:add(5540204,self.add5540204)--请求仙侣pk奖励
    self:add(5540205,self.add5540205)--请求仙侣pk押注
    self:add(5540206,self.add5540206)--请求仙侣pk鼓舞
    self:add(5540207,self.add5540207)--请求仙侣pk匹配
    self:add(5540208,self.add5540208)--请求仙侣pk详细信息
    self:add(5540209,self.add5540209)--请求仙侣pk海选赛场景信息
    self:add(5540210,self.add5540210)--请求仙侣pk场景位置信息
    self:add(5540211,self.add5540211)--请求仙侣pk争霸赛场景信息
end

function XianLvProxy:sendMsg(msgId,param)
    self:send(msgId,param)
end

function XianLvProxy:add8230501(data)
    if data.status == 0 then
        -- print("仙侣pk匹配操作广播",data.reqType)
        if data.reqType == 1 then
            if mgr.FubenMgr:checkScene() then
                GComAlter(language.xianlv34)
                return
            end
            --type 1:跨服，2：全服
            local type = data.actId == 5010 and 2 or 1
            mgr.ViewMgr:openView2(ViewName.XianLvPKMatchingView,{type = type})
        elseif data.reqType == 2 then
            local view = mgr.ViewMgr:get(ViewName.XianLvPKMatchingView)
            if view then
                view:closeView()
            end
        elseif data.reqType == 3 then
            -- print("匹配成功",data.sceneId)
            if mgr.FubenMgr:checkScene() then
                GComAlter(language.xianlv34)
                return
            end
            proxy.ThingProxy:send(1020101,{sceneId = data.sceneId,type = 3})
        elseif data.reqType == 4 then-- 4:队友在特殊场景
            --5010全服
            local msgId = data.actId == 5010 and 1540207 or 1540107 
            local param = {}
            param.type = 14
            param.richtext = language.xianlv33
            param.sure = function()
                proxy.XianLvProxy:sendMsg(msgId,{reqType = 3})
            end
            param.cancel = function ()
                proxy.XianLvProxy:sendMsg(msgId,{reqType = 2})
            end
            GComAlter(param)

        end

    else
        GComErrorMsg(data.status)
    end
end

function XianLvProxy:add8230502(data)
    if data.status == 0 then
        -- printt("血量更新广播",data)
        local view = mgr.ViewMgr:get(ViewName.XianLvPKProceedView)
        if view then
            view:refreshHpInfo(data)
        end
        local myHp = cache.XianLvCache:getMyHp()
        local roleId = cache.PlayerCache:getRoleId()
        local nowHp = 100
        local isOver = true
        for k,v in pairs(data.hpInfos) do
            if roleId == v.roleId then
                nowHp = v.hp
            end
            if data.teamId == v.teamId and v.hp ~= 0 then
                isOver = false
            end
        end
        if myHp ~= 0 then
            cache.XianLvCache:setMyHp(nowHp)
            if nowHp == 0 and not isOver then--自己死了，比赛还没结束
                mgr.ViewMgr:openView2(ViewName.PwsDeadTipsView, {})
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--仙侣pk海选赛结算广播
function XianLvProxy:add8230503(data)
    if data.status == 0 then
        -- if data.reqType == 1 then
            -- printt("仙侣pk结算广播",data)
            mgr.ViewMgr:openView2(ViewName.XianLvPKOverView, data)
        -- elseif data.reqType == 2 then

        -- end
    else
        GComErrorMsg(data.status)
    end
end

--仙侣pk争霸赛每场开始广播
function XianLvProxy:add8230504(data)
    -- printt("仙侣pk争霸赛每场开始广播",data)
    if data.status == 0 then
        local netTime = mgr.NetMgr:getServerTime()
        local dTime = netTime - data.boStartTime
        print("时间间隔",dTime,netTime,data.boStartTime)
        -- if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                -- if not mgr.HookMgr.isHook then
                --     mgr.HookMgr:enterHook()--开始挂机
                -- end
            end)
        -- else
        --     mgr.TimerMgr:addTimer(1, 1, function()
        --         if not mgr.HookMgr.isHook then
        --             mgr.HookMgr:enterHook()--开始挂机
        --         end
        --     end)
        -- end
        
        local view = mgr.ViewMgr:get(ViewName.XianLvPKProceedView)
        if view then
            view:setRound(data)
        end
    else
        GComErrorMsg(data.status)
    end
end




--仙侣pk争霸赛切换场景广播
function XianLvProxy:add8230505(data)
    if data.status == 0 then
        if mgr.FubenMgr:checkScene() then
            GComAlter(language.xianlv34)
            return
        end
        local sceneId = data.actId == 5010 and 269001 or 262001
        proxy.ThingProxy:send(1020101,{sceneId = sceneId ,type = 3})
    else
        GComErrorMsg(data.status)
    end
end
--仙侣pk活动预告广播
function XianLvProxy:add8230506(data)
    if data.status == 0 then
        printt("仙侣pk活动预告广播",data)
        -- if data.reqType == 2 or data.reqType == 3 then
            mgr.ViewMgr:openView2(ViewName.XianLvTipsView,data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk活动信息
function XianLvProxy:add5540101(data)
    if data.status == 0 then
        --设置海选赛阶段奖励缓存
        cache.XianLvCache:setTargetAwardSigns(data.targetAwardSigns)
        cache.XianLvCache:setStakeInfo(data.stakeInfo)
        cache.XianLvCache:setVsInfo(data.vsInfo)
        cache.XianLvCache:setMulActiveId(data.mulActiveId)
        local view = mgr.ViewMgr:get(ViewName.XianLvPKMainView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk队伍操作
function XianLvProxy:add5540102(data)
    if data.status == 0 then
        GComAlter(language.xianlv16)
        proxy.XianLvProxy:sendMsg(1540101,{reqType = 0})
        local view = mgr.ViewMgr:get(ViewName.JoinView)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk排行榜
function XianLvProxy:add5540103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianLvRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙侣pk奖励
function XianLvProxy:add5540104(data)
    if data.status == 0 then
        proxy.XianLvProxy:sendMsg(1540101,{reqType = 0})
        cache.XianLvCache:setTargetAwardSigns(data.targetAwardSigns)
        -- local view =  mgr.ViewMgr:get(ViewName.XianLvRankView)
        -- if view then
        --     view:refreshHaiXuanPlan()
        -- end
        GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end
--请求仙侣pk押注
function XianLvProxy:add5540105(data)
    if data.status == 0 then
        cache.XianLvCache:setStakeInfo(data.stakeInfo)
        -- local group = data.group
        -- local vsTeams = {}
        -- local vsInfo = cache.XianLvCache:getVsInfo()
        -- for k,v in pairs(vsInfo) do
        --     if v.rankType == rankType and v.group == group then
        --         vsTeams = v.vsTeams
        --         group = v.group
        --     end
        -- end
        -- local view = mgr.ViewMgr:get(ViewName.XianLvPKTouZhuView)
        -- if view then
        --     view:initData({vsTeams = vsTeams,group = group})
        -- else
        --     mgr.ViewMgr:openView2(ViewName.XianLvPKTouZhuView,{vsTeams = vsTeams,group = group})
        -- end
        GComAlter("押注成功")
        local view = mgr.ViewMgr:get(ViewName.XianLvPKTouZhuView)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk鼓舞
function XianLvProxy:add5540106(data)
    if data.status == 0 then
        proxy.XianLvProxy:sendMsg(1540101,{reqType = 0})
        GComAlter(language.xianlv19)
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk匹配
function XianLvProxy:add5540107(data)
    if data.status == 0 then
        if data.reqType == 1 then
            mgr.ViewMgr:openView2(ViewName.XianLvPKMatchingView,{type = 1})
        elseif data.reqType == 2 then
            local view = mgr.ViewMgr:get(ViewName.XianLvPKMatchingView)
            if view then
                view:closeView()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙侣pk详细信息
function XianLvProxy:add5540108(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TeamInfoView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk海选赛场景信息
function XianLvProxy:add5540109(data)
    if data.status == 0 then
        printt("海选赛场景信息",data)
        cache.XianLvCache:setTeamId(data.teamId)
        local netTime = data.curTime--mgr.NetMgr:getServerTime()
        local dTime = netTime - data.startTime
        -- print("时间间隔",dTime,netTime,data.startTime)
        if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        else
            mgr.TimerMgr:addTimer(1, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        end
        --场景类型
        data.type = 1
        local view = mgr.ViewMgr:get(ViewName.XianLvPKProceedView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.XianLvPKProceedView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk场景位置信息
function XianLvProxy:add5540110(data)
    printt("仙侣pk场景位置信息返回",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MapView)
        if view then
            view:updateXmzbMap(data)
        end
        local view = mgr.ViewMgr:get(ViewName.MiniMapView)
        if view then
            view:updateXmzbMap(data)
        end
        --如果正在挂机
        print("是否正在挂机",mgr.HookMgr.isHook)
        if mgr.HookMgr.isHook then
            mgr.HookMgr:setHookData(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求仙侣pk争霸赛场景信息
function XianLvProxy:add5540111(data)
    printt("争霸赛场景信息",data)
    if data.status == 0 then
        cache.XianLvCache:setTeamId(data.teamId)
        -- print("设置队伍id缓存")
        local netTime = data.curTime--mgr.NetMgr:getServerTime()
        local dTime = netTime - data.startTime
        -- print("时间间隔",dTime,netTime,data.startTime)
        if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                -- print("挂机状态>>>>>>>>",mgr.HookMgr.isHook)
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        else
            mgr.TimerMgr:addTimer(1, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        end
        --场景类型
        data.type = 2
        local view = mgr.ViewMgr:get(ViewName.XianLvPKProceedView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.XianLvPKProceedView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end


--请求仙侣pk活动信息
function XianLvProxy:add5540201(data)
    if data.status == 0 then
        --设置海选赛阶段奖励缓存
        cache.XianLvCache:setTargetAwardSigns(data.targetAwardSigns)
        cache.XianLvCache:setStakeInfo(data.stakeInfo)
        cache.XianLvCache:setVsInfo(data.vsInfo)
        cache.XianLvCache:setMulActiveId(data.mulActiveId)
        local view = mgr.ViewMgr:get(ViewName.XianLvPKMainView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk队伍操作
function XianLvProxy:add5540202(data)
    if data.status == 0 then
        GComAlter(language.xianlv16)
        proxy.XianLvProxy:sendMsg(1540201,{reqType = 0})
        local view = mgr.ViewMgr:get(ViewName.JoinView)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk排行榜
function XianLvProxy:add5540203(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianLvRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙侣pk奖励
function XianLvProxy:add5540204(data)
    if data.status == 0 then
        proxy.XianLvProxy:sendMsg(1540201,{reqType = 0})
        cache.XianLvCache:setTargetAwardSigns(data.targetAwardSigns)
        -- local view =  mgr.ViewMgr:get(ViewName.XianLvRankView)
        -- if view then
        --     view:refreshHaiXuanPlan()
        -- end
        GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end
--请求仙侣pk押注
function XianLvProxy:add5540205(data)
    if data.status == 0 then
        cache.XianLvCache:setStakeInfo(data.stakeInfo)
        -- local group = data.group
        -- local vsTeams = {}
        -- local vsInfo = cache.XianLvCache:getVsInfo()
        -- for k,v in pairs(vsInfo) do
        --     if v.rankType == rankType and v.group == group then
        --         vsTeams = v.vsTeams
        --         group = v.group
        --     end
        -- end
        -- local view = mgr.ViewMgr:get(ViewName.XianLvPKTouZhuView)
        -- if view then
        --     view:initData({vsTeams = vsTeams,group = group})
        -- else
        --     mgr.ViewMgr:openView2(ViewName.XianLvPKTouZhuView,{vsTeams = vsTeams,group = group})
        -- end
        GComAlter("押注成功")
        local view = mgr.ViewMgr:get(ViewName.XianLvPKTouZhuView)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk鼓舞
function XianLvProxy:add5540206(data)
    if data.status == 0 then
        proxy.XianLvProxy:sendMsg(1540201,{reqType = 0})
        GComAlter(language.xianlv19)
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk匹配
function XianLvProxy:add5540207(data)
    if data.status == 0 then
        if data.reqType == 1 then
            mgr.ViewMgr:openView2(ViewName.XianLvPKMatchingView,{type = 2})
        elseif data.reqType == 2 then
            local view = mgr.ViewMgr:get(ViewName.XianLvPKMatchingView)
            if view then
                view:closeView()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙侣pk详细信息
function XianLvProxy:add5540208(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TeamInfoView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk海选赛场景信息
function XianLvProxy:add5540209(data)
    if data.status == 0 then
        printt("海选赛场景信息",data)
        cache.XianLvCache:setTeamId(data.teamId)
        local netTime = data.curTime--mgr.NetMgr:getServerTime()
        local dTime = netTime - data.startTime
        -- print("时间间隔",dTime,netTime,data.startTime)
        if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        else
            mgr.TimerMgr:addTimer(1, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        end
        --场景类型
        data.type = 1
        local view = mgr.ViewMgr:get(ViewName.XianLvPKProceedView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.XianLvPKProceedView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙侣pk场景位置信息
function XianLvProxy:add5540210(data)
    -- printt("仙侣pk场景位置信息返回",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MapView)
        if view then
            view:updateXmzbMap(data)
        end
        local view = mgr.ViewMgr:get(ViewName.MiniMapView)
        if view then
            view:updateXmzbMap(data)
        end
        --如果正在挂机
        print("是否正在挂机",mgr.HookMgr.isHook)
        if mgr.HookMgr.isHook then
            mgr.HookMgr:setHookData(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求仙侣pk争霸赛场景信息
function XianLvProxy:add5540211(data)
    -- printt("争霸赛场景信息",data)
    if data.status == 0 then
        cache.XianLvCache:setTeamId(data.teamId)
        -- print("设置队伍id缓存")
        local netTime = data.curTime--mgr.NetMgr:getServerTime()
        local dTime = netTime - data.startTime
        -- print("时间间隔",dTime,netTime,data.startTime)
        if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                -- print("挂机状态>>>>>>>>",mgr.HookMgr.isHook)
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        else
            mgr.TimerMgr:addTimer(1, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()
                end
            end)
        end
        --场景类型
        data.type = 2
        local view = mgr.ViewMgr:get(ViewName.XianLvPKProceedView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.XianLvPKProceedView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end


return XianLvProxy