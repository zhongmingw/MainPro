--
-- Author: ohf
-- Date: 2017-03-27 12:05:06
--
--离线经验
local OfflinePanel = class("OfflinePanel",import("game.base.Ref"))

function OfflinePanel:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function OfflinePanel:initPanel()
    self.confData = conf.ActivityConf:getOfflineAward()
    self.listView =  self.panelObj:GetChild("n7")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    local desc = self.panelObj:GetChild("n9")
    desc.text = language.welfare02

    self.timeList = {}
    for i=4,6 do--离线时间
        local time = self.panelObj:GetChild("n"..i)
        table.insert(self.timeList, time)
    end
end
--请求数据
function OfflinePanel:sendMsg()
    proxy.ActivityProxy:send(1030104)
end
--离线时间
function OfflinePanel:setData(data)
    local affectLv1 = cache.PlayerCache:VipIsActivate(2)--黄金
    local affectLv2 = cache.PlayerCache:VipIsActivate(3)--钻石
    self.tequanNum = 0
    if affectLv1 then--激活了黄金
        self.tequanNum = 1
    end
    if affectLv2 then--激活了钻石
        self.tequanNum = 2
    end

    self.sumOutLineTime = data and data.sumOutLineTime or 0
    self.gotExp = data and data.gotExp or 0
    self:onTimer()
    self.listView.numItems = #self.confData
end
--离线经验
function OfflinePanel:cellData(index, cell)
    local data = self.confData[index + 1]
    local icon = cell:GetChild("n6")
    icon.url = UIPackage.GetItemURL("welfare" , data.font)
    local viplv = cache.PlayerCache:getVipLv()--自己的vip
    local vip_affect = data.vip_affect or 0--需要vip
    local expText = cell:GetChild("n8")
    expText.text = data.times * self.gotExp

    local vipDesc = cell:GetChild("n9")

    local getBtn = cell:GetChild("n4")--领取按钮
    getBtn.data = data
    getBtn.visible = false
    getBtn.onClick:Add(self.onClickGet,self)

    local arleayImg = cell:GetChild("n5")--已领取
    arleayImg.visible = false
    if self.gotExp == 0 or self.sumOutLineTime <= 0  then
        getBtn.enabled = false
    else
        getBtn.enabled = true
    end
    local isL = false
    if self.gotExp > 0 and self.sumOutLineTime > 0 then
        isL = true
    end
    if self.tequanNum == 0 then
        if index == 0 then
            getBtn.visible = true
            vipDesc.visible = false
            vipDesc.text = ""
        else
            getBtn.visible = false
            vipDesc.visible = true
            vipDesc.text = language.vip20[vip_affect]..language.welfare04
        end
    elseif self.tequanNum == 1 then--只是激活了黄金
        if index >= 0 and index <= 1 then
            getBtn.visible = true
            vipDesc.visible = false
            vipDesc.text = ""
            if index == 1 and isL then
                getBtn.enabled = true
            else
                getBtn.enabled = false
            end
        else
            getBtn.visible = false
            vipDesc.visible = true
            vipDesc.text = language.vip20[vip_affect]..language.welfare04
        end
    elseif self.tequanNum == 2 then--激活了钻石
        if index >= 0 then
            getBtn.visible = true
            vipDesc.visible = false
            vipDesc.text = ""
            if index == 2 and isL then
                getBtn.enabled = true
            else
                getBtn.enabled = false
            end
        end
    end
end

function OfflinePanel:onTimer()
    local dTime = GGetTimeData(self.sumOutLineTime)
    for k,v in pairs(self.timeList) do
        if k == 1 then
            v.text = string.format("%02d", dTime.hour)
        elseif k == 2 then
            v.text = string.format("%02d", dTime.min)
        elseif k == 3 then
            v.text = string.format("%02d", dTime.sec)
        end
    end
end

function OfflinePanel:setVisible(visible)
    self.panelObj.visible = visible
end

function OfflinePanel:onClickGet(context)
    local cell = context.sender
    local data = cell.data
    proxy.ActivityProxy:send(1030104,{reqType = data.id})
end

return OfflinePanel