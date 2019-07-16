local FightConf = class("FightConf",base.BaseConf)

function FightConf:ctor()
    self:addConf("skill_config")
    self:addConf("area_config")
end

function FightConf:getSkillById(id)
    return self.skill_config[id..""]
end

function FightConf:getAreaById(id)
    return self.area_config[id..""]
end


return FightConf