--
-- Author: 
-- Date: 2018-10-15 15:49:27
--

local LuckyTreasureView = class("LuckyTreasureView", base.BaseView)

function LuckyTreasureView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function LuckyTreasureView:initView()
    local closeBtn = self.view:GetChild("n1"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.lastTime = self.view:GetChild("n8")

    self.listView00 = self.view:GetChild("n3"):GetChild("n4")
    self.listView00.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView00.numItems = 0
    self.listView01 = self.view:GetChild("n9")
    self.listView01.itemRenderer = function(index,obj)
        self:itemData(index,obj)
    end
    self.listView01.numItems = 0
    local ruleBtn = self.view:GetChild("n12")
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.text01 = self.view:GetChild("n13")
    self.text02 = self.view:GetChild("n18")
    self.progressbar = self.view:GetChild("n17")

    self.item = self.view:GetChild("n11")

    self.btn1 = self.view:GetChild("n15")
    self.btn1.data = 1
    self.btn1.onClick:Add(self.onClick,self)

    self.btn2 = self.view:GetChild("n16")
    self.btn2.data = 2
    self.btn2.onClick:Add(self.onClick,self)

    self.cost1 = tonumber(conf.ActivityConf:getValue("luckyIdentify_one_cost")[2])
    self.cost10 = tonumber(conf.ActivityConf:getValue("luckyIdentify_ten_cost")[2])
    self.btn1.text = ""..self.cost1
    self.btn2.text = ""..self.cost10

    self.lucky_value = conf.ActivityConf:getValue("luckyIdentify_lucky_value")

    self.ItemData = conf.ActivityConf:getLuckyTreasure()


end

function LuckyTreasureView:setData(data)
    printt(data)
    self.data = data
    GOpenAlert3(data.items,true)
    self.time = data.leftTime
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if self.data.bigAward then
        self.bigAward = conf.ActivityConf:getLuckyTreasureBigAward(self.data.bigAward)
        printt(self.bigAward )
        local t = {}
        t.mid = self.bigAward[1]
        t.amount = self.bigAward[2]
        t.bind = self.bigAward[3]
        GSetItemData(self.item,t,true)
    end
    self.progressbar.max = self.lucky_value
    self.progressbar.value = data.luckyValue
    self.text02.text = "("..tostring(data.luckyValue >= self.lucky_value and self.lucky_value or data.luckyValue ) .."/"..tostring(self.lucky_value)..")"
    self.text01.text = string.format(language.xyjb01,mgr.TextMgr:getTextColorStr("1~3", 7),
        mgr.TextMgr:getTextColorStr(conf.ItemConf:getName(self.bigAward[1]) , 7))
    self.listView00.numItems = #data.logs 
    self.listView01.numItems = #self.ItemData
end

function LuckyTreasureView:cellData(index,obj)
    local data = self.data.logs[index + 1]
    local strTab = string.split(data,"|")
    local rolename = string.sub(strTab[1],1,#strTab[1])
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.xyjb02, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function LuckyTreasureView:itemData(index,obj)
    local data = self.ItemData[index + 1]
    local t = {}
        t.mid = #data.items ~= 1 and data.items[self.data.bigAward + 1][1] or data.items[1][1] 
        t.amount = #data.items ~= 1 and data.items[self.data.bigAward + 1][2] or data.items[1][2]
        t.bind = #data.items ~= 1 and data.items[self.data.bigAward + 1][3] or data.items[1][3]
        GSetItemData(obj,t,true)
end

function LuckyTreasureView:onTimer()
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

function LuckyTreasureView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function LuckyTreasureView:onClickRule()
    GOpenRuleView(1150)
end

function LuckyTreasureView:onClick(context)
    local data = context.sender.data
    local ybAmount = cache.PackCache:getPackDataById(PackMid.gold).amount
    if data == 1 then
        if  ybAmount >= self.cost1 then
            proxy.ActivityProxy:send(1030637,{reqType = 1})
        else
            self:goToCharge()
        end
    end
    if data == 2 then
        if  ybAmount >= self.cost10 then
            proxy.ActivityProxy:send(1030637,{reqType = 2})
        else
            self:goToCharge()
        end
    end
  
end

function LuckyTreasureView:goToCharge()
    GComAlter(language.ingotcopy10)
    GGoVipTequan(0)
    self:closeView()
end
return LuckyTreasureView

