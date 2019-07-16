--皇陵之战缓存
local HuanglingCache = class("HuanglingCache",base.BaseCache)

function HuanglingCache:init()
    self.taskData = {} --任务缓存
    self.bossData = {
        [1] = { curHpPercent = 10000,
                attris = {},
                hateRoleName = "",},
        [2] = { curHpPercent = 10000,
                attris = {},
                hateRoleName = "",},
    } --boss缓存
    self.nextBossRefreshTime = 0
    self.taskNum = 0-- 任务总数量
    self.bossNum = 0
    self.presentTaskId = 0--当前任务id
    self.pickId = 0
end

--皇陵开始红点
function HuanglingCache:setHuanglingRedPoint(value)
    -- body
    self.huanglingRedPoint = value
end
function HuanglingCache:getHuanglingRedPoint()
    -- body
    return self.huanglingRedPoint or 0
end

--任务缓存
function HuanglingCache:setTaskCache(data)
    -- body
    self.taskData =  self.taskData and data or self.taskData 
    self.taskNum = #self.taskData
end
--boss缓存
function HuanglingCache:setBossCache(data)
    -- body
    if not data or #data==0 then
        self.bossData = self.bossData 
    else
        local num = cache.HuanglingCache:getBossNum()
        if num == 1 then
            self.bossData[1] = data[1]
        elseif num == 2 then
            self.bossData[1] = data[1]
            self.bossData[2] = data[2]
        end
    end
end
--下次刷新boss的时间
function HuanglingCache:setBossTimeCache(data)
    -- body
    self.nextBossRefreshTime = data
end
--当前刷新boss数量
function HuanglingCache:setBossNum(num)
    -- body
    self.bossNum = num or 0
end
function HuanglingCache:getBossNum()
    return self.bossNum
end
function HuanglingCache:getTaskCache()
    -- body
    return self.taskData
end

function HuanglingCache:getBossCache()
    -- body
    return self.bossData
end

function HuanglingCache:getBossTime()
    -- body
    return self.nextBossRefreshTime
end

function HuanglingCache:getTaskNum()
    -- body
    return self.taskNum
end

function HuanglingCache:refreshCache()
    self.taskData = {} --任务缓存
    self.bossData = {
        [1] = { curHpPercent = 10000,
                attris = {},
                hateRoleName = "",},
        [2] = { curHpPercent = 10000,
                attris = {},
                hateRoleName = "",},
    } --boss缓存
    self.nextBossRefreshTime = 0
    self.taskNum = 0-- 任务总数量
    self.bossNum = 0
    self.presentTaskId = 0--当前任务id
end

--皇陵boss挂机状态
function HuanglingCache:BossFightState(flag)
    self.isBossFight = flag
end
function HuanglingCache:getBossFightState()
    return self.isBossFight
end
--当前任务ID
function HuanglingCache:setPresentTaskId(id)
    self.presentTaskId = id
end
function HuanglingCache:getPresentTaskId()
    return self.presentTaskId
end
--记录上一个采集物的id
function HuanglingCache:setPickId(id)
    self.pickId = id
end
function HuanglingCache:getPickId()
    return self.pickId
end
return HuanglingCache