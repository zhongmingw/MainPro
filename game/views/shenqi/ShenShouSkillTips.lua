--
-- Author: Your Name
-- Date: 2018-09-05 11:58:24
--神兽技能弹框
local ShenShouSkillTips = class("ShenShouSkillTips", base.BaseView)

function ShenShouSkillTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ShenShouSkillTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.iconItem = self.view:GetChild("n1")
    self.nameTxt = self.view:GetChild("n2")
    self.kindTxt = self.view:GetChild("n3")
    self.decTxt = self.view:GetChild("n4")
end

function ShenShouSkillTips:initData(data)
    if data then
        local icon = self.iconItem:GetChild("n2")
        icon.url = UIPackage.GetItemURL("_icons" , data.icon)
        self.nameTxt.text = data.name
        self.kindTxt.text = language.pet16 .. data.kind
        self.decTxt.text = data.desc
    end
end

return ShenShouSkillTips