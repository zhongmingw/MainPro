--
-- Author: 
-- Date: 2017-11-30 17:31:06
--
local XmzbCache = class("XmzbCache",base.BaseCache)
--[[
仙盟争霸
--]]
function XmzbCache:init()

end

function XmzbCache:setTrackData(data)
    self.trackData = data
end

function XmzbCache:updateTrackData(data)
    if self.trackData then
        self.trackData.ourRes = data.ourRes
        self.trackData.otherRes = data.otherRes
        self.trackData.ourNum = data.ourNum
        self.trackData.otherNum = data.otherNum
    end
end

function XmzbCache:updateCrystalStatusMap(data)
    if self.trackData then
        self.trackData.crystalStatusMap = data.crystalStatusMap
    end
end

function XmzbCache:getTrackData()
    return self.trackData
end

return XmzbCache