--
-- Author: Your Name
-- Date: 2018-12-18 16:34:29
--

local YiJiTanSuoTips = class("YiJiTanSuoTips", base.BaseView)

function YiJiTanSuoTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function YiJiTanSuoTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local cancelBtn = self.view:GetChild("n2")
    self:setCloseBtn(cancelBtn)

    local sureBtn = self.view:GetChild("n1")
    sureBtn.onClick:Add(self.onClickSure,self)
    self.decTxt = self.view:GetChild("n4")
end

function YiJiTanSuoTips:initData(data)
    self.data = data
    self.decTxt.text = data.richText
end

function YiJiTanSuoTips:onClickSure()
    if self.data and self.data.func then
        self.data.func()
    end
    self:closeView()
end

return YiJiTanSuoTips