--
-- Author: 
-- Date: 2017-08-30 20:28:40
--
local XianMoCache = class("XianMoCache",base.BaseCache)
--[[
--仙魔战缓存
--]]
function XianMoCache:init()
    self.fubenCTime = 0
end

function XianMoCache:setWarData(data)
    self.watData = data
end

function XianMoCache:getWarData()
    return self.watData
end

--仙魔战阵营信息
function XianMoCache:setCampInfo(data)
    if self.watData then
        self.watData.xianCampInfo = data.xianCampInfo
        self.watData.moCampInfo = data.moCampInfo
    end
end
--仙魔战我的信息
--[[1   
int32
变量名：killCount   说明：我的击杀数量
2   
int32
变量名：score   说明：我的积分
3   
int32
变量名：campId  说明：我的阵营
4   
int32
变量名：leftTime    说明：活动倒计时]]
function XianMoCache:setMyWarInfo(data)
    if self.watData then
        self.watData.killCount = data.killCount
        self.watData.score = data.score
        self.watData.campId = data.campId
        self.watData.leftTime = data.leftTime
    end
end

function XianMoCache:getCampId()
    return self.watData and self.watData.campId or 0
end

function XianMoCache:setXianMoRedPoint(redPoint)
    self.redPoint = redPoint
end

function XianMoCache:getXianMoRedPoint()
    return self.redPoint or 0
end
--副本结束时间
function XianMoCache:setFubenETime(time)
    self.fubenCTime = time
end

function XianMoCache:getFubenETime()
    return self.fubenCTime
end

--本服排名前20的平均等级
function XianMoCache:setTop20AvgLev(top20AvgLev)
    self.top20AvgLev = top20AvgLev
end

function XianMoCache:getTop20AvgLev()
    return self.top20AvgLev or 0
end

return XianMoCache