--
-- Author: ohf
-- Date: 2017-03-28 15:06:18
--
local TeamCache = class("TeamCache",base.BaseCache)
--[[
组队缓存
--]]
local maxNum = 3

function TeamCache:init()
    self:dispose()
end

function TeamCache:dispose()
    self.teamMembers = {}--我的队伍
    self.isNotTeam = true--判断我有没有队伍
    self.teamInvitation1 = {}--队伍邀请
    self.teamInvitation2 = {}--队伍申请
    self.maxTeamNum = maxNum
    self.teamJoinList = {}
    self:clearTeamList()
    self.minLvl,self.maxLvl = 0,0
end

function TeamCache:setTeamLv(min,max)
    self.minLvl,self.maxLvl = min,max
end
--队伍等级
function TeamCache:getTeamLv()
    return self.minLvl,self.maxLvl
end
--我的队伍
function TeamCache:setTeamMembers(data)
    self.teamMembers = data or {}
    local len = #self.teamMembers
    if len == 0 then
        self.isNotTeam = true
    else
        self.isNotTeam = false
    end
    self.teamId = self.teamMembers[1] and self.teamMembers[1].teamId or 0
    table.sort(self.teamMembers,function(a,b)
        local acap = a.captain or 0
        local bcap = b.captain or 0
        return acap > bcap
    end)
    if len < maxNum then
        for i=1,maxNum - len do
            table.insert(self.teamMembers, {})
        end
    end
end
--返回队伍id
function TeamCache:getTeamId()
    return self.teamId or 0
end

function TeamCache:addTeamMembers(data)
    local num = self:getTeamMemberNum()
    if num < maxNum then
        for k,v in pairs(self.teamMembers) do
            if not v.roleId then
                self.teamMembers[k] = data
                break
            end
        end
        self.isNotTeam = false
    else
        self:clearInvitation(0,true)
    end
end

function TeamCache:getTeamMembers()
    return self.teamMembers
end
--刷新在线状态
function TeamCache:updateOnlinePlayer(data)
    for k,v in pairs(self.teamMembers) do
        if v.roleId == data.roleId then
            self.teamMembers[k].online = data.online
        end
    end
end
--判断我有没有队伍
function TeamCache:getIsNotTeam()
    return self.isNotTeam
end
--判断我的队伍的队员是不是队长
function TeamCache:getIsCaptain(roleId)
    if not self.isNotTeam then
        for k,v in pairs(self:getTeamMembers()) do
            if v.captain == 1 and roleId == v.roleId then 
                return true
            end
        end
    end
end
--来自别人的申请队列
function TeamCache:setTeamInvitation1(data)
    local num = self:getTeamMemberNum()
    if num < maxNum then
        table.insert(self.teamInvitation1, data)
    else
        self:clearInvitation(0,true)
    end
end
--来自别人的邀请队列
function TeamCache:setTeamInvitation2(data)
    local num = self:getTeamMemberNum()
    if num < maxNum then
        table.insert(self.teamInvitation2, data)
    else
        self:clearInvitation(0,true)
    end
end

function TeamCache:getTeamInvitation(type)
    if type == Team.normalType then
        return self.teamInvitation1
    else
        return self.teamInvitation2
    end
end

function TeamCache:clearInvitation(type,isClear)
    if isClear then--全部清除
        self.teamInvitation1 = {}
        self.teamInvitation2 = {}
    else--清除第一个
        if type == Team.normalType then--来自别人的申请队列
            table.remove(self.teamInvitation1,1)
        else--来自别人的邀请队列
            table.remove(self.teamInvitation2,1)
        end
        
    end
end
--返回我的队伍人数
function TeamCache:getTeamMemberNum()
    local num = 0 
    for k,v in pairs(self:getTeamMembers()) do--判断我的队伍是否满人
        if v and v.roleId then
            num = num + 1
        end
    end
    return num
end
--设置队伍申请或者邀请信息
function TeamCache:addJoinTeamList(data)
    local isFind = false
    for k,v in pairs(self.teamJoinList) do
        if v.roleId == data.roleId then
            self.teamJoinList[k] = data
            isFind = true
            break
        end
    end
    if not isFind then
        table.insert(self.teamJoinList, data)
    end
end

function TeamCache:clearTeamList()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:hideTeamJoin()
    end
    self.teamJoinList = {}
end

function TeamCache:removeTeamList(roleId)
    for k,v in pairs(self.teamJoinList) do
        if v.roleId == roleId then
            table.remove(self.teamJoinList,k)
            break
        end
    end
    if #self.teamJoinList <= 0 then
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:hideTeamJoin()
        end
    end
end

function TeamCache:getJoinTeamList()
    return self.teamJoinList
end

return TeamCache