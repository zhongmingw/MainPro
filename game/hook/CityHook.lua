--
-- Author: yr
-- Date: 2017-07-18 18:52:44
-- 主城点挂机-任务或者打坐

local CityHook = class("CityHook", import(".BaseHook"))

function CityHook:ctor()
    
end

function CityHook:enter()
    self.super.enter(self)
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

function CityHook:exit()
    return true
end


return CityHook