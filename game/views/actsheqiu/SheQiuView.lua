--
-- Author: yr
-- Date: 2018-07-09 20:06:33
--

local SheQiuView = class("SheQiuView", base.BaseView)

function SheQiuView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function SheQiuView:initView()
    local component1 = self.view:GetChild("n2")
    self:setCloseBtn(component1:GetChild("n4"))
    
    self.timeTxt = component1:GetChild("n7")

    self.boxList = component1:GetChild("n19")
    self.boxList:SetVirtual()
    self.boxList.itemRenderer = function(index,obj)
        self:onItemRenderer(index, obj)
    end

    self.model = component1:GetChild("n18")

    self.ybTxt = component1:GetChild("n14"):GetChild("n15")
    self.ybTxt2 = component1:GetChild("n17"):GetChild("n15")

    self.jumpBtn = component1:GetChild("n11")

    self.smBtn = component1:GetChild("n8")
    self.smBtn.onClick:Add(self.onClickOneSm, self)
    self.smMultiBtn = component1:GetChild("n9")
    self.smMultiBtn.onClick:Add(self.onClickMultiSm, self)

    self.awardBtn = component1:GetChild("n10")
    self.awardBtn.onClick:Add(self.onClickAward, self)
    self.awardBtn.visible = false

    self.ballList = {}
    self.playerList = {}
    for i=1,7 do
        local item = component1:GetChild("n"..(i+24))
        table.insert(self.ballList,item)
        local t = component1:GetTransition("t"..i)
        table.insert(self.playerList,t)
    end
    self.t0 = component1:GetTransition("t0")
    
    self.leftBtn = component1:GetChild("n22")
    self.leftBtn.onClick:Add(self.onClickLeft,self)
    self.rightBtn = component1:GetChild("n23")
    self.rightBtn.onClick:Add(self.onClickRight,self)
end

function SheQiuView:onClickLeft()
    self.index = self.index > 5 and 5 or self.index
    if self.index > 0 then
        self.index = self.index-1
    end
    self.boxList:ScrollToView(self.index,true)
end

function SheQiuView:onClickRight()
    if self.index < 5 then
        self.index = self.index+1
    else
        self.index = 5
    end
    self.boxList:ScrollToView(self.index,true)
end

function SheQiuView:initData(data)
    self.index = 0
    self.isShe = true
    self:initModel()
end

function SheQiuView:redPoint(actId)
    local var = cache.PlayerCache:getRedPointById(20182)
    -- print("红点>>>>>>>>>>",cache.PlayerCache:getRedPointById(20182),cache.PlayerCache:getRedPointById(20183))
    if actId == 3063 then
        var = cache.PlayerCache:getRedPointById(20183)
    end
    -- if var > 0 then
    --     self.awardBtn:GetChild("red").visible = true
    -- else
        self.awardBtn:GetChild("red").visible = false
    -- end
end

function SheQiuView:setData(data)
    printt("射门好礼>>>>>>>>>>>",data)
    -- for k,v in pairs(data.boxData) do
    --     print("宝箱数据>>>>",k,v)
    -- end
    self:redPoint(data.actId)
    self.actId = data.actId
    self.data = data
    self.time = data.lastTime
    self:releaseTimer()
    if not self.timer then
        self:onTimer()
        self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    
    self.boxData = data.boxData
    if data.reqType == 2 then--射门
        if data.times == 1 then
            local delay = 2.5
            if self.jumpBtn.selected then
                delay = 0.1
            else
                self.t0:Play()
                self.playerList[data.currIndex]:Play()
            end
            self.timer = self:addTimer(delay, 1, function()
                for k,v in pairs(self.ballList) do
                    if self.boxData[k] then
                        v.visible = true
                        local icon = v:GetChild("n0")
                        if self.boxData[k] == 1 then
                            icon.url = UIPackage.GetItemURL("actsheqiu" , "sheqiuhali_005")
                        else
                            icon.url = UIPackage.GetItemURL("actsheqiu" , "300000026")
                        end
                    else
                        v.visible = false
                    end
                end
                self.isShe = true
                self.t0:Stop()
            end)
        else
            if data.items and #data.items>0 then
                GOpenAlert3(data.items)
            end
            for k,v in pairs(self.ballList) do
                if self.boxData[k] then
                    v.visible = true
                    local icon = v:GetChild("n0")
                    if self.boxData[k] == 1 then
                        icon.url = UIPackage.GetItemURL("actsheqiu" , "sheqiuhali_005")
                    else
                        icon.url = UIPackage.GetItemURL("actsheqiu" , "300000026")
                    end
                else
                    v.visible = false
                end
            end
        end
    else
        for k,v in pairs(self.ballList) do
            if self.boxData[k] then
                v.visible = true
                local icon = v:GetChild("n0")
                if self.boxData[k] == 1 then
                    icon.url = UIPackage.GetItemURL("actsheqiu" , "sheqiuhali_005")
                else
                    icon.url = UIPackage.GetItemURL("actsheqiu" , "300000026")
                end
            else
                v.visible = false
            end
        end
    end
    local num = 0
    for k,v in pairs(self.boxData) do
        num = num + 1
    end
    local cost = conf.ActivityConf:getHolidayGlobal("shoot_gift_cost")[2]
    self.ybTxt.text = cost
    self.ybTxt2.text = cost*num

    self.perBoxData = {}
    local t = conf.ActivityConf:getSheQiuSeeList(data.actId)
    for k,v in pairs(t) do
        if type(v) == "table" then
            table.insert(self.perBoxData,v)
        end
    end
    table.sort(self.perBoxData,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    self.boxList.numItems = #self.perBoxData

end

function SheQiuView:releaseTimer()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
end

function SheQiuView:onTimer()
    if self.time > 86400 then 
        self.timeTxt.text = GTotimeString7(self.time)
    else
        self.timeTxt.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onBtnClose()
    end

    self.time = self.time - 1
end

function SheQiuView:initModel()
    self.sex = cache.PlayerCache:getSex()
    local modelId = conf.ActivityConf:getHolidayGlobal("shoot_modelId")[1]
    -- print("模型ID>>>>>>>>>",modelId)
    local modelObj1 = self:addModel(modelId,self.model)
    modelObj1:setScale(60)
    modelObj1:setRotationXYZ(0,120,0)
    modelObj1:setPosition(-30,-100,500)
end

function SheQiuView:onClickOneSm()
    local cost = conf.ActivityConf:getHolidayGlobal("shoot_gift_cost")[2]
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if myYb >= cost then
        if self.isShe then
            self.isShe = false
            proxy.ActivityProxy:sendMsg(1030324,{actId = self.actId,reqType = 2,times = 1})
        end
    else
        GComAlter(language.gonggong18)
    end
end
function SheQiuView:onClickMultiSm()
    local i = 0
    for k,v in pairs(self.boxData) do
        i = i + 1
    end
    local cost = conf.ActivityConf:getHolidayGlobal("shoot_gift_cost")[2]
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if myYb >= cost*i then
        proxy.ActivityProxy:sendMsg(1030324,{actId = self.actId,reqType = 2,times = i})
    else
        GComAlter(language.gonggong18)
    end
end

function SheQiuView:onClickAward()
    if self.data then
        mgr.ViewMgr:openView2(ViewName.SheQiuAwardView,self.data)
    end
end

function SheQiuView:onItemRenderer(index, obj)
    local data = self.perBoxData[index + 1]
    if type(data) == "table" then
        local mid = data.rewards[1]
        GSetItemData(obj,{mid=mid, },true)
    end
end

return SheQiuView