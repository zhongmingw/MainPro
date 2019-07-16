--
-- Author: 
-- Date: 2017-05-15 10:52:02
--
local GuideCache = class("GuideCache",base.BaseCache)
--[[

--]]
function GuideCache:init()
    self.isGuide = false 

    self.shouzhi = false

    self.jiehun = nil

    self.data = nil 
end

function GuideCache:setMarry(id)
    -- body
    self.jiehun = id 
end

function GuideCache:getMarry()
    -- body
    return self.jiehun
end

--副本离开的时候不要继续任务
function GuideCache:setNotGoon(var)
    -- body
    self.goon = var
end

function GuideCache:getNotGoon()
    -- body
    return self.goon
end

function GuideCache:setData(data)
    -- body
    self.data = data
end

function GuideCache:getData()
    -- body
    return self.data
end


function GuideCache:setGuide(var)
    -- body
    self.isGuide = var 
end

function GuideCache:getGuide()
    -- body
    return self.isGuide
end
--是否剑神进阶引导
function GuideCache:setIsJsguide(isGuide)
    self.ssJsguide = isGuide
end

function GuideCache:getIsJsguide()
    return self.ssJsguide
end

return GuideCache