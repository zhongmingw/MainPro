--
-- Author: 
-- Date: 2017-06-29 10:44:59
--
local KuaFuCache = class("KuaFuCache",base.BaseCache)
--[[

--]]
function KuaFuCache:init()
    self.EliteData = {}
    self.fubenData = {}

    self.activelist = {}

    --跨服三界争霸
    self.taskcache = {}

    self.isauto = false

    self.lastsend = 0 --发送
end
function KuaFuCache:setTaskCache(data)
    -- body
    self.taskcache = data
end

function KuaFuCache:getTaskCache(index)
    -- body
    if index == 1 then
        return self.taskcache.dailyTask
    elseif index == 2 then
        return self.taskcache.carTask
    elseif index == 3 then
        return self.taskcache.boxTask
    else
        return self.taskcache
    end
end
--自己车的roleid
function KuaFuCache:setCheRoleId(var)
    -- body
    self.cheid = var
end

function KuaFuCache:getCheRoleId()
    -- body
    return self.cheid
end

function KuaFuCache:setDailyTask(data)
    -- body
    self.taskcache.dailyTask = data
end
function KuaFuCache:setCardTask(data)
    -- body
    self.taskcache.carTask = data
end
function KuaFuCache:setBoxTask(data)
    -- body
    self.taskcache.boxTask = data
end

function KuaFuCache:setBoxGrids(data)
    -- body
    self.taskcache.boxGrids = data
end
function KuaFuCache:getBoxGrids()
    -- body
    return self.taskcache.boxGrids
end

function KuaFuCache:setBoxTaskAppear(appear)
    -- body
    self.taskcache.boxTask.triggerAppear = appear
end
function KuaFuCache:setBoxTaskRolId(appear)
    -- body
    self.taskcache.boxTask.boxRoleId = appear
end
--自己所在服的区域1,2,3
function KuaFuCache:getZone()
    -- body
    return self.taskcache.zone
end


function KuaFuCache:setIsAuto(var)
    -- body
    self.isauto = var
end

function KuaFuCache:getIsAuto()
    -- body
    return self.isauto
end


function KuaFuCache:setActiveList(data)
    -- body
    self.activelist = data
end

function KuaFuCache:getActiveList()
    -- body
    return self.activelist
end

function KuaFuCache:isWillOpenByid(id)
    -- body
    if not self.activelist.willOpenTimes then
        return false 
    end
    return self.activelist.willOpenTimes[id]
end

function KuaFuCache:setEliteData(data)
    -- body
    self.EliteData = data
end
function KuaFuCache:getEliteData()
    -- body
    return self.EliteData
end

function KuaFuCache:getEliteTime()
    -- body
    return self.EliteData and self.EliteData.leftPlayTime
end


--精英boss排行榜刷新广播
function KuaFuCache:setEliteRank(data)
    if self.EliteData then
        self.EliteData.rankList = data.rankList
    end
end
--精英boss攻击伤害广播
function KuaFuCache:setEliteHurt(data)
    if self.EliteData then
        self.EliteData.myHurtMul = data.myHurtMul
        self.EliteData.myHurtMod = data.myHurtMod
    end
end
--精英boss血条变化广播
function KuaFuCache:setEliteHp(data)
    if self.EliteData then
        self.EliteData.curHpPercent = data.curHpPercent
    end
end

-- 请求跨服进阶副本信息
function KuaFuCache:setFubenData(data)
    self.fubenData = data
end

function KuaFuCache:getFubenData()
    -- body
    return self.fubenData 
end
--跨服2、每10秒只能发一次寻求公告，太快则提示“每10秒才能发一次公告”
function KuaFuCache:setLastsend()
    -- body
    self.lastsend = os.time()
end

function KuaFuCache:getLastsend()
    -- body
    return self.lastsend
end
--2、继续代表帮玩家快速加入队伍，如果没有队伍可加入，则创建队伍
function KuaFuCache:setQuitAdd(var)
    -- body
    self.quitsid= var
end

function KuaFuCache:getQuitAdd()
    -- body
    return self.quitsid
end
-- function KuaFuCache:setIsFristReady(var)
--     -- body
--     self.IsFristReady = var
-- end
-- function KuaFuCache:getIsFristReady()
--     -- body
--     return self.IsFristReady
-- end

-- function KuaFuCache:getIsFristCreate()
--     -- body
--     return self.IsFristCreate
-- end
-- function KuaFuCache:setIsFristCreate(var)
--     -- body
--     self.IsFristCreate = var
-- end

-- function KuaFuCache:getIsFristManren()
--     -- body
--     return self.IsFristManren
-- end
-- function KuaFuCache:setIsFristManren(var)
--     -- body
--     self.IsFristManren = var
-- end
return KuaFuCache