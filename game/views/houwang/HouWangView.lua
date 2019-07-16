--
-- Author: 
-- Date: 2018-08-01 17:23:21
----猴王除妖

local HouWangView = class("HouWangView", base.BaseView)

function HouWangView:ctor()
    HouWangView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function HouWangView:initView()
    local closeBtn = self.view:GetChild("n32")
    self:setCloseBtn(closeBtn)

    local ruleBtn = self.view:GetChild("n99")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.logsList = self.view:GetChild("n22")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

    self.showList = self.view:GetChild("n23")
    self.showList.itemRenderer = function(index,obj)
        self:cellShowData(index, obj)
    end
    self.showList:SetVirtual()

    local dec1 = self.view:GetChild("n11")
    dec1.text = language.houWang01

    local dec2 = self.view:GetChild("n25")
    dec2.text = language.houWang03

    local dec3 = self.view:GetChild("n26")
    dec3.text = language.houWang02

    self.lastTime = self.view:GetChild("n12")

    local killBtn = self.view:GetChild("n30")
    killBtn.onClick:Add(self.onClickKillBtn,self)

    self.realBgjNum = self.view:GetChild("n33")

    self.modlePanle = self.view:GetChild("n10")

    self.cardList = self.view:GetChild("n24")
    self.cardList.itemRenderer = function(index,obj)
        self:cellCardData(index, obj)
    end
    -- self.cardList.onClickItem:Add(self.onClickCard,self) 
    -- self.cardList:SetVirtual()

end

function HouWangView:initData()
    self:initModel()
    self.oneCost = conf.ActivityConf:getHolidayGlobal("hwcy_once_cost")
    self.view:GetChild("n28").text = self.oneCost
    
    self.showAwardConfData = conf.ActivityConf:getHolidayGlobal("hwcy_awards_show")
    self.showList.numItems = #self.showAwardConfData

end

function HouWangView:initModel()
    local sex = cache.PlayerCache:getSex()
    local suitId
    if sex == 1 then
        suitId = conf.ActivityConf:getHolidayGlobal("hwcy_suit_boy")
    else
        suitId = conf.ActivityConf:getHolidayGlobal("hwcy_suit_girl")
    end
    local modelObj1 = self:addModel(suitId[1],self.modlePanle)
    modelObj1:setSkins(suitId[1], suitId[2])
    modelObj1:setScale(210)
    modelObj1:setRotationXYZ(0,166,0)
    modelObj1:setPosition(50,-160,150)

end


function HouWangView:setData(data)
    printt("猴王",data)
    self.data = data
    self.time = data.lastTime
    --真白骨精
    local realBgjNum = data.realBgjNum
    local realBgjCof = conf.ActivityConf:getHolidayGlobal("hwcy_real_spec_award")
    local needRealBgj = realBgjCof[1]
    local color = realBgjNum < needRealBgj and 14 or 7
    local textData = {
        {text = realBgjNum ,color = color},
        {text = "/",color = 7},
        {text = needRealBgj,color = 7},
    }
    self.realBgjNum.text = "("..mgr.TextMgr:getTextByTable(textData)..")"

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    self.cardList.numItems = #data.cardData

    self.logsList.numItems = #data.record

end

function HouWangView:cellLogData(index, obj)
    local data = self.data.record[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.houWang04, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function HouWangView:cellShowData(index,obj)
    local data = self.showAwardConfData[index+1]
    local awardList = obj:GetChild("n17")
    if data then
        GSetAwards(awardList,data)
    end
end
--[[6   
map<int32,int32>
变量名：cardData    说明：牌数据<索引,0:未翻 1:假白骨精 2:真白骨精]]
function HouWangView:cellCardData(index,obj)
    local data = self.data.cardData[index+1]
    local c1 = obj:GetController("c1")
    if data then
        c1.selectedIndex = data
        obj.data = {index = index+1,status = c1.selectedIndex}
        obj.onClick:Add(self.onClickCard,self)
    end
end

function HouWangView:onClickCard(context)
    local data = context.sender.data
    local index = data.index
    local status = data.status
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    if status == 0 then
        proxy.ActivityProxy:sendMsg(1030230,{reqType = 1,index = index})
    end
end


function HouWangView:onClickKillBtn()
    proxy.ActivityProxy:sendMsg(1030230,{reqType = 2,index = 0})
end

function HouWangView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
    end
    self.time = self.time - 1
end

function HouWangView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function HouWangView:onClickRule()
    GOpenRuleView(1117)
end

return HouWangView