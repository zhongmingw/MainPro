--
-- Author: 
-- Date: 2018-08-20 17:13:42
--连消特惠

local ContinueCost = class("ContinueCost", base.BaseView)

function ContinueCost:ctor()
    ContinueCost.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ContinueCost:initView()
    local closeBtn = self.view:GetChild("n10")
    self:setCloseBtn(closeBtn)
    
    local ruleBtn = self.view:GetChild("n12")  
    ruleBtn.onClick:Add(self.onClickRule,self)
    
    local dec1 = self.view:GetChild("n14")
    dec1.text = language.lxth01

    local dec2 = self.view:GetChild("n16")
    dec2.text = language.lxth02

    local dec3 = self.view:GetChild("n19")
    dec3.text = language.lxth03

    local dec4 = self.view:GetChild("n31")
    dec4.text = language.lxth07

    self.titleIcon = self.view:GetChild("icon")

    self.lastTime = self.view:GetChild("n15")
    self.dayCost = self.view:GetChild("n18")
    self.reachDay = self.view:GetChild("n20")

    self.everyDayAwardList = self.view:GetChild("n35")
    self.everyDayAwardList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.everyDayAwardList:SetVirtual()
    --奖励展示
    self.awardList = self.view:GetChild("n25"):GetChild("n4")
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList:SetVirtual()
    --特殊奖励
    self.specialAward = self.view:GetChild("n23")
    self.specialAward.itemRenderer = function(index,obj)
        self:cellSpecialData(index, obj)
    end
    self.specialAward:SetVirtual()

    self.bar = self.view:GetChild("n34")
    self.curProgress = self.view:GetChild("n32")
    --每日领取
    self.everyDayGetbtn = self.view:GetChild("n29")
    self.everyDayGetbtn.onClick:Add(self.getEveryDayAward,self)

    --连续消费领取
    self.continueGetbtn = self.view:GetChild("n22")
    self.continueGetbtn.onClick:Add(self.getContinueAward,self)
end


function ContinueCost:initData()
    if self.data then
        -- self.showAward = conf.ActivityConf:getValue("lxth_show_award")
        -- self.awardList.numItems = #self.showAward
        -- self.conf = conf.ActivityConf:getLXTHDataByType(2)
        -- self.specialAward.numItems = #self.conf[1].item

        -- self.everyConfData = conf.ActivityConf:getLXTHDataByType(1)


        local day = self.conf[1].day--连续%d天消费达标可额外领取
        self.view:GetChild("n21").text = string.format(language.lxth05,day)
    end
end


function ContinueCost:setData(data)
    printt("连消特惠",data)
    self.data = data
    self.time = data.actLeftTime
    --今日消费
    self.dayCost.text = data.dayCostSum
    --达标天数
    self.reachDay.text = data.okDay

    --多开活动配置
    -- self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    -- local titleIconStr = self.mulConfData.title_icon or "lianxiaotehui_001"
    -- self.titleIcon.url = UIPackage.GetItemURL("continue" , titleIconStr)
    local awardTable = conf.ActivityConf:getMulactiveshow(self.data.mulActId)
    self.showAward = awardTable.awards
    self.awardList.numItems = #self.showAward
    
    self.conf = conf.ActivityConf:getMulLxcz(self.data.mulActId,2)
    self.specialAward.numItems = #self.conf[1].item

    self.everyConfData = conf.ActivityConf:getMulLxcz(self.data.mulActId,1)

    local day = self.conf[1].day--连续%d天消费达标可额外领取
    self.view:GetChild("n21").text = string.format(language.lxth05,day)
  
    local max
    local cfgId
    --local confData = conf.ActivityConf:getLXTHDataByType(1)
    local confData = conf.ActivityConf:getMulLxcz(self.data.mulActId,1)
    for k,v in pairs(confData) do
        if v.day == data.curDay then
            self.everyConfData = v
            max = v.quota
            cfgId = v.id
            break
        end
    end
    --每日提示
    local dayTitle = self.view:GetChild("n30")
    local t = clone(language.lxth06)
    t[1].text = string.format(t[1].text,data.curDay)
    t[2].text = string.format(t[2].text,max)
    dayTitle.text = mgr.TextMgr:getTextByTable(t)

    self.everyDayAwardList.numItems = #self.everyConfData.item
    self.bar.max = max
    self.bar.value = data.curCost
    local color = data.curCost < max and 14 or 7
    local t2 = {
        {text = data.curCost ,color = color},
        {text = "/"..max ,color = 7},
    }
    self.curProgress.text = mgr.TextMgr:getTextByTable(t2)

    if data.curCost < max then
        self.everyDayGetbtn.grayed = true
        self.everyDayGetbtn.data = {isCanGet = false ,cfgId = cfgId}
    else
        self.everyDayGetbtn.grayed = false
        self.everyDayGetbtn.data = {isCanGet = true ,cfgId = cfgId}
    end

    --连续目标奖励标识==1:已领取
    if data.targetGotSign == 1 then
        self.view:GetChild("n24").visible = true
        self.continueGetbtn.visible = false
    else
        self.view:GetChild("n24").visible = false
        self.continueGetbtn.visible = true
    end
    if self.data.okDay >= self.conf[1].day then
        self.continueGetbtn.grayed = false
        self.continueGetbtn.data = true
    else
        self.continueGetbtn.data = false
        self.continueGetbtn.grayed = true
    end

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end
--每日消费奖励
function ContinueCost:cellData(index, obj)
    local data = self.everyConfData.item[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end

--奖励展示
function ContinueCost:cellAwardData(index, obj)
    local data = self.showAward[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end

--连消费奖励
function ContinueCost:cellSpecialData(index, obj)
    local data = self.conf[1].item[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end

function ContinueCost:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end
function ContinueCost:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end


function ContinueCost:onClickRule()
    GOpenRuleView(1130)
end
--领取每日奖励
function ContinueCost:getEveryDayAward(context)
    local data = context.sender.data
    local isCanGet = data.isCanGet
    if not isCanGet then
        GComAlter(language.czccl08)
        return
    else
        proxy.ActivityProxy:sendMsg(1030513,{reqType = 1,cfgId = data.cfgId})
    end
end
--领取连续消费奖励
function ContinueCost:getContinueAward(context)
    local id = self.conf[1].id
    local data = context.sender.data 
    if data then
        proxy.ActivityProxy:sendMsg(1030513,{reqType = 2,cfgId = id})
    else
        GComAlter(language.czccl08)
    end
end




return ContinueCost