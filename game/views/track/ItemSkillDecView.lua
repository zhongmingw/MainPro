--
-- Author: 
-- Date: 2017-12-26 20:31:02
--

local ItemSkillDecView = class("ItemSkillDecView", base.BaseView)

function ItemSkillDecView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ItemSkillDecView:initView()
    self:setCloseBtn(self.view)
    self.desc = self.view:GetChild("n2")
end

function ItemSkillDecView:initData(data)
    local skillAffectId = conf.ItemConf:getSkillAffectId(data.mid)
    local confData = conf.SkillConf:getSkillByIndex(skillAffectId)
    self.desc.text = confData and confData.dec or ""
end

return ItemSkillDecView