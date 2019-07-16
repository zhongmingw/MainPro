local InputMgr = class("InputMgr")

function InputMgr:ctor()
    
end
--使用操作杆之后除了一些事情
function InputMgr:IsJoystick()
    -- body
    --三界停止护送追随
    cache.KuaFuCache:setIsAuto(false)
    --打断进度条
    CClearPickView()
    GCancelPick()
end

function InputMgr:update()
    if gRole == nil then return end

    if Input.GetMouseButtonUp(0) then
        --使用操作杆
        if UJoystick.IsJoystick then
            self:IsJoystick()
            return
        end
        --点击了fairygui
        if Stage.isTouchOnUI then
            return
        end
        
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:setMoshiState(cache.PlayerCache:getPKState())
        end

        local position = Input.mousePosition
        local clickName = UnityCamera:CameraRayHitTransform(position)
        if clickName ~= "" then
            local arr = string.split(clickName, "-")

            if arr[2] == gRole:getID()then  --选中主角
                
            elseif tonumber(arr[1]) == ThingType.pet then  --选中宠物

            elseif tonumber(arr[1]) == ThingType.monster then --选中怪物
                local flag = false
                local monster = mgr.ThingMgr:getObj(ThingType.monster, arr[2])
                if monster then
                    local data = monster.data
                    local npcConf = conf.NpcConf:getNpcById(data.mId)
                    local isSjPick = npcConf and npcConf.is_sj_pick or 0
                    if isSjPick > 0 then
                        flag = true
                    elseif data.kind == 0 then
                        local mConf = conf.MonsterConf:getInfoById(data.mId)
                        if mConf.kind == 4 
                        or mConf.kind == 5 
                        or mConf.kind == MonsterKind.homedog  then --不给选择塔
                            flag = true
                        end
                    elseif data.kind == MonsterKind.crystal or data.kind == MonsterKind.collection then--不给选择拾取buff
                        flag = true
                    elseif data.kind == WidgetKind.home then
                        flag = true
                    end
                end
                if not flag then
                    mgr.FightMgr:changeBattleTarget(true, arr[1], arr[2])
                else
                    mgr.ThingMgr:addSelectEct(arr[1], arr[2])
                end
                --mgr.ThingMgr:addSelectEct(arr[1], arr[2])
                --检测是否选择的是怪物
                self:chooseMonster(arr)
            elseif tonumber(arr[1]) == ThingType.npc then --选择的是npc
                mgr.ThingMgr:addSelectEct(arr[1], arr[2])
                self:chooseNpc(arr)
            else
                local sId = cache.PlayerCache:getSId()
                if mgr.FubenMgr:isExpFuben(sId) then return end
                local otherPlayer = mgr.ThingMgr:getObj(ThingType.player, arr[2])
                if otherPlayer and otherPlayer.data.kind == PlayerKind.statue_new then
                    mgr.ViewMgr:openView2(ViewName.DumplingsView) --EVE 主城选中汤锅模型
                elseif otherPlayer and otherPlayer.data.kind ~= PlayerKind.statue then--排除雕像
                    mgr.FightMgr:changeBattleTarget(true, arr[1], arr[2])
                    --mgr.ThingMgr:addSelectEct(arr[1], arr[2])
                    --检测是否选择的是玩家
                    self:choosePlayer(arr)
                end
            end
        else
            --若在采集，点击寻路关闭采集信息bxp2018/9/27
            local view = mgr.ViewMgr:get(ViewName.PickAwardsView)
            if view then
                CClearPickView()
                GCancelPick()
            end  
            local clickpos = UnityCamera:CameraRayHitPosition(position)
            gRole:moveToPoint(clickpos, 10, function()
               
            end)
            local id = cache.PlayerCache:getSkins(4)
            if not self.mousePosition then
                return
            end
            local x = position.x  - self.mousePosition.x 
            local y = position.y  - self.mousePosition.y
            if math.abs(x) <  math.abs(y) and math.abs(y) > 50 then
                if y < 0 then --下
                    if gRole:isMount() then
                        if id > 0 then
                            gRole:handlerMount(ResPath.mountRes(id))
                        end
                    else
                    end
                else--上
                    if not gRole:isMount() then
                        if id > 0 then
                            
                            gRole:handlerMount(ResPath.mountRes(id))
                        end
                    end
                end
            end
        end
    end

    if Input.GetMouseButtonDown(0) then
        --点击了fairygui
        if Stage.isTouchOnUI then
            return
        end
        --使用操作杆
        if UJoystick.IsJoystick then
            self:IsJoystick()
            return
        end
        self.mousePosition = Input.mousePosition
    end
end

function InputMgr:choosePlayer(arr)
    -- body
    --选择的不是玩家
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isXdzzWar(sId) then return end
    if mgr.FubenMgr:isWenDing(sId) then return end
    local otherPlayer = mgr.ThingMgr:getObj(ThingType.player, arr[2])
    if otherPlayer then
        local data = otherPlayer.data
        if data.attris[544] and data.attris[544] == 1 then
            print("这个是机器人")
            return
        end
        -- printt(data)
        local param = {}
        param.level = data.level
        param.roleIcon = data.roleIcon
        param.roleName = data.roleName
        param.roleId = data.roleId
        param.friend = true
        param.trade = true --
        param.teamId = data.teamId
        param.teamCaptain = data.teamCaptain
        param.mainSvrId = data.mainSvrId
        param.level = data.attris[502] or 1--角色等级
        --plog("param.svrId",param.svrId)
        --param.heiming = true
        --param.pos = {x=0,y=0}--位置偏移
        local kind = data and data.kind or 0
        if kind ~= 7 then
            mgr.ViewMgr:openView(ViewName.FriendTips, function( view )
                -- body
                view:setData(param)
            end)
        end
    end
end

function InputMgr:choosSjbx(data)
    -- body
    if not data.attris or not data.attris[603] then
        return
    end

    ---需要检测是否是自己的箱子 11/25
    local task = cache.KuaFuCache:getTaskCache(3)
    local box = cache.KuaFuCache:getBoxGrids()
    local t = {}
    for k ,v in pairs(box) do
        t[v.gridId] = v 
    end
    if not task then
        return
    else 
        if data.attris and data.attris[611] then


            if t[data.attris[611]] and t[data.attris[611]].roleId ~=  cache.PlayerCache:getRoleId() then
                GComAlter(language.kuafu165)
                return
            end
        end
        --print(task.boxRoleId,data.roleId)
        -- if task.boxRoleId ~= data.roleId then
        --     GComAlter(language.kuafu165)
        --     return
        -- end
    end

    if data.attris[603]>0 then
        GComAlter(string.format(language.kuafu135,data.attris[603]))
    else
        proxy.KuaFuProxy:sendMsg(1810501,{roleId = data.roleId,reqType=1})
    end
end

function InputMgr:chooseMonster(arr)
    local monster = mgr.ThingMgr:getObj(ThingType.monster, arr[2])
    if mgr.ViewMgr:get(ViewName.PickAwardsView) then
        return
    end
    if monster then
        local data = monster.data
        local p = Vector3.New(data.pox, gRolePoz, data.poy)
        if data.kind == MonsterKind.chest then
            gRole:moveToPoint(p, PickDistance, function()
                gRole:collect(function(state)
                end)
                if not mgr.ViewMgr:get(ViewName.PickAwardsView) then
                    local func = function() end
                    local pickUseTime = nil
                    if data.kind == MonsterKind.chest then--宝箱
                        func = function()
                            proxy.FubenProxy:send(1810301,{tarPox = data.pox,tarPoy = data.poy})--拾取
                            gRole:idleBehaviour()
                        end
                    end
                    local data2 = {monsterData = data,pickUseTime = pickUseTime,func = func}
                    mgr.ViewMgr:openView2(ViewName.PickAwardsView, data2)
                end
            end)
        elseif data.kind == MonsterKind.collection then
            gRole:moveToPoint(p, PickDistance, function()
                if mgr.FubenMgr:isHuangLing(cache.PlayerCache:getSId()) then --如果是皇陵战
                    local taskList = cache.HuanglingCache:getTaskCache()
                    for k,v in pairs(taskList) do --查看任务是否完成
                        local confData = conf.HuanglingConf:getTaskAwardsById(v.taskId)
                        if data.mId == confData.tar_con[1][1] then
                            if v.taskFlag == 1 then
                                GComAlter(language.huangling09)
                            else
                                proxy.ThingProxy:send(1810302,{roleId = data.roleId,reqType = 1})
                            end
                        end
                    end
                elseif mgr.FubenMgr:isWanShenDian(cache.PlayerCache:getSId()) then--万神殿
                    -- printt("当前采集>>>>>>>>>>",data)
                    proxy.ThingProxy:send(1810302,{roleId = data.roleId,reqType = 5})
                else
                    proxy.ThingProxy:send(1810302,{roleId = data.roleId,reqType = 1})
                end
            end)
        elseif data.kind == MonsterKind.crystal then
            gRole:moveToPoint(p, PickDistance, function()
                proxy.ThingProxy:send(1810302,{roleId = data.roleId,reqType = 4})
            end)
        elseif data.kind == MonsterKind.sjchest then 
            --三界争霸的箱子
            self:choosSjbx(data)
        elseif data.kind == WidgetKind.tree then
            local coupleName = cache.PlayerCache:getCoupleName()
            if coupleName == "" then return end
            if data.name == coupleName or data.name == cache.PlayerCache:getRoleName() then
                mgr.ViewMgr:openView2(ViewName.MarryTreeHandle, data)
            end
        elseif data.kind == MonsterKind.sjmonster then 
            if mgr.FubenMgr:isKuaFuWar(cache.PlayerCache:getSId()) then
                --选择的是三界中的镖车
                local view = mgr.ViewMgr:get(ViewName.KuaFuCheHpView)
                if not data.isDead then
                    if view then
                        view:initData(data)
                    else
                        mgr.ViewMgr:openView2(ViewName.KuaFuCheHpView,data)
                    end
                else
                    
                    if view then
                        view:closeView()
                    end
                end
            end
        elseif data.kind == WidgetKind.home then
            --printt("data",data) 
            local condata = conf.HomeConf:getHomeThing(data.ext01)
            monster:addComponent()
        end
    end
end

--EVE 使用坐骑函数，供给主界面快捷键使用
function InputMgr:useMountsUpper()
    local id = cache.PlayerCache:getSkins(4)
    if not gRole:isMount() then      --上马
        if id > 0 then
                local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
                if confdata.kind ~= SceneKind.mainCity and
                    confdata.kind ~= SceneKind.field and
                    confdata.kind ~= SceneKind.xinshou then 
                    GComAlter(language.usemounts01) 
                    -- plog("副本中不能上马！")
                    return
                end
                gRole:handlerMount(ResPath.mountRes(id))
        end
    end
end
function InputMgr:useMountsLower()
    local id = cache.PlayerCache:getSkins(4)
    if gRole:isMount() then         --下马
        if id > 0 then
            gRole:handlerMount(ResPath.mountRes(id))
        end
    end
end


function InputMgr:chooseNpc(arr)
    -- body
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isKuaFuWar(sId) then
        --如果是跨服三界争霸
        local _npc = conf.NpcConf:getNpcById(arr[2])
        if not _npc or not _npc.npc_use or _npc.npc_use < 1 or _npc.npc_use > 3  then
            return
        end
        --跨服日常任务npc
        --检测任务状态
        local task = cache.KuaFuCache:getTaskCache(_npc.npc_use)
        local _t = conf.KuaFuConf:getSjzbTask(_npc.npc_use)
        if (_t.open_lev or 0) > cache.PlayerCache:getRoleLevel() then
            --等级不足
            GComAlter(string.format(language.kuafu133,_t.open_lev or 0))
            return
        end
        local var = _t and _t.limit_count or 1
        if task.taskState == 1 then--已经接受
            GComAlter(language.kuafu125)
            --打开界面
            -- if _npc.npc_use == 1 or _npc.npc_use == 3 then
            --     mgr.ViewMgr:openView2(ViewName.TaskViewKuaFu,_npc.npc_use)
            -- end
        elseif task.curCount>= var then 
            GComAlter(language.kuafu124)
        else
            if _npc.npc_use == 1 then
                proxy.KuaFuProxy:sendMsg(1410201,{type=1}) 
            elseif _npc.npc_use == 2 then
                mgr.ViewMgr:openView2(ViewName.KufuCheViewNew,_npc.npc_use)
            elseif _npc.npc_use ==  3 then
                proxy.KuaFuProxy:sendMsg(1410203,{type=0})
                --proxy.KuaFuProxy:sendMsg(1410203,{type=1}) 
            end
        end
    elseif mgr.FubenMgr:isWSJChuMo(sId) then
        local _npc = conf.NpcConf:getNpcById(arr[2])
        --万圣狂欢降妖除魔NPC
        if _npc.npc_use ==  4 then
            local floor = sId%100
            -- mgr.ViewMgr:openView2(ViewName.WSJTaskView,{floor = floor})
            local point = Vector3.New(_npc.pos[1], gRolePoz, _npc.pos[2])
            mgr.TaskMgr:goTaskBy(sId, point, function()
                mgr.ViewMgr:openView2(ViewName.WSJTaskView,{floor = floor})
            end)
        end
    end
    --选择的是npc
    local condata = conf.TaskConf:getTaskById(9003)
    if tonumber(arr[2]) == tonumber(condata.npc) then --选择的是指定结婚npc
        --打开
        mgr.ViewMgr:openView2(ViewName.MarryNpcView)
        return
    end
    
end

return InputMgr