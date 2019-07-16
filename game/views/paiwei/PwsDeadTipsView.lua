--
-- Author: Your Name
-- Date: 2018-03-07 16:13:23
--

local PwsDeadTipsView = class("PwsDeadTipsView", base.BaseView)

function PwsDeadTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function PwsDeadTipsView:initData()
    local desTxt = self.view:GetChild("n6")
    desTxt.text = language.qualifier61
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local sureBtn = self.view:GetChild("n5")
    self:setCloseBtn(sureBtn)
end

return PwsDeadTipsView