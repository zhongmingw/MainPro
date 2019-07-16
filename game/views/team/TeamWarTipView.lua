--
-- Author: 
-- Date: 2017-10-25 18:01:10
--

local TeamWarTipView = class("TeamWarTipView", base.BaseView)

function TeamWarTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function TeamWarTipView:initView()
    self.richText = self.view:GetChild("n2")

    self.okBtn = self.view:GetChild("n3")
    self.okBtn.onClick:Add(self.onBtnOk,self)

    self.cancelBtn = self.view:GetChild("n4")
    self.cancelBtn.onClick:Add(self.onBtnCancel,self)
end

function TeamWarTipView:initData(data)
    self.data = data
    self.richText.text = data.richText
    self.okBtn.title = data.okText or language.gonggong01
    self.cancelBtn.title = data.cancelText or language.gonggong02
end

function TeamWarTipView:onBtnOk()
    if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

function TeamWarTipView:onBtnCancel()
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end

return TeamWarTipView