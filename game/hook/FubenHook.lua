--
-- Author: yr
-- Date: 2017-07-18 19:25:34
-- 副本类挂机，服务端主动推刷怪

local FubenHook = class("FubenHook", import(".BaseHook"))

function FubenHook:ctor()
    self.super.ctor(self)
    self.mRefType = 0
end

function FubenHook:enter()
    self.super.enter(self)
    self.mRefType = 0
    local sId = cache.PlayerCache:getSId()
    local key = cache.FubenCache:getDayKey(sId)
    local mId = nil
    if key and key ~= 0 then
        local fbConf = conf.FubenConf:getdailyFubenRed(key)
        if not fbConf then
            print("@策划 daily_task_fuben_ref 缺少",key)
            return
        end
        if fbConf.order_monster then
            local pos = fbConf.order_monster[1]
            --print("pos[4]",pos[4],pos[5])
            self.hookPoint = Vector3.New(pos[3], gRolePoz, pos[4])
        end
        --mId = self:getSceneExitMonster()
    else
        local sConf = conf.SceneConf:getSceneById(sId)
        local fbId = cache.FubenCache:getCurrPass(sId)
        local fbConf = conf.FubenConf:getPassDatabyId(fbId)
        local refType = fbConf["ref_monster_type"]

        if refType == 3 or refType == 4 or refType == 7 then
            mId = self:getSceneExitMonster()
            if not mId then
                if fbConf["order_monsters"] then
                    mId = fbConf["order_monsters"][1][2]
                end
            end
            self.mRefType = refType
        else
            if fbConf["ref_monsters"] then
                mId = fbConf["ref_monsters"][1][1]
            end
        end
        if mId then
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
    self:update()
end

function FubenHook:checkMove()
    -- local t,info = mgr.ThingMgr:getNearTar()
    -- if t then
    --     self:changeState(HookState.moveComplete)
    -- end
end

--检查是否可以攻击
function FubenHook:checkCanAttack()
    --秘境副本：小范围的挂机，
    --不用检查而去找怪调用self:getSceneExitMonster()会有移动过程，直接可以冲的
    if self.mRefType == 7 then
        return true
    end
    return self.super.checkCanAttack(self)
end

function FubenHook:update()
    self.super.update(self)
end

return FubenHook