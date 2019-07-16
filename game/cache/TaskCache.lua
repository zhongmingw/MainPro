--
-- Author: yr
-- Date: 2016-12-30 15:26:36
--

local TaskCache = class("TaskCache")

function TaskCache:ctor()
    self.data = {} --任务列表
    self.dailyTasks ={}--日常任务
    self.gangTasks ={}--帮派任务
    self.dailyFinishCount = 0 --日常任务完成次数
    self.gangFinishCount = 0 --日常任务完成次数
    self.shangHuiTasks = {} -- 商会任务
    self.shangHuiFinishCount = 0 --商会任务完成次数
    self.branchTasks = {}

    self.npcTask = {}

    self.isGuide = false
end

function TaskCache:setTaskBack(var)
    -- body
    self.isreset = var
end

function TaskCache:getTaskBack( ... )
    -- body
    return self.isreset
end

function TaskCache:setGuide(flag)
    -- body
    self.isGuide = flag
end

function TaskCache:getGuide()
    -- body
    return self.isGuide
end

function TaskCache:CheckTaskID(id)
    -- body
    if not self.data or not self.data[1] then
        return false
    end
    --plog("self.data[1].taskId",self.data[1].taskId)
    if self.data[1].taskId == id then
        return true
    else
        return false
    end
end

function TaskCache:isfinish(id)
    -- body
    if self.data and #self.data==0 then
        return true
    end
    if not self.data or not self.data[1] then
        return true
    end
    if self.data[1].taskId > id then
        return true
    end
    return false
end


--当前主线任务ID
function TaskCache:getCurMainId()
    -- body
    if self.data and #self.data>0 then
        return self.data[1].taskId
    else
        return 0 
    end
end
--当前任务是否副本任务
function TaskCache:isFubenTask()
    -- body
    local id = self:getCurMainId()
    if not id or id == 0 then
        return false
    end

    local confdata = conf.TaskConf:getTaskById(id)
    if confdata.task_type == 4 then
        return true
    end
end

function TaskCache:findNpcTask(param)
    -- body
    if not param then
        return
    end
    for k ,v in pairs(param) do
        if v.taskStatu == 1 then
            local confdata = conf.TaskConf:getTaskById(v.taskId)
            if confdata and tonumber(confdata.task_type) == 1 then --找NPC
                --print("设置？")
                self.npcTask[tonumber(confdata.conditions[1][1])] = true
            end
        end
    end
end

function TaskCache:setData(data)
    -- body
    self.data = data.tasks
    self.dailyTasks = data.dailyTasks
    self.gangTasks = data.gangTasks
    self.dailyFinishCount = data.dailyFinishCount
    self.gangFinishCount = data.gangFinishCount
    --printt("data.shangHuiTasks",data.shangHuiTasks)
    self.shangHuiTasks = data.shangHuiTasks
    self.shangHuiFinishCount = data.shangHuiFinishCount
    self.branchTasks = data.branchTasks

    self.npcTask = {}
    self:findNpcTask(data.tasks) --主线
    self:findNpcTask(data.dailyTasks)--日常
    self:findNpcTask(data.gangTasks)--帮派
end

function TaskCache:getData()
    -- body
    return self.data
end

function TaskCache:getDataById(id)
    -- body
    local index =tonumber(string.sub(id,1,1)) 
    if index == 1 then
        for k ,v in pairs(self.data) do 
            if v.taskId == id  then
                return v 
            end
        end
    elseif index == 4 then
         for k ,v in pairs(self.dailyTasks) do 
            if v.taskId == id  then
                return v 
            end
        end
    elseif index == 5 then
        for k ,v in pairs(self.gangTasks) do 
            if v.taskId == id  then
                return v 
            end
        end
    elseif index == 2 then
        for k ,v in pairs(self.branchTasks) do 
            if v.taskId == id  then
                return v 
            end
        end
    end

    return nil 
end

--任务广播
function TaskCache:updateData( data )
    -- body
    if not data then 
        return
    end
   
    local pairs = pairs
    for k ,v in pairs(data) do 
        ---npc 问号
        local confdata = conf.TaskConf:getTaskById(v.taskId)
        if confdata.task_type == 1 then
            local npcId = tonumber(confdata.conditions[1][1])
            local _npc = mgr.ThingMgr:getObj(ThingType.npc,npcId)
            --plog(_npc,npcId)
            if v.taskStatu == 2 then
                --久的删除
                self.npcTask[npcId] = nil
                if _npc then
                    _npc:removeWenHao()
                end
            else
                --新的npc添加问号
                self.npcTask[npcId] = true
                if _npc then
                    if self:CheckISLevelOver(v.taskId) then
                        _npc:addWenHao()
                    end
                end
            end
        end

        local index =tonumber(string.sub(v.taskId,1,1))
        local param 
        if index == 1 then --主线任务
            param = self.data
        elseif index == 4 then--日常任务
            param = self.dailyTasks
        elseif index == 5 then--帮派任务
            param = self.gangTasks
        elseif index == 6 then --商会任务
            param = self.shangHuiTasks
        elseif index == 2 then --支线任务
            param = self.branchTasks
        end  

        if param then
            if v.taskStatu == 2 then --移除操作
                for i ,j in pairs(param) do
                    if v.taskId == j.taskId then
                        table.remove(param,i)
                        break
                    end
                end
            else --更新或者新加
                local findflag = false
                for i ,j in pairs(param) do
                    if v.taskId == j.taskId then
                        findflag = true
                        param[i] = v 
                        break
                    end
                end

                if not findflag then
                    table.insert(param,v)
                end
            end
        end
    end
end

--改变任务状态 任务状态0:默认,1已接受,2已完成
function TaskCache:setTaskStatu(id,value)
    -- body
    if not next(self.data) then 
        return
    end
    local index = tonumber(string.sub(tostring(id),1,1))
    if index == 1 then
        for k ,v in pairs(self.data) do 
            if tonumber(v.taskId) == tonumber(id) then 
                v.taskStatu = value
            end 
        end
    elseif index == 4 then
        for k ,v in pairs(self.dailyTasks) do 
            if tonumber(v.taskId) == tonumber(id) then 
                v.taskStatu = value
            end 
        end
    elseif index == 5 then
        for k ,v in pairs(self.gangTasks) do 
            if tonumber(v.taskId) == tonumber(id) then 
                v.taskStatu = value
            end 
        end
    elseif index == 6 then
        for k ,v in pairs(self.shangHuiTasks) do 
            if tonumber(v.taskId) == tonumber(id) then 
                v.taskStatu = value
            end 
        end
    end
end

function TaskCache:getTaskStatu(id)
    -- body
    local index = tonumber(string.sub(tostring(id),1,1))
    if index == 1 then
        return self.data[id] and  self.data[id].taskStatu or 0
    elseif index == 2 then
        return self.branchTasks[id] and  self.branchTasks[id].taskStatu or 0
    elseif index == 4 then
        return self.dailyTasks[id] and  self.dailyTasks[id].taskStatu or 0
    elseif index == 5 then
        return self.gangTasks[id] and  self.gangTasks[id].taskStatu or 0
    elseif index == 6 then
        return self.shangHuiTasks[id] and  self.shangHuiTasks[id].taskStatu or 0
    end
    return 0
end


--用于额外的进度,例如收集任务
function TaskCache:setextMap(id,key,value)
    -- body
    if not next(self.data) then 
        return
    end
    local index = tonumber(string.sub(tostring(id),1,1))

    local t = self:getDataById(id)
    if  t then
        self:getDataById(id).extMap[key] = value
    end
end

function TaskCache:getextMap(id,key)
    -- body
    local t = self:getDataById(id)
    if t then
        return t.extMap[key] or 0
    else
        return 0
    end
end
--是否只有主线任务
function TaskCache:isOnlyMain()
    -- body
    if not self.data then
        return false
    end

    if #self.data == 0 then
        return false
    end

    if self.data[1].taskId <= conf.TaskConf:getValue("fresh_man_task_done_id") then
        return true
    else
        return false
    end

    -- local flag = false
    -- for k ,v in pairs(self.data) do
        
    --     local taskconf = conf.TaskConf:getTaskById(v.taskId)
    --     --plog("v.taskId",v.taskId,taskconf.type)
    --     if 1 == tonumber(taskconf.type) and 1 == tonumber(v.taskStatu) then --只有主线任务而且未完成
    --         --plog("11")
    --         flag = true
    --     else
    --         flag = false
    --         break
    --     end
    -- end
    -- return flag
end

--获取日常任务
function TaskCache:getdailyTasks()
    -- body
    return self.dailyTasks
end
--当前完成此处
function TaskCache:getdailyFinishCount()
    -- body
    return self.dailyFinishCount
end
function TaskCache:setdailyFinishCount(var)
    -- body
    self.dailyFinishCount = var
end
function TaskCache:deletedailyTasksByid(id)
    -- body
    for k ,v in pairs(self.dailyTasks) do
        if v.taskId == id then
            table.remove(self.dailyTasks,k)
            break
        end
    end
end

--获取帮派
function TaskCache:getgangTasks()
    -- body
    return self.gangTasks
end
function TaskCache:deletegangTasksByid(id)
    -- body
    for k ,v in pairs(self.gangTasks) do
        if v.taskId == id then
            table.remove(self.gangTasks,k)
            break
        end
    end
end

function TaskCache:deletegangTasks()
    -- body
    self.gangTasks = {}
end

function TaskCache:getgangFinishCount()
    -- body
    return self.gangFinishCount
end
function TaskCache:setgangFinishCount(var)
    -- body
    self.gangFinishCount = var
end

function TaskCache:getshangHuiTasks()
    -- body
    return self.shangHuiTasks
end

function TaskCache:getshangHuiFinishCount()
    -- body
    return self.shangHuiFinishCount or 0
end

--获取支线任务
function TaskCache:getbranchTasks()
    -- body
    return self.branchTasks
end
--TaskCache 检测任务是否断开了
function TaskCache:CheckISLevelOver(id)
    -- body
    local confdata = conf.TaskConf:getTaskById(id or self:getCurMainId() )
    if confdata and confdata.trigger_lev and cache.PlayerCache:getRoleLevel() < confdata.trigger_lev  then 
        return false
    else
        return true
    end
end

return TaskCache