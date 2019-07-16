--
-- Author: 
-- Date: 2017-10-23 10:59:13
--

local AlertView16 = class("AlertView16", base.BaseView)

function AlertView16:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function AlertView16:initView()
    local btnClose = self.view:GetChild("n2"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    local btnSure = self.view:GetChild("n14")
    btnSure.onClick:Add(self.onSure,self)

    local btnCancel = self.view:GetChild("n13")
    btnCancel.onClick:Add(self.onCancel,self)

    local btnReduce = self.view:GetChild("n6")
    btnReduce.onClick:Add(self.onReduce,self)

    local btnPlus = self.view:GetChild("n7")
    btnPlus.onClick:Add(self.onPlus,self)
    
    self.Counttext = self.view:GetChild("n5")
    

    self.moneytext = self.view:GetChild("n11")
    self.moneytext.text = ""
    self.moneytext2 = self.view:GetChild("n20")
    self.moneytext2.text = ""

    self.dec1 = self.view:GetChild("n12")
    self.dec2 = self.view:GetChild("n4")
    self.dec3 = self.view:GetChild("n10")

    self.dec4 = self.view:GetChild("n8")
    self.dec5 = self.view:GetChild("n15")
    self.dec6 = self.view:GetChild("n19")

    self.yb1 = self.view:GetChild("n16")
    self.yb2 = self.view:GetChild("n18")
    self.costTitle = self.view:GetChild("n23")
    self.costTitle.text = language.fuben210
end

function AlertView16:initData(data)
    -- body
    self.data = data

    self.count = 1

    local money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    self.max = data.max or math.min(1,math.floor(money/self.data.price))

    self:setCost()

    self:setData()
end

function AlertView16:setData(data_)
    self.dec1.text = ""
    self.dec2.text = ""
    self.dec3.text = ""
    self.dec4.text = ""
    self.dec5.text = ""
    self.dec6.text = ""
    self.moneytext.visible = false
    self.moneytext2.visible = false
    self.yb1.visible = false
    self.yb2.visible = false
    if self.data.module_id == 1130 
    or self.data.module_id == 1132  then
        --单人守塔 
        self.dec1.text = language.fuben138
        self.dec2.text = language.fuben138
        self.dec3.text = language.fuben141
        self.dec4.text = string.format(language.fuben139,1) 
        self.dec5.text = string.format(language.fuben140,1) 
        self.dec6.text = language.fuben141
        self.moneytext.visible = true
        self.moneytext2.visible = true
        self.yb1.visible = true
        self.yb2.visible = true
        self.costTitle.y = globalConst.AlertView16_01 --bxp
    elseif  self.data.module_id == 1131 then
        --组队守塔
        self.dec1.text = language.fuben138
        self.dec2.text = language.fuben138
        self.dec3.text = language.fuben141
        self.dec4.text = string.format(language.fuben140,1) 
        self.dec5.text = ""
        self.dec6.text = ""
        self.moneytext.visible = true
        self.moneytext2.visible = false
        self.yb1.visible = true
        self.yb2.visible = false
        self.costTitle.y = globalConst.AlertView16_02 --bxp
    elseif self.data.module_id == 1133 then
        self.dec1.text = language.fuben138
        self.dec2.text = language.fuben138
        self.dec3.text = language.fuben141
        self.dec4.text = string.format(language.fuben140,1)
        self.moneytext.visible = true
        self.yb1.visible = true
        self.costTitle.y = globalConst.AlertView16_02 --bxp
    end
end

function AlertView16:setCost()
    -- body
    self.Counttext.text = self.count

    local price = self.data.price
    self.moneytext.text = price
    self.moneytext2.text = price
end

function AlertView16:onReduce()
    -- body--减少
    self.count = self.count - 1
    if self.count < 1 then
        self.count = 1
        GComAlter(language.gonggong97)
    end
    -- self.count = math.max(self.count-1,1)
    self:setCost()
end

function AlertView16:onPlus()
    -- body
    self.count = self.count + 1
    if self.count > self.max then
        self.count = self.max
        GComAlter(language.gonggong98)
    end
    -- self.count = math.min(self.count+1,self.max)
    self:setCost()
end

function AlertView16:onSure()
    -- body
    if not self.data then
        return
    end
    if self.data.sure then
        self.data.sure(self.count)
    end
    self:onCloseView()
end

function AlertView16:onCancel()
    -- body
    if not self.data then
        return
    end
    if self.data.cancel then
        self.data.cancel()
    end
    self:onCloseView()
end

function AlertView16:onCloseView( ... )
    -- body
    self:closeView()
end

return AlertView16