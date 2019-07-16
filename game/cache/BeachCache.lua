--
-- Author: 
-- Date: 2018-01-04 16:12:06
--
local BeachCache = class("BeachCache",base.BaseCache)
--[[

--]]
function BeachCache:init()
    self.data = {}
end

function BeachCache:setData(data)
    -- body
    self.data = data
end

function BeachCache:getData()
    -- body
    return self.data
end
--是否有足够的道具
function BeachCache:isEnough()
    -- body
    if self.data.itemCountMap then
        for k ,v in pairs(self.data.itemCountMap) do
            if v > 0 then
                return true
            end
        end
    end
    return false
end

function BeachCache:getXiaoYazi()
    -- body
    if self.data.itemCountMap then
        return self.data.itemCountMap[1] or 0
    end
    return 0
end

function BeachCache:plusXiaoYazi()
    -- body
    if self.data.itemCountMap then
        if not self.data.itemCountMap[1] then
            self.data.itemCountMap[1] = 0
        end
        self.data.itemCountMap[1] = self.data.itemCountMap[1] + 1 
    end
end

function BeachCache:reduceXiaoYazi()
    -- body
    if self.data.itemCountMap then
        self.data.itemCountMap[1] = self.data.itemCountMap[1] - 1 
    end
end


function BeachCache:getFeizhao()
    -- body
    if self.data.itemCountMap then
        return self.data.itemCountMap[2] or 0
    end
    return 0
end

function BeachCache:reduceFeizhao()
    -- body
    if self.data.itemCountMap then
        self.data.itemCountMap[2] = self.data.itemCountMap[2] - 1 
    end
end

function BeachCache:plusFeizhao()
    -- body
    if self.data.itemCountMap then
        if not self.data.itemCountMap[2] then
            self.data.itemCountMap[2] = 0
        end
        self.data.itemCountMap[2] = self.data.itemCountMap[2] + 1 
    end
end

return BeachCache