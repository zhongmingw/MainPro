--
-- Author: yr
-- Date: 2017-04-25 16:09:49
--

local XingNengConf = class("XingNengConf",base.BaseConf)

function XingNengConf:ctor()
    self:addConf("xingneng")
end

function XingNengConf:getInfoById(id)
    return self.xingneng[tostring(id)]
end

return XingNengConf