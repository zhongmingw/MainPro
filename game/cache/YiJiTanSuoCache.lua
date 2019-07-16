--
-- Author: Your Name
-- Date: 2018-12-17 16:06:34
--遗迹探索缓存

local YiJiTanSuoCache = class("YiJiTanSuoCache", base.BaseCache)

function YiJiTanSuoCache:init()
    self.exploreCount = 0--探索次数
    self.buyCount = 0--已购买探索次数
    self.robbingCount = 0--掠夺次数
    self.robbingBuyCount = 0--已购买掠夺次数
    self.logs = {}--探索日志
    self.cityId = nil--缓存当前选择的城池id
end

function YiJiTanSuoCache:setCityId(cityId)
    self.cityId = cityId
end

function YiJiTanSuoCache:getCityId()
    return self.cityId
end

function YiJiTanSuoCache:setData(data)
    self.exploreCount = data.exploreCount
    self.buyCount = data.buyCount
    self.robbingCount = data.robbingCount
    self.robbingBuyCount = data.robbingBuyCount
    self.logs = data.logs
end

--探索次数返回
function YiJiTanSuoCache:getTanSuoCount()
    return self.exploreCount
end

--掠夺次数返回
function YiJiTanSuoCache:getLueDuoCount()
    return self.robbingCount
end

--刷新探索次数
function YiJiTanSuoCache:refreshExploreCount(exploreCount)
    self.exploreCount = exploreCount
end

--刷新掠夺次数
function YiJiTanSuoCache:refreshRobbingCount(robbingCount)
    self.robbingCount = robbingCount
end

--刷新已购买探索次数
function YiJiTanSuoCache:refreshExploreBuyCount(data)
    self.buyCount = data.buyCount
end

--刷新已购买掠夺次数
function YiJiTanSuoCache:refreshRobbingBuyCount(data)
    self.robbingBuyCount = data.buyCount
end

--剩余探索次数
function YiJiTanSuoCache:getExploreCount()
    local find_times = conf.YiJiTanSuoConf:getYiJiGlobal("find_times")

    return (find_times + self.buyCount - self.exploreCount)
end

--已购买探索次数
function YiJiTanSuoCache:getBuyCount()
    return self.buyCount
end

--剩余掠夺次数
function YiJiTanSuoCache:getRobbingCount()
    local robbing_times = conf.YiJiTanSuoConf:getYiJiGlobal("robbing_times")
    return (robbing_times + self.robbingBuyCount - self.robbingCount)
end

--已购买掠夺次数
function YiJiTanSuoCache:getRobbingBuyCount()
    return self.robbingBuyCount
end

--探索日志
function YiJiTanSuoCache:getTanSuoLogs()
    return self.logs
end

return YiJiTanSuoCache