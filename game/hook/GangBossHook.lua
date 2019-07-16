--
-- Author: yr
-- Date: 2017-07-18 21:18:08
--

local GangBossHook = class("GangBossHook", import(".BaseHook"))

function GangBossHook:ctor()
    
end

function GangBossHook:enter(data)
    self.super.enter(self)
    if data then
        self.hookPoint = data.point
    else   --默认顺序
        local bossList = cache.GangWarCache:getBossList()
        local disList = {}
        for k,v in pairs(bossList) do
            if v.x ~= 0 and v.y ~= 0 then
                local pos = Vector3.New(v.x,gRolePoz,v.y)
                local distance = GMath.distance(gRole:getPosition(), pos)
                local data = {pos = pos,distance = distance}
                table.insert(disList, data)
            end
        end
        if #disList > 0 then
            table.sort(disList, function(a, b)
                return a.distance < b.distance
            end)
            self.hookPoint = disList[1].pos
        end
    end
    self:update()
end

function GangBossHook:checkMove()
    
end

function GangBossHook:checkCanAttack()
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    for k, v in pairs(things) do
        self:setLockThing(ThingType.monster, k)
        return true
    end
    return false
end

function GangBossHook:update()
    self.super.update(self)
end


return GangBossHook