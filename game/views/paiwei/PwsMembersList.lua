--
-- Author: Your Name
-- Date: 2018-01-30 16:15:09
--

local PwsMembersList = class("PwsMembersList", base.BaseView)

function PwsMembersList:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function PwsMembersList:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local cancelBtn = self.view:GetChild("n7")
    self:setCloseBtn(cancelBtn)
    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end

function PwsMembersList:cellData(index,obj)
    local data = self.members[index+1]
    if data then
        local c1 = obj:GetController("c1")
        c1.selectedIndex = self.type-1
        local icon = obj:GetChild("n2"):GetChild("n0")
        local roleName = obj:GetChild("n3")
        icon.url = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
            if icon then icon.url = t.headUrl end
        end).headUrl
        roleName.text = data.roleName
        local kickBtn = obj:GetChild("n4")
        kickBtn.data = data
        kickBtn.onClick:Add(self.onClickKick,self)
        local transferBtn = obj:GetChild("n5")
        transferBtn.data = data
        transferBtn.onClick:Add(self.onClickTransfer,self)
    end
end

function PwsMembersList:onClickKick( context )
    local data = context.sender.data
    proxy.QualifierProxy:sendMsg(1480204,{teamId = self.teamId,reqType = 2,roleId = data.roleId})
end

function PwsMembersList:onClickTransfer( context )
    local data = context.sender.data
    proxy.QualifierProxy:sendMsg(1480204,{teamId = self.teamId,reqType = 1,roleId = data.roleId})
end

function PwsMembersList:initData(data)
    self.type = data.type--type 1 踢出队伍 2 转移队长
    local members = cache.PwsCache:getTeamList()
    local teamInfo = cache.PwsCache:getTeamInfo()
    self.teamId = teamInfo.teamId
    -- members
        -- roleId  说明：角色id
        -- roleName    说明：角色名字
        -- level   说明：等级
        -- power   说明：战力
        -- roleIcon    说明：头像
        -- skinMap 说明：外观
    self.members = {}
    local roleId = cache.PlayerCache:getRoleId()
    for k,v in pairs(members) do
        if roleId ~= v.roleId then
            table.insert(self.members,v)
        end 
    end
    self.listView.numItems = #self.members
end

return PwsMembersList