--
-- Author: 
-- Date: 2017-12-26 20:01:43
--

local XdzzTipView = class("XdzzTipView", base.BaseView)

function XdzzTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XdzzTipView:initView()
    self.title = self.view:GetChild("n1")
end

function XdzzTipView:initData(data)
    local confData = conf.ActivityWarConf:getSnowCollectRef(data.mid)
    local title = confData and confData.bx_title or ""
    self.title.url = UIPackage.GetItemURL("track" , title)
    self:addTimer(3, -1, function()
        self:closeView()
    end)
end

return XdzzTipView