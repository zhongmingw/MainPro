--
-- Author: 
-- Date: 2017-04-15 11:10:47
--
local HpConf = class("HpConf",base.BaseConf)

function HpConf:init()
    self:addConf("hp_color")
end

function HpConf:getHpData(id)
    return self.hp_color[tostring(id)]
end

return HpConf