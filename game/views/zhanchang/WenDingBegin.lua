--
-- Author: 
-- Date: 2017-05-04 16:56:11
--

local WenDingBegin = class("WenDingBegin", base.BaseView)

function WenDingBegin:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function WenDingBegin:initData(data)
    local floor = tonumber(string.sub(cache.PlayerCache:getSId(),6,6))
    self.numText.text = floor
    local rise = data.rise--是否升层
    self.img1.visible = rise
    self.img2.visible = not rise
    self:addTimer(1.5, 1, function()
        self:closeView()
    end)
end

function WenDingBegin:initView()
    self.img1 = self.view:GetChild("n1")
    self.img2 = self.view:GetChild("n4")
    self.numText = self.view:GetChild("n3")
end

function WenDingBegin:setData(data)

end

return WenDingBegin