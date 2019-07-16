--
-- Author: yr
-- Date: 2017-07-18 22:17:04
--

local WenDingHook = class("WenDingHook", import(".BaseHook"))

function WenDingHook:ctor()
    
end

function WenDingHook:enter()
    self.super.enter(self)
    self:restHook()
    self:update()
end

function WenDingHook:restHook()
    local sId = cache.PlayerCache:getSId()
    local conds = cache.WenDingCache:getConds()
    local sceneNum = tonumber(string.sub(sId,6,6)) --当前层数
    local flagHoldRoleId = cache.WenDingCache:getflagHoldRoleId()
    if sceneNum > 8 and flagHoldRoleId ~= cache.PlayerCache:getRoleId() then
        local isOver = cache.WenDingCache:getWendingOver()
        if not isOver then
            proxy.WenDingProxy:send(1350104,{reqType = 4})
        end
    else
        self:changeState(HookState.moveComplete)
    end
end

function WenDingHook:hookBreak(point)
    self:restHook()
end

function WenDingHook:moveBreakHandler()
    self:changeState(HookState.moveComplete)
end

function WenDingHook:setHookData(data)
    local code = data.code
    local info = data.info
    if code == 1 then    --1350105返回
        local pos = info.pos
        if pos.pox ~= 0 and pos.poy ~= 0 then
            self:setHookPoint(Vector3.New(pos.pox, gRolePoz, pos.poy))
            self.moveDo = HookMoveDo.fight
            self:changeState(HookState.idle)
        else
            -- print("移动类型",self.moveDo)
            -- print(debug.traceback())
            self.moveDo = HookMoveDo.fight
            self:changeState(HookState.findPlayer)
        end
    elseif code == 2 then  --5350104
        local pox,poy = info.pox,info.poy
        local distance = 100
        if pox == 0 and poy == 0 then
            local warFlag = conf.NpcConf:getNpcById(3090201)
            -- print("战旗刷新 捡旗子",warFlag)
            if warFlag then
                pox,poy = warFlag.pos[1],warFlag.pos[2]
                self:setHookPoint(Vector3.New(pox, gRolePoz, poy))
                self.moveDo = HookMoveDo.pick
                self:changeState(HookState.idle)
            end
        else
            self:setHookPoint(Vector3.New(pox, gRolePoz, poy))
            self.moveDo = HookMoveDo.fight
            self:changeState(HookState.idle)
        end
    end
end

--是否有可攻击对象 1-有攻击对象可以攻击，2-附近有玩家需要移动 3-附近都没有玩家需要服务器告知哪里有玩家
function WenDingHook:isHasTarget()
    local sId = cache.PlayerCache:getSId()
    local sceneNum = tonumber(string.sub(sId,6,6)) --当前层数
    local flagHoldRoleId = cache.WenDingCache:getflagHoldRoleId()
    if sceneNum > 8 then
        if flagHoldRoleId ~= cache.PlayerCache:getRoleId() then
            local isOver = cache.WenDingCache:getWendingOver()
            if not isOver then
                local player = mgr.ThingMgr:getObj(ThingType.player, flagHoldRoleId)
                if player then
                    self:setLockThing(ThingType.player, flagHoldRoleId)
                    return 1
                end
            end
        end
        local t,info = mgr.ThingMgr:getNearTar()
        if t then
            self:setLockThing(nil, nil)
            return 1
        end
    else
        local t,info = mgr.ThingMgr:getNearTar()
        if t then
            self:setLockThing(nil, nil)
            return 1
        end
        local _ , point = self:getSceneExitPlayer()
        if point then
            self:setHookPoint(point)
            self:changeState(HookState.idle)
            return 3
        end
    end
    return 2
end

function WenDingHook:checkMove()
    if self:isHasTarget() == 1 then
        self:changeState(HookState.moveComplete)
    end
end

function WenDingHook:checkCanAttack()
    local exit = self:isHasTarget()
    if exit == 1 then
        return true
    elseif exit == 2 then
        local fbId = cache.PlayerCache:getSId()
        proxy.WenDingProxy:sendMsg(1350105,{sceneId = fbId})
        return false
    else
        return false
    end
end

function WenDingHook:startPick()
    self.super.startPick(self)
    local roleId = 0
    local objs = mgr.ThingMgr:objsByType(ThingType.monster)
    for k,v in pairs(objs) do
        if v.data.kind == MonsterKind.collection then
            roleId = v.data.roleId
            break
        end
    end
    -- print("开始采集",roleId)
    proxy.FubenProxy:send(1810302,{roleId = roleId,reqType = 1})
end

return WenDingHook