--
-- Author: 
-- Date: 2018-08-13 11:11:50
--
local ScratchConf = class("ScratchConf",base.BaseConf)

function ScratchConf:init()
    self:addConf("ggl_lottery")
    self:addConf("ggl_cost")--消耗
    self:addConf("ggl_global")
end



function ScratchConf:getGGLShowAward()
    local data = {}
    for k,v in pairs(self.ggl_lottery) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ScratchConf:getDataById(id)
    return self.ggl_cost[tostring(id)]
end

function ScratchConf:getValue(id)
    return self.ggl_global[id..""]
    
end


return ScratchConf