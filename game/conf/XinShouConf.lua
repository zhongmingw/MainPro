--
-- Author: yr
-- Date: 2017-03-28 21:53:23
--

local XinShouConf = class("XinShouConf",base.BaseConf)

function XinShouConf:ctor()
    self:addConf("open_module")
    self:addConf("remind_module")
end

function XinShouConf:getOpenModule(id)
    if not id then
        return nil 
    end
    return self.open_module[id..""]
end

function XinShouConf:getRemindModule()
    local t = table.values(self.remind_module)
    table.sort(t,function(a,b)
        -- body
        return a.sort < b.sort
    end)
    return t
end


return XinShouConf