--
-- Author: 
-- Date: 2018-02-23 17:33:33
--
--符文管理
local RuneMgr = class("RuneMgr")

function RuneMgr:ctor()
    
end
--获取符文属性id
function RuneMgr:getDataAttiId(data)
    local color = conf.ItemConf:getQuality(data.mid)
    local fwType = conf.ItemConf:getFwType(data.mid)
    local level = data.propMap[517] or 0
    return self:getAttiId(color,fwType,level)
end

function RuneMgr:getAttiId(color,fwType,level)
    return ((1000 + fwType) * 100 + color) * 1000 + level
end

function RuneMgr:getRuneName(data)
    local color = conf.ItemConf:getQuality(data.mid)
    local name = conf.ItemConf:getName(data.mid)
    local level = data.propMap[517] or 0
    return mgr.TextMgr:getQualityStr1(name.."Lv."..level,color)
end

return RuneMgr