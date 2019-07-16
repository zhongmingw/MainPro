--
-- Author: yr
-- Date: 2017-10-24 11:03:34
--

local PickMgr = class("PickMgr")

function PickMgr:ctor()
    self.dropsQueue = {}
    self.collectQueue = {}
    self.pickItems = {}

    self.dropDataList = {}
    self.getList = {}
end

function PickMgr:addTimer()
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(1, -1, function()
            self:update()
        end,"pickup1")
    end
end

-- data掉落物列表信息
-- ownerId=nil默认是主角自己的掉落物
function PickMgr:addDrop(data, ownerId, monsterId, sx, sy)
    if g_var.gameFrameworkVersion < 15 then
        local effectTime = 0--掉落物 旧的写法
        local confData = conf.MonsterConf:getInfoById(monsterId)
        local effectId = confData and confData.drop_effect--特效id
        if effectId then--爆掉落物特效
            local confEffectData = conf.EffectConf:getEffectById(effectId)
            effectTime = confEffectData and confEffectData.durition_time or 0
            local parent = UnitySceneMgr.pEffectState
            local e = nil
            e = mgr.EffectMgr:playCommonEffect(effectId, parent)
            e.LocalRotation = Vector3.New(60, 0, 180)
            e.Scale = Vector3.New(90, 90, 90)
            if e then
                local item = data[1]
                local pox,poy = sx, sy
                e.LocalPosition = Vector3.New(pox,gRolePoz,poy)
            end
        end
        table.insert(self.pickItems, data)
        local callback = function()
            if self.pickItems[1] then
                local dropsList = {}
                for k,v in pairs(self.pickItems[1]) do
                    local dropItem = thing.DropItem.new()
                    UnityObjMgr:AddToStage(dropItem.character)
                    dropItem:setSPos(sx, sy)
                    dropItem:setData(v)
                    table.insert(dropsList, dropItem)
                end
                table.insert(self.dropsQueue, {drops = dropsList, time = Time.getTime(),ownerId = ownerId})
                table.remove(self.pickItems, 1)
                self:addTimer()
            end
        end
        if effectTime > 0 then
            mgr.TimerMgr:addTimer(effectTime, 1, function()
                callback()
            end)
        else
            callback()
        end
    else
        table.insert(self.dropDataList, {data=data, ownerId=ownerId, sx=sx, sy=sy})
        if not self.timer2 then
            self.timer2 = mgr.TimerMgr:addTimer(0.12, -1, function()
                if #self.dropDataList > 0 then
                    local dropData = self.dropDataList[1]
                    local list = dropData.data
                    local dInfo = list[1]
                    local dropItem = thing.DropItem.new()
                    UnityObjMgr:AddToStage(dropItem.character)
                    dropItem:setSPos(sx, sy)
                    dropItem:setData(dInfo)
                    table.remove(list, 1)
                    table.insert(self.getList, dropItem)
                    if #list <= 0 then
                        table.remove(self.dropDataList, 1)
                        mgr.TimerMgr:addTimer(2, 1, function()
                            self:moveToThing(dropData.ownerId)
                        end)
                    end
                    self:dropThingTween(dropItem, dInfo, dropData)
                else
                    if self.timer2 then
                        mgr.TimerMgr:removeTimer(self.timer2)
                        self.timer2 = nil
                    end
                end
            end,"pickup2")
        end
    end
end

function PickMgr:dropThingTween(drop, dInfo, dropData)
    local spx = dropData.sx or dInfo.cx 
    local spy = dropData.sy or dInfo.cy
    local epx = dInfo.cx
    local epy = dInfo.cy
    local cpx = spx + (epx - spx)/2
    local cpy = spy + (epy - spy)/2 - 250
    local path = cpx..","..cpy
    UTransition.TweenDoPathMove(drop.character, path, 0.25, DG.Tweening.Ease.OutCirc, function()
        local path2 = epx..","..epy
        UTransition.TweenDoPathMove(drop.character, path2, 0.2, DG.Tweening.Ease.InCirc, nil)
    end)
end

--拾取采集物
function PickMgr:addCollection(obj)
    table.insert(self.collectQueue, obj)
    self:addTimer()
end
--移除采集物
function PickMgr:removeCollection(roleId)
    for k,v in pairs(self.collectQueue) do
        if v:getID() == roleId then
            table.remove(self.collectQueue,k)
            break
        end
    end
end

function PickMgr:moveToThing(ownerId)
    local count = #self.getList
    if count > 0 then
        for i = count, 1, -1 do
            --获取掉落物的主人
            local ownerPoint
            local owner = self:getOwner(ownerId)
            if owner then
                ownerPoint = owner:getPosition()
            end
            --掉落物获取表现
            local drop = self.getList[i]
            if not ownerPoint then
                drop:dispose()
            else
                local beginPoint = drop:getCPoint()
                local endPoint = Vector3.New(ownerPoint.x,gRolePoz,ownerPoint.z - 10)
                local p = GMath.dirDistanceB(beginPoint, endPoint, 0)
                local point = Vector2.New(p.x, p.z)
                UTransition.TweenDead(drop.character, point, drop:getDeadTime(), function()
                    drop:dispose()
                end)
            end
            --获取特效
            mgr.TimerMgr:addTimer(0.3, 1, function()
                local owner = self:getOwner(ownerId)
                if owner then
                    mgr.EffectMgr:playCommonEffect(4040117, owner:getRoot())
                end
            end,"pickup")
        end
    end
    self.getList = {}
end

function PickMgr:update()
    --掉落物 旧的写法
    local count = #self.dropsQueue
    if g_var.gameFrameworkVersion < 15 then
        if count > 0 then
            for i = count, 1, -1 do
                local dropInfo = self.dropsQueue[i]
                if Time.getTime() - dropInfo.time > 3 then
                    --获取掉落物的主人
                    local ownerPoint
                    local owner = self:getOwner(dropInfo.ownerId)
                    if owner then
                        ownerPoint = owner:getPosition()
                    end
                    --掉落物获取表现
                    local drops = dropInfo.drops
                    for j=1, #drops do
                        local drop = drops[j]
                        if not ownerPoint then
                            drop:dispose()
                        else
                            local beginPoint = drop:getCPoint()
                            local endPoint = Vector3.New(ownerPoint.x,gRolePoz,ownerPoint.z - 10)
                            local p = GMath.dirDistanceB(beginPoint, endPoint, 0)
                            local point = Vector2.New(p.x, p.z)
                            UTransition.TweenDead(drop.character, point, drop:getDeadTime(), function()
                                drop:dispose()
                            end)
                        end
                    end
                    --获取特效
                    mgr.TimerMgr:addTimer(0.3, 1, function()
                        local owner = self:getOwner(dropInfo.ownerId)
                        if owner then
                            mgr.EffectMgr:playCommonEffect(4040117, owner:getRoot())
                        end
                    end,"pickup")
                    --移除列表
                    table.remove(self.dropsQueue,i)
                end
            end
        end
    end
    --采集物
    local len = #self.collectQueue
    if len > 0 then
        for k,v in pairs(self.collectQueue) do
            local obj = mgr.ThingMgr:getObj(ThingType.monster, v:getID())
            if obj then
                local distance = GMath.distance(gRole:getPosition(), obj:getPosition())
                if distance <= 150 then
                    proxy.FubenProxy:send(1810302,{roleId = v:getID(), reqType = 3})
                    break
                end
            end
        end
    end
    if len <= 0 and count <= 0 then
        if self.timer then
            mgr.TimerMgr:removeTimer(self.timer)
            self.timer = nil
        end
    end
end

function PickMgr:getOwner(oId)
    local owner
    if oId then
        if tostring(oId) == gRole:getID() then
            owner = gRole
        else
            owner = mgr.ThingMgr:getObj(ThingType.player, oId)
        end 
    else
        owner = gRole
    end
    return owner
end

function PickMgr:dispose()
    if g_var.gameFrameworkVersion < 15 then
        if #self.dropsQueue > 0 then
            for i = #self.dropsQueue, 1, -1 do
                local dropInfo = self.dropsQueue[i]
                local drops = dropInfo.drops
                for j=1, #drops do
                    local drop = drops[j]
                    drop:dispose()
                end
                table.remove(self.dropsQueue,i)
            end
        end
    end
    if #self.getList > 0 then
        for i = #self.getList, 1, -1 do
            local drop = self.getList[i]
            if drop then drop:dispose() end
            table.remove(self.getList,i)
        end
    end
    self.collectQueue = {}
    self.pickItems = {}
end


return PickMgr