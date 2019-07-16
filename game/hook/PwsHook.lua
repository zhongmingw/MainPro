--
-- Author: 
-- Date: 2018-01-17 12:14:30
-- 排位赛挂机，寻找最近的敌人挂机

local PwsHook = class("PwsHook", import(".BaseHook"))

function PwsHook:ctor()
    
end

function PwsHook:enter()
    self.super.enter(self)
    self.moveDo = HookMoveDo.fight
    -- 默认进入挂机，
    -- 如果同屏有玩家随机一个攻击
    -- 否则发送sendFind 服务端通知坐标
    -- local _ , point = self:getSceneExitPlayer()
    -- if point then
    --     self:setHookPoint(point)
    --     self:changeState(HookState.idle)
    --     self:update()
    -- else
        self:sendFind()
    -- end
    self:update()
end

function PwsHook:setHookData(data)
    -- printt("敌方玩家位置信息返回",data.otherPos)
    self.hookData = data
    self.pos = {x = 0,z = 0}
    for _,p in pairs(data.otherPos) do
        self.pos.x = p.pox
        self.pos.z = p.poy
        break
    end
    if self.pos.x == 0 and self.pos.z == 0 then--没有敌方玩家
        -- GComAlter(language.xianmoWar16)
        self:changeState(HookState.moveComplete)
        return
    else
        self:setHookPoint(self.pos)
        self:changeState(HookState.idle)
    end
end

function PwsHook:checkMove()
    if not self.hookData then return end
    local enemys = self.hookData.enemys
    -- printt("敌人信息",enemys)
    if enemys then
        local flag = false
        local enemyRoleId = nil
        for k,v in pairs(enemys) do
            local enemyTar = mgr.ThingMgr:getObj(ThingType.player, v)
            if enemyTar then
                flag = true
                enemyRoleId = v
            end
        end
        if flag then
            self:setLockThing(ThingType.player, enemyRoleId)
            self:changeState(HookState.moveComplete)
        else
            self:sendFind()
        end
    else
        local t,info = mgr.ThingMgr:getNearTar()
        if t then
            self:setLockThing(nil, nil)
            self:changeState(HookState.moveComplete)
        else
            self:sendFind()
        end
    end
end

function PwsHook:sendFind()
    -- print("请求寻找敌方玩家位置")
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isPlayoffPaiWeiSai(sId) then
        proxy.QualifierProxy:sendMsg(1480304)
    elseif mgr.FubenMgr:isTeamPaiWeiSai(sId) then
        proxy.QualifierProxy:sendMsg(1480214)
    elseif mgr.FubenMgr:isPaiWeiSai(sId) then
        proxy.QualifierProxy:sendMsg(1480108)
    end
end

function PwsHook:checkCanAttack()
    if not self.hookData then return end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isPaiWeiSai(sId) then
        local _ , point = self:getSceneExitPlayer()
        if point then
            return true
        else
            return false
        end
    else
        local tar = mgr.ThingMgr:getNearTar()
        if tar and tar:canBeSelect() then
            return true
        end
        local _ , point = self:getSceneExitPlayer()
        if point then
            self:setHookPoint(point)
            self:changeState(HookState.idle)
        else
            self:sendFind()
        end
        -- local enemys = self.hookData.enemys
        -- -- printt("敌人信息",enemys)
        -- local flag = false
        -- local enemyRoleId = nil
        -- for k,v in pairs(enemys) do
        --     local enemyTar = mgr.ThingMgr:getObj(ThingType.player, v)
        --     if enemyTar then
        --         flag = true
        --         enemyRoleId = v
        --     end
        -- end
        -- if flag then
        --     self:setLockThing(ThingType.player, enemyRoleId)
        --     self:changeState(HookState.moveComplete)
        --     return true
        -- else
        --     self:sendFind()
        -- end
    end
end



return PwsHook