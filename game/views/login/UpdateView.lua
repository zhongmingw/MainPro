--
-- Author: yr
-- Date: 2017-03-02 19:45:02
--

local UpdateView = class("UpdateView", base.BaseView)

function UpdateView:ctor()
    self.super.ctor(self)
end

function UpdateView:initView()
    local bgLoader = self.view:GetChild("n0")
    self.label = self.view:GetChild("n5")
    bgLoader.url = UIItemRes.denlufuwuqi_016
    self.loadBar = self.view:GetChild("n4")
end

function UpdateView:updateBar(value, max)
    if self.loadBar then
        self.loadBar.max = max
        self.loadBar.value = value
    end
end

function UpdateView:updateLabel(str)
    self.label.text = str
end

function UpdateView:setData(data_)

end

return UpdateView