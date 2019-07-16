--
-- Author: Your Name
-- Date: 2016-12-29 20:28:23
--

local TaskProxy = class("TaskProxy",base.BaseProxy)

function TaskProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5050101,self.add5050101)--任务列表
    self:add(5050102,self.add5050102)--接受任务
    self:add(5050103,self.add5050103)--完成任务
    self:add(5050104,self.add5050104)--完成任务
    self:add(5050201,self.add5050201)-- 请求完成日常任务
    self:add(5050301,self.add5050301)-- 请求完成日常任务
    self:add(5050402,self.add5050402)-- 请求完成商会任务
    self:add(5050501,self.add5050501)-- 请求完成支线任务
    self:add(8030102,self.add8030102)--任务广播
end

function TaskProxy:add5050101(data)
    -- body
    if data.status == 0 then 
        cache.TaskCache:setData(data)
        --printt("5050101",data)

        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then 
            cache.TaskCache:setTaskBack(false)
            view:add5050101()-- onController1()
            view:checkOpen()
            local num = cache.PlayerCache:getAttribute(10202)
            num = num + cache.PlayerCache:getRedPointById(10238)
            num = num + cache.PlayerCache:getRedPointById(10239)
            view:setRedBag(num)
            --任务信息检测预告
            mgr.XinShouMgr:enterGame()
        else
            cache.TaskCache:setTaskBack(true)
        end

        mgr.ThingMgr:addWenHaoToNpc()
        
    else
        GComErrorMsg(data.status)
    end
end

function TaskProxy:add5050102(data)
    -- body
    if data.status == 0 then 
        --cache.TaskCache:setTaskStatu()
        --plog("接受任务 ID ",data.taskId)
    else
        GComErrorMsg(data.status)
    end
end

function TaskProxy:add5050103(data)
    -- body
    if data.status == 0 then
        --任务成功之后特效
        mgr.XinShouMgr:PlayEffect(data.taskId)

        mgr.XinShouMgr:newBianshen(true) 
        mgr.SoundMgr:playSound(Audios[3])
        --停止攻击
        mgr.HookMgr:cancelHook()
        --任务完成之后需要继续的操作
        if not mgr.XinShouMgr:checkTaskFinsh(data.taskId) then --如果没有新手指导
            if not g_ios_test then
                mgr.TaskMgr:completeTask(data.taskId)
            end
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:chenkOpenById(data.taskId)
            end
        end
        ---检测是否是最后一天新手任务
        if conf.TaskConf:getValue("fresh_man_task_done_id") == data.taskId then
            cache.BangPaiCache:setTaskReset(true)
            proxy.TaskProxy:send(1050101)
        end
        --是否开启红包
        if data.taskId == 1121 then
            UPlayerPrefs.SetInt("RedBag", 11)
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:setRedBag(cache.PlayerCache:getAttribute(10202))
            end
        end        
    else
        GComErrorMsg(data.status)
    end
end

function TaskProxy:add5050104(data)
    -- body
    if data.status == 0 then 

        local view = mgr.ViewMgr:get(ViewName.CollectBarView)
        if view then 
            view:add5050104()
        end 
        mgr.SoundMgr:playSound(Audios[3])
    else
        GComErrorMsg(data.status)
    end
end

function TaskProxy:add8030102(data)
    -- body
    if data.status == 0 then
        --mgr.ThingMgr:addWenHaoToNpc(true) --移除
        cache.TaskCache:updateData(data.taskInfos)
        --mgr.ThingMgr:addWenHaoToNpc() --添加
        mgr.TaskMgr:checkCurTask()

        local view = mgr.ViewMgr:get(ViewName.MainView) 
        if view then
            view:add8060101()
        end

    else
        GComErrorMsg(data.status)
    end
end
--1:普通完成,2:1.5倍完成,3一键完成
function TaskProxy:add5050201(data)
    -- body
    if data.status == 0 then
        --printt(data)
        if data.reqType == 3 then
            cache.TaskCache:deletedailyTasksByid(data.taskId)
            local condata = conf.TaskConf:getTaskById(data.taskId) 
            if condata then
                mgr.ViewMgr:openView(ViewName.TaskOverView, function(view)
                    -- body
                    view:setData(condata)
                end)
            end

            mgr.TaskMgr:stopTask()
        else
            cache.TaskCache:setdailyFinishCount(cache.TaskCache:getdailyFinishCount()+1 )
        end
        local view = mgr.ViewMgr:get(ViewName.MainView) 
        if view then
            view:add8060101()
        end
        --完成任务
        mgr.HookMgr:cancelHook()
        mgr.TaskMgr:completeTask(data.taskId)
        mgr.SoundMgr:playSound(Audios[3])
        --GOpenAlert3(data.items)
        if GCheckMainTask() then
            GgoToMainTask()
        end
    else
        GComErrorMsg(data.status)
    end
end

--1:普通完成,2:1.5倍完成,3一键完成
function TaskProxy:add5050301(data)
    -- body
    if data.status == 0 then

        if data.reqType == 3 then
            cache.TaskCache:deletegangTasksByid(data.taskId)
            local condata = conf.TaskConf:getTaskById(data.taskId) 
            if condata then
                mgr.ViewMgr:openView(ViewName.TaskOverView, function(view)
                    -- body
                    view:setData(condata)
                end)
            end

            mgr.TaskMgr:stopTask()
        else
            cache.TaskCache:setgangFinishCount(cache.TaskCache:getgangFinishCount()+1 )
        end
        local view = mgr.ViewMgr:get(ViewName.MainView) 
        if view then
            view:add8060101()
        end
        --完成任务
        mgr.HookMgr:cancelHook()
        mgr.TaskMgr:completeTask(data.taskId)
        mgr.SoundMgr:playSound(Audios[3])
        --GOpenAlert3(data.items)
        if GCheckMainTask() then
            GgoToMainTask()
        end
    else
        GComErrorMsg(data.status)
    end
end

function TaskProxy:add5050402( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MainView) 
        if view then
            view:add8060101()
        end
        --GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end

function TaskProxy:add5050501( data )
    -- body
    if data.status == 0 then
        if not mgr.XinShouMgr:getXianFaSkill(data.taskId) then
            GOpenAlert3(data.items)
        end

        local view = mgr.ViewMgr:get(ViewName.MainView) 
        if view then
            view:add8060101()
        end
    else
        GComErrorMsg(data.status)
    end
end


return TaskProxy