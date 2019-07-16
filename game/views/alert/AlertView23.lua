local AlertView23 = class("AlertView23", base.BaseView)

function AlertView23:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function AlertView23:initData(data)
    self.toggle.selected = false
    self.data = data
    self.btnRight.icon = data.okUrl or UIItemRes.imagefons01
    self.textComponent.text = data.content
    self.btnLeft.icon = data.cancelUrl or UIItemRes.imagefons02
    self.toggleText.text = data.toggleStr or language.kagee61
end

function AlertView23:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView, self)

    self.toggle = self.view:GetChild("n5")
    self.toggleText = self.view:GetChild("n6")

    self.textComponent = self.view:GetChild("n1")

    self.btnLeft = self.view:GetChild("n10")
    self.btnLeft.onClick:Add(self.onBtnLeftCallBack, self)

    self.btnRight = self.view:GetChild("n7")
    self.btnRight.onClick:Add(self.onBtnRightCallBack, self)
end

function AlertView23:onBtnLeftCallBack()
    if self.data.leftHandler then
        self.data.leftHandler(self.toggle.selected)
    end
    self:closeView()
end

-- 默认右边为确认按钮
function AlertView23:onBtnRightCallBack()
    if self.data.rightHandler then
        self.data.rightHandler(self.toggle.selected)
    end
    self:closeView()
end

function AlertView23:onCloseView()
    if self.data.closefun then
        self.data.closefun()
    end
    self:closeView()
end

return AlertView23