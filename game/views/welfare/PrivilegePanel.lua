--
-- Author: ohf
-- Date: 2017-03-27 12:05:32
--
--仙尊特权区域
local PrivilegePanel = class("PrivilegePanel",import("game.base.Ref"))

local privilegeTypes = {
    [0] = 1,--普通领取
    [1] = 2,--白银领取
    [2] = 3,--黄金领取
    [3] = 4,--钻石领取
}

function PrivilegePanel:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function PrivilegePanel:initPanel()
    self.privilegeList = {}
    for i=3,6 do
        local privilege = self.panelObj:GetChild("n"..i)
        table.insert(self.privilegeList, privilege)
    end
end
--请求数据
function PrivilegePanel:sendMsg()
    proxy.ActivityProxy:send(1030105,{reqType = 0})
end

function PrivilegePanel:setData(data)
    self.gotStateList = data.gotStateList
    self.confData = conf.ActivityConf:getAllPrivilege(data.day)
    for k,data in pairs(self.confData) do
        self:setPrivilegeData(data)
    end
end
--仙尊奖励
function PrivilegePanel:setPrivilegeData(data)
    local item = self.privilegeList[data.type]
    local awards = data.awards
    local awardsList = item:GetChild("n1")
    awardsList.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
    awardsList.numItems = #awards

    local getBtn = item:GetChild("n2")
    getBtn.visible = true
    getBtn.data = data
    getBtn.onClick:Add(self.onClickGet,self)

    local redPoint = getBtn:GetChild("red")
    local num = data.privilege or 0
    local privilege = tonumber(num)
    local isStage = cache.PlayerCache:VipIsActivate(privilege)
    if privilege == 1 and isStage then
        local curTime = cache.VipChargeCache:getXianzunTyTime()
        if curTime then --体验中
            -- print("现在是存在白银体验时间",curTime)
            isStage = false
        end
    end
    if isStage and privilege > 0 then--判断是否激活了特权
        redPoint.visible = true
    else
        if privilege == 0 then
            redPoint.visible = true
        else
            redPoint.visible = false
        end
    end

    local arleayImg = item:GetChild("n3")
    arleayImg.visible = false
    if self:isGot(data.type) then
        arleayImg.visible = true
        getBtn.visible = false
    end
end

function PrivilegePanel:isGot(type)
    for k,v in pairs(self.gotStateList) do
        if type == v then
            return true
        end
    end
end

function PrivilegePanel:setVisible(visible)
    self.panelObj.visible = visible
end

function PrivilegePanel:onClickGet(context)
    local cell = context.sender
    local data = cell.data
    local num = data.privilege or 0
    local privilege = tonumber(num)
    local isStage = cache.PlayerCache:VipIsActivate(privilege)
    if privilege == 1 and isStage then
        local curTime = cache.VipChargeCache:getXianzunTyTime()
        if curTime then --体验中
            -- print("因为现在是白银体验时间",curTime)
            isStage = false
        end
    end
    if isStage and privilege > 0 then--判断是否激活了特权
        proxy.ActivityProxy:send(1030105,{reqType = privilegeTypes[privilege]})
    else
        if privilege == 0 then
            proxy.ActivityProxy:send(1030105,{reqType = privilegeTypes[privilege]})
        else
            local param = {type = 14,richtext = language.welfare03[privilege],sure = function()
                GOpenView({id = 1050})
            end}
            GComAlter(param)
        end
    end
end

return PrivilegePanel