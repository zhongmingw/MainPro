--
-- Author: yr
-- Date: 2017-01-17 21:12:34
--

local MonsterConf = class("MonsterConf",base.BaseConf)

function MonsterConf:ctor()
    self:addConf("monster")
end

function MonsterConf:getInfoById(id)
    if not self.monster[tostring(id)] then
        --self:error(id)
        return
    end
    return self.monster[tostring(id)]
end

return MonsterConf