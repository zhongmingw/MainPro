--
-- Author: Your Name
-- Date: 2018-04-23 20:38:59
--

local CityWarCache = class("CityWarCache",base.BaseCache)

function CityWarCache:init()
    self.cityData = {}
    self.warSceneId = 0
    self.isXz = 0
    self.warData = {}--城战面板信息
    self.breakCity = 0--城门状态 0:未破 1:已破
    self.awardGot = 0--每日奖励领取状态
    self.taskCache = nil--城战任务栏点击缓存(从城外到城内过传送阵时会用到)
end

--城池信息缓存
function CityWarCache:setCityData(data)
    self.cityData = data
end

function CityWarCache:getCityData()
    return self.cityData
end

--当前宣战的城池id
function CityWarCache:setWarSceneId(sId)
    self.warSceneId = sId
end

function CityWarCache:getWarSceneId()
    return self.warSceneId
end

--宣战权限
function CityWarCache:setisXz(var)
    self.isXz = var
end

function CityWarCache:getisXz()
    return self.isXz
end

--城战面板信息缓存
function CityWarCache:setCityWarTrackData(data)
    self.warData = data
end

function CityWarCache:getCityWarTrackData()
    return self.warData
end

--城门信息
function CityWarCache:getCityDoorData()
    local doorData = {}
    if self.warData then
        for k,v in pairs(self.warData) do
            local confData = conf.MonsterConf:getInfoById(v.attris[601])
            if confData and confData.kind == 9 then
                table.insert(doorData,v)
            end
        end
    end
    return doorData
end
--柱子信息
function CityWarCache:getCityBossData()
    local bossData = {}
     if self.warData then
        for k,v in pairs(self.warData) do
            local confData = conf.MonsterConf:getInfoById(v.attris[601])
            if confData and confData.kind == 8 then
                table.insert(bossData,v)
            end
        end
    end
    return bossData
end

--城门状态
function CityWarCache:setCityDoorState(isBreak)
    self.breakCity = isBreak
end

function CityWarCache:getCityDoorState()
    return self.breakCity
end

--每日奖励领取状态
function CityWarCache:setAwardGot(awardGot)
    self.awardGot = awardGot
end
function CityWarCache:getAwardGot()
    return self.awardGot
end

function CityWarCache:setCityWarTaskCache(taskInfo)
    self.taskCache = taskInfo
end

function CityWarCache:getCityWarTaskCache()
    return self.taskCache
end

return CityWarCache