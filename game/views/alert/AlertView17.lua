--
-- Author: 
-- Date: 2017-10-25 16:28:17
--

local AlertView17 = class("AlertView17", base.BaseView)

function AlertView17:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function AlertView17:initData(data)
    self.data = data
    self.btnRight.icon = data.okUrl or UIItemRes.imagefons01
    self.richText.text = data.richtext 
    self.btnLeft.icon = data.cancelUrl or UIItemRes.imagefons02
    if data.itemData then
        local packData = cache.PackCache:getPackDataById(data.itemData.mid)
        self.countText.text = packData.amount.."/"..data.itemData.amount
        data.itemData.amount = 1
        data.itemData.isquan = true
        GSetItemData(self.itemObj, data.itemData, true)
    end
end

function AlertView17:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.richText = self.view:GetChild("n4")
    self.btnLeft = self.view:GetChild("n2")
    self.btnLeft.onClick:Add(self.onBtnLeftCallBack,self)

    self.btnRight = self.view:GetChild("n1")
    self.btnRight.onClick:Add(self.onBtnRightCallBack,self)

    self.itemObj = self.view:GetChild("n5")

    self.countText = self.view:GetChild("n6")
end

function AlertView17:onBtnLeftCallBack()
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end

function AlertView17:onBtnRightCallBack()
    if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

function AlertView17:onCloseView()
    -- body
    
    if self.data.closefun then 
        self.data.closefun()
    end
    self:closeView()
end

return AlertView17