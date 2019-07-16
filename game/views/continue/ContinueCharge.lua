--
-- Author: 
-- Date: 2018-08-01 15:33:25
--

local ContinueCharge = class("ContinueCharge", base.BaseView)

function ContinueCharge:ctor()
    ContinueCharge.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ContinueCharge:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    local bgTitle = self.view:GetChild("n0"):GetChild("n8")
    bgTitle.url = UIPackage.GetItemURL("continue" , "lianchongtehui_002")
    local chargeBtn = self.view:GetChild("n23")
    chargeBtn.onClick:Add(self.onClickCharge,self)

    local ruleBtn = self.view:GetChild("n26")  
    ruleBtn.onClick:Add(self.onClickRule,self)
    
    local dec1 = self.view:GetChild("n10")
    dec1.text = language.lcth01

    local dec2 = self.view:GetChild("n12")
    dec2.text = language.lcth02

    local dec3 = self.view:GetChild("n15")
    dec3.text = language.lcth03

    self.lastTime = self.view:GetChild("n11")
    self.datCz = self.view:GetChild("n14")
    self.reachDay = self.view:GetChild("n16")

    self.listView = self.view:GetChild("n9")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    --奖励展示
    self.awardList = self.view:GetChild("n19"):GetChild("n4")
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList:SetVirtual()
    --特殊奖励
    self.specialAward = self.view:GetChild("n22")
    self.specialAward.itemRenderer = function(index,obj)
        self:cellSpecialData(index, obj)
    end
    self.specialAward:SetVirtual()


    self.getBtn = self.view:GetChild("n20")
    self.getBtn.onClick:Add(self.onClickGetAwards,self)
     self.titleIcon = self.view:GetChild("n0"):GetChild("icon")
end

function ContinueCharge:initLianChong()
    self.conf = conf.ActivityConf:getLCTHConByType(2,self.mulConfData.award_pre)
   
    self.specialAward.numItems = #self.conf[1].item
    local day = self.conf[1].day
    self.view:GetChild("n17").text = string.format(language.lcth04,day)
end

function ContinueCharge:setData(data)
    self.data = data
    printt("连冲特惠",data)
    self.time = data.actLeftTime
    --今日充值
    self.datCz.text = data.dayCzSums[data.curDay] or 0
    --达标天数
    self.reachDay.text = data.okDay
       --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "lianchongtehui_001"
    self.titleIcon.url = UIPackage.GetItemURL("continue" , titleIconStr)
    self.confAwardData = conf.ActivityConf:getMulactiveshow(self.data.mulActId)
    self.showAward = conf.ActivityConf:getMulactiveshow(self.data.mulActId).awards


    self.awardList.numItems = #self.showAward
    self:initLianChong()
    --连续目标奖励标识>0:已领取
    if data.targetGotSign > 0 then
        self.view:GetChild("n24").visible = true
        self.getBtn.visible = false
    else
        self.view:GetChild("n24").visible = false
        self.getBtn.visible = true
    end
    if self.data.okDay >= self.conf[1].day then
        self.getBtn.grayed = false
        self.getBtn.touchable = true
    else
        self.getBtn.grayed = true
        self.getBtn.touchable = false
    end

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    self.awardConfData = conf.ActivityConf:getLCTHConByType(1,self.mulConfData.award_pre)
    self.listView.numItems = #self.awardConfData
end

function ContinueCharge:cellData(index, obj)
    local data = self.awardConfData[index+1]
    local title = obj:GetChild("n3")
    local awardList = obj:GetChild("n4")
    local c1 = obj:GetController("c1")
    local getBtn = obj:GetChild("n7")
    getBtn.onClick:Add(self.getDayAward,self)
    if data then
        getBtn.data = data.id
        GSetAwards(awardList, data.item)
        title.text = string.format(language.lcth05,data.day,tonumber(data.quota))

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

function ContinueCharge:getDayAward(context)
    local id = context.sender.data
    if not self.data.gotSigns[id] then
        proxy.ActivityProxy:sendMsg(1030508,{reqType = 1,cfgId = id})
    end
end

--奖励展示
function ContinueCharge:cellAwardData(index, obj)
    -- print("2222222")
    local data = self.showAward[index+1]
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
   
end
--连冲奖励
function ContinueCharge:cellSpecialData(index, obj)
    local data = self.conf[1].item[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end

function ContinueCharge:onTimer()
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

function ContinueCharge:onClickGetAwards()
    proxy.ActivityProxy:sendMsg(1030508,{reqType = 2,cfgId = self.conf[1].id})
end

function ContinueCharge:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function ContinueCharge:onClickCharge()
    GGoVipTequan(0)
    self:closeView()
end

function ContinueCharge:onClickRule()
    GOpenRuleView(1116)
end


return ContinueCharge