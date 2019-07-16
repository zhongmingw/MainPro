--
-- Author: yr
-- Date: 2017-07-19 12:08:01
--

local TaskHook = class("TaskHook", import(".BaseHook"))

function TaskHook:ctor()
    
end

function TaskHook:enter()
    self.super.enter(self)
    self:changeState(HookState.moveComplete)
    self:startAttack()
end

function TaskHook:checkCanAttack()
    return true
end


return TaskHook