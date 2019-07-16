--
-- Author: yr
-- Date: 2017-02-28 22:05:02
--

local BuffConf = class("BuffConf", base.BaseConf)

function BuffConf:ctor()
    self:addConf("buff_affect")
end

function BuffConf:getBuffConf(id)
    return self.buff_affect[id..""]
end

return BuffConf