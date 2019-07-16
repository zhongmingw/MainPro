--
-- Author: 
-- Date: 2018-07-27 14:40:05
--

local NearPlayer = class("NearPlayer", base.BaseView)

function NearPlayer:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function NearPlayer:initView()
    local btnclose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnclose)

    self.listView =  self.view:GetChild("n1")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.onClickItem:Add(self.onCallBack,self)
    self.listView.numItems = 0

    self.panle = self.view:GetChild("n0")
end

function NearPlayer:celldata(index, obj)
    -- body
    local data = self.data[index+1]
    local c1 = obj:GetController("c1")
    local lab = obj:GetChild("n8")
    if not data  then
        c1.selectedIndex = 1
        obj:GetChild("n5").text = language.near01

        obj.touchable = false
    else
        c1.selectedIndex = 0
        obj:GetChild("n4").text = data.roleName

        lab.max = data.attris[105] or 100
        lab.value = data.attris[104] or 100

        obj.touchable = true
    end
    
    
    --print(data.roleName,lab.value)
    obj.data = data 
end

function NearPlayer:onCallBack( context)
    -- body
    local data = context.data.data
    if not data then
        return
    end
    self.selectdata = data 
    mgr.FightMgr:fightByTarget2(data)
    self:closeView()
end

function NearPlayer:isJQR(roleId)
    -- body
    if tonumber(roleId)<10000 then
        return true
    end
    return false
end

function NearPlayer:initData()
    local data = mgr.ThingMgr:objsByType(ThingType.player) or {}
    self.data = {}
    for k , v in pairs(data) do
        local player = mgr.ThingMgr:getObj(ThingType.player,k)
        if player and not self:isJQR(player.data.roleId) then
            table.insert(self.data,clone(player.data))
        end
    end
    self:setData()
end

function NearPlayer:addData( data )
    -- body
    local flag = true
    for k ,v in pairs(self.data) do 
        if v.roleId == data then
            flag = false
            break
        end
    end
    if flag then
        local player = mgr.ThingMgr:getObj(ThingType.player,data)
        if player and not self:isJQR(player.data.roleId) then
            table.insert(self.data,clone(player.data))
        end
        self:setData()
    end
end

function NearPlayer:removeData( data )
    -- body
    for k ,v in pairs(self.data) do 
        if v.roleId == data then
            table.remove(self.data,k)
            break
        end
    end
    self:setData()
end

function NearPlayer:setData()
    -- body
    --self.listView:SelectNone()
    self.listView.numItems = math.max(#self.data,1)

    local target = mgr.FightMgr.fuji_target

    if target and mgr.ThingMgr:getObj(ThingType.player, target.data.roleId) then
        for k , v in pairs(self.data) do
            if v.roleId == target.data.roleId then
                self.listView:AddSelection(k-1,false)
                break
            end
        end
    end

    if 1 == self.listView.numItems then
        self.panle.height = 91
    else
        self.panle.height = 340
    end
end

function NearPlayer:refreshHp( data )
    -- body
    for k ,v in pairs(self.data) do 
        if v.roleId == data.roleId then
            self.data[k].attris = data.attris
            break
        end
    end
    self.listView:RefreshVirtualList()
end

return NearPlayer