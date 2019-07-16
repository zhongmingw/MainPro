--
-- Author: Your Name
-- Date: 2018-01-09 20:50:31
--

local LastCountBuyView = class("LastCountBuyView", base.BaseView)

function LastCountBuyView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true 
end

function LastCountBuyView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.cancelBtn = self.view:GetChild("n11")
    self:setCloseBtn(self.cancelBtn)
    self.buyBtn = self.view:GetChild("n12")
    self.dec1 = self.view:GetChild("n7")
    self.dec2 = self.view:GetChild("n8")
    self.selectBtn = self.view:GetChild("n10")
    self.selectBtn.onChanged:Add(self.onCheck,self)
end

function LastCountBuyView:onCheck()
    if self.selectBtn.selected then
        if self.type and self.type == 1 then
            cache.PwsCache:setIsSoloBuy(true)
            cache.PwsCache:setIsTeamBuy(false)
        elseif self.type and self.type == 2 then
            cache.PwsCache:setIsTeamBuy(true)
            cache.PwsCache:setIsSoloBuy(false)            
        end
    else
        if self.type and self.type == 1 then
            cache.PwsCache:setIsSoloBuy(false)
        elseif self.type and self.type == 2 then
            cache.PwsCache:setIsTeamBuy(false)            
        end
    end
end

function LastCountBuyView:initData(data)
    self.selectBtn.selected = false
    self.buyCount = data.buyCount
    self.type = data.type
    local cost = conf.QualifierConf:getValue("one_buy_cfg")[2]
    local maxBuyCount = conf.QualifierConf:getValue("one_buy_max")
    if self.type == 2 then
        cost = conf.QualifierConf:getValue("zd_buy_cfg")[2]
        maxBuyCount = conf.QualifierConf:getValue("zd_buy_max")
    end
    self.buyBtn.onClick:Add(self.onClickBuy,self)
    local textData = {
        {text = language.qualifier04[1],color = 6},
        {text = string.format(language.qualifier04[2],cost),color = 7},
        {text = language.qualifier04[3],color = 6},
    }
    self.dec1.text = mgr.TextMgr:getTextByTable(textData)
    self.dec2.text = string.format(language.qualifier05,maxBuyCount)
end

function LastCountBuyView:onClickBuy(data)
    local maxBuyCount = conf.QualifierConf:getValue("one_buy_max")
    local cost = conf.QualifierConf:getValue("one_buy_cfg")[2]
    if self.type == 2 then
        cost = conf.QualifierConf:getValue("zd_buy_cfg")[2]
        maxBuyCount = conf.QualifierConf:getValue("zd_buy_max")
    end
    local lastBuyCount = maxBuyCount - self.buyCount
    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local moneyBy = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
    if moneyYb + moneyBy >= cost then
        if lastBuyCount > 0 then
            if self.type == 1 then
                proxy.QualifierProxy:sendMsg(1480105,{count = 1})
            elseif self.type == 2 then
                proxy.QualifierProxy:sendMsg(1480209,{count = 1})
            end
            self:closeView()
        else
            GComAlter(language.kuafu77)
        end
    else
        GComAlter(language.gonggong18)
    end
end

return LastCountBuyView