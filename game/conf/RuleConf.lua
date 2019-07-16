local RuleConf = class("RuleConf",base.BaseConf)

function RuleConf:ctor()
    self:addConf("rule_config")
end

function RuleConf:getRuleById(id)
    return self.rule_config[id..""]
end

return RuleConf