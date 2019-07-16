--
-- Author:ohf 
-- Date: 2017-01-22 15:58:19
--
--
local GrowthProxy = class("GrowthProxy",base.BaseProxy)

function GrowthProxy:init()
    self:add(5020301,self.add5020301)
end

--请求
function GrowthProxy:send_1020301()
    self:send(1020301)
end

function GrowthProxy:add5020301(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.GrowthView)
        if view then
            view:add5020301(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

return GrowthProxy