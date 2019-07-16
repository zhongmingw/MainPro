--
-- Author: ohf
-- Date: 2017-03-28 15:23:54
--
--队伍角色信息
local TeamRolePanel = class("TeamRolePanel",import("game.base.Ref"))

function TeamRolePanel:ctor(mParent,panel,index)
    self.mParent = mParent
    self.panelObj = panel
    self.index = index
    self:initPanel()
end

function TeamRolePanel:initPanel()
    self.captainIcon = self.panelObj:GetChild("n1")
    self.captainIcon.visible = false

    self.model = self.panelObj:GetChild("n5")

    self.touchPanel = self.panelObj:GetChild("n13")
    self.touchPanel.onClick:Add(self.onClickRole,self)

    self.powerText = self.panelObj:GetChild("n4")
    self.powerText.text = ""
    self.nameText = self.panelObj:GetChild("n9")
    self.nameText.text = ""

    self.unlineImg = self.panelObj:GetChild("n14")
    local btn = self.panelObj:GetChild("n6")
    btn.onClick:Add(self.onClickTeam,self)
end
--设置角色信息
function TeamRolePanel:setRoleData(data)
    local c1 = self.panelObj:GetController("c1")
    self.captainIcon.visible = false
    self.data = data
    if data and data.roleId then
        c1.selectedIndex = 0
        self.powerText.text = data.power
        self.nameText.text = data.roleName--角色名字
        if data.captain == 1 then--1队长,否则普通队员
            self.captainIcon.visible = true
        else
            self.captainIcon.visible = false
        end
        self:setModel(data.skinMap)
        self:refOnlineState(data)
    else
        if c1 then
            if cache.TeamCache:getIsNotTeam() then
                c1.selectedIndex = 0
            else
                c1.selectedIndex = 1
            end
        end
        self:clear()
        self.powerText.text = ""
        self.nameText.text = ""
        self.unlineImg.visible = false
    end
end
--刷新离线状态
function TeamRolePanel:refOnlineState(data)
    if not data.roleId then 
        self.unlineImg.visible = false
        return
    end
    if data.online == 1 then
        self.unlineImg.visible = false
    else
        self.unlineImg.visible = true
    end
end
--设置模型
function TeamRolePanel:setModel(data)
    self.skins1 = data[Skins.clothes]
    self.skins2 = data[Skins.wuqi]
    self.skins3 = data[Skins.xianyu]
    local modelObj = self.mParent:addModel(self.skins1,self.model)
    modelObj:setSkins(nil,self.skins2,self.skins3)
    self.modelObj = modelObj
    local sex = GGetMsgByRoleIcon(self.data.roleIcon).sex
    modelObj:setPosition(self.model.actualWidth/2 + 10,-self.model.actualHeight-200,500)
    modelObj:setRotation(RoleSexModel[sex].angle)
    modelObj:setScale(130)
end

--打开邀请组队
function TeamRolePanel:onClickTeam()
    if GGetisOperationTeam() == Team.fubenType1 then
        GComAlter(language.team64)
        return
    end
    mgr.ViewMgr:openView(ViewName.TeamSearchView, function(view)
        view:onController1()
    end)
end

function TeamRolePanel:onClickRole()
    local posList = {
        [1] = {0,60},
        [2] = {249,60},
        [3] = {500,60},
    }
    -- local pos = self.touchPanel:LocalToGlobal(self.touchPanel.xy)
    local pos = posList[self.index]
    if self.data and self.data.roleId and self.data.roleId ~= cache.PlayerCache:getRoleId() then
        local params = {roleId = self.data.roleId,roleName = self.data.roleName,level = self.data.level,captain = self.data.captain,teamId = self.data.teamId,pos = {x = pos[1],y = pos[2]},roleIcon = self.data.roleIcon,trade = true}
        mgr.ViewMgr:openView(ViewName.FriendTips,function(view)
            view:setData(params)
        end)
    end
end

function TeamRolePanel:clear()
    if self.modelObj then
        self.mParent:removeModel(self.modelObj)
    end
    self.modelObj = nil
end

return TeamRolePanel