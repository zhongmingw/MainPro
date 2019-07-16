--
-- Author:bxp 
-- Date: 2018-11-28 16:20:47
--帝魂技能

local DiHunSkillView = class("DiHunSkillView", base.BaseView)

function DiHunSkillView:ctor()
    DiHunSkillView.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function DiHunSkillView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)
    self.leftPanel = self.view:GetChild("n1")
    self.righPanel = self.view:GetChild("n2")
    self.c1 = self.view:GetController("c1")
end

function DiHunSkillView:initData(data)
    self:setLeftPanel(data.id)
    self:setRightPanel(data.id + 1)
end


function DiHunSkillView:setLeftPanel(id)
    local skillConf = conf.DiHunConf:getDhSkillById(id)
    local skillbtn = self.leftPanel:GetChild("n1")
    skillbtn.icon = ResPath.iconRes(skillConf.skill_icon)
    -- local str = skillConf.level == 0 and "" or  "Lv."..mgr.TextMgr:getTextColorStr(skillConf.level ,7)
    skillbtn.title = skillConf.name.."Lv."..mgr.TextMgr:getTextColorStr(skillConf.level ,7)
    --描述
    local ms = self.leftPanel:GetChild("n4")
    ms.text = skillConf.ms

    local dec = self.leftPanel:GetChild("n5")
    
    dec.text = "当前技能"
end

function DiHunSkillView:setRightPanel(id)
    local lastSkillConf = conf.DiHunConf:getDhSkillById(id-1)
    local skillConf = conf.DiHunConf:getDhSkillById(id)
    local skillbtn = self.righPanel:GetChild("n1")
    local ms = self.righPanel:GetChild("n4")
    local dec = self.righPanel:GetChild("n5")
    if skillConf then
        skillbtn.icon = ResPath.iconRes(skillConf.skill_icon)
        -- local str = skillConf.level == 0 and "" or  "Lv."..mgr.TextMgr:getTextColorStr(skillConf.level ,7)
        skillbtn.title = skillConf.name.."Lv."..mgr.TextMgr:getTextColorStr(skillConf.level ,7)
        ms.text = skillConf.ms
        if id %1000 == 1 then
            dec.text = language.dihun09
            self.c1.selectedIndex = 2--未激活
        else
            self.c1.selectedIndex = 0--正常
            dec.text = string.format(language.dihun10,(id%1000)-1)
        end
    else
        self.c1.selectedIndex = 1--满级
        if lastSkillConf then
            skillbtn.icon = ResPath.iconRes(lastSkillConf.skill_icon)
            -- local str = lastSkillConf.level == 0 and "" or  "Lv."..mgr.TextMgr:getTextColorStr(lastSkillConf.level ,7)
            skillbtn.title =  lastSkillConf.name.."Lv."..mgr.TextMgr:getTextColorStr(lastSkillConf.level ,7)
            ms.text = lastSkillConf.ms
        end
        dec.text = language.skill08
    end
end


return DiHunSkillView