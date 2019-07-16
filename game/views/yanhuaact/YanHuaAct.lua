--
-- Author: 
-- Date: 2018-10-15 10:47:11
-- 烟花庆典

local YanHuaAct = class("YanHuaAct", base.BaseView)

function YanHuaAct:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function YanHuaAct:initView()
    local closeBtn = self.view:GetChild("n12")
    self:setCloseBtn(closeBtn)
    self.oneBtn = self.view:GetChild("n4")
    self.oneBtn.onClick:Add(self.btnOnClick,self)
    self.tenBtn = self.view:GetChild("n5")
    self.tenBtn.onClick:Add(self.btnOnClick,self)
    self.actCountDowmText = self.view:GetChild("n2")
    self.actCountDowmText.text = " "
    local oneConst = conf.ActivityConf:getValue("fireworks_one_cost")
    local tenConst = conf.ActivityConf:getValue("fireworks_ten_cost")
    local oneCostText = self.view:GetChild("n10")
    oneCostText.text = oneConst[2]
    local tenCostText = self.view:GetChild("n11")
    tenCostText.text = tenConst[2]
    self.awardList = self.view:GetChild("n3")
    self.awardList.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.awardList.numItems = 0
    self.awardList:SetVirtual()

    self.effectImg = self.view:GetChild("n15")
end

function YanHuaAct:initData()
    self.confData = {}
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function YanHuaAct:setData(data)
    self.data = data
    -- printt("烟花庆典>>>",data)
    self.actCountDown = data.leftTime
    self.mulActId = data.mulActId
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActId)
    if mulActConf then
        self.confData = conf.ActivityConf:getYHAward(mulActConf.award_pre)

    end
    self.awardList.numItems = #self.confData
end

function YanHuaAct:setAwardData(index,obj)
    local awardObj = self.confData[index+1]
    if awardObj then
        local isquan
        if awardObj.zq and awardObj.zq == 1 then
            isquan = false
        else
            isquan = true
        end
        local itemData = {mid = awardObj.items[1],amount = awardObj.items[2],bind = awardObj.items[3],isquan = isquan}
        GSetItemData(obj, itemData, true)
    end
end

function YanHuaAct:btnOnClick(context)
    local btn = context.sender
    self:setEffect()
    local moneyCache = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if moneyCache <= 0 then
        GOpenView({id = 1042})
    end
    if btn.name == "n4" then
        proxy.ActivityProxy:sendMsg(1030635,{reqType = 1})
    elseif btn.name == "n5" then
        proxy.ActivityProxy:sendMsg(1030635,{reqType = 2})        
    end
end

function YanHuaAct:setEffect()
    self.effect = self:addEffect(4020212, self.effectImg)
    self.effect.Scale = Vector3.New(50,50,50)
    self.effect.LocalPosition = Vector3.New(0,-173,0)
    self:addTimer(2, 1, function ()
        if not self.data then return end
        GOpenAlert3(self.data.items)
    end)
end

function YanHuaAct:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown - 1,0)
    if self.actCountDown <= 0 then      
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDowmText.text = mgr.TextMgr:getTextColorStr(GGetTimeData3(self.actCountDown),7)
    else
        self.actCountDowmText.text = mgr.TextMgr:getTextColorStr(GGetTimeData4(self.actCountDown),7)     
    end
end

return YanHuaAct