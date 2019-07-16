--
-- Author: Your Name
-- Date: 2018-04-19 11:38:42
--

local CityWarHook = class("CityWarHook", import(".BaseHook"))

function CityWarHook:ctor()
    
end

function CityWarHook:enter()
    self.super.enter(self)
    self.moveDo = HookMoveDo.fight
    self:setHookData()
    self:update()
end

function CityWarHook:setHookData(data)
    print("城战挂机")
    self.moveDo = HookMoveDo.fight
    self:checkCanAttack()

end

--城池外挂机
function CityWarHook:outCityHook()
    self.hookPointType = 1
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    local point = nil
    local cityStateData = cache.CityWarCache:getCityDoorState()--城门状态
    if cityStateData == 1 then--城门已破
        local dt = 9999
        for k,v in pairs(sConf.transfer) do
            local monsterData = cache.CityWarCache:getCityWarTrackData()
            local transferData = conf.CityWarConf:getTransferData(v)
            local mData = {}
            for _,monster in pairs(monsterData) do
                mData[monster.attris[601]] = true
            end
            if not mData[transferData.monsterId] then--找到最近的已破城门传送点
                local confData = conf.NpcConf:getNpcById(v)
                if confData then
                    pos = Vector3.New(confData.pos[1], gRolePoz, confData.pos[2])
                    local distance = GMath.distance(gRole:getPosition(), pos)
                    if distance <= dt then
                        dt = distance
                        point = pos
                    end
                end
            end
        end
    else
        local dt = 9999
        for k,v in pairs(sConf.transfer) do
            local npcData = conf.NpcConf:getNpcById(v)
            if npcData.type == 10 then
                pos = Vector3.New(npcData.pos[1], gRolePoz, npcData.pos[2])
                local distance = GMath.distance(gRole:getPosition(), pos)
                if distance <= dt then
                    dt = distance
                    point = pos
                end 
            end
        end
    end
    if point then
        gRole:moveToPoint(point, 50, function()
            self:checkCanAttack()
        end)
    end
end
--城池内挂机
function CityWarHook:inCityHook()
    self.hookPointType = 2
    local bossData = cache.CityWarCache:getCityBossData()
    local dt = 9999
    local point = nil
    for k,v in pairs(bossData) do
        local monsterData = conf.MonsterConf:getInfoById(v.attris[601])
        if monsterData.kind == 8 then
            pos = Vector3.New(monsterData.pos[1], gRolePoz, monsterData.pos[2])
            local distance = GMath.distance(gRole:getPosition(), pos)
            if distance <= dt then
                dt = distance
                point = pos
            end 
        end
    end
    if point then
        gRole:moveToPoint(point, 50, function()
            self:checkCanAttack()
        end)
    end
end

function CityWarHook:checkCanAttack()
    local _ , point = self:getSceneExitPlayer()
    if point and self:isOwnBoss() then
        -- print("附近有敌方玩家出现")
        self:setHookPoint(point)
        self:changeState(HookState.findPlayer)
        return true
    end

    local things = mgr.ThingMgr:getNearTar()
    if things then
        for k,v in pairs(things) do
            --printt("附近对象",v)
            -- if v:canBeSelect() then
                -- self:setLockThing(ThingType.monster, k)
                self:changeState(HookState.moveComplete)
                return true
            -- end
        end
    end
    self:changeState(HookState.findPlayer)
    -- print("寻找附近可攻击对象",self.hookState)
    return false
end

--附近柱子是否是己方的归属
function CityWarHook:isOwnBoss()
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    local flag = false
    local gangId = cache.PlayerCache:getGangId()
    for k,v in pairs(monster) do
        local bossData = cache.CityWarCache:getCityBossData()
        for _,boss in pairs(bossData) do
            if v:getMId() == boss.attris[601] then
                if gangId == boss.gangId then
                    flag = true
                end
            end
        end
    end
    return flag
end

return CityWarHook