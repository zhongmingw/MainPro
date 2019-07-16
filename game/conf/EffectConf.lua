local EffectConf = class("EffectConf", base.BaseConf)

function EffectConf:ctor()
    self:addConf("effect_config")
end

function EffectConf:getEffectById(id)
    return self.effect_config[id..""]
end

return EffectConf