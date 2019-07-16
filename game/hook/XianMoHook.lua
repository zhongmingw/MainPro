--
-- Author: 
-- Date: 2017-08-31 19:54:55
--

local XianMoHook = class("XianMoHook", import(".BaseHook"))

function XianMoHook:ctor()
    self.hookType = 1  --挂机状态 1-随机打 2-追随打 3-追击打
    self.hookData = {code = 1, info = nil}
    self.surchPoint = {{6034,2536},{1862,1614},{3508,907},{4350,3336}}  -- 如果搜不到目标随机点巡逻
    self.surchIndex = 0
end

function XianMoHook:enter()
    self.super.enter(self)
    self.moveDo = HookMoveDo.fight
    -- 默认进入挂机，
    -- 如果同屏有玩家随机一个攻击
    -- 否则发送sendFind 服务端通知坐标
    local _ , point = self:getSceneExitPlayer()
    if point then
        self:setHookPoint(point)
        self:changeState(HookState.idle)
        self:update()
    else
        self:sendFind(1)
    end
end

function XianMoHook:setHookData(data)
    local code = data.code
    local info = data.info
    self.hookData = data
    if code == 1 then --随便打
        local pox,poy = info.pox,info.poy
        if pox == 0 and poy == 0 then  -- 中心点集合开干
            self.surchIndex = self.surchIndex%3 + 1
            local goPoint = self.surchPoint[self.surchIndex]
            pox = goPoint[1]
            poy = goPoint[2]
        end
        self:setHookPoint(Vector3.New(pox, gRolePoz, poy))
        self:changeState(HookState.idle)
    elseif code == 2 then--追随
        self.firstWeId = info.roleId
        local pox,poy = info.pox,info.poy
        --TODO 目标是自己，就直接进入普通挂机
        if info.roleId == cache.PlayerCache:getRoleId() then
            GComAlter(language.xianmoWar15)
            self:changeState(HookState.moveComplete)
            return
        end
        --TODO 没有目标，就直接进入普通挂机
        if pox == 0 and poy == 0 then
            GComAlter(language.xianmoWar16)
            self:changeState(HookState.moveComplete)
            return
        end

        self:goToFindPlayer(info)
    elseif code == 3 then--追杀
        self.firstEnemyId = info.roleId
        local pox,poy = info.pox,info.poy
        --TODO 没有目标，就直接进入普通挂机
        if pox == 0 and poy == 0 then
            GComAlter(language.xianmoWar16)
            self:changeState(HookState.moveComplete)
            return
        end

        self:goToFindPlayer(info)
    end
end

function XianMoHook:goToFindPlayer(info)
    local pos
    local tar = mgr.ThingMgr:getObj(ThingType.player, info.roleId)
    if tar then  --目标在同屏
        pos = tar:getPosition()
    else
        pos = Vector3.New(info.pox, gRolePoz, info.poy)
    end
    self:setHookPoint(pos)
    self:changeState(HookState.idle)
end

function XianMoHook:hookBreak(point)
    local _ , point = self:getSceneExitPlayer()
    if point then
        self:setHookPoint(point)
        self:changeState(HookState.idle)
    else
        self:sendFind(1)
    end
end

function XianMoHook:checkMove()
    if not self.hookData then return end
    local code = self.hookData.code
    local info = self.hookData.info
    if code == 1 then
        local t,info = mgr.ThingMgr:getNearTar()
        if t and t:getGridValue() ~= 7 then
            self:setLockThing(nil, nil)
            self:changeState(HookState.moveComplete)
        end
    elseif code == 2 then
        local weTar = mgr.ThingMgr:getObj(ThingType.player, info.roleId)
        if weTar then
            self:setHookPoint(weTar:getPosition())
            self:changeState(HookState.idle)
        end
    elseif code == 3 then
        local enemyTar = mgr.ThingMgr:getObj(ThingType.player, info.roleId)
        if enemyTar then
            self:setLockThing(ThingType.player, info.roleId)
            self:changeState(HookState.moveComplete)
        end
    end
end

function XianMoHook:checkCanAttack()
    if not self.hookData then return end
    local code = self.hookData.code
    local info = self.hookData.info
    
    -- 如果找到追杀目标则追击  -- 否则直接攻击周围目标
    if code == 3 then  
        local enemyTar = mgr.ThingMgr:getObj(ThingType.player, info.roleId)
        if enemyTar and enemyTar:getGridValue() ~= 7 then
            self:setLockThing(ThingType.player, info.roleId)
            return true
        end
    end

    -- 如果找到追随目标则追随  -- 否则直接攻击周围目标
    if code == 2 then  
        -- local weTar = mgr.ThingMgr:getObj(ThingType.player, info.roleId)
        -- if weTar then
        --     self:setHookPoint(weTar:getPosition())
        --     self:changeState(HookState.idle)
        --     return false
        -- end
    end

    -- 攻击周围可攻击目标  -- 否则搜索同屏玩家
    local tar = mgr.ThingMgr:getNearTar()
    if tar and tar:getGridValue() ~= 7 then
        return true
    end

    -- 寻找同屏可攻击目标  -- 否则发送服务端获取坐标
    local _ , point = self:getSceneExitPlayer()
    if point then
        self:setHookPoint(point)
        self:changeState(HookState.idle)
    else
        self:sendFind(1)
    end
end

function XianMoHook:sendFind(code)
    proxy.XianMoProxy:send(1420104,{reqType = code})
end


return XianMoHook