-- 排位赛协议
-- Author: Your Name
-- Date: 2018-01-05 10:55:45
--

local QualifierProxy = class("QualifierProxy",base.BaseProxy)

function QualifierProxy:init()
    --单人排位请求
    self:add(5480101,self.add5480101)--请求单人排位赛信息
    self:add(5480102,self.add5480102)--请求单人排位赛竞技奖励
    self:add(5480103,self.add5480103)--请求单人排位排行
    self:add(5480104,self.add5480104)--请求单人排位赛目标奖励
    self:add(5480105,self.add5480105)--请求单人排位赛购买次数
    self:add(5480106,self.add5480106)--请求单人排位赛匹配
    self:add(5480107,self.add5480107)--请求单人排位赛场景信息
    self:add(5480108,self.add5480108)--请求单人玩家位置信息
    --组队排位请求
    self:add(5480201,self.add5480201)--请求组队排位赛信息
    self:add(5480202,self.add5480202)--请求组队排位战队列表
    self:add(5480203,self.add5480203)--请求组队排位赛创建加入战队
    self:add(5480204,self.add5480204)--请求组队排位战队操作
    self:add(5480205,self.add5480205)--请求组队排位赛开始匹配
    self:add(5480206,self.add5480206)--请求组队排位赛段位奖励
    self:add(5480207,self.add5480207)--请求组队排位赛目标奖励
    self:add(5480208,self.add5480208)--请求组队排位赛排行榜
    self:add(5480209,self.add5480209)--请求组队排位赛购买次数
    self:add(5480210,self.add5480210)--请求组队排位邀请玩家列表
    self:add(5480211,self.add5480211)--请求组队排位玩家申请列表
    self:add(5480212,self.add5480212)--请求组队排位赛押注
    self:add(5480213,self.add5480213)--请求组队排位赛场景信息
    self:add(5480214,self.add5480214)--请求组队玩家位置信息
    --季后赛请求
    self:add(5480301,self.add5480301)--请求季后赛排位信息
    self:add(5480302,self.add5480302)--请求季后赛场景信息
    self:add(5480303,self.add5480303)--请求季后赛押注
    self:add(5480304,self.add5480304)--请求季后赛玩家位置信息


    --单人匹配广播
    self:add(8230101,self.add8230101)--单人匹配结算广播
    self:add(8230102,self.add8230102)--单人匹配成功广播
    --组队匹配广播
    self:add(8230201,self.add8230201)--组队排位战队操作
    self:add(8230202,self.add8230202)--组队排位邀请广播
    self:add(8230203,self.add8230203)--组队排位队伍更新广播
    self:add(8230204,self.add8230204)--组队排位赛匹配广播
    self:add(8230205,self.add8230205)--组队排位匹配成功广播
    self:add(8230206,self.add8230206)--组队排位匹配结算广播
    self:add(8230207,self.add8230207)--组队排位赛血量广播
    --季后赛每场广播
    self:add(8230301,self.add8230301)--季后赛每场开始广播
    self:add(8230302,self.add8230302)--季后赛排位赛结算广播
end

function QualifierProxy:sendMsg(msgId, param)
    -- body
    self:send(msgId,param)
end

function QualifierProxy:add5480101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function QualifierProxy:add5480102(data)
    if data.status == 0 then
        if data.reqType == 1 then--领取
            if data.items and #data.items>0 then
                GOpenAlert3(data.items)
            end
            local var = cache.PlayerCache:getRedPointById(attConst.A50124)
            cache.PlayerCache:setRedpoint(attConst.A50124,var-1)
            print("竞技奖励红点",var-1)
            local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
            if view and view.PanelRanking then
                view.PanelRanking:refreshRed()
            end
            mgr.GuiMgr:updateRedPointPanels(attConst.A50124)
        end
        local view = mgr.ViewMgr:get(ViewName.RankAwardsView)
        if view then
            view:setAwardsData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function QualifierProxy:add5480103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RankAwardsView)
        if view then
            view:setRankData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function QualifierProxy:add5480104(data)
    if data.status == 0 then
        local var = cache.PlayerCache:getRedPointById(attConst.A50126)
        cache.PlayerCache:setRedpoint(attConst.A50126,var-1)

        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:refreshAward(data)
            view.PanelRanking:refreshRed()
        end
        mgr.GuiMgr:updateRedPointPanels(attConst.A50126)
    else
        GComErrorMsg(data.status)
    end
end

function QualifierProxy:add5480105(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:refreshLastCount(data.buyCount)
        end
    else
        GComErrorMsg(data.status)
    end
end

function QualifierProxy:add5480106(data)
    if data.status == 0 then
        if data.reqType == 1 then
            mgr.ViewMgr:openView2(ViewName.MatchingView, {type = 1})
        elseif data.reqType == 2 then
            -- print("取消单人匹配")
            local view = mgr.ViewMgr:get(ViewName.MatchingView)
            if view then
                view:closeView()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function QualifierProxy:add5480107(data)
    if data.status == 0 then
        local netTime = data.curTime--mgr.NetMgr:getServerTime()
        local dTime = netTime - data.startTime
        print("时间间隔",dTime,netTime,data.startTime)
        if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()--开始挂机
                end
            end)
        else
            mgr.TimerMgr:addTimer(1, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()--开始挂机
                end
            end)
        end
        --场景类型
        data.type = 1
        local view = mgr.ViewMgr:get(ViewName.RankProceedView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.RankProceedView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求单人玩家位置信息
function QualifierProxy:add5480108(data)
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
        if mgr.HookMgr.isHook then
            mgr.HookMgr:setHookData(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function QualifierProxy:add8230101(data)
    if data.status == 0 then
        cache.PwsCache:setSoloOverData(data)
        mgr.ViewMgr:openView(ViewName.ArenaSaoDown,function(view)
            -- body
            view:add8230101(data)
        end,data)
        local view = mgr.ViewMgr:get(ViewName.MatchingView)
        if view then
            view:closeView()
        end
        if mgr.HookMgr.isHook then
            mgr.HookMgr:cancelHook()--停止挂机
        end
    else
        GComErrorMsg(data.status)
    end
end

function QualifierProxy:add8230102(data)
    if data.status == 0 then
        if data.reqType == 1 then
            print("匹配成功",data.sceneId)
            proxy.ThingProxy:send(1020101,{sceneId = data.sceneId,type = 3})
        else
            print("匹配失败",data.reqType)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛信息
function QualifierProxy:add5480201(data)
    if data.status == 0 then
        --缓存队伍成员信息
        cache.PwsCache:setCanJoin(data.canJoin)
        cache.PwsCache:setTeamList(data.members)
        cache.PwsCache:setTeamInfo(data.teamInfo)
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位战队列表
function QualifierProxy:add5480202(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PwsTeamListView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛创建加入战队
function QualifierProxy:add5480203(data)
    if data.status == 0 then
        printt("战队创建成功",data)
        cache.PwsCache:setTeamList(data.members)
        cache.PwsCache:setTeamInfo(data.teamInfo)
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:showMembers(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.SetUpTeam)
        if view2 then
            view2:closeView()
        end
        local view3 = mgr.ViewMgr:get(ViewName.PwsTeamListView)
        if view3 then
            view3:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位战队操作
function QualifierProxy:add5480204(data)
    if data.status == 0 then
        if data.reqType == 1 then--转移队长
            -- local view = mgr.ViewMgr:get(ViewName.TeamInformation)
            -- if view then
            --     view:closeView()
            -- end
            local view2 = mgr.ViewMgr:get(ViewName.PwsMembersList)
            if view2 then
                view2:closeView()
            end
        elseif data.reqType == 2 then--踢人
            local view = mgr.ViewMgr:get(ViewName.PwsMembersList)
            if view then
                view:closeView()
            end
        elseif data.reqType == 5 then--邀请
            -- local view = mgr.ViewMgr:get(ViewName.PwsTeamInviteList)
            -- if view then
            --     view:refreshView()
            -- end
            GComAlter(language.qualifier29)
        elseif data.reqType == 7 then--申请返回
            print("申请入队返回")
            local view = mgr.ViewMgr:get(ViewName.PwsTeamListView)
            if view then
                view:refreshList()
            end
        elseif data.reqType == 8 or data.reqType == 9 then--同意和拒绝后刷新申请列表
            local view = mgr.ViewMgr:get(ViewName.PwsTeamApplyView)
            if view then
                view:refreshView()
            end
        elseif data.reqType == 10 then
            local view = mgr.ViewMgr:get(ViewName.PwsTeamApplyView)
            if view then
                view:refreshView()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛开始匹配
function QualifierProxy:add5480205(data)
    if data.status == 0 then
        if data.notNumber and data.notNumber > 0 then
            local param = {}
            param.type = 2
            param.richtext = language.qualifier52
            param.sure = function()
                -- body
                self:sendMsg(1480205,{reqType = 1})
            end
            param.cancel = function()
                
            end
            GComAlter(param)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛段位奖励
function QualifierProxy:add5480206(data)
    if data.status == 0 then
        if data.reqType == 1 then--领取
            if data.items and #data.items>0 then
                GOpenAlert3(data.items)
            end
            local var = cache.PlayerCache:getRedPointById(attConst.A50125)
            cache.PlayerCache:setRedpoint(attConst.A50125,var-1)

            local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
            if view and view.PanelRanking then
                view.PanelRanking:refreshRed()
            end
            mgr.GuiMgr:updateRedPointPanels(attConst.A50125)
        end
        local view = mgr.ViewMgr:get(ViewName.TeamRankAwardsView)
        if view then
            view:setAwardsData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛目标奖励
function QualifierProxy:add5480207(data)
    if data.status == 0 then
        local var = cache.PlayerCache:getRedPointById(attConst.A50127)
        cache.PlayerCache:setRedpoint(attConst.A50127,var-1)

        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:refreshTeamAward(data)
            view.PanelRanking:refreshRed()
        end
        mgr.GuiMgr:updateRedPointPanels(attConst.A50127)
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛排行榜
function QualifierProxy:add5480208(data)
    if data.status == 0 then
        printt("排行榜信息",data)
        local view = mgr.ViewMgr:get(ViewName.TeamRankAwardsView)
        if view then
            view:setRankData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛购买次数
function QualifierProxy:add5480209(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:refreshTeamLastCount(data.buyCount)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求组队排位邀请玩家列表
function QualifierProxy:add5480210(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PwsTeamInviteList)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求组队排位玩家申请列表
function QualifierProxy:add5480211(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PwsTeamApplyView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛押注
function QualifierProxy:add5480212(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TeamRankAwardsView)
        if view then
            view:setGuessData(data)
        end
        --竞猜红点刷新
        if data.stage == 0 then--暂未开始
            cache.PlayerCache:setRedpoint(attConst.A50122,0)
        elseif data.stage == 1 then--押注阶段
            if data.stakeCount > 0 or (data.stakes and #data.stakes <= 0) then
                cache.PlayerCache:setRedpoint(attConst.A50122,0)
            end
        elseif data.stage == 2 then--领奖阶段
            local flag = false
            for _,sid in pairs(data.winSid) do
                for k,v in pairs(data.stakes) do
                    if sid == v.agentServerId and v.myStake > 0 and v.awardSign ~= 1 then
                        flag = true
                        break
                    end
                end
            end
            if not flag then
                cache.PlayerCache:setRedpoint(attConst.A50122,0)
            end
        end
        print("竞猜红点",cache.PlayerCache:getRedPointById(attConst.A50122))
        mgr.GuiMgr:updateRedPointPanels(attConst.A50122)
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:refreshRed()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求组队排位赛场景信息
function QualifierProxy:add5480213(data)
    if data.status == 0 then
        printt("组排场景信息",data)
        cache.PwsCache:setTeamId(data.teamId)
        local netTime = data.curTime--mgr.NetMgr:getServerTime()
        local dTime = netTime - data.startTime
        print("时间间隔",dTime,netTime,data.startTime)
        if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()--开始挂机
                end
            end)
        else
            mgr.TimerMgr:addTimer(1, 1, function()
                if not mgr.HookMgr.isHook then
                    mgr.HookMgr:enterHook()--开始挂机
                end
            end)
        end
        --场景类型
        data.type = 2
        local view = mgr.ViewMgr:get(ViewName.RankProceedView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.RankProceedView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求组队玩家位置信息
function QualifierProxy:add5480214(data)
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
        if mgr.HookMgr.isHook then
            mgr.HookMgr:setHookData(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

--组队排位战队操作
function QualifierProxy:add8230201(data)
    if data.status == 0 then
        printt("组队排位操作广播",data)
        if data.reqType == 1 then--转移队长

        elseif data.reqType == 2 or data.reqType == 4 or data.reqType == 3 then--踢人、退出、解散
            local roleId = cache.PlayerCache:getRoleId()
            if ((data.reqType == 2 or data.reqType == 4) and roleId == data.roleId) or data.reqType == 3 then--如果被踢出的人是自己
                local teamInfo = cache.PwsCache:getTeamInfo()
                teamInfo.pwLev = 0
                teamInfo.teamId = 0
                teamInfo.icon = 1
                cache.PwsCache:setTeamInfo(teamInfo)
                local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
                if view and view.PanelRanking then
                    view.PanelRanking:showMembers({teamInfo = cache.PwsCache:getTeamInfo()})
                end
                local view2 = mgr.ViewMgr:get(ViewName.TeamInformation)
                if view2 then
                    view2:closeView()
                end
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--组队排位邀请广播
function QualifierProxy:add8230202(data)
    if data.status == 0 then
        --type 1.来自别人的申请，2.来自别人的邀请
        printt("组队申请邀请广播",data)
        if data.reqType == 3 then--被拒绝
            GComAlter(string.format(language.qualifier60,data.teamName))
        else
            if data.reqType == 1 then--邀请
                data.type = 2
            elseif data.reqType == 2 then--申请
                data.type = 1
            end
            local view = mgr.ViewMgr:get(ViewName.PwsTeamTipView)
            if view then
                view:initData(data)
            else
                mgr.ViewMgr:openView2(ViewName.PwsTeamTipView,data)
            end
        end

    else
        GComErrorMsg(data.status)
    end
end

--组队排位队伍更新广播
function QualifierProxy:add8230203(data)
    if data.status == 0 then
        printt("队伍更新广播",data)
        cache.PwsCache:setTeamInfo(data.teamInfo)
        cache.PwsCache:setTeamList(data.members)
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:showMembers(data)
        end
        local view = mgr.ViewMgr:get(ViewName.TeamInformation)
        if view then
            view:showMembers()
        end
    else
        GComErrorMsg(data.status)
    end
end

--组队排位赛匹配广播
function QualifierProxy:add8230204(data)
    if data.status == 0 then
        printt("组队匹配广播",data)
        local view = mgr.ViewMgr:get(ViewName.PwsTeamWarSendView)
        if data.reqType == 1 then--发起匹配
            if view then
                view:setData(data)
            else
                mgr.ViewMgr:openView(ViewName.PwsTeamWarSendView,function(view)
                    view:setData(data)
                end)
            end
        elseif data.reqType == 2 then--匹配中
            if view then
                view:closeView()
            end
            mgr.ViewMgr:openView2(ViewName.MatchingView, {type = 2})
        elseif data.reqType == 3 then--取消匹配
            local view = mgr.ViewMgr:get(ViewName.MatchingView)
            if view then
                local roleId = cache.PlayerCache:getRoleId()
                if data.captainRoleId == roleId then
                    proxy.QualifierProxy:sendMsg(1480205,{reqType = 2})
                end
                view:closeView()
            end
        elseif data.reqType == 4 then--拒绝匹配
            if view then
                view:closeView()
            end
            local teamInfo = cache.PwsCache:getTeamList()
            for k,v in pairs(teamInfo) do
                if data.roleId == v.roleId then
                    GComAlter(string.format(language.qualifier19,v.roleName))
                    break
                end
            end
        elseif data.reqType == 5 then--同意匹配
            if view then
                view:setData(data)
            else
                mgr.ViewMgr:openView(ViewName.PwsTeamWarSendView,function(view)
                    view:setData(data)
                end)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--组队排位匹配成功广播
function QualifierProxy:add8230205(data)
   if data.status == 0 then
        if data.reqType == 1 then
            print("匹配成功",data.sceneId)
            proxy.ThingProxy:send(1020101,{sceneId = data.sceneId,type = 3})
        else
            print("匹配失败",data.reqType)
        end
    else
        GComErrorMsg(data.status)
    end
end
--组队排位结算广播
function QualifierProxy:add8230206(data)
    if data.status == 0 then
        printt("组队排位结算广播",data)
        cache.PwsCache:setTeamOverData(data)
        data.isPlayoff = false
        local view = mgr.ViewMgr:get(ViewName.MatchingView)
        if view then
            view:closeView()
        end
        mgr.ViewMgr:openView2(ViewName.PwsOverAwards, data)
    else
        GComErrorMsg(data.status)
    end
end
--组队排位赛血量广播
function QualifierProxy:add8230207(data)
    if data.status == 0 then
        -- printt("血量更新广播",data)
        local view = mgr.ViewMgr:get(ViewName.RankProceedView)
        if view then
            view:refreshHpInfo(data)
        end
        local myHp = cache.PwsCache:getMyHp()
        local roleId = cache.PlayerCache:getRoleId()
        local newHp = 100
        local isOver = true
        for k,v in pairs(data.hpInfos) do
            if roleId == v.roleId then
                newHp = v.hp
            end
            if v.hp ~= 0 and data.teamId == v.teamId then
                -- print("有活人")
                isOver = false
            end
        end
        if myHp ~= 0 then
            cache.PwsCache:setMyHp(newHp)
            if newHp == 0 and not isOver then
                mgr.ViewMgr:openView2(ViewName.PwsDeadTipsView, {})
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--季后赛排位信息
function QualifierProxy:add5480301(data)
    if data.status == 0 then
        printt("季后赛信息返回",data)
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--季后赛场景信息
function QualifierProxy:add5480302(data)
    if data.status == 0 then
        printt("季后赛场景信息",data)
        cache.PwsCache:setTeamId(data.teamId)
        local netTime = data.curTime--mgr.NetMgr:getServerTime()
        local delayTime = conf.QualifierConf:getValue("jhs_ready_sec")
        local readyTime = data.startTime + delayTime
        local dTime = netTime - readyTime
        print("时间间隔",dTime,readyTime,netTime,data.startTime)
        if dTime >= 0 and dTime < 5 then
            mgr.ViewMgr:openView2(ViewName.StartGoView,{time = 5 - dTime})
            mgr.TimerMgr:addTimer(5 - dTime, 1, function()
                -- if not mgr.HookMgr.isHook then
                --     mgr.HookMgr:enterHook()--开始挂机
                -- end
            end)
        else
            if dTime < 0 then
                GComAlter("准备时间")
            else
                mgr.TimerMgr:addTimer(1, 1, function()
                    -- if not mgr.HookMgr.isHook then
                    --     mgr.HookMgr:enterHook()--开始挂机
                    -- end
                end)
            end
        end
        --场景类型
        data.type = 3
        local view = mgr.ViewMgr:get(ViewName.RankProceedView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.RankProceedView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--季后赛押注
function QualifierProxy:add5480303(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PayoffRankAwardsView)
        if view then
            view:setGuessData(data)
        end
        --季后赛竞猜红点
        if data.stage == 0 then--暂未开始
            cache.PlayerCache:setRedpoint(attConst.A50123,0)
        elseif data.stage == 1 then--押注阶段
            print("押注阶段")
            if data.stakeCount > 0 or (data.stakes and #data.stakes <= 0) then
                cache.PlayerCache:setRedpoint(attConst.A50123,0)
            end
        elseif data.stage == 2 then--领奖阶段
            local flag = false
            for k,v in pairs(data.stakes) do
                if data.winTeamId == v.teamId and v.myStake > 0 and v.awardSign ~= 1 then
                    flag = true
                    break
                end
            end
            if not flag then
                cache.PlayerCache:setRedpoint(attConst.A50123,0)
            end
        end
        print("季后赛竞猜红点",cache.PlayerCache:getRedPointById(attConst.A50123))
        mgr.GuiMgr:updateRedPointPanels(attConst.A50123)
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view and view.PanelRanking then
            view.PanelRanking:refreshRed()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求季后赛玩家位置信息
function QualifierProxy:add5480304(data)
    -- body
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
        if mgr.HookMgr.isHook then
            mgr.HookMgr:setHookData(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

--季后赛每场广播
function QualifierProxy:add8230301(data)
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
        
        local view = mgr.ViewMgr:get(ViewName.RankProceedView)
        if view then
            view:setRound(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--季后赛结算广播
function QualifierProxy:add8230302(data)
    if data.status == 0 then
        printt("季后赛结算广播",data)
        data.isPlayoff = true
        local view = mgr.ViewMgr:get(ViewName.MatchingView)
        if view then
            view:closeView()
        end
        mgr.ViewMgr:openView2(ViewName.PwsOverAwards, data)
    else
        GComErrorMsg(data.status)
    end
end

return QualifierProxy