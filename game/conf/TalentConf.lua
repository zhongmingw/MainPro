--
-- Author: 
-- Date: 2017-02-06 17:22:29
--
local TalentConf = class("TalentConf",base.BaseConf)

function TalentConf:init()
    self:addConf("talent_tree")
    self:addConf("talent_skill_attr")
    self:addConf("talent_global")
end

function TalentConf:getTalentTree()
    return self.talent_tree
end

function TalentConf:getTalentSkillAttr()
    return self.talent_skill_attr
end

function TalentConf:getTalentGlobal()
    return self.talent_global
end

return TalentConf