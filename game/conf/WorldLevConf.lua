--世界等级配置
local WorldLevConf = class("WorldLevConf",base.BaseConf)

function WorldLevConf:init()
    self:addConf("worldlev_global")
    self:addConf("worldlev")
end

function WorldLevConf:getAdditionById( id )
    local addition = self.worldlev[tostring(id)].exp_per
    addition = addition + self.worldlev_global.basic_exp_per
    return addition
end

function WorldLevConf:getBaseExpPer()
    return self.worldlev_global.basic_exp_per
end

return WorldLevConf