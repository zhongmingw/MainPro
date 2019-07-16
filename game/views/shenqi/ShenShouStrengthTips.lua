--
-- Author: Your Name
-- Date: 2018-09-03 22:01:45
--神兽双倍强化提示
local ShenShouStrengthTips = class("ShenShouStrengthTips", base.BaseView)

function ShenShouStrengthTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ShenShouStrengthTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local cancelBtn = self.view:GetChild("n4")
    self:setCloseBtn(cancelBtn)
    local sureBtn = self.view:GetChild("n3")
    sureBtn.onClick:Add(self.onClickSure,self)
    self.costYb = self.view:GetChild("n7")
end

function ShenShouStrengthTips:initData(data)
    self.data = data
    self.costYb.text = data.costYb or 0
end

function ShenShouStrengthTips:onClickSure()
    if self.data then
        proxy.ShenShouProxy:sendMsg(1590105,self.data)
        self:closeView()
    end
end

return ShenShouStrengthTips