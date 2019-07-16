--
-- Author: 
-- Date: 2017-10-23 17:20:17
--

local ShoutaHook = class("ShoutaHook",import(".BaseHook"))

function ShoutaHook:ctor()
   self.centerPoint = Vector3.New(1779,gRolePoz,1575)
end

function ShoutaHook:enter()
    self.super.enter(self)
    if self:mInRange() then
        self:changeState(HookState.moveComplete)
    else
        self.hookPoint = self.centerPoint
        self:changeState(HookState.idle)
    end
    self:update()
end

--怪物是否在警戒范围内
function ShoutaHook:mInRange()
    local tar = mgr.ThingMgr:getNearTar()
    if tar then
        local distance = GMath.distance(tar:getPosition(), self.centerPoint)
        if distance < 700 then
            return true
        end
    end
    return false
end

function ShoutaHook:rInRange()
    local distance = GMath.distance(gRole:getPosition(), self.centerPoint)
    if distance < 700 then
        return true
    end
    return false
end


function ShoutaHook:checkCanAttack()
    if self:mInRange() then
        return true
    else
        self.hookPoint = self.centerPoint
        self:changeState(HookState.idle)
        -- if not self:rInRange() then
        --     self.hookPoint = self.centerPoint
        --     self:changeState(HookState.idle)
        -- else
        --     local exit = self:getSceneExitMonster()
        --     if not exit then
        --         self.hookPoint = self.centerPoint
        --         self:changeState(HookState.idle)
        --     end 
        -- end
    end
    return false
end

return ShoutaHook