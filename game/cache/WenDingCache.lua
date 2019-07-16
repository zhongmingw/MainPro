--
-- Author: 
-- Date: 2017-05-03 16:09:50
--
local WenDingCache = class("WenDingCache",base.BaseCache)
--[[
问鼎缓存
--]]
function WenDingCache:init()
    self.sId = 219001
end

function WenDingCache:setConds(conds)
    self.conds = conds
end

function WenDingCache:getConds()
    return self.conds
end
--个人积分
function WenDingCache:setScore(score)
    self.score = score
end

function WenDingCache:getScore()
    return self.score or 0
end
--战旗持有者缓存
function WenDingCache:setflagHoldRoleId(flagHoldRoleId)
    self.flagHoldRoleId = flagHoldRoleId
end
function WenDingCache:getflagHoldRoleId()
    -- body
    return self.flagHoldRoleId
end
--当层的升层奖励是否已领取
function WenDingCache:setIsGotAwards(isGotAwards)
    self.isGotAwards = isGotAwards
end

function WenDingCache:getIsGotAwards()
   return self.isGotAwards
end

function WenDingCache:setWendingOver(flag)
    -- body
    self.isOver = flag
end

function WenDingCache:getWendingOver()
    -- body
    return self.isOver
end

function WenDingCache:cleanSid()
    self.sId = 219001
end

function WenDingCache:setWendingSid()
    self.sId = cache.PlayerCache:getSId()
end

function WenDingCache:getWendingSid()
    return self.sId
end

function WenDingCache:setWendingRedPoint(redPoint)
    self.redPoint = redPoint
end

function WenDingCache:getWendingRedPoint()
    return self.redPoint or 0
end
--本服排名前20的平均等级
function WenDingCache:setTop20AvgLev(top20AvgLev)
    self.top20AvgLev = top20AvgLev
end

function WenDingCache:getTop20AvgLev()
    return self.top20AvgLev or 0
end

return WenDingCache