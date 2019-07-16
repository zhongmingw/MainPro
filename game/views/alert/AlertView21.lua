--
-- Author: 
-- Date: 2018-11-27 20:41:31
--

local AlertView21 = class("AlertView21", base.BaseView)

function AlertView21:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true

end

function AlertView21:initData(data)
    self.data = data
    self.btnRight.icon = data.okUrl or UIItemRes.imagefons01
    self.richText.text = data.richtext 
    self.btnLeft.icon = data.cancelUrl or UIItemRes.imagefons02
end

function AlertView21:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.richText = self.view:GetChild("n5")
    self.btnLeft = self.view:GetChild("n6")
    self.btnLeft.onClick:Add(self.onBtnLeftCallBack,self)

    self.btnRight = self.view:GetChild("n7")
    self.btnRight.onClick:Add(self.onBtnRightCallBack,self)
end

function AlertView21:onBtnLeftCallBack()
    -- body
    
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end

function AlertView21:onBtnRightCallBack()
    
    if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

function AlertView21:onCloseView()
    -- body
    
    if self.data.closefun then 
        self.data.closefun()
    end
    self:closeView()
end

return AlertView21