--[[
挂机管理
1、在主城场景中，点挂机，就自动做任务（主线、日常、帮派优先级），如果任务都做完了，就跑到对应等级的点进行挂机
2、在野外场景中，点挂机，就自动寻找当前地图中最近的怪点进行自动挂机
3、副本场景中挂机，进行指定的任务（一般做在玩法的地图里，采集、杀怪、或者杀人）

以下操作不取消挂机状态
1、使用技能
2、更换伙伴
3、跳跃
4、打开UI界面
]]
local HookMgr = class("HookMgr")

local SceneType = 1
local FieldType = 2
local FuBenType = 3
local GangBossType = 4
local WenDingType = 5

function HookMgr:ctor()
    self.isHook = false
    self.timer = nil
    self.skillList = {}
    self.hookType = 0
    self.hookCount = 0
end

--挂机定时器
function HookMgr:addHookTimer()
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(0.4, -1, function()
            self:update()
        end, "HookMgr")
    end
end

function HookMgr:enterHook(force)
    if force then self:stopHook() end
    if self.isHook == false then
        local sId = cache.PlayerCache:getSId()
        local sConf = conf.SceneConf:getSceneById(sId)
        if sConf.kind then
            if sConf.kind == SceneKind.mainCity or sConf.kind == SceneKind.xinshou then
                self.hookType = SceneType
                self:sceneHook()
            elseif sConf.kind == SceneKind.field or sConf.kind == SceneKind.lianjigu then --野外搜索最近的怪物PK 
                self.hookType = FieldType 
                local ms = sConf["monsters"]
                if not ms then
                    self:startHook()
                    return
                end
                local minDis = 10000000
                local mNear
                for i=1,#ms do
                    local mc = conf.MonsterConf:getInfoById(ms[i][2])
                    local mPos = Vector3.New(0, gRolePoz, 0)
                    if mc["pos"] then
                        mPos.x = mc["pos"][1]
                        mPos.z = mc["pos"][2]
                        local dis = GMath.distance(gRole:getPosition(), mPos)
                        if dis < minDis then
                            minDis = dis
                            mNear = mPos
                        end
                    else
                        plog("@策划：怪物配置的pos字段没有配")
                    end
                end
                if mNear then
                    gRole:moveToPoint(mNear, 400, function()
                        local tar = mgr.ThingMgr:getNearTar()
                        if tar then
                            mgr.TimerMgr:addDelay(function()
                                self:startHook()
                            end)
                        end
                    end)
                else
                    self:startHook()
                end
            elseif sConf.kind == SceneKind.fuben or sConf.kind == SceneKind.kuafueZudui then
                self.isFubenHook = true
                self.hookType = FuBenType
                local sId = cache.PlayerCache:getSId()
                local fbId = cache.FubenCache:getCurrPass(sId)
                local fbConf = conf.FubenConf:getPassDatabyId(fbId)
                local refType = fbConf["ref_monster_type"]
                --print("Debug:当前副本ID：", fbId)
                if refType == 3 then
                    if fbConf["order_monsters"] then
                        self.fbPath = {}
                        for i=1, #fbConf["order_monsters"] do
                            table.insert(self.fbPath, {mId=fbConf["order_monsters"][i][2], mount=fbConf["order_monsters"][i][3]})
                        end
                        self:fuBenHook(300)
                    else
                        print("@策划： 没有配置怪物")
                    end
                else
                    if fbConf["ref_monsters"] then
                        self.fbPath = {}
                        for i=1, #fbConf["ref_monsters"] do
                            table.insert(self.fbPath, {mId=fbConf["ref_monsters"][i][1], mount=fbConf["ref_monsters"][i][2]})
                        end
                        self:fuBenHook(300)
                    else
                        print("@策划： 没有配置怪物")
                    end
                end
            elseif sConf.kind == SceneKind.worldBoss or sConf.kind == SceneKind.eliteBoss 
                or sConf.kind == SceneKind.kuafueliteBoss or sConf.kind == SceneKind.dujie then
                self.hookType = FuBenType
                self.isFubenHook = true
                local fbId = cache.PlayerCache:getSId()
                print("Debug:当前副本ID：", fbId)
                local fbConf = conf.SceneConf:getSceneById(fbId)
                self.fbPath = {}
                if fbConf and fbConf["order_monsters"] then
                    for i=1, #fbConf["order_monsters"] do
                        table.insert(self.fbPath, {mId=fbConf["order_monsters"][i][2], mount=-1})
                    end
                    self:fuBenHook(300)
                else
                    print("@策划： 没有配置怪物")
                end
            elseif sConf.kind == SceneKind.gangBoss then
                self:gangBossHook()
            elseif sConf.kind == SceneKind.huangling then --皇陵挂机
                self.hookType = FuBenType
                self.isFubenHook = true
                local taskData = cache.HuanglingCache:getTaskCache()
                local bossData = cache.HuanglingCache:getBossCache()
                self.otherData = {} --未完成的任务
                for k,v in pairs(taskData) do
                    if v.taskFlag ~= 1 then
                        table.insert(self.otherData,v)
                    end
                end
                local bossNum = cache.HuanglingCache:getBossNum()
                if bossNum > 0 and bossData[bossNum].curHpPercent > 0 then--优先杀boss
                    self:HuanglingHook(2)
                else
                    if #self.otherData > 0 then --如果有未完成的任务
                        local tData = self.otherData[1]
                        local task = conf.HuanglingConf:getTaskAwardsById(tData.taskId)
                        self:HuanglingTaskHook(task)
                    else                        --没有任务挂机杀怪
                        self:HuanglingHook(1)
                    end
                end
            elseif sConf.kind == SceneKind.wending then --问鼎
                self.hookType = WenDingType
                self:WendingHook()
            end
        end
    else
        self:stopHook()
    end
end
--问鼎挂机
function HookMgr:WendingHook(data)
    local p = nil
    local sId = cache.PlayerCache:getSId()
    local conds = cache.WenDingCache:getConds()
    local sceneNum = tonumber(string.sub(sId,6,6)) --当前层数
    if data then
        local pos = data.pos
        p = Vector3.New(pos.pox, gRolePoz, pos.poy) 
    else
        p = gRole:getPosition()
    end
    local flagHoldRoleId = cache.WenDingCache:getflagHoldRoleId()
    if sceneNum > 8 and flagHoldRoleId ~= cache.PlayerCache:getRoleId() then
        local isOver = cache.WenDingCache:getWendingOver()
        if not isOver then
            proxy.WenDingProxy:send(1350104,{reqType = 4})
        end
    else
        gRole:moveToPoint(p, 100, function()
            self:playerCheckHook()
        end)
    end
end
--寻找下一个玩家
function HookMgr:playerCheckHook()
    local t,info = mgr.ThingMgr:getNearTar()
    if t ~= nil then
        if not self.isHook then
            self.hookType = WenDingType
            self:startHook()
        end
        return true
    else
        local exit = false
        local player = mgr.ThingMgr:objsByType(ThingType.player)
        for k, v in pairs(player) do
            exit = true
            self:gotoHook(v:getPosition(), 100)
            break
        end
        if not exit then
            self:stopHook()
            local fbId = cache.PlayerCache:getSId()
            proxy.WenDingProxy:send(1350105,{sceneId = fbId})
        else

        end
        return false
    end
end
--皇陵挂机任务
function HookMgr:HuanglingTaskHook(data)
    local target = nil
    local point = nil
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
        target = conf.MonsterConf:getInfoById(data.tar_con[1][1])
        point = target["pos"]
    end

    if target then
        -- local kind = target.kind
        mgr.HookMgr:stopHook()
        local p = Vector3.New(point[1], gRolePoz, point[2])
        gRole:moveToPoint(p, PickDistance, function()
            if data.type == 1 then
                gRole:idleBehaviour()
                -- proxy.FubenProxy:send(1810302,{tarPox = point[1],tarPoy = point[2]})--拾取
            else
                self:startHook()
            end
        end)
    else
        GComAlter(language.huangling08)
    end
end
--皇陵挂机杀怪和boss   param hookType 1为杀怪 2为杀boss
function HookMgr:HuanglingHook(hookType)
    -- body
    local taskData = conf.HuanglingConf:getAllTask()
    local monsterMap = {}
    for k,v in pairs(taskData) do
        if v.type == 2 then
            table.insert(monsterMap,v)
        end
    end

    -- local allMonster = mgr.ThingMgr:objsByType(ThingType.monster)--所有的怪物
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
            -- print("当前boss",bossNum)
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
        mgr.HookMgr:stopHook()
        local p = Vector3.New(target.pos[1], gRolePoz, target.pos[2])
        gRole:moveToPoint(p, PickDistance, function()
            gRole:idleBehaviour()
            -- print("******************")
            self:startHook()
        end)
    else
        GComAlter(language.huangling08)
    end
end

--副本挂机 path=副本怪物点列表
function HookMgr:fuBenHook(dis)
    if #self.fbPath <= 0 then return end
    local info = self.fbPath[1]
    local mConf = conf.MonsterConf:getInfoById(info.mId)
    local point = mConf["pos"]
    if not point then
        plog("@策划： 怪物的中心点没有配置")
        return
    end
    if info.mount > 0 then
        m = cache.FubenCache:getExpMonsters(info.mId)
        if m<info.mount then  --没有杀完
            local p = Vector3.New(point[1], gRolePoz, point[2])
            mgr.TimerMgr:addDelay(function()
                self:gotoHook(p, dis)
            end)    
        else  --完成下个怪
            if #self.fbPath > 1 then
                table.remove(self.fbPath, 1)
                self:fuBenHook(300)
            else
                --
                plog("完成杀怪，停止挂机")
                --TODO 完成杀怪，停止挂机
                self:stopHook()
            end            
        end
    else
        local p = Vector3.New(point[1], gRolePoz, point[2])
        local s = gRole:moveToPoint(p, dis, function()
            self:fuBenCheckHook()
        end)
    end
end
--仙盟boss挂机
function HookMgr:gangBossHook()
    local bossList = cache.GangWarCache:getBossList()
    local disList = {}
    for k,v in pairs(bossList) do
        if v.x ~= 0 and v.y ~= 0 then
            local pos = Vector3.New(v.x,gRolePoz,v.y)
            local distance = GMath.distance(gRole:getPosition(), pos)
            local data = {pos = pos,distance = distance}
            table.insert(disList, data)
        end
    end
    -- printt(disList)
    if #disList > 0 then
        table.sort(disList, function(a, b)
            return a.distance < b.distance
        end)
        local s = gRole:moveToPoint(disList[1].pos, 100, function()
            if mgr.ThingMgr:getNearTar() then 
                if not self.isHook then
                    self:startHook()
                end
            else
                mgr.TimerMgr:addTimer(0.5, 1, function()
                    self:gangBossHook()
                end)
            end
        end)
    else
        if gRole then gRole:stopAI() end
    end
end

--去到某个点挂机
function HookMgr:gotoHook(p, dis)
    local s = gRole:moveToPoint(p, dis, function()
        self:fuBenCheckHook()
    end)
    if s==false then
        plog("配到不可走区域")
    end
end

--进入下个挂机点
function HookMgr:fuBenCheckHook()
    if mgr.ThingMgr:getNearTar() then  -- 检查是否有可攻击的怪
        --TODO 周围有挂则打怪
        if not self.isHook then
            self:startHook()
        end
        return true
    else
        local exit = false
        local ms = mgr.ThingMgr:objsByType(ThingType.monster)
        for k, v in pairs(ms) do
            exit = true
            self:gotoHook(v:getPosition(), 200)
            break
        end
        if not exit then
            self:fuBenHook(0)
        end
        return false
    end
end

--场景挂机
function HookMgr:sceneHook()
    --TODO 有任务直接做任务
    local flag = false
    local data = cache.TaskCache:getData()
    local param
    if data and #data>0 then --主线
        if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
            param = data
            flag = true
        end
    end
    if not flag then
        data = cache.TaskCache:getdailyTasks()
        if data and #data>0 then --主线
            if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
                param = data
                flag = true
            end
        end
    end
    if not flag then
        data = cache.TaskCache:getgangTasks()
        if data and #data>0 then --主线
            if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
                param = data
                flag = true
            end
        end
    end
    if flag then
        mgr.TaskMgr:setCurTaskId(data[1].taskId)
        mgr.TaskMgr.mState = 2 --设置任务标识
        mgr.TaskMgr:resumeTask(true)
        return  
    end
    --TODO 没任务根据等级去对应的挂机点
    --local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    if mgr.FubenMgr:isSitDownSid() then --主城挂机 打坐
        local view = mgr.ViewMgr:get(ViewName.SitDownView)
        if not view then
            gRole:sendsit()
        end
    end
end

--原地挂机
function HookMgr:startHook()
    --print("HookMgr:startHook()")
    if self.isHook == false then
        self:addHookTimer()
        self.isHook = true
        gRole:baseAttack()
        self.hookCount = 1
        self:setHookState()
    end
end

--停止挂机
function HookMgr:stopHook()
    --print("HookMgr:stopHook()")
    --print(debug.traceback())
    self.hookCount = 0
    self.isHook = false
    self.hookType = 0
    self.fbPath = {}
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
        self:setHookState()
    end
    self:setPickState(false)
end
--拾取状态
function HookMgr:setPickState(state)
    self.isPickState = state
end

function HookMgr:getPickState()
    return self.isPickState
end
--更新玩家可释放的技能
function HookMgr:updateSkills(sId, cool)
    if cool==false then
        self.skillList[sId] = 1
    else
        self.skillList[sId] = nil
    end
end
--挂机检测
function HookMgr:checkHook()
    --检查是否有遥感操作
    if UJoystick.IsJoystick then
        mgr.TaskMgr.mState = 0 --设置为自动取消任务
        self:stopHook()
        return false
    end
    --副本挂机检查周围的怪
    if self.hookType == FuBenType then
        if not self:fuBenCheckHook() then
            return false
        end
    end
    if self.hookType == WenDingType then
        if not self:playerCheckHook() then
            return false
        end
    end

    return true
end
--更新
function HookMgr:update()
    if self.isHook then
        --检查挂机
        if not self:checkHook() then
            return
        end
        self.hookCount = self.hookCount + 1
        -- 如果有技能则释放技能
        -- 策划要求 注意一下挂机时候的技能释放顺序，是不是优先放高级的技能的，现在是反的，三个技能都有的情况，是应该先放最高级，再放第二个，再放第一个
        -- id 大的是后面的 
        local s = nil
        for k, v in pairs(self.skillList) do
            local open = UPlayerPrefs.GetInt(k.."_SkillPanel")
            print(open,k)
            if open and open>0 then
                if not s then
                    s = k 
                else
                    math.max(k,s)
                end
            end
        end
        if s and self.hookCount > 2 then
            gRole:skillAttack(s)
            self:AutoChange()
            return
        end
        gRole:baseAttack()
    end
end
--设置挂机状态（如主界面的按钮）
function HookMgr:setHookState()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view and view.BtnFight then
        view.BtnFight:setHookState()
    end
end
--挂机期间 尝试变身
function HookMgr:AutoChange()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view and view.BtnFight then
        view.BtnFight:AutoChange()
    end
end
return HookMgr