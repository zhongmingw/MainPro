--
-- Author: 
-- Date: 2018-07-16 15:49:26
--
local WuxingConf = class("WuxingConf",base.BaseConf)

function WuxingConf:init()
    self:addConf("wuxing_global")
    self:addConf("wuxing_stren")
    self:addConf("wuxing_suit")
    self:addConf("wuxing_compose")
end

function WuxingConf:getStrenInfo(part,color,lv)
    -- body
    --前缀1+部位01+等级001
    local index = string.format("1%02d%03d",part,lv)
    return self.wuxing_stren[index]
end

function WuxingConf:getValue(id)
    -- body
    return self.wuxing_global[id]
end

function WuxingConf:getSuit()
    -- body
    return table.values(self.wuxing_suit)
end

function WuxingConf:getEquipCompose(id, color,star )
    -- body
    local index = string.format("%d%02d%d000",id,color,star)
    return self.wuxing_compose[index]
end

return WuxingConf