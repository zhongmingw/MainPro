--
-- Author: 
-- Date: 2017-06-29 10:42:42
--

local KuaFuProxy = class("KuaFuProxy",base.BaseProxy)

function KuaFuProxy:init()
    self:add(5400101,self.add5400101)-- 请求跨服活动列表

    self:add(5330301,self.add5330301)-- 请求跨服精英boss信息
    self:add(5330302,self.add5330302)-- 请求跨服精英boss场景信息

    self:add(5380101,self.add5380101)-- 请求跨服进阶副本信息
    self:add(5380102,self.add5380102)-- 请求跨服进阶队伍创建或加入
    self:add(5380103,self.add5380103)-- 请求跨服进阶副本设置
    self:add(5380104,self.add5380104)-- 请求跨服进阶副本成员操作
    self:add(5380105,self.add5380105)-- 请求跨服进阶副本队伍列表刷新
    self:add(5380201,self.add5380201)-- 请求跨服副本任务追踪
    self:add(5380107,self.add1380107)-- 请求跨服进阶副本一键扫荡

    self:add(5410101,self.add5410101)-- 请求三界争霸信息
    self:add(5410102,self.add5410102)-- 请求三界争霸场景信息
    self:add(5410104,self.add5410104)-- 请求三界争霸刷新镖车
    self:add(5410201,self.add5410201)-- 请求三界争霸杀怪任务
    self:add(5410202,self.add5410202)-- 请求三界争霸护送任务
    self:add(5410203,self.add5410203)-- 请求三界争霸寻宝任务
    self:add(5410204,self.add5410204)-- 请求三界争霸镖车位置

    self:add(8180301,self.add8180301)-- 任务结算
    self:add(8180302,self.add8180302)-- 三界争霸广播日常任务进度
    self:add(8180303,self.add8180303)-- 宝箱任务
    self:add(8180304,self.add8180304)-- 三界争霸劫镖广播

    self:add(8150101,self.add8150101)-- 跨服进阶副本队伍状态广播
    self:add(8150102,self.add8150102)--  跨服进阶副本伤害排行榜广播
end

function KuaFuProxy:sendMsg(msgId,param,index)
    -- body
    -- if 1380102 == msgId then
    --     if cache.PlayerCache:getRoleLevel() < SHUZI.teamfuben then
    --         GComAlter(language.kuafu173)
    --         return
    --     end
    -- end

    self.index = index
    self.param = param
    self:send(msgId,param)
end

function KuaFuProxy:add5400101( data )
    -- body
    if data.status == 0 then
        cache.KuaFuCache:setActiveList(data)
        if self.index then
            if self.index == 0 then
                local view = mgr.ViewMgr:get(ViewName.FubenView)
                if view then
                    view:add5400101(data)
                end
                -- mgr.ViewMgr:openView2(ViewName.FubenView, {index = 8})
            else
                mgr.ViewMgr:openView2(ViewName.KuaFuMainView, {index = self.index})
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5330301(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5330302(data)
    -- body
    if data.status == 0 then
        cache.KuaFuCache:setEliteData(data)
        cache.FubenCache:setFubenModular(language.fuben13[BossScene.elite])
        --cache.FubenCache:setFubenModular(language.fuben13[BossScene.kuafuelite])
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setBossTrack()
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 1})
        end

        mgr.ViewMgr:openView2(ViewName.BossHpView,data)
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5380101(data)
    -- body
    if data.status == 0 then
        cache.KuaFuCache:setFubenData(data)

        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setData(data)
        else
            if self.param.teamId~=0 then
                local param = { id = 1093 , falg = true }
                if GCheckView(param) then
                    GOpenView({id = 1093})
                end
            end
        end

        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- else
        --     if self.param.teamId~=0 then
        --         local param = { id = 1093 , falg = true }
        --         if GCheckView(param) then
        --             GOpenView({id = 1093})
        --         end
        --     end
        -- end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5380102( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setData(data)
        end
        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5380103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setData(data)
        end
        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5380104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setData(data)
        end
        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5380105( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setData(data)
        end
        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add8150101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            view:setData(data)
        else
            if data.reqType == 1 then--队长开始 
                local param = cache.KuaFuCache:getFubenData()
                local __reqdata = {sceneId = param.sceneId}--副本信息
                mgr.ViewMgr:openView2(ViewName.StartGoView,__reqdata)
            end
        end

        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- else
        --     if data.reqType == 1 then--队长开始 
        --         local param = cache.KuaFuCache:getFubenData()
        --         local __reqdata = {sceneId = param.sceneId}--副本信息
        --         mgr.ViewMgr:openView2(ViewName.StartGoView,__reqdata)
        --     end
        -- end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5380201(data)
    -- body
    if data.status == 0 then
        cache.FubenCache:setExpMonsters(data.conMap)
        local sId = cache.PlayerCache:getSId()
        cache.FubenCache:setCurrPass(sId,data.passId)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setKuaFuTeamTrack()
            view:kuaFuTeamMsg(data)
        else
            mgr.ViewMgr:openView(ViewName.TrackView, function(view)
                view:setKuaFuTeamTrack()
                view:kuaFuTeamMsg(data)
            end)
        end

        mgr.HookMgr:enterHook()
        mgr.TaskMgr.mState = 0
    else
        GComErrorMsg(data.status)
    end
end
--跨服进阶副本一键扫荡
function KuaFuProxy:add1380107(data)
    if data.status == 0 then  
        proxy.KuaFuProxy:sendMsg(1380101,{teamId=0})--刷新界面
        GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end 

function KuaFuProxy:add8150102(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:resetRank(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--
function KuaFuProxy:add5410101(data)
    -- body
    if data.status == 0 then
        local  view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end

        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end



--
function KuaFuProxy:add5410102(data)
    -- body
    if data.status == 0 then
        cache.KuaFuCache:setTaskCache(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setKuaFu3War()
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 7,data = data})
        end

        -- --三界争霸中，BOSS任务，达到等级的玩家，进入场景直接有任务，不需要接
        -- --检测一下 自动接
        -- local id = 1
        -- local _t = conf.KuaFuConf:getSjzbTask(id)
        -- local var = _t and _t.limit_count or 1
        -- local task = cache.KuaFuCache:getTaskCache(id)
        -- if (_t.open_lev or 0) <= cache.PlayerCache:getRoleLevel() then --等级足
        --     if task.curCount < var then
        --         if task.taskState == 0 then 
        --             self.notsee = true
        --             self:sendMsg(1410201,{type=1})
        --         end
        --     end
        -- end
    else
        GComErrorMsg(data.status)
    end
end

--
function KuaFuProxy:add5410103(data)
    -- body
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5410104(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KufuCheViewNew)
        if view then
            view:add5410104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5410201( data )
    -- body
    if data.status == 0 then
        cache.KuaFuCache:setDailyTask(data.dailyTask)
        if data.type == 1 then
            if not self.notsee then
                mgr.ViewMgr:openView2(ViewName.TaskViewKuaFu,1)
            end
            self.notsee = nil 

            local _view = mgr.ViewMgr:get(ViewName.TrackView)
            if _view and _view.KuaFuWar then
                _view.KuaFuWar:initMsg()
            end
        elseif data.type == 0 then
            mgr.ViewMgr:openView2(ViewName.SjRCTask)
        end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5410202( data )
    -- body
    if data.status == 0 then
        --printt("data",data.cardTask)
        cache.KuaFuCache:setCardTask(data.cardTask)
        if data.type == 1 then
            local _view = mgr.ViewMgr:get(ViewName.TrackView)
            if _view and _view.KuaFuWar then
                _view.KuaFuWar:initMsg()
            end

            cache.KuaFuCache:setIsAuto(true)
            self:sendMsg(1410204)
            self:sendMsg(1410202,{type=0})
        elseif data.type == 0 then
            local view = mgr.ViewMgr:get(ViewName.SjHSTask)
            if view then
                view:setData()
            else
                mgr.ViewMgr:openView2(ViewName.SjHSTask)
            end
            
        end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5410203( data )
    -- body
    if data.status == 0 then
        --printt("data.boxTask",data.boxTask)
        cache.KuaFuCache:setBoxTask(data.boxTask)
        cache.KuaFuCache:setBoxGrids(data.boxGrids)
        if data.type == 1 or data.type == 2 then
            local _view = mgr.ViewMgr:get(ViewName.TrackView)
            if _view and _view.KuaFuWar then
                _view.KuaFuWar:initMsg()
            end
            --mgr.ViewMgr:openView2(ViewName.TaskViewKuaFu,3)
            mgr.ViewMgr:openView2(ViewName.SjXBTask, data)
        elseif data.type == 0 then
            mgr.ViewMgr:openView2(ViewName.KuafuBoxView)
        end
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add5410204( data )
    -- body
    if data.pox == 0 and data.poy == 0 then

        cache.KuaFuCache:setIsAuto(false)
        gRole:idleBehaviour()
    else
        local var = cache.KuaFuCache:getCheRoleId()
        if not var or var ~= data.roleId then --如果是自己的镖车不给攻击
            local monster = mgr.ThingMgr:getObj(ThingType.monster, data.roleId)
            if monster then
                --plog("设置自己的车不能被自己攻击")
                cache.KuaFuCache:setCheRoleId(data.roleId)
                monster:setCanSelect(false)
                monster:ignoreHide(false)
            end
        end
        local view = mgr.ViewMgr:get(ViewName.SjHSTask)
        if view then
            view:add5410204(data)
        end
        
        local point = Vector3.New(data.pox, gRolePoz,data.poy)
        mgr.JumpMgr:findPath(point, 0, function()

        end)
    end
end


function KuaFuProxy:add8180301( data )
    -- body
    if data.status == 0 then
        --printt("add8180301",data)

        local view = mgr.ViewMgr:get(ViewName.AwardsCaseView)
        if view then
            plog("这里面检测到获得界面打开着 先关闭一下")
            view:closeView()
        end


        if data.calcType == 1 then --抢任务的人 
            if data.taskType == 3 then

                local param = {}
                param.items = {}
                param.type = 5
                param.show = true
                param.doubleFlag = data.doubleFlag
                param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
                local condata = conf.KuaFuConf:getSjzbBox(data.mId)
                if condata.finish_item then
                    for k ,v in pairs(condata.finish_item) do
                        local t = {mid = v[1],amount = v[2],bind = v[3]}
                        table.insert(param.items,t)
                    end
                end

                local level_coef = conf.KuaFuConf:getValue("box_level_coef")
                local base_add = conf.KuaFuConf:getValue("box_base_add_value")
                local level = cache.PlayerCache:getRoleLevel()
                local _exp = math.floor((level*level_coef+base_add)*condata.exp_coef/100)
                table.insert(param.items,{mid = PackMid.exp,amount = _exp,bind = 1})

                for k ,v in pairs(param.items) do
                    param.items[k].amount = math.floor(v.amount/2)
                end

                param.richtext = string.format(language.kuafu157,data.extStr01,condata.name)
                mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
            end
        elseif data.calcType == 3 then
            --宝箱的
            GComAlter(language.kuafu167)
            --printt("data.extStr01",data.extStr01)
            local info = cache.KuaFuCache:getBoxGrids()
            for k ,v in pairs(info) do
                if tostring(v.gridId) == tostring(data.extStr01) then
                    info[k].open = 1
                end
            end
            --printt(cache.KuaFuCache:getBoxGrids())

            --结算完成 刷新任务追踪信息
            local _view = mgr.ViewMgr:get(ViewName.TrackView)
            if _view and _view.KuaFuWar then
                _view.KuaFuWar:initMsg()
            end
            
        else --任务人
            --任务结算
            cache.KuaFuCache:setIsAuto(false)
            --停止
            mgr.HookMgr:cancelHook()
            --关闭一些界面
            local _t = {ViewName.SjHSTask,ViewName.SjRCTask,ViewName.SjXBTask}
            for k ,v in pairs(_t) do
                local _view = mgr.ViewMgr:get(v)
                if _view then
                    _view:closeView()
                end
            end

            local param = {}
            if data.taskType == 1 then --日常
                --结算任务结束
                local _task = cache.KuaFuCache:getTaskCache(1)
                if not _task then
                    return
                end
                _task.taskState = 2
                _task.curCount =_task.curCount + 1 

                param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
                param.items = {}
                param.show = true
                param.doubleFlag = data.doubleFlag
                --开始计算奖励
                local condata = conf.KuaFuConf:getSjzbdaily(data.mId)
                if condata.finish_item then
                    for k ,v in pairs(condata.finish_item) do
                        local t = {mid = v[1],amount = v[2],bind = v[3]}
                        table.insert(param.items,t)
                    end
                end
                --是否有额外奖励
                local _t = conf.KuaFuConf:getSjzbTask(1)
                local maxPass = _t and _t.limit_count or 1
                local _task = cache.KuaFuCache:getTaskCache(1)
                if _task.curCount>= maxPass then
                    if _t.ext_item then
                        for k ,v in pairs(_t.ext_item) do
                            local t = {mid = v[1],amount = v[2],bind = v[3]}
                            table.insert(param.items,t)
                        end
                    end
                end

                mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
            elseif data.taskType == 3 then
                local _task = cache.KuaFuCache:getTaskCache(3)
                if not _task then
                    return
                end
                _task.taskState = 2
                _task.curCount =_task.curCount + 1 

                param.items = {}
                param.type = 5
                param.show = true
                param.doubleFlag = data.doubleFlag
                local condata = conf.KuaFuConf:getSjzbBox(data.mId)
                if condata.finish_item then
                    for k ,v in pairs(condata.finish_item) do
                        local t = {mid = v[1],amount = v[2],bind = v[3]}
                        table.insert(param.items,t)
                    end
                end

                local level_coef = conf.KuaFuConf:getValue("box_level_coef")
                local base_add = conf.KuaFuConf:getValue("box_base_add_value")
                local level = cache.PlayerCache:getRoleLevel()
                local _exp = math.floor((level*level_coef+base_add)*condata.exp_coef/100)
                table.insert(param.items,{mid = PackMid.exp,amount = _exp,bind = 1})


                if data.sucFlag == 1 then
                    param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
                    --开始计算奖励
                   -- mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
                else
                    for k ,v in pairs(param.items) do
                        param.items[k].amount = math.floor(v.amount/2)
                    end

                    param.titleUrl =  "ui://_imgfonts/sanjiezhengba_020" 
                    param.richtext = string.format(language.kuafu156,condata.name,data.extStr01)
                    --GComAlter(language.kuafu143)
                end

                mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
            elseif data.taskType == 2 then
                --结算任务结束
                local _task = cache.KuaFuCache:getTaskCache(2)
                if not _task then
                    return
                end
                _task.cardId = 1
                _task.taskState = 2
                _task.curCount =_task.curCount + 1 
                --
                local param = {}
                param.items = {}
                param.type = 5
                param.show = true
                local condata = conf.KuaFuConf:getSjzbCar(data.mId)
                
                if condata.finish_item then
                    for k ,v in pairs(condata.finish_item) do
                        local t = {mid = v[1],amount = v[2],bind = v[3]}
                        table.insert(param.items,t)
                    end
                end
                local level_coef = conf.KuaFuConf:getValue("level_coef")
                local base_add = conf.KuaFuConf:getValue("base_add_value")
                local level = cache.PlayerCache:getRoleLevel()
                local _exp = math.floor((level*level_coef+base_add)*condata.car_exp_coef/100)
                table.insert(param.items,{mid = PackMid.exp,amount = _exp,bind = 1})

                if data.sucFlag == 1 then
                    param.titleUrl = "ui://_imgfonts/sanjiezhengba_016"
                    param.richtext = string.format(language.kuafu155,condata.name)
                else
                    for k ,v in pairs(param.items) do
                        param.items[k].amount = math.floor(v.amount/2)
                    end
                    param.titleUrl = "ui://_imgfonts/sanjiezhengba_017"
                    param.richtext =string.format(language.kuafu156,condata.name,data.extStr01)
                end
                mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
               
            end

            --结算完成 刷新任务追踪信息
            local _view = mgr.ViewMgr:get(ViewName.TrackView)
            if _view and _view.KuaFuWar then
                _view.KuaFuWar:initMsg()
            end
        end

        
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add8180302( data )
    -- body
    if data.status == 0 then
        --printt("rc任务",data)
        cache.KuaFuCache:setDailyTask(data.dailyTask)
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add8180303( data )
    -- body
    if data.status == 0 then
        --printt("xb任务",data)
        --cache.KuaFuCache:setBoxTaskAppear(data.boxTask.triggerAppear)
        --cache.KuaFuCache:setBoxTaskRolId(data.boxTask.boxRoleId)
        -- local boxold = cache.KuaFuCache:getBoxGrids()
        -- local mId 
        -- for k ,v in pairs(data.boxGrids) do
        --     for i ,j in pairs(boxold) do
        --         if v.gridId == j.gridId then
        --             if v.triggerAppear ~= j.triggerAppear then
        --                 mId = v.mId
        --                 break
        --             end
        --         end
        --     end
        --     if mId then
        --         break
        --     end
        -- end
        cache.KuaFuCache:setBoxGrids(data.boxGrids)
        --出现一个什么宝箱
        --local condata = conf.KuaFuConf:getSjzbBox(mId)
        --local str = string.format(language.kuafu134,condata.name)
        --GComAlter(str)
    else
        GComErrorMsg(data.status)
    end
end

function KuaFuProxy:add8180304(data)
    -- body
    if data.status == 0 then
        --成功打劫了谁 
        --GComAlter( string.format(language.kuafu145,data.roleName))
        

        local param = {}
        param.items = {}
        param.type = 5
        param.show = true
        param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
        param.richtext = string.format(language.kuafu145,data.roleName)
        --plog("data.carId",data.carId)
        local condata = conf.KuaFuConf:getSjzbCar(data.carId)

        if condata.killed_item then
            for k ,v in pairs(condata.killed_item) do
                local t = {mid = v[1],amount = v[2] ,bind = v[3]}
                table.insert(param.items,t)
            end  
        end
        local level_coef = conf.KuaFuConf:getValue("level_coef")
        local base_add = conf.KuaFuConf:getValue("base_add_value")
        local level = data.ownerLev
        local _exp = math.floor((level*level_coef+base_add)*condata.car_exp_coef/100)
        table.insert(param.items,{mid = PackMid.exp,amount =  math.floor(_exp/2),bind = 1})

        
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
    else
        GComErrorMsg(data.status)
    end
end

return KuaFuProxy