--
-- Author: ohf
-- Date: 2017-04-06 16:52:44
--

local LevelTipView = class("LevelTipView", base.BaseView)

function LevelTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function LevelTipView:initView()
    self:setCloseBtn(self.view:GetChild("n2"))
    local btnCancel = self.view:GetChild("n11")
    self:setCloseBtn(btnCancel)
    local btnBuy = self.view:GetChild("n12")
    btnBuy.onClick:Add(self.onClickBuy, self)
    local btnAdd = self.view:GetChild("n4")
    btnAdd.data = 1
    btnAdd.onClick:Add(self.onClickUpdateCount, self)
    local btnLess = self.view:GetChild("n5")
    btnLess.data = 2
    btnLess.onClick:Add(self.onClickUpdateCount, self)
    self.moneyText = self.view:GetChild("n10")
    -- self.moneyText2 = self.view:GetChild("n17")
    self.hourText = self.view:GetChild("n13")
    self.titleText = self.view:GetChild("n6")
end

function LevelTipView:setData(index)
    self.hour = 1
    self.mIndex = index
    if index == 1 then--普通时间加成
        self.titleText.text = language.fuben55
        self.price = conf.SysConf:getValue("lianji_time_hour_gold")
    else--1.5倍时间加成
        self.titleText.text = language.fuben49
        self.price = conf.SysConf:getValue("lianji_exp_plus_time_hour_gold")
    end
    self:updateHour()
end

function LevelTipView:onClickBuy()
    if self.mIndex == 1 then--普通时间加成
        proxy.FubenProxy:send(1025102,{hour = self.hour})
    else--1.5倍时间加成
        proxy.FubenProxy:send(1025103,{hour = self.hour})
    end
    self:closeView()
end

function LevelTipView:onClickUpdateCount(context)
    local tag = context.sender.data
    if tag == 1 then
        self.hour = self.hour + 1
    else
        self.hour = self.hour - 1
    end
    self:updateHour()
end

function LevelTipView:updateHour()
    if self.hour <= 1 then
        self.hour = 1
    end
    self.hourText.text = self.hour
    local money = self.hour * self.price
    self.moneyText.text = money
    -- self.moneyText2.text = money
end

return LevelTipView