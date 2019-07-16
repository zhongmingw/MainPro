local AlertView22 = class("AlertView22", base.BaseView)

function AlertView22:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function AlertView22:initData(data)
    self.data = data
    self.btnRight.icon = data.okUrl or UIItemRes.imagefons01
    self.textComponent.text = data.content
    self.btnLeft.icon = data.cancelUrl or UIItemRes.imagefons02
end

function AlertView22:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView, self)

    self.textComponent = self.view:GetChild("n11")
    self.btnLeft = self.view:GetChild("n8")
    self.btnLeft.onClick:Add(self.onBtnLeftCallBack, self)

    self.btnRight = self.view:GetChild("n4")
    self.btnRight.onClick:Add(self.onBtnRightCallBack, self)
end

function AlertView22:onBtnLeftCallBack()
    if self.data.leftHandler then
        self.data.leftHandler()
    end
    self:closeView()
end

-- 默认右边为确认按钮
function AlertView22:onBtnRightCallBack()
    if self.data.rightHandler then
        self.data.rightHandler()
    end
    self:closeView()
end

function AlertView22:onCloseView()
    if self.data.closefun then
        self.data.closefun()
    end
    self:closeView()
end

return AlertView22