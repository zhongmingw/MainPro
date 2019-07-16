local TaskConf = class("TaskConf",base.BaseConf)

function TaskConf:ctor()
    self:addConf("task_global")
    self:addConf("task_config")
    self:addConf("task_daily")
    self:addConf("task_gang")
    self:addConf("task_daily_award")
    self:addConf("task_daily_ext_award")
    self:addConf("task_gang_award")
    self:addConf("task_gang_ext_award")
    self:addConf("task_chamber")
    --self:addConf("task_chamber_award")
    --特殊任务
    self:addConf("task_special")
    --支线任务
    self:addConf("task_branch")
    --前往挂机
    self:addConf("task_hook")
    --随机副本npc
    self:addConf("taskfubennpc")

end

function TaskConf:getNpcByLevel(lv)
    -- body
    if not lv then
        return 
    end

    for k ,v in pairs(self.taskfubennpc) do
        if v.lv_begin and v.lv_end then
            if v.lv_begin <= lv and lv <= v.lv_end then
                return v 
            end
        end
    end 
    return 
end

function TaskConf:getValue(id)
    -- body
    return self.task_global[id..""]
end

function TaskConf:getTaskById(id)
    local index = tonumber(string.sub(tostring(id),1,1))
    if index == 1 then
        return self.task_config[id..""]
    elseif index == 2 then
        --支线任务
        return self.task_branch[id..""]
    elseif index == 4 then
        return self.task_daily[id..""]
    elseif index == 5 then
        return self.task_gang[id..""]
    elseif index == 9 then
        if id == 9002 then --默认是没有path 程序单独加的
            if self.task_special[id..""] then
                self.task_special[id..""].path = nil 
            end
        end
        return self.task_special[id..""]
    elseif index == 6 then
        return self.task_chamber[id..""]
    end
end

function TaskConf:getTaskHook(lvl)
    local roleLv = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(self.task_hook) do
        local lvls = v.lvls or {1,1}
        if roleLv >= lvls[1] and roleLv <= lvls[2] then
            return v
        end
    end
end

function TaskConf:getTaskDailyAward(id)
    -- body
    -- local confdata = self:getTaskById(id)
    -- local index
    -- if cache.PlayerCache:getRoleLevel()>confdata.limit_lev then
    --     index = id .. string.format("%03d",confdata.limit_lev)
    -- else
    --     index = id .. string.format("%03d",cache.PlayerCache:getRoleLevel())
    --     if not self.task_daily_award[index] then
    --         index = id .. string.format("%03d",confdata.trigger_lev)
    --     end
    -- end
    --plog("index",index)

    return self.task_daily_award[tostring(id)]
end

function TaskConf:getTaskDailyexTaward()
    -- body
    local day = 1
    local data = cache.ActivityCache:get5030111()
    if data then
        day = data.openDay % 9 
    end
    if day == 0 then
        day = 9
    end
    local index = day * 10000 + 1
    --local index = cache.PlayerCache:getRoleLevel()
    return self.task_daily_ext_award[index..""]
end

function TaskConf:getTaskGangAward(id)
    -- body
    local confdata = self:getTaskById(id)
    local index
    if cache.PlayerCache:getRoleLevel()>confdata.limit_lev then
        index = id .. string.format("%03d",confdata.limit_lev)
    else
        index = id .. string.format("%03d",cache.PlayerCache:getRoleLevel())
        if not self.task_gang_award[index] then
            index = id .. string.format("%03d",confdata.trigger_lev)
        end
    end
    plog("index",index)
    return self.task_gang_award[index]
end

function TaskConf:getTaskGangexTaward()
    -- body
    local day = 1
    local data = cache.ActivityCache:get5030111()
    if data then
        day = data.openDay % 9 
    end
    if day == 0 then
        day = 9
    end
    local index = day * 10000 + 1
    --local index = cache.PlayerCache:getRoleLevel()
    return self.task_gang_ext_award[index..""]
end
--商会任务奖励
function TaskConf:getTaskChamberAward(id)
    -- body
    local confdata = self:getTaskById(id)
    local index
    if cache.PlayerCache:getRoleLevel()>confdata.limit_lev then
        index = id .. string.format("%03d",confdata.limit_lev)
    else
        index = id .. string.format("%03d",cache.PlayerCache:getRoleLevel())
        if not self.task_chamber_award[index] then
            index = id .. string.format("%03d",confdata.trigger_lev)
        end
    end
    --plog(index,"index")
    return self.task_chamber_award[index]
end




return TaskConf