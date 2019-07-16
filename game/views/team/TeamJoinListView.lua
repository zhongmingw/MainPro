--
-- Author: 
-- Date: 2017-11-27 15:50:02
--
--进入队伍列表
local TeamJoinListView = class("TeamJoinListView", base.BaseView)

function TeamJoinListView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function TeamJoinListView:initView()
    self.window = self.view:GetChild("n0")
    self:setCloseBtn(self.window:GetChild("n2"))
    local hlBtn = self.view:GetChild("n3")
    hlBtn.onClick:Add(self.onClickHl,self)
    self.listView = self.view:GetChild("n2")--邀请或者申请列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function TeamJoinListView:initData()
    self:setData()
end

function TeamJoinListView:setData(data)
    self.teamList = cache.TeamCache:getJoinTeamList()
    self.type = self.teamList[1].type
    self.window.icon = UIItemRes.team05[self.type]
    self.listView.numItems = #self.teamList
end

function TeamJoinListView:cellData(index,obj)
    local playerData = self.teamList[index + 1]
    obj:GetChild("n1").text = playerData.roleName
    local target = obj:GetChild("n3")
    if self.type == Team.capType then
        local targetId = playerData.targetId
        if targetId == 0 then
            targetId = 1
        end
        local confData = conf.TeamConf:getTeamConfig(targetId)
        local name = confData and confData.name or ""
        target.text = string.format(language.team68, name)
    else
        target.text = ""
    end
    obj:GetChild("n2").text = string.format(language.team67, playerData.power)
    local refuseBtn = obj:GetChild("n4")
    refuseBtn.data = playerData
    refuseBtn.onClick:Add(self.onClickRefuse,self)
    local refuseBtn = obj:GetChild("n5")
    refuseBtn.data = playerData
    refuseBtn.onClick:Add(self.onClickAgree,self)
end

--拒绝
function TeamJoinListView:onClickRefuse(context)
    local data = context.sender.data
    if self.type == Team.capType then
        self:send1300106(data.roleId,2)
    else
        self:send1300112(data.roleId,2)
    end
    self:closeView()
end
--同意
function TeamJoinListView:onClickAgree(context)
    local data = context.sender.data
    if self.type == Team.capType then
        self:send1300106(data.roleId,1)
    else
        self:send1300112(data.roleId,1)
    end
    self:closeView()
end

--目标玩家id  1同意2拒绝
function TeamJoinListView:send1300106(tarRoleId,reqType)
    cache.TeamCache:removeTeamList(tarRoleId)
    proxy.TeamProxy:send(1300106,{tarRoleId = tarRoleId,reqType = reqType})
end

function TeamJoinListView:send1300112(tarRoleId,reqType)
    cache.TeamCache:removeTeamList(tarRoleId)
    proxy.TeamProxy:send(1300112,{tarRoleId = tarRoleId,reqType = reqType})
end

function TeamJoinListView:onClickHl()
    cache.TeamCache:clearTeamList()
    self:closeView()
end

return TeamJoinListView