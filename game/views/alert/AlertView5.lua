--
-- Author: 
-- Date: 2017-02-16 20:19:25
--

local AlertView5 = class("AlertView5", base.BaseView)

function AlertView5:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level3 
end

function AlertView5:initView()
    local window4 = self.view:GetChild("n0")
    local btn = window4:GetChild("n2")
    btn.onClick:Add(self.onCloseView,self)

    self.titleIcon = window4:GetChild("icon")
    self.title = self.titleIcon.url 
    self.btnSure = self.view:GetChild("n4")
    self.btnSure.onClick:Add(self.onbtnSure,self)
    self.btnSureIcon = self.btnSure:GetChild("icon")
    self.btnSureTitle = self.btnSure:GetChild("title")

    self.richText = self.view:GetChild("n5")
end

function AlertView5:setData(data_)
    self.data = data_

    if data_.titleIcon then
        self.titleIcon.url = data_.titleIcon
    else
        self.titleIcon.url = self.title
    end

    if data_.sureIcon then
        self.btnSureIcon.url = data_.sureIcon
    end

    if data_.sureTitle then
        self.btnSureTitle.text = data_.sureTitle
    end

    self.richText.text = data_.richtext or ""
end

function AlertView5:onbtnSure()
    -- body
    if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

function AlertView5:onCloseView()
    -- body
    if self.data.cancel then
        self.data.cancel()
    end
    self:closeView()
end

return AlertView5