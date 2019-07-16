--
-- Author: Your Name
-- Date: 2018-08-23 11:10:29
--天晶洞窟挂机
local tjdkHook = class("tjdkHook",import(".BaseHook"))

function tjdkHook:ctor()

end

function tjdkHook:enter()
    self.super.enter(self)
    self.moveDo = HookMoveDo.fight
    if self:mInRange() then
        self:changeState(HookState.moveComplete)
    else
        self:changeState(HookState.findMonster)
    end
    self:update()
end

--周围是否有怪物或者可攻击玩家
function tjdkHook:mInRange()
    local tar = mgr.ThingMgr:getNearTar()
    if tar then
        return true
    end
    return false
end

function tjdkHook:checkCanAttack()
    if self:mInRange() then
        return true
    else
        self:changeState(HookState.moveComplete)
    end
    return false
end

return tjdkHook