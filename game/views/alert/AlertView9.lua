--
-- Author: 
-- Date: 2017-02-27 11:35:14
--

local AlertView9 = class("AlertView9", base.BaseView)

function AlertView9:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function AlertView9:initView()
    self.descText = self.view:GetChild("n2")
    local closeBtn = self.view:GetChild("n5")
    self:setCloseBtn(closeBtn)
    local okBtn = self.view:GetChild("n3")
    okBtn.onClick:Add(self.onClickBtn,self)
end

function AlertView9:setData(data)
    self.data = data
    self.descText.text = data.richtext or ""
end

function AlertView9:onClickBtn()
    if self.data.sure then
        self.data.sure()
    end
    self:closeView()
end

return AlertView9