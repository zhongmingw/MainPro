--
-- Author: 
-- Date: 2017-02-06 17:30:21
--

local TalentProxy = class("TalentProxy",base.BaseProxy)

function TalentProxy:init()
    self:add(5110103,self.add5110103)
    self:add(5110104,self.add5110104)
    self:add(5110105,self.add5110105)
end


function TalentProxy:add5110103(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SkillView)
        if view then
            view:add5110103(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function TalentProxy:add5110104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SkillView)
        if view then
            view:add5110104(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function TalentProxy:add5110105( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SkillView)
        if view then
            view:add5110105(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

return TalentProxy