--
-- Author: yr
-- Date: 2017-02-16 10:44:37
--

local MsgDef = require("game.message.MessageDef")

local JumpMgr = class("JumpMgr")


local MaxInt = 1000000

function JumpMgr:ctor()
    self.isJump = false
end

--初始化该场景的跳跃有向图
function JumpMgr:init(sId)
    self.sceneId = sId
    if self.disCache[tostring(sId)] then
        return
    end
    self.disCache[tostring(sId)] = {}
    local mapConf = conf.SceneConf:getSceneById(sId)
    self.ids = mapConf["jump"]
    self.maxLen = #self.ids
    for i=1, self.maxLen do
        local point = self.ids[i]
        local conf1 = conf.NpcConf:getNpcById(point)
        local nextPts = conf1["next"]
        if nextPts then
            local len = #nextPts
            for j=1, len do
                local nPoint = nextPts[j]
                local nConf = conf.NpcConf:getNpcById(nPoint)
                local dx = (nConf["pos"][1] - conf1["pos"][1])
                local dy = (nConf["pos"][2] - conf1["pos"][2])
                local d = math.sqrt(dx*dx + dy*dy)
                if not self.disCache[tostring(sId)][tostring(point)] then
                    self.disCache[tostring(sId)][tostring(point)] = {}
                end
                self.disCache[tostring(sId)][tostring(point)][tostring(nextPts[j])] = d
            end
        end 
    end
end

--有向图计算最短路径
function JumpMgr:dijkstraPath(sPoint)
    local path = {}
    local visited = {}
    local dist = {}
    local n = self.maxLen
    for i=1, n do
        local nPoint = self.ids[i]
        d = self.disCache[tostring(self.sceneId)][tostring(sPoint)]
        if d then
            d = d[tostring(nPoint)]
        end
        if sPoint ~= nPoint and d then
            dist[nPoint] = d
            path[nPoint] = sPoint
        else
            dist[nPoint] = MaxInt
            path[nPoint] = -1
        end
        visited[nPoint] = false

        if sPoint == nPoint then
            path[sPoint] = sPoint
        end
    end
    visited[sPoint] = true
    dist[sPoint] = 0
    
    for i=2, n do
        local min = MaxInt
        local u
        for j=1, n do
            local nPoint = self.ids[j]
            if visited[nPoint] == false and dist[nPoint] < min then
                min  = dist[nPoint]
                u = nPoint
            end
        end
        if u then
            visited[u] = true
            for k=1, n do
                local nPoint = self.ids[k]
                d = self.disCache[tostring(self.sceneId)][tostring(u)]
                if d then
                    d = d[tostring(nPoint)]
                end
                if visited[nPoint] == false and d and min + d < dist[nPoint] then
                    dist[nPoint] = min + d
                    path[nPoint] = u
                end
            end
        end
    end

    return path
end

function JumpMgr:jumpPath(e)
    --寻找最近的跳点
    local jumpList = {}
    local s = gRole:getPosition()
    local sPoint = self:getNearest(s)
    local path = self:dijkstraPath(sPoint)
    local endjump = self:getNearest(e)
    if not endjump then
        plog("终点：", endjump)
        return nil
    end
    local temp = path[endjump]
    if temp == -1 then
        return nil
    end
    -- while temp ~= sPoint do
    --     table.insert(jumpList, temp)
    --     temp = path[endjump]
    -- end
    -- for k, v in pairs(path) do
    --     plog("sdfsfsfs",k.."-"..v)
    -- end
    table.insert(jumpList, sPoint)
    return jumpList
end

function JumpMgr:getNearest(s)
    local min = MaxInt
    local visited = {}
    local jp
    for i=1, self.maxLen do
        min = MaxInt
        for j=1, self.maxLen do
            local p = self.ids[j]
            local nConf = conf.NpcConf:getNpcById(p)
            local dx = (nConf["pos"][1] - s.x)
            local dy = (nConf["pos"][2] - s.z)
            local d = math.sqrt(dx*dx + dy*dy)
            if d < min and not visited[p] then
                jp = p
                min = d
            end
        end
        visited[jp] = true
        local nConf = conf.NpcConf:getNpcById(jp)
        local position = Vector3.New(nConf["pos"][1], -1500, nConf["pos"][2])
        plog("JumpMgr:getNearest(s)>>", jp,",", nConf["pos"][1],",", nConf["pos"][2])
        local path = GameUtil.GetNavPath(s, position)
        if path then
            plog("JumpMgr:getNearest(s)>>", jp)
            return jp
        end
    end
end

--------------------------------------------------------------------------------

function JumpMgr:moveByPath(point, path, completeFunc, stopFunc)
    self.point = point
    self.completeFunc = completeFunc
    self.stopFunc = stopFunc
    gRole:moveToPath(path, 0, function(args)
        if completeFunc then
            completeFunc()
        end
        self.point = nil
        self.reachDis = nil
        self.completeFunc = nil
        self.stopFunc = nil
    end, function()
        if not self.jumpBreak then
            self.point = nil
            self.reachDis = nil
            self.func = nil
        end
        if stopFunc then
            stopFunc()
        end
    end)
end

--场景寻路
function JumpMgr:findPath(point, reachDis, completeFunc, stopFunc)
    if not reachDis or reachDis == 0 then
        reachDis = 60
    end

    self.point = point
    self.reachDis = reachDis
    self.completeFunc = completeFunc
    self.stopFunc = stopFunc
    gRole:moveToPoint(point, reachDis, function(args)
        if completeFunc then
            completeFunc()
        end
        self.point = nil
        self.reachDis = nil
        self.completeFunc = nil
        self.stopFunc = nil
    end, function()
        if not self.jumpBreak then
            self.point = nil
            self.reachDis = nil
            self.func = nil
        end
        if stopFunc then
            stopFunc()
        end
    end)
end

--主角跳点跳跃
function JumpMgr:startJump(nextInfo)
    if not nextInfo then return end
    self.jumpBreak = true
    local len = #nextInfo
    local arr = ArrayList.New()
    for i=1, len do
        local pos = nextInfo[i]
        local v = Vector3.New(pos[1], gRolePoz, pos[2])
        arr:Add(v)
    end
    gRole:jump(2,arr, function(arg)
        if arg == 99 then  --跳跃完成
            self.isJump = false
            self.jumpBreak = false
            if self.point then
                self:findPath(self.point, self.reachDis or 0, self.completeFunc, self.stopFunc)
            end
            local pos = nextInfo[len]
            local arr2 = {}
            arr2[1] = MsgDef.Position:create({pox=pos[1], poy=pos[2]})
            local param = {type=2,jumpPos=arr2}
            self:sendJumpToServer(param) 
        else
            self.isJump = true
            --TODO 发送服务端跳跃
            local arr2 = {}
            arr2[1] = MsgDef.Position:create({pox=0,poy=0})
            for i=1,len do
                local pos = nextInfo[i]
                arr2[i+1] = MsgDef.Position:create({pox=pos[1], poy=pos[2]})
            end
            local param = {type=1,jumpPos=arr2}
            self:sendJumpToServer(param)
        end
        arr = nil
    end)
end

--小飞鞋 point = 终点
function JumpMgr:feiXieJump(sId, x, y,ptype)
    if sId == cache.PlayerCache:getSId() then  --相同场景
        local point = Vector3.New(x, gRolePoz, y)
        local rolePos = gRole:getPosition()
        local totalDis = GMath.distance(rolePos, point)
        local count = math.floor(totalDis / 1600)
        local everyDis
        local arr = ArrayList.New()
        if count > 1 then
            everyDis = totalDis / count
            local dir = (point - rolePos).normalized
            for i = 1, count-1 do
                local v = gRole:getPosition() + dir*everyDis*i
                arr:Add(v)
            end
        else
            everyDis = totalDis
        end
        arr:Add(point)
        gRole:jump(2,arr, function(arg)
            if arg == 99 then  
                --落地特效
                local parent = UnitySceneMgr.pStateTransform
                local e = mgr.EffectMgr:playCommonEffect(4040112, parent)
                e.LocalPosition = gRole:getPosition()
                --TODO跳跃完成:发送切换场景完成
                if ptype and ptype == 4 then
                    --
                    cache.PlayerCache.marryTime = 0
                    mgr.ViewMgr:closeAllView2()
                    mgr.ViewMgr:openView2(ViewName.MarryNpcView)
                else
                    mgr.TimerMgr:addTimer(0.2,1,function()
                        -- body
                        mgr.TaskMgr.mState = 2
                        mgr.TaskMgr:resumeTask()
                    end)
                end
                proxy.ThingProxy:sChangeScene(sId, x, y, ptype or 2)
            end
            arr = nil
        end)
    else  --不同场景直接切场景
        gRole:flyUp(function()
            mgr.TimerMgr:addTimer(0.4, 1, function()
                local view = mgr.ViewMgr:get(ViewName.AutoFindView)
                if view then
                    cache.GuideCache:setNotGoon(false)
                end
                proxy.ThingProxy:sChangeScene(sId, x, y,ptype or  2)
            end)
        end)
    end
end

--主角技能跳跃
function JumpMgr:skillJump()
    local s = gRole:jump(1, nil, function(arg, point)
        if arg == 1 then
            if self.isJump == true then
                --跳跃特效
                local parent = UnitySceneMgr.pStateTransform
                local e = mgr.EffectMgr:playCommonEffect(4040114, parent)
                e.LocalPosition = gRole:getJumpWorldPos()
                e.LocalRotation = gRole:getBodyRotation()
            end
            self.isJump = true
            --TODO 发送服务端跳跃
            local arr = {}
            arr[1] = MsgDef.Position:create({pox=1,poy=1})
            arr[2] = MsgDef.Position:create({pox=point.x, poy=point.z})
            local param = {type=1,jumpPos=arr}
            self:sendJumpToServer(param)
        else
            self.isJump = false
            --跳跃特效
            local parent = UnitySceneMgr.pStateTransform
            local e = mgr.EffectMgr:playCommonEffect(4040112, parent)
            local p = gRole:getPosition()
            e.LocalPosition = p
            --TODO 发送服务端跳跃
            local arr = {}
            arr[1] = MsgDef.Position:create({pox=p.x, poy=p.z})
            local param = {type=2,jumpPos=arr}
            self:sendJumpToServer(param)
        end
    end)
end

--发送数据
function JumpMgr:sendJumpToServer(arr)
    proxy.ThingProxy:sJump(arr)    
end

--其他玩家跳跃
function JumpMgr:otherJump(data, del)
    --print("广播其他玩家跳跃", del)
    local thing = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
    if thing then
        if data.jumpType and data.jumpType > 0 then  --剧情跳跃
            local info = conf.NpcConf:getNpcById(data.jumpType)
            thing:otherGameMovie(info, del)
        else  --跳跃
            local len = #data.jumpPos
            local arr = ArrayList.New()
            for i=1, len-1 do
                local pos = data.jumpPos[i+1]
                local v = Vector3.New(pos.pox, gRolePoz, pos.poy)
                arr:Add(v)
            end
            thing:jump(3,arr,function(arg, point)
                if arg == 99 then  --玩家跳跃完成
                    if del then
                        thing:dispose()
                    end
                end
            end)
        end
    end
    if del then
        mgr.ThingMgr:removeObj(ThingType.player, data.roleId, false)
    end
end

--主角剧情表现
function JumpMgr:roleMovie(info, func, isFirst)
    print("触发剧情表现ID：", info.id)
    if 3999995 == info.id and not cache.TaskCache:isfinish(1001) then
        --print("击杀任务怪没有完成")
        mgr.TaskMgr:firstTask()
        return
    end

    gRole:downMount()
    local suc = gRole:gameMovie(info, function()
        --移除特效
        if self.movieEct then
            mgr.EffectMgr:removeEffect(self.movieEct)
            self.movieEct = nil
        end
        if self.gEctList then
            for i=1, #self.gEctList do
                mgr.EffectMgr:removeEffect(self.gEctList[i])
            end
            self.gEctList = nil
        end
        if self.transEct then
            local parent = UnitySceneMgr.pStateTransform
            self.transEct.Parent = parent
            self.transEct.LocalPosition = gRole:getPosition()
            self.transEct = nil
        end
        --触发下次剧情或完成
        if info.next then
            self:movieNext(info.next, func)
        else
            -- TODO 剧情完成
            if func then
                func()
            end
            --隐藏头顶信息
            gRole:setHeadBarVisible(true)
            --发送服务端跳跃完成
            local jumpPos = info.jump_pos
            local arr = {}
            local posList = string.split(jumpPos,",")
            local len = #posList
            arr[1] = MsgDef.Position:create({pox=posList[len-1], poy=posList[len]})
            local param = {type=2,jumpType=info.id, jumpPos=arr}
            proxy.ThingProxy:sJump(param)
        end
    end)
    
    if suc then
        --发送服务端
        if isFirst == true then
            local function loopNext(info)
                if info.next then
                    local config = conf.NpcConf:getNpcById(info.next)
                    return loopNext(config)
                end
                return info.jump_pos
            end
            local jumpPos = loopNext(info)
            local arr = {}
            local posList = string.split(jumpPos,",")
            local len = #posList
            arr[1] = MsgDef.Position:create({pox=1,poy=1})
            arr[2] = MsgDef.Position:create({pox=posList[len-1], poy=posList[len]})
            local param = {type=1,jumpType=info.id, jumpPos=arr}
            proxy.ThingProxy:sJump(param)
        end
        
        --旋转
        if info.rotation then
            gRole:setDirection(info.rotation)
        end
        --特效
        if info.effect then
            local parent = UnitySceneMgr.pStateTransform
            self.movieEct = mgr.EffectMgr:getPreloadEct(info.effect)
            if not self.movieEct then
                self.movieEct = mgr.EffectMgr:playCommonEffect(info.effect, parent)
            else
                self.movieEct.Parent = parent
            end
            self.movieEct.LocalPosition = gRole:getPosition()
        end
        --挂点特效
        if info.guadian then
            for i=1, #info.guadian do
                local gInfo = info.guadian[i]
                local parent = gRole:getGuaDian(tostring(gInfo[1]))
                if parent then
                    local gEct = mgr.EffectMgr:playCommonEffect(tostring(gInfo[2]), parent)
                    if not self.gEctList then
                        self.gEctList = {}
                    end
                    table.insert(self.gEctList, gEct)
                end
            end
        end
        --需要转移到场景的特效
        if info.trans_ect then
            local parent = gRole:getRoot()
            self.transEct = mgr.EffectMgr:getPreloadEct(info.trans_ect)
            if not self.transEct then
                self.transEct = mgr.EffectMgr:playCommonEffect(info.trans_ect, parent)
            else
                self.transEct.Parent = parent
            end
            self.transEct.LocalPosition = Vector3.zero
            self.transEct.LocalRotation = StaticVector3.vector3Z180
            self.transEct.Scale = Vector3.one
        end
        --有剧情怪物需要移除
        if info.del_npc then
            mgr.ThingMgr:delMovieList()
        end
        --音效
        if info.sound then
            mgr.SoundMgr:playSound(info.sound)
        end
        --隐藏头顶信息
        gRole:setHeadBarVisible(false)
    end
end

function JumpMgr:movieNext(id, func)
    local config = conf.NpcConf:getNpcById(id)
    self:roleMovie(config, func, false)
end

--其他玩家剧情表现
function JumpMgr:otherMovie(info, thing, func)
    thing:gameMovie(info, function()
        --需要转移到场景的特效
        if info.trans_ect then
            thing:delMovieEct()
        end
        --触发下次剧情或完成
        if info.next then
            self:otherMovieNext(info.next, thing, func)
        else
            -- TODO 剧情完成
            if func then
                func()
            end
        end
    end)
    if info.rotation then
        thing:setDirection(info.rotation)
    end
    --需要转移到场景的特效
    if info.trans_ect then
        thing:addMovieEct(info.trans_ect)
    end
end
function JumpMgr:otherMovieNext(id, thing, func)
    local config = conf.NpcConf:getNpcById(id)
    self:otherMovie(config, thing, func)
end

return JumpMgr