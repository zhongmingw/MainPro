--
-- Author: ohf
-- Date: 2017-12-07 15:54:52
--
--仙盟争霸挂机
local XmzbHook = class("XmzbHook", import(".BaseHook"))

function XmzbHook:ctor()

end

function XmzbHook:enter(data)
    self.super.enter(self)
    self:againHook()
    self:update()
end

function XmzbHook:setHookData(data)
    -- local code = data.code
    -- local info = data.info
    -- if code == 1 then    --5360207返回
    --     local pos = info.pos
    --     if pos.pox == 0 and pos.poy == 0 then--采集水晶
    --         self:pickCrystal()
    --     else--前往挂机
    --         self:setHookPoint(Vector3.New(pos.pox, gRolePoz, pos.poy))
    --         self.moveDo = HookMoveDo.fight
    --         self:changeState(HookState.idle)
    --     end
    -- else--拾取完成
        
    -- end
end
--重新挂机
function XmzbHook:againHook()
    self:finishPick()
    self:changeState(HookState.moveComplete)
end
--采集水晶
function XmzbHook:pickCrystal()
    local crystalId = 0--最近的水晶
    local p --最近的位置
    local isFind = false
    local trackData = cache.XmzbCache:getTrackData()
    -- printt("trackData",trackData)
    if not trackData then return end
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    for k, v in pairs(things) do--先寻找周围有没有水晶
        local status = trackData.crystalStatusMap[v:getMId()]
        if status ~= 1 then
            p = v:getPosition()
            crystalId = v:getMId()
            isFind = true
            break
        end
    end
    -- plog(crystalId)
    if not isFind then--周围没有水晶就寻找最近的
        local sId = cache.PlayerCache:getSId()
        local sConf = conf.SceneConf:getSceneById(sId)
        if sConf.pendant then
            local dis = 0
            for k,v in pairs(sConf.pendant) do
                local status = trackData.crystalStatusMap[v[1]]
                if status ~= 1 then
                    local pos = Vector3.New(v[2], gRolePoz, v[3])
                    dis = GMath.distance(gRole:getPosition(), pos)--获取其中一个非自己的水晶的距离
                    break
                end
            end
            for k,v in pairs(sConf.pendant) do
                local pendantId = v[1]
                local status = trackData.crystalStatusMap[pendantId]
                if status ~= 1 then
                    local pos = Vector3.New(v[2], gRolePoz, v[3])
                    local distance = GMath.distance(gRole:getPosition(), pos)
                    if distance <= dis then--寻找最近的可采集水晶
                        dis = distance
                        crystalId = pendantId
                        p = pos
                    end
                end
            end
        end
    end

    if p then
        gRole:moveToPoint(p, PickDistance, function()
            local roleId = "0"
            for k,v in pairs(mgr.ThingMgr:objsByType(ThingType.monster)) do
                if v:getMId() == crystalId then
                    local trackData = cache.XmzbCache:getTrackData()
                    if trackData then
                        local status = trackData.crystalStatusMap[crystalId]
                        if status ~= 1 then--寻找无状态的水晶
                            roleId = v:getID()
                        else
                            self:changeState(HookState.moveComplete)
                        end
                    end
                    break
                end
            end
            if roleId ~= "0" then
                self.starPick = true
                print("为了保险先缓存采集id",roleId)
                self:setPickRoleId(roleId) 
                proxy.FubenProxy:send(1810302,{roleId = roleId,reqType = 4})
            end
        end)
    else
        self:againHook()
    end
end

function XmzbHook:finishPick()
    self.starPick = false
    mgr.HookMgr:setPickRoleId("0")
end

--是否有可攻击对象 1-有攻击对象可以攻击，2-附近有玩家需要移动 3-附近都没有玩家就采集水晶
function XmzbHook:isHasTarget()
    if self.starPick then
        return 0
    end
    local t,info = mgr.ThingMgr:getNearTar()
    if t then
        if t and t:getGridValue() ~= 7 then
            self:finishPick()
            self:setLockThing(nil, nil)
            self:changeState(HookState.moveComplete)
        else
            self:pickCrystal()
        end
        return 1
    end
    local _ , point = self:getSceneExitPlayer()
    if point then
        self:finishPick()
        self:setHookPoint(point)
        self:changeState(HookState.idle)
        return 2
    end
    self:finishPick()
    return 3
end

function XmzbHook:checkMove()
    if self:isHasTarget() == 1 then
        self:changeState(HookState.moveComplete)
    end
end

function XmzbHook:checkCanAttack()
    local exit = self:isHasTarget()
    if exit == 1 then
        return true
    elseif exit == 2 then
        return false
    elseif exit == 3 then
        -- proxy.XmhdProxy:send(1360207)
        self:pickCrystal()
        return false
    end
end

function XmzbHook:update()
    self.super.update(self)
end

return XmzbHook