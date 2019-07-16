--
-- Author: ohf
-- Date: 2017-05-12 20:01:49
--
local GangWarCache = class("GangWarCache",base.BaseCache)
--[[
仙盟战缓存
--]]
function GangWarCache:init()
    self.bossList = {}
end
--缓存boss列表
function GangWarCache:setBossList(bossList)
    self.bossList = bossList
end

function GangWarCache:getBossList()
    return self.bossList
end
--缓存我的出生点
function GangWarCache:setPosition(position)
    self.mPosition = position
end

function GangWarCache:getPosition()
    return self.mPosition
end

function GangWarCache:setGangWarRedPoint(redPoint)
    self.redPoint = redPoint
end

function GangWarCache:getGangWarRedPoint()
    return self.redPoint or 0
end

return GangWarCache