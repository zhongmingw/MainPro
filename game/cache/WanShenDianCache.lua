--
-- Author: Your Name
-- Date: 2018-09-12 20:30:38
--万神殿缓存
local WanShenDianCache = class("WanShenDianCache",base.BaseCache)

function WanShenDianCache:init()
    self.jlValue = 0
    self.endTime = 0
    self.leftCount = 0
end

--缓存当前剩余精力
function WanShenDianCache:setJlValue(value)
    self.jlValue = value
end

function WanShenDianCache:getJlValue()
    return self.jlValue
end

--缓存图腾结束时间
function WanShenDianCache:setEndTime(endTime)
    self.endTime = endTime
end
function WanShenDianCache:getEndTime()
    return self.endTime
end

--缓存剩余进入次数
function WanShenDianCache:setLeftCount(leftCount)
    self.leftCount = leftCount
end
function WanShenDianCache:getLeftCount()
    return self.leftCount
end

return WanShenDianCache