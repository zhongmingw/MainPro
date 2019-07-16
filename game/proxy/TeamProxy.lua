--
-- Author: ohf
-- Date: 2017-03-28 14:52:11
--
--组队系统
local TeamProxy = class("TeamProxy",base.BaseProxy)

local normalType = Team.normalType
local capType = Team.capType

function TeamProxy:init()
    self:add(5300101,self.add5300101)--请求附件队伍列表
    self:add(5300102,self.add5300102)--请求我的队伍信息
    self:add(5300103,self.add5300103)--请求邀请玩家列表
    self:add(5300104,self.add5300104)--请求创建队伍
    self:add(5300105,self.add5300105)--请求邀请玩家进入队伍
    self:add(5300106,self.add5300106)--请求应允邀请
    self:add(5300107,self.add5300107)--请求退出队伍
    self:add(5300108,self.add5300108)--请求踢出队伍
    self:add(5300109,self.add5300109)--请求转让队长
    self:add(5300110,self.add5300110)--请求设置组队状态
    self:add(5300111,self.add5300111)--请求申请入队
    self:add(5300112,self.add5300112)--请求同意申请入队
    self:add(5300113,self.add5300113)--请求快速加入队伍
    self:add(5300114,self.add5300114)--请求队伍等级调整

    self:add(8080101,self.add8080101)--队伍广播
    self:add(8080102,self.add8080102)--队伍新成员加入
    self:add(8080103,self.add8080103)--广播队伍信息
    self:add(8080104,self.add8080104)--队伍创建广播
    self:add(8080105,self.add8080105)--队伍操作广播
    self:add(8080106,self.add8080106)--队伍在线状态广播
end
--请求附件队伍列表
function TeamProxy:add5300101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TeamView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求我的队伍信息
function TeamProxy:add5300102(data)
    if data.status == 0 then
        cache.TeamCache:setTeamLv(data.minLvl,data.maxLvl)
        cache.TeamCache:setTeamMembers(data.teamMembers)
        local view = mgr.ViewMgr:get(ViewName.TeamView)
        if view then
            view:setData(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.DujieView)
        if view2 then
            --请求队员准备状态
            proxy.ImmortalityProxy:sendMsg(1290203)
        end
        self:refreshMainTeam()
    else
        GComErrorMsg(data.status)
    end
end
--请求邀请玩家列表
function TeamProxy:add5300103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TeamSearchView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求创建队伍
function TeamProxy:add5300104(data)
    if data.status == 0 then
        self:sendRefreshView()
    else
        GComErrorMsg(data.status)
    end
end
--请求邀请玩家进入队伍
function TeamProxy:add5300105(data)
    if data.status == 0 then
        GComAlter(language.team18)
    else
        GComErrorMsg(data.status)
    end
end
--请求应允邀请
function TeamProxy:add5300106(data)
    if data.status == 0 then
        cache.TeamCache:clearInvitation(capType)--
        self:sendRefreshView()
    else
        GComErrorMsg(data.status)
    end
end
--请求退出队伍
function TeamProxy:add5300107(data)
    if data.status == 0 then
        cache.TeamCache:clearTeamList()
        cache.TeamCache:dispose()
        local view = mgr.ViewMgr:get(ViewName.TeamView)
        if view then
            view:onController1()
        else
            proxy.TeamProxy:send(1300102)
        end
        self:refreshMainTeam()
    else
        GComErrorMsg(data.status)
    end
end
--请求踢出队伍
function TeamProxy:add5300108(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DujieView)
        if view then
            view:setIsDujie(false)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求转让队长
function TeamProxy:add5300109(data)
    if data.status == 0 then
    else
        GComErrorMsg(data.status)
    end
end
--请求设置组队状态
function TeamProxy:add5300110(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TeamView)
        if view then
            view:updateState(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求申请入队
function TeamProxy:add5300111(data)
    if data.status == 0 then
        GComAlter(language.bangpai13)
    else
        GComErrorMsg(data.status)
    end
end
--请求同意申请入队
function TeamProxy:add5300112(data)
    if data.status == 0 then
        cache.TeamCache:clearInvitation(normalType)--
        self:sendRefreshView()
    else
        GComErrorMsg(data.status)
    end
end
--请求快速加入队伍
function TeamProxy:add5300113(data)
    if data.status == 0 then
        self:sendRefreshView()
    else
        GComErrorMsg(data.status)
    end
end
--请求队伍等级调整
function TeamProxy:add5300114(data)
    -- printt("请求队伍等级调整",data)
    if data.status == 0 then
        -- self:sendRefreshView()
    else
        GComErrorMsg(data.status)
    end
end
--1邀请入队2同意邀请3拒绝邀请4申请入队5同意申请6拒绝申请
function TeamProxy:add8080101(data)
    if data.status == 0 then
        if data.reqType == 1 then
            cache.TeamCache:setTeamInvitation2(data)
            if cache.TeamCache:getTeamMemberNum() <= 0 then
                self:refreshTipView(capType,data)
            end
        elseif data.reqType == 2 then
            proxy.TeamProxy:send(1300102)
        elseif data.reqType == 3 then
            GComAlter(string.format(language.team39, data.roleName))
        elseif data.reqType == 4 then
            cache.TeamCache:setTeamInvitation1(data)
            if cache.TeamCache:getTeamMemberNum() < Team.maxNum then
                self:refreshTipView(normalType,data)
            end
        elseif data.reqType == 5 then
            proxy.TeamProxy:send(1300102)
        elseif data.reqType == 6 then
            GComAlter(string.format(language.team40, data.roleName))
        end
    else
        GComErrorMsg(data.status)
    end
end
--队伍新成员加入
function TeamProxy:add8080102(data)
    if data.status == 0 then
        cache.TeamCache:addTeamMembers(data.member)
        local view = mgr.ViewMgr:get(ViewName.TeamView)
        if view then
            view:nextStep(1)
        else
            proxy.TeamProxy:send(1300102)
        end
        local view2 = mgr.ViewMgr:get(ViewName.TeamWarSendView)
        if view2 then
            view2:closeView()
        end
        self:refreshMainTeam()
    else
        GComErrorMsg(data.status)
    end
end
--广播队伍信息
function TeamProxy:add8080103(data)
    if data.status == 0 then
        cache.TeamCache:clearTeamList()
        cache.TeamCache:setTeamLv(data.minLvl,data.maxLvl)
        cache.TeamCache:setTeamMembers(data.members)
        local view = mgr.ViewMgr:get(ViewName.TeamView)
        if view then
            if data.teamId == cache.TeamCache:getTeamId() then
                view:nextStep(1)
            else
                view:onController1()
            end
        end
        self:refreshMainTeam()
        -- print("广播队伍信息")
        -- printt(data)
        local view = mgr.ViewMgr:get(ViewName.DujieView)
        if view then
            if data.teamId == 0 then
                view:onCloseView()
            else
                proxy.ImmortalityProxy:sendMsg(1290203)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--队伍附件的人广播
function TeamProxy:add8080104(data)
    if data.status == 0 then
        if data.roleId == gRole:getID() then--自己
            gRole.data.teamId = data.teamId
            gRole.data.teamCaptain = data.teamCaptain
        else
            local player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
            if player then
                player.data.teamId = data.teamId
                player.data.teamCaptain = data.teamCaptain
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--type 1.来自别人的申请，2.来自别人的邀请
function TeamProxy:refreshTipView(type,data)
    local len = #cache.TeamCache:getTeamInvitation(type)
    if len > 0 then--如果队列大于0
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            data.type = type
            view:setTeamJoin(data)
        end 
    end
end

function TeamProxy:refreshMainTeam()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:setTeamData()
    end
    local view = mgr.ViewMgr:get(ViewName.TeamSearchView)
    if view then
        view:onController1()
    end
end

function TeamProxy:sendRefreshView()
    local view = mgr.ViewMgr:get(ViewName.TeamView)
    if view then
        view:onController1()
    else
        proxy.TeamProxy:send(1300102)
    end
end
--队伍操作广播
function TeamProxy:add8080105(data)
    -- printt("队伍操作广播",data)
    if data.status == 0 then
        if data.reqType == 4 then--等级区间不足
            GComAlter(string.format(language.team52, data.roleName))
            return
        elseif data.reqType == 5 then--某某在特殊场景
            GComAlter(string.format(language.team61, data.roleName))
            return
        elseif data.reqType == 6 then--某某不在线
            GComAlter(string.format(language.team62, data.roleName))
            return
        elseif data.reqType == 7 then--某某在跨服组队中
            GComAlter(string.format(language.team65, data.roleName))
            return
        end
        if cache.TeamCache:getTeamMemberNum() == 1 then--只有自己一个人的时候
            mgr.FubenMgr:gotoFubenWar(data.sceneId)
        else
            local view = mgr.ViewMgr:get(ViewName.TeamWarSendView)
            if view then
                view:setData(data)
            else
                mgr.ViewMgr:openView2(ViewName.TeamWarSendView, data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--队伍在线状态广播
function TeamProxy:add8080106(data)
    -- printt("队伍在线状态广播",data)
    if data.status == 0 then
        cache.TeamCache:updateOnlinePlayer(data)
        local view = mgr.ViewMgr:get(ViewName.TeamView)
        if view then
            view:refOnlineState()
        end
    else
        GComErrorMsg(data.status)
    end
end

return TeamProxy