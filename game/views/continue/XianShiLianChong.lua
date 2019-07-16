--
-- Author: 
-- Date: 2018-08-28 14:41:30
--

local XianShiLianChong = class("XianShiLianChong", base.BaseView)

function XianShiLianChong:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XianShiLianChong:initView()
    local closeBtn = self.view:GetChild("n1"):GetChild("n7")
    self:setCloseBtn(closeBtn)
 
    local chargeBtn = self.view:GetChild("n19")
    chargeBtn.onClick:Add(self.onClickCharge,self)
    
    self.lastTime = self.view:GetChild("n22")
    self.dayCz = self.view:GetChild("n10")
    self.reachDay = self.view:GetChild("n12")

    self.listView = self.view:GetChild("n6")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    --奖励展示
    self.awardList = self.view:GetChild("n7"):GetChild("n4")
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList:SetVirtual()
    --特殊奖励
    self.specialAward = self.view:GetChild("n24")
    self.specialAward.itemRenderer = function(index,obj)
        self:cellSpecialData(index, obj)
    end

    self.getBtn = self.view:GetChild("n18")
    self.getBtn.onClick:Add(self.onClickGetAwards,self)

    self.titleIcon = self.view:GetChild("n1"):GetChild("icon")
end


function XianShiLianChong:initAward()
    -- self.showAward = conf.ActivityConf:getValue("xslc_show_award")

    self.conf = conf.ActivityConf:getXslcConByType(2,self.mulConfData.award_pre)
    self.specialAward.numItems = #self.conf[1].item
    local day = self.conf[1].day
    self.view:GetChild("n14").text = string.format(language.xslc03,day)
    
end

function XianShiLianChong:setData(data)
    self.data = data
    printt("限时连冲",data)
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "xianshilianchong_001"
    self.titleIcon.url = UIPackage.GetItemURL("continue" , titleIconStr)
    self.showAward = conf.ActivityConf:getMulactiveshow(self.data.mulActId).awards
    self.awardList.numItems = #self.showAward
    self:initAward()
    self.time = data.actLeftTime
    --今日充值
    self.dayCz.text = data.dayCzSums[data.curDay] or 0
    --达标天数
    self.reachDay.text = data.okDay
   --连续目标奖励标识>0:已领取
    if data.targetGotSign > 0 then
        self.view:GetChild("n25").visible = true
        self.getBtn.visible = false
    else
        self.view:GetChild("n25").visible = false
        self.getBtn.visible = true
    end
    if self.data.okDay >= self.conf[1].day then
        self.getBtn.grayed = false
    else
        self.getBtn.grayed = true
    end
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    self.awardConfData = conf.ActivityConf:getXslcConByType(1,self.mulConfData.award_pre)
    self.listView.numItems = #self.awardConfData

    
end

function XianShiLianChong:cellData(index, obj)
    local data = self.awardConfData[index+1]
    local day = obj:GetChild("n5")
    local title = obj:GetChild("n6")
    local awardList = obj:GetChild("n7")
    local c1 = obj:GetController("c1")
    local getBtn = obj:GetChild("n8")
    getBtn.onClick:Add(self.getDayAward,self)
    if data then
        getBtn.data = data.id
        GSetAwards(awardList, data.item)
        day.text = string.format(language.xslc01,data.day)
        title.text = string.format(language.xslc02,tonumber(data.quota))

        if self.data.gotSigns[data.id] and self.data.gotSigns[data.id] == 1 then
            c1.selectedIndex = 2--已领取
        else
            local dayCzSum = self.data.dayCzSums[data.day]--每天的充值额度
            if dayCzSum and dayCzSum >= data.quota then
                c1.selectedIndex = 1--可领取
            else
                if data.day < self.data.curDay then
                    c1.selectedIndex = 3--已过期
                else
                    c1.selectedIndex = 0--未达成
                end
            end
        end
    end
end

function XianShiLianChong:getDayAward(context)
    local data = context.sender
    local id = data.data
    if data.grayed then
        GComAlter(language.active32)
    else
        if not self.data.gotSigns[id] then
            proxy.ActivityProxy:sendMsg(1030517,{reqType = 1,cfgId = id})
        end
    end
end

function XianShiLianChong:onClickGetAwards()
    if self.getBtn.grayed then
        GComAlter(language.active32)
    else
        proxy.ActivityProxy:sendMsg(1030517,{reqType = 2,cfgId = self.conf[1].id})
    end
end

--奖励展示
function XianShiLianChong:cellAwardData(index, obj)
    local data = self.showAward[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end
--连冲奖励
function XianShiLianChong:cellSpecialData(index, obj)
    local data = self.conf[1].item[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end

function XianShiLianChong:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function XianShiLianChong:onTimer()
    self.lastTime.text = GGetTimeData2(self.time)
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end

function XianShiLianChong:onClickCharge()
    GGoVipTequan(0)
    self:closeView()
end

return XianShiLianChong