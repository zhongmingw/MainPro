--
-- Author: 
-- Date: 2017-02-06 17:30:21
--

local SkillProxy = class("SkillProxy",base.BaseProxy)

function SkillProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5110101,self.add5110101)
    self:add(5110102,self.add5110102)
    self:add(5110106,self.add5110106)
end


function SkillProxy:add5110101(data)
    -- body
    if data.status == 0 then
        
        local view = mgr.ViewMgr:get(ViewName.SkillView)
        if view then
            view:add5110101(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function SkillProxy:add5110102( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SkillView)
        if view then
            view:add5110102(data,true)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function SkillProxy:add5110106(data)
    -- body
    if data.status == 0 then
        
        local view = mgr.ViewMgr:get(ViewName.SkillView)
        if view then
            view:add5110106(data.skills)
        end
    else
        GComErrorMsg(data.status)
    end 
end
return SkillProxy