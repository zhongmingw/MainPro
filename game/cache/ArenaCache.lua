--
-- Author: 
-- Date: 2017-04-07 10:54:34
--
local ArenaCache = class("ArenaCache",base.BaseCache)
--[[

--]]
function ArenaCache:init()
    self.data = {}
    self.isGuide = false
    self.flag = false
end

function ArenaCache:setData(data)
    -- body
    self.data = data
end

function ArenaCache:getData()
    -- body
    return self.data
end
--是否指导中
function ArenaCache:setGuide(var)
    -- body
    self.isGuide = var
end

function ArenaCache:getGuide( ... )
    -- body
    return self.isGuide 
end

function ArenaCache:setArenaFight(flag)
    -- body
    self.flag = flag
end
function ArenaCache:getIsAreanFight()
    -- body
    return self.flag
end
function ArenaCache:setOtherRoleId(var)
    -- body
    self.OtherRoleId = var
end
function ArenaCache:getOtherRoleId()
    -- body
    return self.OtherRoleId or 0
end
return ArenaCache