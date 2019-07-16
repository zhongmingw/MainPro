--
-- Author: 
-- Date: 2018-07-25 22:15:11
--

local XianLvPKHook = class("XianLvPKHook", import(".BaseHook"))


function XianLvPKHook:ctor()
    
end


function XianLvPKHook:enter()
    self.super.enter(self)
    self.moveDo = HookMoveDo.fight
    self:sendFind()
    self:update()
end

function XianLvPKHook:setHookData(data)
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

function XianLvPKHook:checkMove()
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
            --锁定对象
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

function XianLvPKHook:sendFind()
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isXianLvPKhxs(sId) or mgr.FubenMgr:isXianLvPKzbs(sId) then
        -- print("请求仙侣pk场景位置信息")
        proxy.XianLvProxy:sendMsg(1540110)
    elseif mgr.FubenMgr:isXianLvPKhxs_2(sId) or mgr.FubenMgr:isXianLvPKzbs_2(sId) then
        proxy.XianLvProxy:sendMsg(1540210)
    end
end
--检测可否攻击， 重写basehook
function XianLvPKHook:checkCanAttack()
    if not self.hookData then return end
    -- local sId = cache.PlayerCache:getSId()
    -- if mgr.FubenMgr:isXianLvPKhxs(sId) then
    --     local _ , point = self:getSceneExitPlayer()--获取场景存在的怪物id ，pos
    --     if point then
    --         return true
    --     else
    --         return false
    --     end
    -- else
        local tar = mgr.ThingMgr:getNearTar()
        if tar and tar:getHp() > 0 and tar:canBeSelect()  then
            return true
        end
        local _ , point = self:getSceneExitPlayer()
        if point then
            self:setHookPoint(point)
            self:changeState(HookState.idle)
        else
            self:sendFind()
        end
    -- end
end


return XianLvPKHook