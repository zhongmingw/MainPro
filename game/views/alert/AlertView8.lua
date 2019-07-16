--
-- Author: 
-- Date: 2017-02-24 17:19:34
--

local AlertView8 = class("AlertView8", base.BaseView)

function AlertView8:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function AlertView8:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.titleIcon = window4:GetChild("icon")
    self.richtext = self.view:GetChild("n1")
    self.richtext1 =  self.view:GetChild("n6")
    self.radiobtn = self.view:GetChild("n5")
    self.btnSure = self.view:GetChild("n7")
    self.btnSure.onClick:Add(self.onbtnSure,self)

    self.sureIcon = self.btnSure:GetChild("icon")
end

function AlertView8:setData(data_)
    self.data = data_
    if self.data.titleIcon then
        self.titleIcon.url = self.data.titleIcon
    end
    if self.data.richtext then
        self.richtext.text = self.data.richtext
    end
    if self.data.richtext1 then
        self.richtext1.text = self.data.richtext1
    end
    if self.sureIcon then
        self.sureIcon.url = self.data.sureIcon
    end

    self.radiobtn.selected = false
    if self.data.isradio then
        self.radiobtn.selected = self.data.isradio
    end

    if self.data.sureText then
        local text = btnSure:GetChild("title")
        text.text = self.data.sureText
        text.visible = true
    end
end

function AlertView8:onbtnSure()
    -- body
    
    if self.data.sure then 
        self.data.sure(self.radiobtn.selected)
    end
    self:closeView()
end

function AlertView8:onBtnClose(  )
    -- body
    if self.data.cancel then
        self.data.cancel()
    end
    self:closeView()
end

return AlertView8