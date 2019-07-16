--
-- Author: ohf
-- Date: 2017-03-27 12:02:43
--
--在线奖励
local OnlinePanel = class("OnlinePanel",import("game.base.Ref"))

function OnlinePanel:ctor(mParent,panel)
    self.mParent = mParent
    self.panelObj = panel
    self:initPanel()
end

function OnlinePanel:initPanel()
    self.listView =  self.panelObj:GetChild("n7")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    self.timeList = {}
    for i=4,6 do--在线时间
        local time = self.panelObj:GetChild("n"..i)
        table.insert(self.timeList, time)
    end
end
--在线奖励
function OnlinePanel:cellData(index, cell)
    local data = self.confData[index + 1]
    local desc = cell:GetChild("n1")
    local onlineTime = data.online_time
    local min = math.floor(onlineTime / 60)
    desc.text = string.format(language.welfare01, min)

    local awards = data.awards
    local awardList = cell:GetChild("n2")
    awardList.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
    awardList.numItems = #awards

    local max = onlineTime
    local value = self.onlineTime
    local progress = cell:GetChild("n3")
    progress.max = max
    progress.value = value
    local timeText = progress:GetChild("title")
    timeText.text = GTotimeString(onlineTime - self.onlineTime)
    local getBtn = cell:GetChild("n4")
    getBtn.visible = false
    getBtn.data = data
    getBtn.onClick:Add(self.onClickGet,self)
    local arleayImg = cell:GetChild("n5")
    arleayImg.visible = false
    if value >= max then
        getBtn.visible = true
        progress.visible = false
    end
    if self:isGot(data.id) then
        arleayImg.visible = true
        getBtn.visible = false
        progress.visible = false
    end
end
--请求数据
function OnlinePanel:sendMsg()
    proxy.ActivityProxy:send(1030102,{reqType = 0,gotId = 0})
end

function OnlinePanel:setData(data)
    self.confData = conf.ActivityConf:getOnlineAward()
    -- printt(cache.ActivityCache:getLoopDay(),self.confData)
    self.onlineTime = data and data.onlineTime or 0
    self.gotList = data and data.gotList or {}
    self:onTimer()
    if not self.timer then
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function OnlinePanel:onTimer()
    local dTime = GGetTimeData(self.onlineTime)
    for k,v in pairs(self.timeList) do
        if k == 1 then
            v.text = string.format("%02d", dTime.hour)
        elseif k == 2 then
            v.text = string.format("%02d", dTime.min)
        elseif k == 3 then
            v.text = string.format("%02d", dTime.sec)
        end
    end
    self.onlineTime = self.onlineTime + 1
    self.listView.numItems = #self.confData
end

function OnlinePanel:isGot(id)
    for k,v in pairs(self.gotList) do
        if id == v then
            return true
        end
    end
end
--领取奖励
function OnlinePanel:onClickGet(context)
    local cell = context.sender
    local data = cell.data
    proxy.ActivityProxy:send(1030102,{reqType = 1,gotId = data.id})
end

function OnlinePanel:setVisible(visible)
    if not visible then
        if self.timer then
            self.mParent:removeTimer(self.timer)
            self.timer = nil
        end
    end
    self.panelObj.visible = visible
end

return OnlinePanel