--
-- Author: 
-- Date: 2017-06-05 14:50:36
--

local AlertView14 = class("AlertView14", base.BaseView)

function AlertView14:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function AlertView14:initData(data)
    self.data = data
    self.btnRight.icon = data.okUrl or UIItemRes.imagefons01
    self.richText.text = data.richtext 
    self.btnLeft.icon = data.cancelUrl or UIItemRes.imagefons02
end

function AlertView14:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.richText = self.view:GetChild("n9")
    self.btnLeft = self.view:GetChild("n8")
    self.btnLeft.onClick:Add(self.onBtnLeftCallBack,self)

    self.btnRight = self.view:GetChild("n4")
    self.btnRight.onClick:Add(self.onBtnRightCallBack,self)
end

function AlertView14:onBtnLeftCallBack()
    -- body
    
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end

function AlertView14:onBtnRightCallBack()
    -- body
    
    if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

function AlertView14:onCloseView()
    -- body
    
    if self.data.closefun then 
        self.data.closefun()
    end
    self:closeView()
end

return AlertView14