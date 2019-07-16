--
-- Author: 
-- Date: 2017-09-22 10:53:30
--

local AwakenBossHook = class("AwakenBossHook", import(".BaseHook"))

function AwakenBossHook:ctor()
    
end

function AwakenBossHook:enter(data)
    self.super.enter(self)
    if data then
        self.hookPoint = data.point
    else   --默认顺序
        local bossList = cache.AwakenCache:getBossList()
        local disList = {}
        for k,v in pairs(bossList) do
            if v.pox ~= 0 and v.poy ~= 0 then
                local pos = Vector3.New(v.pox,gRolePoz,v.poy)
                local distance = GMath.distance(gRole:getPosition(), pos)
                local data = {pos = pos,distance = distance}
                table.insert(disList, data)
            end
        end
        if #disList > 0 then
            local pos = nil
            local distance = disList[1].distance
            for k,v in pairs(disList) do
                if v.distance <= distance then pos = v.pos end
            end
            if pos then self.hookPoint = pos end
        end
    end
    self:update()
end

function AwakenBossHook:checkMove()
    
end

function AwakenBossHook:checkCanAttack()
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    for k, v in pairs(things) do
        self:setLockThing(ThingType.monster, k)
        return true
    end
    return false
end

function AwakenBossHook:update()
    self.super.update(self)
end

return AwakenBossHook