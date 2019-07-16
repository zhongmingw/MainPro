--
-- Author: ohf
-- Date: 2017-02-28 10:47:14
--
--剑神弹窗
local AwakenTipView = class("AwakenTipView", base.BaseView)

function AwakenTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function AwakenTipView:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.panelObj1 = self.view:GetChild("n11")--剑神技能
end

function AwakenTipView:setData(data)
    self.mData = data
    self:initPanel()
end
--剑神技能
function AwakenTipView:initPanel()
    local skillId = self.mData.skillId
    local index = self.mData.index
    self.panelObj1.visible = true
    local skillPanel = self.view:GetChild("n1")
    local skillIcon = skillPanel:GetChild("n2")
    local skillLv = skillPanel:GetChild("n3")

    local iconId = conf.SkillConf:getSkillIcon(skillId)
    skillIcon.url = ResPath.iconRes(iconId) -- UIPackage.GetItemURL("_icons" , ""..iconId)
    local skillName = self.view:GetChild("n2")
    local name = conf.SkillConf:getSkillName(skillId)
    skillName.text = name
    local starLev = conf.AwakenConf:getIdByStarLv(self.mData.starlv)--当前阶对应id
    local curEffect = self.view:GetChild("n6")--当前效果
    local curSkill = conf.AwakenConf:getSkillLv(starLev)
    skillLv.text = "Lv."..self.mData.level
    local descData = conf.AwakenConf:getAwakenSkill(self.mData.starlv)
    -- print(">>>>>>>>>>>>>>>>>>>>>>",index,self.mData.starlv)
    curEffect.text = descData["skill_desc"..index]
    local nextEffect = self.view:GetChild("n9")--下级效果
    local maxLvImg = self.view:GetChild("n10")--已满级标识
    maxLvImg.visible = false
    local jie = self.mData.starlv + 1--下一阶
    local jieId = conf.AwakenConf:getIdByStarLv(jie)--下一阶对应id
    local nextDescData = conf.AwakenConf:getAwakenSkill(jie)

    local nextTitleDesc = self.view:GetChild("n12")--下级升级需要条件
    local desc3 = self.view:GetChild("n14")

    local dian1 = self.view:GetChild("n8")
    local dian2 = self.view:GetChild("n13")
    if jie <= conf.AwakenConf:getEndMaxJie() then
        dian1.visible = true
        dian2.visible = true
        nextEffect.visible = true
        desc3.visible = true
        nextEffect.text = nextDescData["skill_desc"..index]
        desc3.text = string.format(language.awaken09, jie)
    else--已满级
        dian1.visible = false
        dian2.visible = false
        nextEffect.visible = false
        maxLvImg.visible = true
        nextTitleDesc.visible = false
        desc3.visible = false
    end
    
end

return AwakenTipView