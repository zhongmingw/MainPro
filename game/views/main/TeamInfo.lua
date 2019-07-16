--
-- Author: wx
-- Date: 2017-01-17 14:55:14
--

local TeamInfo = class("TeamInfo",import("game.base.Ref"))

function TeamInfo:ctor(param)
    self.listView = param
    self:initView()
end

function TeamInfo:initView()
    self.listView.itemRenderer = function(index,obj)
        self:cellTeamData(index, obj)
    end
    self.listView.onClick:Add(self.onClickTeam,self)
end

function TeamInfo:setData()
    -- body
    self.mRoleData = cache.TeamCache:getTeamMembers()
    local isNotTeam = cache.TeamCache:getIsNotTeam()
    local len = #self.mRoleData
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if isNotTeam then
        local trackView = mgr.ViewMgr:get(ViewName.TrackView)
        if trackView then
            if trackView:getIsHaveTeam() then
                view:setTeamBtnVisible(true)
            end
        else
            view:setTeamBtnVisible(true)
        end
    else
        view:setTeamBtnVisible(false)
    end
    self.listView.numItems = len
end

function TeamInfo:cellTeamData(index,obj)
    local data = self.mRoleData[index + 1]
    obj.data = data
    if data and data.roleId then
        obj.visible = true
        --头像
        local roleIcon = obj:GetChild("n2")
        local playerData = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
            if roleIcon then
                roleIcon.url = t.headUrl
            end
        end)
        roleIcon.url = playerData.headUrl
        --进度条
        local hp = data.hp
        local maxHp = data.maxHp
        local progressbar = obj:GetChild("n5")
        local max = maxHp
        progressbar.value = hp
        progressbar.max = max
        --
        local roleLevel = obj:GetChild("n6")
        roleLevel.text = data.level --EVE string.format(language.team01,data.level)
        --
        local roleName = obj:GetChild("n7")
        roleName.text = data.roleName

        local captain = obj:GetChild("n4")
        if data.captain == 1 then
            captain.visible = true
        else
            captain.visible = false
        end
    else
        obj.visible = false
    end
end

function TeamInfo:refMyTeamData()
    for i=1,self.listView.numItems do
        local obj = self.listView:GetChildAt(i - 1)
        if obj then
            local data = obj.data
            if data and data.roleId then
                if data.roleId == cache.PlayerCache:getRoleId() then
                    data.level = cache.PlayerCache:getRoleLevel()
                    local roleLevel = obj:GetChild("n6")
                    roleLevel.text = data.level
                    break
                end
            end
        end
    end
end

function TeamInfo:clear()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    view:setTeamBtnVisible(true)
    self.listView.numItems = 0
end

function TeamInfo:onClickTeam()
    local isNotTeam = cache.TeamCache:getIsNotTeam()
    local sId = cache.PlayerCache:getSId()
    local isOpen = false
    if mgr.FubenMgr:isLevel(sId) then
        if not isNotTeam then
            isOpen = true
        end
    else
        isOpen = true
    end
    if isOpen then
        mgr.ViewMgr:openView2(ViewName.TeamView,{index = 1})
    end
end

return TeamInfo