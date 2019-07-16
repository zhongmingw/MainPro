--旺财配置
local WangcaiConf = class("WangcaiConf",base.BaseConf)

function WangcaiConf:init()
    self:addConf("wangcai_attr")
    self:addConf("wangcai_normal")
    self:addConf("wangcai_global")
end

--属性加成信息
function WangcaiConf:getAttData( id )
    -- body
    return self.wangcai_attr[tostring(id)] or nil
end

--收益信息
function WangcaiConf:getEarningsData( id )
    -- body
    return self.wangcai_normal[tostring(id)] or nil
end

--疯狂招财次数
function WangcaiConf:getCrazyTimes(num)
    return self.wangcai_global["crazy_zc_max_times"][num]
end

--疯狂招财消耗元宝
function WangcaiConf:getCrazyCost()
    return self.wangcai_global["crazy_zc_cost"]
end

return WangcaiConf