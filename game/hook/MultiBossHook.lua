--
-- Author: 
-- Date: 2017-10-12 20:02:06
--
--多boss挂机（世界boss，boss之家）仙域禁地boss
local MultiBossHook = class("MultiBossHook",import(".BaseHook"))

function MultiBossHook:ctor()
    
end

function MultiBossHook:enter()
    self.super.enter(self)
    mgr.FightMgr:clear()
    self.isNotChooseBoss = false
    local sId = cache.PlayerCache:getSId()
    local data = cache.FubenCache:getWorldData()
    if mgr.FubenMgr:isBossHome(sId) then
        data = cache.FubenCache:getBossHomeData()
    elseif mgr.FubenMgr:isXianyuJinDi(sId) or mgr.FubenMgr:isKuafuXianyu(sId) then
        data = cache.FubenCache:getXianYuJinDiData()
    elseif mgr.FubenMgr:isKuafuWorld(sId) then
        data = cache.FubenCache:getKuafuBossData()
    elseif mgr.FubenMgr:isShangGuShenJi(sId) then
        data = cache.FubenCache:getShangGuData()
    elseif mgr.FubenMgr:isWuXingShenDian(sId) then
        data = cache.FubenCache:getWuXingData()
    elseif mgr.FubenMgr:isFsFuben(sId) then
        data = cache.FubenCache:getFSData()
    elseif mgr.FubenMgr:isShenShou(sId) then
        data = cache.FubenCache:getShenShouData()
    elseif mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
        data = cache.FubenCache:getSSdata()
    elseif mgr.FubenMgr:isTaiGuXuanJing(sId) then
        data = cache.TaiGuXuanJingCache:getTaiGuData()
    end
    if not data and #data.bossList < 0 then return end
    local pos,chooseBossId
    if mgr.FubenMgr:isTaiGuXuanJing(sId) then
         chooseBossId = cache.TaiGuXuanJingCache:getChooseBossId()
    else
         chooseBossId = cache.FubenCache:getChooseBossId()
    end
    local disList = {}
    if chooseBossId == 0 then--如果没有选中boss
        local t,info = mgr.ThingMgr:getNearTar()
        if t then
            plog("附近的怪物",info.objId)
            
            self:setLockThing(ThingType.monster, info.objId)
        else
            local mAllObjs = mgr.ThingMgr:objsByType(ThingType.monster)
            local collectObj
            for k,v in pairs(mAllObjs) do
                if v:getKind() == MonsterKind.collection then--如果是采集物
                    collectObj = v
                    break
                end
            end
            if collectObj then--去采集
                local data = collectObj.data
                local p = Vector3.New(data.pox, gRolePoz, data.poy)
                printt("~~~~~~",p)
                gRole:moveToPoint(p, PickDistance, function()
                    proxy.ThingProxy:send(1810302,{roleId = collectObj:getID(),reqType = 1})
                end)
            end
        end
        self:changeState(HookState.moveComplete)
    else

        local mConf = conf.MonsterConf:getInfoById(chooseBossId)
        local p = mConf and mConf.pos or {1,1}
        pos = {x = p[1],y = p[2]}
        for k,v in pairs(data.bossList) do
            local monsterId = v.attris and v.attris[601] and v.attris[601]
            if monsterId == chooseBossId then
                if v.pox == 0 and v.poy == 0 then--还没刷新
                    self.isNotChooseBoss = true
                    break
                end
            end
        end
    end

    if pos then
        self.hookPoint = Vector3.New(pos.x, gRolePoz, pos.y)
    else
        print("@策划：怪物配置的pos字段没有配")
    end
    self:update()
end

function MultiBossHook:checkCanAttack()
    if not mgr.FightMgr:checkExit() then
        local pId = self:getSceneExitPlayer()
        if pId then
            mgr.FightMgr:changeBattleTarget(true, ThingType.player, pId)
            return true
        end
    end
    local tar, info = mgr.ThingMgr:getNearTar()
    if tar then
        return true
    end
    if cache.FubenCache:getChooseBossId() > 0 then
        if not self.isNotChooseBoss then--还没刷新就等boss刷新
            cache.FubenCache:setChooseBossId(0)
            mgr.HookMgr:cancelHook()
        end
    end
    self:changeState(HookState.moveComplete)
    return false
end

function MultiBossHook:checkMove()
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

function MultiBossHook:update()
    self.super.update(self)
end


return MultiBossHook