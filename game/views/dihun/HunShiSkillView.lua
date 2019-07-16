--
-- Author:bxp 
-- Date: 2018-11-28 15:22:42
--魂饰技能

local HunShiSkillView = class("HunShiSkillView", base.BaseView)

function HunShiSkillView:ctor()
    HunShiSkillView.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function HunShiSkillView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local itemSkill = self.view:GetChild("n1")
    self.icon = itemSkill:GetChild("n2")

    self.name = self.view:GetChild("n2")
    self.name.text = ""

    self.type = self.view:GetChild("n3")
    self.type.text = language.dihun20

    self.desc = self.view:GetChild("n4")
    self.desc2 = self.view:GetChild("n7")

end

function HunShiSkillView:initData(data)
    self.data = data
    self.icon.url = ResPath.iconRes(self.data.skill_icon) 
    self.name.text = self.data.name 

    self.desc.text = self.data.desc or ""

    local dhInfo = cache.DiHunCache:getDiHunInfoByType(data.type)
    local nowLv = 0--当前等级
    for k,v in pairs(dhInfo.partInfo) do
        nowLv = nowLv +v.strenLevel
    end
    local color = nowLv >= data.level and 7 or 14

    local str1 = language.dihun01[data.type+1]
    local str2 = mgr.TextMgr:getTextColorStr(nowLv,color)..mgr.TextMgr:getTextColorStr("/"..data.level,7)

    self.desc2.text = string.format(language.dihun19,str1,str2)

end

return HunShiSkillView