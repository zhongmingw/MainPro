--
-- Author: bxp
-- Date: 2018-10-24 14:37:46
--降妖除魔挂机

local XycmHook = class("XycmHook",import(".BaseHook"))

function XycmHook:ctor()
    
end
local hasDropItem = false
function XycmHook:enter()
    self.super.enter(self)
    self.moveDo = HookMoveDo.pick
    self:changeState(HookState.moveComplete)
    -- if self:iaDropItem() then
    --     self:goPick()
    -- else
    --     if self:mInRange() then
    --         self:changeState(HookState.moveComplete)
    --     else
    --         self:changeState(HookState.findMonster)
    --     end
    --     -- self:change()
    -- end
    self:update()
end

-- function XycmHook:update()
--     -- if self:checkState(HookState.idle) or self:checkState(HookState.moveBreak) then
--     --     if self.hookPoint then
--     --         local p = self.hookPoint
--     --         self:startMoveToPoint(p)
--     --     end
--     -- elseif self:checkState(HookState.moveComplete) then  --移动完成
--     --     if self.moveDo == HookMoveDo.pick then
--     --         self:checkPick()
--     --     elseif self.moveDo == HookMoveDo.fight then
--     --         self:startAttack()
--     --     end
--     -- elseif self:checkState(HookState.findMonster) then  --寻找怪物
--     --     local _ , point = self:getSceneExitMonster()
--     --     if point then
--     --         self.hookPoint = point
--     --         self:changeState(HookState.idle)
--     --         self:update()
--     --     end
--     -- end
--     -- print("self:iaDropItem()",self:iaDropItem())
--     -- if self:iaDropItem() then
--     --     self:goPick()
--     -- else
--     --     print("self:mInRange()",self:mInRange())
--     --     if self:mInRange() then
--     --         self.moveDo = HookMoveDo.fight
--     --         self:changeState(HookState.moveComplete)
--     --     else
--     --         self:changeState(HookState.findMonster)
--     --     end
--     --     self:change()
--     -- end
-- end

function XycmHook:change()
    
end

--周围是否有怪物或者可攻击玩家
function XycmHook:mInRange()
    local tar = mgr.ThingMgr:getNearTar()
    if tar then
        return true
    end
    return false
end
--周围有采集物
function XycmHook:checkPick()
    -- hasDropItem = false
    local monsterList = mgr.ThingMgr:objsByType(ThingType.monster)
    local flag = false
    if monsterList then
        local posList = {}
        local distanceList = {}
        for k,v in pairs(monsterList) do
            if v.data and v.data.kind and v.data.kind ==  MonsterKind.chest then
                table.insert(posList,{roleId = v.data.roleId, x = v.data.pox,y = v.data.poy})
            end
        end
        for k,v in pairs(posList) do
            local distance = GMath.distance(gRole:getPosition(), Vector3.New(v.x,gRolePoz,v.y))
            table.insert(distanceList,{roleId = v.roleId ,distance = distance})
        end
        table.sort(distanceList,function ( a,b )
            if a.distance ~= b.distance then
                return a.distance < b.distance 
            end
        end )
        if #distanceList > 0 then
            local nearRoleId = distanceList[1].roleId
            --最近的宝箱
            self.monster = mgr.ThingMgr:getObj(ThingType.monster, nearRoleId)
            if self.monster then
                flag = true
            end
        end
    end
    if flag then
        self.moveDo = HookMoveDo.pick
        self:startPick()
    else
        self.moveDo = HookMoveDo.fight
    end
end

-- function XycmHook:startPick()
--     -- body
-- end

function XycmHook:startPick()
    local data = self.monster.data
    local p = Vector3.New(data.pox, gRolePoz, data.poy)
    if data.kind == MonsterKind.chest then
        gRole:moveToPoint(p, PickDistance, function()
            self.moveDo = HookMoveDo.pick
            gRole:collect(function(state)
            end)
            if not mgr.ViewMgr:get(ViewName.PickAwardsView) then
                local func = function() end
                local pickUseTime = nil
                if data.kind == MonsterKind.chest then--宝箱
                    func = function()
                        proxy.FubenProxy:send(1810301,{tarPox = data.pox,tarPoy = data.poy})--拾取
                        gRole:idleBehaviour()
                    end
                end
                local data2 = {monsterData = data,pickUseTime = pickUseTime,func = func}
                mgr.ViewMgr:openView2(ViewName.PickAwardsView, data2)
            end
        end)
    else
        self.moveDo = HookMoveDo.fight
    end
end

function XycmHook:checkCanAttack()
    if self:mInRange() then
        self.moveDo = HookMoveDo.fight
        return true
    else
        self.moveDo = HookMoveDo.pick
    end
    return false
end

return XycmHook