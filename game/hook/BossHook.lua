--
-- Author: yr
-- Date: 2017-07-18 21:10:36
-- boss 类挂机，锁定boss攻击
--

local BossHook = class("BossHook", import(".BaseHook"))

function BossHook:ctor()
    
end

function BossHook:enter()
    self.super.enter(self)
    local tar = mgr.ThingMgr:getNearTar()
    if tar then
        self:changeState(HookState.moveComplete)
    else
        local mId, pos, rId = self:getSceneExitMonster()
        if mId then
            self.hookPoint = pos
            self:changeState(HookState.idle)
        else
            local fbId = cache.PlayerCache:getSId()
            local fbConf = conf.SceneConf:getSceneById(fbId)
            if fbConf and fbConf["order_monsters"] then
                local mId=fbConf["order_monsters"][1][2]
                local monsterConfig = conf.MonsterConf:getInfoById(mId)
                local centerPoint = monsterConfig["pos"]
                if centerPoint then
                    self.hookPoint = Vector3.New(centerPoint[1], gRolePoz, centerPoint[2])
                else
                    print("@策划：怪物配置的pos字段没有配")
                    return
                end
            else
                print("@策划： 没有配置怪物")
                return
            end
        end
    end
    self:update()
end

function BossHook:checkCanAttack()
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    for k, v in pairs(things) do
        if v:canBeSelect() then
            self:setLockThing(ThingType.monster, k)
            return true
        end
    end
    self:changeState(HookState.idle)
    return false
end

function BossHook:checkMove()
    -- local things = mgr.ThingMgr:objsByType(ThingType.monster)
    -- for k, v in pairs(things) do
    --     if v:canBeSelect() then
    --         self:setLockThing(ThingType.monster, k)
    --         self.hookPoint = v:getPosition()
    --         self:changeState(HookState.moveComplete)
    --     end
    --     break
    -- end
end

function BossHook:update()
    self.super.update(self)
end


return BossHook