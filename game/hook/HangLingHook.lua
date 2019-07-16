--
-- Author: yr
-- Date: 2017-07-18 21:53:22
--

local HangLingHook = class("HangLingHook", import(".BaseHook"))

function HangLingHook:ctor()
    
end

function HangLingHook:enter()
    self.super.enter(self)
    self:restHook()
    self:update()
end

function HangLingHook:restHook()
    local taskData = cache.HuanglingCache:getTaskCache()
    local bossData = cache.HuanglingCache:getBossCache()
    self.otherData = {} --未完成的任务
    for k,v in pairs(taskData) do
        if v.taskFlag ~= 1 then
            table.insert(self.otherData,v)
        end
    end
    local bossNum = cache.HuanglingCache:getBossNum()
    
    if #self.otherData > 0 then --如果有未完成的任务
        local tData = self.otherData[1]
        local task = conf.HuanglingConf:getTaskAwardsById(tData.taskId)
        self:huanglingTaskHook(task)
    elseif bossNum > 0 and bossData[bossNum].curHpPercent > 0 then--次优先杀boss
        self:huanglingHook(2)
    else                        --没有任务挂机杀怪
        self:huanglingHook(1)
    end
end

function HangLingHook:setHookData(data)
    local code = data.code
    local info = data.info
    if code == 1 then  --huanglingHook
        self:huanglingHook(info)
    elseif code == 2 then
        self:huanglingTaskHook(info)
    end
end

--皇陵挂机杀怪和boss   param hookType 1为杀怪 2为杀boss
function HangLingHook:huanglingHook(hookType)
    --print("HangLingHook:huanglingHook"..hookType)
    --print(debug.traceback())
    local taskData = conf.HuanglingConf:getAllTask()
    local monsterMap = {}
    for k,v in pairs(taskData) do
        if v.type == 2 then
            table.insert(monsterMap,v)
        end
    end
    cache.HuanglingCache:setPresentTaskId(hookType)
    local target = nil
    if hookType == 1 then
        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        local num = math.random(1,#monsterMap)
        for k,v in pairs(monsterMap) do
            if k == tonumber(num) then
                local mId = v.tar_con[1][1]
                local mConf = conf.MonsterConf:getInfoById(mId)
                target = mConf
            end
        end
    else
        local fbId = cache.PlayerCache:getSId()
        local fbConf = conf.SceneConf:getSceneById(fbId)
        if fbConf and fbConf["order_monsters"] then
            local bossNum = cache.HuanglingCache:getBossNum()
            if bossNum == 0 or bossNum == 1 then
                bossNum = 0
            else
                bossNum = 1
            end
            local bossId = fbConf["order_monsters"][bossNum+1][2]
            local mConf = conf.MonsterConf:getInfoById(bossId)
            target = mConf
        end
    end
    if target then
        self.hookPoint = Vector3.New(target.pos[1], gRolePoz, target.pos[2])
        self.moveDo = HookMoveDo.fight
        self:changeState(HookState.idle)
    else
        GComAlter(language.huangling08)
    end
end

--检查是否可以攻击
function HangLingHook:checkCanAttack()
    return true
end

--皇陵挂机任务
function HangLingHook:huanglingTaskHook(data)
    local target = nil
    local point = nil
    --print("挂机类型",data.type)
    cache.HuanglingCache:setPresentTaskId(data.id)
    if data.type == 1 then
        local fbId = cache.PlayerCache:getSId()
        local fbConf = conf.SceneConf:getSceneById(fbId)
        target = fbConf["pendant"]
        --获取当前采集物的所有坐标
        local posTab = {}
        for k,v in pairs(target) do
            if v[1] == data.tar_con[1][1] then
                local pos = {v[2],v[3]}
                table.insert(posTab,pos)
            end
        end
        local len = #posTab
        if len > 0 then
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
            point = posTab[math.random(1,#posTab)]
        else
            GComAlter("找不到采集物")
        end
    else
        cache.HuanglingCache:setPresentTaskId(0)
        target = conf.MonsterConf:getInfoById(data.tar_con[1][1])
        point = target["pos"]
    end

    if target then
        self.hookPoint = Vector3.New(point[1], gRolePoz, point[2])
        if data.type == 1 then
            self.moveDo = HookMoveDo.pick
        else
            self.moveDo = HookMoveDo.fight
        end
        self:changeState(HookState.idle)
    else
        GComAlter(language.huangling08)
    end
end

function HangLingHook:startPick()
    self.super.startPick(self)
    local roleId = 0
    local objs = mgr.ThingMgr:objsByType(ThingType.monster)
    for k,v in pairs(objs) do
        if v.data.kind == MonsterKind.collection then
            if v:getPosition().x == self.hookPoint.x and v:getPosition().z == self.hookPoint.z then
                roleId = v.data.roleId
                break
            end
        end
    end
    proxy.FubenProxy:send(1810302,{roleId = roleId,reqType = 1})
end

return HangLingHook