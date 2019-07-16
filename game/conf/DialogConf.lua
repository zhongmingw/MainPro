--
-- Author: 
-- Date: 2017-01-10 10:59:38
--
local DialogConf = class("DialogConf",base.BaseConf)

function DialogConf:init()
    self:addConf("dialog_config")
end

function DialogConf:getDataById(id)
    -- body
    return self.dialog_config[id..""] 
end

return DialogConf