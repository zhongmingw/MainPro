--
-- Author: 
-- Date: 2018-08-13 16:06:35
--

local MonthCardView = class("MonthCardView", base.BaseView)

function MonthCardView:ctor()
    MonthCardView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function MonthCardView:initView()
    local closeBtn = self.view:GetChild("n20")
    self:setCloseBtn(closeBtn)
    
    local investBtn = self.view:GetChild("n9")
    investBtn.onClick:Add(self.goInvest,self)
    
    local dec1 = self.view:GetChild("n13")
    dec1.text = language.month01[1]

    -- local monthCost = conf.ActivityConf:getValue("month_card_cost")

    local dec2 = self.view:GetChild("n15")
    local t = conf.ActivityConf:getMonthCardByDay(2000)
    dec2.text = string.format(language.month01[2],t.yb) 

    local dec3 = self.view:GetChild("n17")
    dec3.text = language.month02[1]

    local dec4 = self.view:GetChild("n19")
    local t = conf.ActivityConf:getMonthCardByDay(2001)
    dec4.text = string.format(language.month02[2],t.yb) 


    local dec5 = self.view:GetChild("n21")
    dec5.text = language.month06

    local dec6 = self.view:GetChild("n22")
    dec6.text = language.month07

    local item1 = self.view:GetChild("n12")
    self:setItem(item1)
    local item2 = self.view:GetChild("n16")
    self:setItem(item2)
    local ruleBtn = self.view:GetChild("n25")
    ruleBtn.onClick:Add(self.onClickRule,self)
end

function MonthCardView:setItem(item)
    local itemData = {mid = PackMid.bindGold,amount = 0 ,bind = 1}
    GSetItemData(item, itemData,true)
end

function MonthCardView:goInvest()
    mgr.ViewMgr:openView2(ViewName.VipChargeView,{index = 2})
    self:closeView()

end

function MonthCardView:onClickRule()
    GOpenRuleView(1157)
end

return MonthCardView