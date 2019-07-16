--
-- Author: 
-- Date: 2018-12-17 16:50:05
--

local MianJuSkillView = class("MianJuSkillView", base.BaseView)

function MianJuSkillView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function MianJuSkillView:initView()
     local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.iconItem = self.view:GetChild("n1")
    self.text01 = self.view:GetChild("n3")-- 技能名
    self.text02 = self.view:GetChild("n7")-- 技能等级
    self.text03 = self.view:GetChild("n5"):GetChild("n0")-- 技能描述



end

function MianJuSkillView:initData(data)
     if data then
        local icon = self.iconItem:GetChild("n2")
        icon.url = UIPackage.GetItemURL("shenqi" ,data.icon)
        self.text01.text = data.name
        self.text02.text = "LV.".."[color=#0b8109]"..data.lv.."[/color]"
        self.text03.text = data.desc
    end
end

return MianJuSkillView