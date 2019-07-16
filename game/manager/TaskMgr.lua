local TaskMgr = class("TaskMgr")

function TaskMgr:ctor()
    self.mCurTaskId = nil
    self.mState = 0 -- 1.任务进行中,2.场景切换后继续任务 
    self.mTaskCof = nil
    self.timer = nil

    self.toMap = nil --目标地图
    self.toPos = nil --目标地方
end

function TaskMgr:setCurTaskId(id)
    -- body
    self.mCurTaskId = id
end

function TaskMgr:addTaskTimer()
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(0.2, -1, function()
            self:update()
        end, "taskTimer")  
    end
end

function TaskMgr:update()
    -- body
    if self.mState~=1 then
       mgr.ModuleMgr:closeFindPath(0)
        return
    end

    if not self.toMap or not self.toPos then
        mgr.ModuleMgr:closeFindPath(0) --自动寻路关闭
        return
    end
    --到目的地了
    if cache.PlayerCache:getSId() == self.toMap then
        local t = gRole:getPosition()
        if self.toPos.x == t.x and self.toPos.z == t.z then
            mgr.ModuleMgr:closeFindPath(0) --自动寻路关闭
 
            --self.mState = 2 --设置任务标识
            --self:resumeTask()
            return
        end
    end
    -- 2-死亡 3-打坐 4-采集1-战斗 0 待机
    if gRole and gRole:getStateID() <= 4 then
        mgr.ModuleMgr:closeFindPath(0)
        return
    end

    --遥感操作
    if UJoystick.IsJoystick then
        mgr.TaskMgr.mState = 0 --设置为自动取消任务
        mgr.ModuleMgr:closeFindPath(0) --自动寻路关闭
        return
    end
    
    mgr.ModuleMgr:startFindPath(0)
    mgr.HookMgr:setHookState()
end
--停止当前任务 --一些一键完成的时候 任务要停下来
function TaskMgr:stopTask()
    -- body
    self.mState = 0
    gRole:idleBehaviour()
    mgr.ModuleMgr:closeFindPath(0)
end



--开始任务
function TaskMgr:startTask(id)
    --
    -- if cache.GuideCache:getMarry() then
    --     return
    -- end

    if not self.mCurTaskId then
        plog("not self.mCurTaskId")
        return
    elseif self.mState ~= 2 then
        plog("self.mState ~= 2")
        return
    end
    self:addTaskTimer()
    --
    mgr.XinShouMgr:enterGame()
    --停止追着打
    mgr.FightMgr:removeTimer()
    
    self.mState = 1
    plog("self.mCurTaskId",self.mCurTaskId)

    self.mTaskCof = conf.TaskConf:getTaskById(self.mCurTaskId)
    --printt(self.mTaskCof)
    


    local index = tonumber(string.sub(tostring(self.mCurTaskId),1,1))
    if index == 1 then
        if self.mTaskCof.type == 1 and self.mTaskCof.trigger_lev 
            and cache.PlayerCache:getRoleLevel() < self.mTaskCof.trigger_lev  then
            GGuildeLevel()
            return
        end
    end

    local taskConf = self.mTaskCof
    local taskType = taskConf["task_type"]

    local id = cache.PlayerCache:getSkins(Skins.zuoqi)
    if id ~= 0 and taskType ~= 4 then
        if not gRole:isMount() and not mgr.FubenMgr:checkScene() then
            gRole:handlerMount(ResPath.mountRes(id))
        end
    end
    
    if taskType == 1 then  --寻找npc
        self:openNpc()
    elseif taskType == 2 then  --打怪走到怪物点
        self:openMonster()
    elseif taskType == 3 then  --采集物
        if gRole:getStateID() == 4 then --本身就在采集中
            return
        end
        if self:isfinish(self.mTaskCof) then
            self:openTaskProess()
        end
        
    elseif taskType == 4 then --副本关卡
        if index == 1 then
            if self:checkTaskType4() then
                mgr.XinShouMgr:runNearTar(self.mTaskCof)
            end
        else
            if self:isfinish(self.mTaskCof) then
                self:dailyTaskFindNpc()
                -- if self.mTaskCof.findnpc then
                --     self:dailyTaskFindNpc()
                -- else
                --     mgr.FubenMgr:gotoFubenWar(self.mTaskCof.conditions[1][1])
                -- end

                --
            end
        end
    elseif taskType == 5 then  --进入练级谷
        -- gRole:inFuben()
        -- mgr.FubenMgr:gotoFubenWar(Fuben.level)
    elseif taskType == 98 then  --前往某个点
        self:goWhere()
    elseif taskType == 99 then --只是前往某个点，然后打坐
        self:goandsit()
    elseif taskType == 97 then --前往结婚点
        self:goandMarry()
    elseif taskType == 96 then --三界争霸日常任务boss
        self:goandSjrc()
    else
        plog("不存在的任务 task_type",self.mCurTaskId)
    end

    --self.mCurTaskId = nil 
end

function TaskMgr:isFubenTask()
    -- body
    if not self.mTaskCof then
        return false
    end
    if self.mTaskCof.task_type == 4 then
        return true
    end
    return false
end

function TaskMgr:roleMoveTo(nPos, reach, callback)
    local point = Vector3.New(nPos[1], gRolePoz, nPos[2])
    local dis = GMath.distance(point, gRole:getPosition())
    if dis <= (reach or 0) or dis<80 then --避免再同一个位置停止的问题 
        plog("本身就在目的地")
        if callback then 
            callback()
        end
        return
    end
    mgr.JumpMgr:findPath(point, reach or 0, callback)
end

function TaskMgr:toChangMap( param,curstep,nextstp)
    -- body
    local findId 
    if curstep > nextstp then
        findId = param[curstep-1]
    else
        findId = param[curstep+1]
    end

    if findId then
        --plog("hahaha")
        local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
        local transfer = curMapConf.transfer
        for k ,v in pairs(transfer) do
            local confData = conf.NpcConf:getNpcById(v) 
            if confData.to_pos then
                --plog(confData.to_pos[1],findId)
                if tonumber(confData.to_pos[1]) == tonumber(findId) then
                    local taskMgrcall = function()
                        local t = gRole:getPosition()
                        local pos = Vector3.New(confData.pos[1],gRolePoz,confData.pos[2])
                        local dis = GMath.distance(pos, gRole:getPosition())
                        if dis<80 then
                            plog("传送点位置改变")
                            self.mState = 2
                        end
                    end
                    local point = Vector3.New(confData.pos[1], 0, confData.pos[2])
                    mgr.JumpMgr:findPath(point, reach or 0, taskMgrcall, taskMgrcall)
                    return
                end    
            end
        end
    end
end

function TaskMgr:find(toMap,curMap)
    -- body
    --plog(toMap,curMap)
    local maplian =  conf.SceneConf:getMapLian({curMap,toMap})
    if maplian then --在同一个地图连上
        --printt("在同一个地图连上",maplian)
        local curMap_step 
        local toMap_step
        for k ,v in pairs(maplian) do
            if tonumber(curMap) == tonumber(v) then
                curMap_step = k
            end
            if tonumber(toMap) == tonumber(v) then
                toMap_step = k
            end

            if curMap_step and toMap_step then --在同一张地图上
                break
            end
        end
        self:toChangMap(maplian,curMap_step,toMap_step)
        return
    end

    ---不在同一地图连上
     --主城连
    local maplist = conf.SceneConf:getMapById(1)
    local curinmain = false
    local tomapinmian = false
    for k ,v in pairs(maplist.maplian) do
        if tonumber(curMap) == tonumber(v) then --当前地图是在主干上
            curinmain = true
        elseif tonumber(toMap) == tonumber(v) then
            tomapinmian = true --目标地图在主干上
        end
    end

    if not curinmain then
        local confData = conf.SceneConf:getMapButMain(curMap)
        if not confData then
            plog("找不到包含 curMap "..curMap.."的链接")
            return
        end
        for k ,v in pairs(confData) do
            if tonumber(curMap) == tonumber(v) then
                self:toChangMap(confData,k,1)
                return 
            end
        end
    end

    if not tomapinmian then
        local confData = conf.SceneConf:getMapButMain(toMap)
        --plog("confData",confData)
        if not confData then --找到
            plog("找不到包含 toMap "..toMap.."的链接")
            return
        end
        local curMap_step 
        local toMap_step
        for k ,v in pairs(maplist.maplian) do
            if tonumber(curMap) == tonumber(v) then
                curMap_step = k
            end
            if tonumber(confData[1]) == tonumber(v) then --目标的主城
                toMap_step = k
            end

            if curMap_step and toMap_step then
                break
            end
        end
        self:toChangMap(maplist.maplian,curMap_step,toMap_step)
        return
    end

    --plog("map_lian 第一条主城连没有连上")
end

function TaskMgr:openNpc()
    -- body
    local npcId = self.mTaskCof.conditions[1][1]
    local reach = self.mTaskCof.reach or 0
    local npcConf = conf.NpcConf:getNpcById(npcId)
    local nPos = npcConf.pos
    local mapId = npcConf.map_id --Npc所在地图

    local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    local curMap = curMapConf.map_id  --当前所在地图

    self.toMap = mapId
    self.toPos = Vector3.New(nPos[1], gRolePoz, nPos[2])

    if mapId == curMap then
        self:roleMoveTo(nPos,reach,function(  )
            -- body
            self.toPos = nil 
            self.toMap = nil 
            self:reachToNpc()
        end)
    else
        self:find(mapId,curMap)
    end
end

function TaskMgr:dailyTaskFindNpc()
    -- body
    local lv = cache.PlayerCache:getRoleLevel()

    local npclistConf = conf.TaskConf:getNpcByLevel(lv)

    if npclistConf and npclistConf.npc then
        if not self.lastid then
            self.lastid = math.random(1,#npclistConf.npc)
        end
        local npcId = npclistConf.npc[checkint(self.lastid)]
        local npcConf = conf.NpcConf:getNpcById(npcId)
        local nPos = npcConf.pos
        local mapId = npcConf.map_id --Npc所在地图
        local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
        local curMap = curMapConf.map_id  --当前所在地图

        self.toMap = mapId
        self.toPos = Vector3.New(nPos[1], gRolePoz, nPos[2])

        if mapId == curMap then

            self:roleMoveTo(nPos,50,function()
                -- body
                self.lastid = nil 
                --在这个打开npc对话
                self.toPos = nil 
                self.toMap = nil 
                -- print("对话NPC~~~~~~~~~~~~~")
                
                local tempData = {
                    npcId = npcId,
                    data = self.mTaskCof,
                }
                mgr.ViewMgr:openView2(ViewName.TaskView3, tempData)
                -- mgr.FubenMgr:gotoFubenWar(self.mTaskCof.conditions[1][1])
            end)
        else
            self:find(mapId,curMap)
        end
    end
end

--对话
function TaskMgr:openDialogView()
    -- body
    mgr.ViewMgr:openView(ViewName.DialogView,function( view )
        -- body
        view:setData(self.mTaskCof.dialogid)
    end)
end
--完成任务
function TaskMgr:openTaskView(id)
    -- body
    mgr.ViewMgr:openView(ViewName.TaskView,function( view )
        -- body
        view:setData(self.mTaskCof.task_id,id)
    end)
end
--采集 进度
function TaskMgr:openTaskProess()
    -- body
    local t,key = self:isfinish(self.mTaskCof)
    local function callBack()
        -- body
        gRole:collect(function(state)
            if 1 == state then
                 mgr.ViewMgr:openView(ViewName.CollectBarView,function( view )
                    -- body
                    view:setData(self.mTaskCof.task_id,t,key)
                end)
            else
                local view = mgr.ViewMgr:get(ViewName.CollectBarView)
                if view then
                    view:closeView()
                end
            end
        end)
    end

    if t then
        local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
        local curMap = curMapConf.map_id  --当前所在地图
        local x = self.mTaskCof.monster_pos[key][1]
        local z = self.mTaskCof.monster_pos[key][2]

        self.toMap = self.mTaskCof.mapid
        self.toPos = Vector3.New(x, gRolePoz, z)
        if tonumber(self.mTaskCof.mapid) == tonumber(curMap) then
            
            local param = {x,z}
            if x and z then
                self:roleMoveTo(param,0,function()
                    self.toPos = nil 
                    self.toMap = nil 
                    callBack()
                end)
            else
                callBack()
            end

        else
            self:find(self.mTaskCof.mapid, curMap)
        end
    else
    end
end
--杀怪任务
function TaskMgr:openMonster()
    -- body
    local t,key = self:isfinish(self.mTaskCof)
    if t then
        local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
        local curMap = curMapConf.map_id  --当前所在地图
        local x = self.mTaskCof.monster_pos[key][1]
        local z = self.mTaskCof.monster_pos[key][2]
        local param = {x,z}

        self.toMap = self.mTaskCof.mapid
        self.toPos = Vector3.New(x, gRolePoz, z)

        if tonumber(self.mTaskCof.mapid) == tonumber(curMap) then

            self:roleMoveTo(param,self.mTaskCof.reach or 0,function(  )
                -- body
                self.toPos = nil 
                self.toMap = nil 
                self:reachToMonster()
            end)
        else

            self:find(self.mTaskCof.mapid, curMap)
        end
    end
end
--任务广播之后检测一下当前任务是否完成
function TaskMgr:checkCurTask()
    -- body
    --检测所有任务
    --检测主线任务
    local data = cache.TaskCache:getData()
    if data and #data>0 then --主线
        --printt("主线",data)
        if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
            local condata = conf.TaskConf:getTaskById(data[1].taskId)
            if 2 == condata.task_type 
            or 3 == condata.task_type then
                self:isfinish(condata)
            end
        end
    end

    local data = cache.TaskCache:getbranchTasks()
    if data and #data>0 then --支线
        --printt("主线",data)
        if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
            local condata = conf.TaskConf:getTaskById(data[1].taskId)
            if 2 == condata.task_type then
                self:isfinish(condata)
            end
        end
    end

    local data = cache.TaskCache:getdailyTasks()
    if data and #data>0 then --日常
        --print("日常",data[1].taskStatu )
        if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
            local condata = conf.TaskConf:getTaskById(data[1].taskId)
            if 2 == condata.task_type
            or 3 == condata.task_type then
            --or 4 == condata.task_type then
                self:isfinish(condata)
            end
        end
    end

    local data = cache.TaskCache:getgangTasks()
    if data and #data>0 then --帮派
        --printt("主线",data)
        if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
            local condata = conf.TaskConf:getTaskById(data[1].taskId)
            if 2 == condata.task_type then
                self:isfinish(condata)
            end
        end
    end


    -- if self.mTaskCof and self.mTaskCof.conditions and 2 == self.mTaskCof.task_type then
    --     self:isfinish(self.mTaskCof)
    -- end
end

--根据任务完成条件判定任务是否完成
function TaskMgr:isfinish(data)
    -- body
    local t 
    local key 
    for k ,v in pairs(data.conditions) do
        if data.task_type == 2 or data.task_type == 3 or data.task_type == 4 then 
            if cache.TaskCache:getextMap(data.task_id,v[1]) < v[2] then 
                t = v
                key = k
                break
            end
        end
    end

    if not t then
        if data.type == 1 then
            --plog("完成任務", data.task_id)
            proxy.TaskProxy:send(1050103,{taskId = data.task_id}) --发送完成任务
        elseif data.type == 4 or data.type == 5 then --请求完成日常任务
            -- mgr.ViewMgr:openView(ViewName.TaskOneView, function(view)
            --     -- body
            --     view:setData(data)
            -- end)
            if mgr.FubenMgr:isDayTaskFuben(mgr.SceneMgr.lastSid)  then
                mgr.TimerMgr:addTimer(0.5, 1,function( ... )
                    -- body
                    mgr.ViewMgr:openView2(ViewName.TaskOneView,clone(data))
                end)
            else
                mgr.ViewMgr:openView2(ViewName.TaskOneView,clone(data))
            end
        elseif data.type == 2  then
            --支线任务
            proxy.TaskProxy:send(1050501,{taskId = data.task_id})
        end
    else
        return t,key --返回未完成
    end

    return nil , nil
end
--抵达npc
function TaskMgr:reachToNpc()
    if self.mTaskCof then --当前任务
        if self.mTaskCof.trigger_lev and cache.PlayerCache:getRoleLevel() < self.mTaskCof.trigger_lev  then 
            return
        end
        if not mgr.XinShouMgr:runNearTar(self.mTaskCof) then
            if self.mTaskCof.dialogid then --如果有对话
                self:openDialogView()
            else
                self:openTaskView()
            end
        end
    end
end
--抵达打怪点
function TaskMgr:reachToMonster()
    if not mgr.XinShouMgr:runNearTar(self.mTaskCof) then
        mgr.HookMgr:startHook()
    end
end
--特殊处理 请勿调用
function TaskMgr:firstTask()
    -- body
    local condata = conf.TaskConf:getTaskById(1001)
    mgr.XinShouMgr:runNearTar(condata) --self:reachToMonster()
end

--唤起任务
function TaskMgr:resumeTask(flag)
    if self.mState ~= 2 then
        self:stopTask()
        return
    end
    --副本不继续任务主线和日常 仙盟任务
    if mgr.FubenMgr:checkScene() then--副本不继续的任务
        if not self.mCurTaskId then
            self:stopTask()
            return
        elseif self.mCurTaskId and self.mCurTaskId<=6000 then
            self:stopTask()
            return
        end
    end
    mgr.HookMgr:cancelHook()
    --获得坐骑界面不继续任务
    local view = mgr.ViewMgr:get(ViewName.GuideZuoqi)
    if view then
        return
    end


    self:startTask()
end
--完成任务 任务协议返回完成那条人物
function TaskMgr:completeTask(id)
	--任务完成处理一下采集是蹲着的情况
    if gRole and gRole:getStateID() == 4 then 
        gRole:idleBehaviour()
    end

    local confData = conf.TaskConf:getTaskById(id) 
    if confData.type == 4 or confData.type == 5 then
        if confData.type == 4 then
            --获取新的日常任务
            local data = cache.TaskCache:getdailyTasks()
            if data and #data>0 then
                if id == self.mCurTaskId then
                    self.mCurTaskId = data[1].taskId  
                end
                self.mState = 2
                self:resumeTask()
            else
                self.mCurTaskId = nil 
            end
        elseif confData.type == 5 then
            local data = cache.TaskCache:getgangTasks()
            if data and #data>0 then
                if id == self.mCurTaskId then
                    self.mCurTaskId = data[1].taskId
                end
                self.mState = 2
                self:resumeTask()
            else
                self.mCurTaskId = nil 
            end
        end
    --检测一下新的任务是否生成
    else 
        if confData["next_task"] then
            local t = cache.TaskCache:getDataById(confData["next_task"])
            --printt("t",t)
            if  t and  t.taskStatu == 1 or t.taskStatu == 0 then
                self.mCurTaskId = confData["next_task"] 
                self.mState = 2
                self:resumeTask()
            else
                self.mCurTaskId = nil 
            end
        else
            self.mCurTaskId = nil 
        end
    end

end
--任务完成临时测试接口
function TaskMgr:testMonsterDeadCount()
    if not self.testCount then
        self.testCount = 0
    end
    proxy.LoginProxy:reqTestCmd("set task")
    proxy.TaskProxy:send(1050103,{taskId = self.mTaskCof.task_id})
end
--只是前往某个点
function TaskMgr:goWhere()
    -- body
    local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    local kind = curMapConf and curMapConf.kind or 0
    local curMap = curMapConf.map_id  --当前所在地图
    if not self.mTaskCof.monster_pos then
        return
    end

    local x = self.mTaskCof.monster_pos[1][1]
    local z = self.mTaskCof.monster_pos[1][2]
    local param = {x,z}

    self.toMap = self.mTaskCof.mapid
    self.toPos = Vector3.New(x, gRolePoz, z)
  
    if mgr.FubenMgr:checkScene(cache.PlayerCache:getSId()) 
        or SceneKind.XianmengZhudi == kind then
        --如果是副本里面的地图
        if self.mTaskCof.path then --地图算好的路径
            local t = gRole:getPosition()
            if self.toPos.x == t.x and self.toPos.z == t.z then
            else
                mgr.JumpMgr:moveByPath(param, self.mTaskCof.path, nil, nil)
            end
        else
            self:roleMoveTo(param,self.mTaskCof.reach,function(  )
                -- body
                if self.func then
                    self.func()
                    self.func = nil 
                end
                self.toPos = nil 
                self.toMap = nil 
            end)
        end
        return
    end


    if tonumber(self.mTaskCof.mapid) == tonumber(curMap) then
        if self.mTaskCof.path then --地图算好的路径
            local t = gRole:getPosition()
            if self.toPos.x == t.x and self.toPos.z == t.z then
            else
                mgr.JumpMgr:moveByPath(param, self.mTaskCof.path, nil, nil)
            end
        else
            
            self:roleMoveTo(param,self.mTaskCof.reach,function(  )
                -- body
                --跑到了指定位置
                if self.func then
                    self.func()
                    self.func = nil 
                end
                self.toPos = nil 
                self.toMap = nil 
            end)
            
        end
    else
        self:find(self.mTaskCof.mapid, curMap)
    end
end

--
function TaskMgr:goTaskBy(mapId,point,func)
    --plog(mapId,point.x,point.z)
    self.func = func
    if not mapId then
        return
    end

    if not point then
        return
    end

    local id = 9002
    local condata = conf.TaskConf:getTaskById(id)
    condata.mapid = tonumber(mapId) 
    condata.monster_pos = {{point.x,point.z}}
    self:setCurTaskId(id)
    self.mState = 2 --设置任务标识
    self:resumeTask()
end
--前往打坐点
function TaskMgr:goandsit()
    -- body
    gRole:cancelSit()
    local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    local curMap = curMapConf.map_id  --当前所在地图
    local x = self.mTaskCof.monster_pos[1][1]
    local z = self.mTaskCof.monster_pos[1][2]
    local param = {x,z}

    self.toMap = self.mTaskCof.mapid
    self.toPos = Vector3.New(x, gRolePoz, z)

    if tonumber(self.mTaskCof.mapid) == tonumber(curMap) then
        self:roleMoveTo(param,self.mTaskCof.reach,function(  )
            -- body
            self.toPos = nil 
            self.toMap = nil 
            gRole:sendsit()
        end)
    else
        self:find(self.mTaskCof.mapid, curMap)
    end
end
--检测当前任务是否完成
function TaskMgr:checkTaskType4()
    -- body
    --self.mCurTaskId =
    local index = tonumber(string.sub(tostring(self.mCurTaskId),1,1))
    if index == 1 then
        local id = cache.TaskCache:getCurMainId()
        local confdata = conf.TaskConf:getTaskById(id)
        if confdata then
            return self:isfinish(confdata)
        end
    else
        if self.mTaskCof then
            return self:isfinish(self.mTaskCof)
        end
    end
    return true
end

--升级检测是否需要请求任务
function TaskMgr:checkLevelTask()
    -- body
    local var = conf.TaskConf:getValue("check_level_task")
    if cache.TaskCache:isOnlyMain() then
        return
    end
    local level = cache.PlayerCache:getRoleLevel()
    for k , v in pairs(var) do
        if v[1] == 4 and v[2]<=level then --日常
            local data = cache.TaskCache:getdailyTasks()
            if not data or #data == 0 then
                cache.BangPaiCache:setTaskReset(true)
                proxy.TaskProxy:send(1050101)
                break
            end
        elseif v[1] == 5 and v[2]<=level then --帮派
            if cache.PlayerCache:getGangId()~="0" then
                local data = cache.TaskCache:getgangTasks()
                if not data or #data == 0 then
                    cache.BangPaiCache:setTaskReset(true)
                    proxy.TaskProxy:send(1050101)
                    break
                end
            end
        elseif v[1] == 6 and v[2]<=level then --商会
            local data = cache.TaskCache:getshangHuiTasks()
            local count = cache.TaskCache:getshangHuiFinishCount()
            if not data or #data == 0 and count == 0 then
                cache.BangPaiCache:setTaskReset(true)
                proxy.TaskProxy:send(1050101)
                break
            end
        elseif v[1] == 2 and v[2]<=level then --支线
            cache.BangPaiCache:setTaskReset(true)
            proxy.TaskProxy:send(1050101)
            break
        end
    end
end


function TaskMgr:goandMarry()
    -- bodd
    local npcId = self.mTaskCof.npc
    local reach = self.mTaskCof.reach or 0
    local npcConf = conf.NpcConf:getNpcById(npcId)
    local nPos = npcConf.pos
    local mapId = npcConf.map_id --Npc所在地图

    local curMapConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    local curMap = curMapConf.map_id  --当前所在地图

    self.toMap = mapId
    self.mCurTaskId = nil 

    mgr.JumpMgr:feiXieJump(mapId,nPos[1],nPos[2],4)
end

function TaskMgr:goandSjrc()
    -- body
    if not mgr.FubenMgr:isKuaFuWar(cache.PlayerCache:getSId()) then
        return
    end
    local npcConf = conf.NpcConf:getNpcById(GNPC.kfrc)
    local nPos = npcConf.pos
    local reach = 50

    self.mCurTaskId = nil 
    self:roleMoveTo(nPos,reach,function(  )
        -- body
        local task = cache.KuaFuCache:getTaskCache(GNPC.kfrc)
        local _t = conf.KuaFuConf:getSjzbTask(1)
        local var = _t and _t.limit_count or 1
        if task.taskState == 1 then--已经接受
            GComAlter(language.kuafu125)
            --打开界面
            mgr.ViewMgr:openView2(ViewName.TaskViewKuaFu,GNPC.kfrc)
        elseif task.curCount>= var then 
            GComAlter(language.kuafu124)
        else
            proxy.KuaFuProxy:sendMsg(1410201,{type=1}) 
        end
    end)
end


return TaskMgr