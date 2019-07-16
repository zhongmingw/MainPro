--
-- Author: 
-- Date: 2017-05-13 10:55:16
--
local GangWarConf = class("GangWarConf",base.BaseConf)

function GangWarConf:init()
    self:addConf("xianmeng_global")
    self:addConf("xianmeng_award")
end

function GangWarConf:getValue(id)
    return self.xianmeng_global[tostring(id)]
end
--[[
1:玩家积分排名奖励
2:非冠军帮派积分排名
3:冠军帮派奖励
]]
--积分奖励
function GangWarConf:getScoreAwards(score)
    local data = {}
    for k,v in pairs(self.xianmeng_award) do
        if v.type == 1 then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a, b)
        return a.id < b.id
    end)
    for k,v in pairs(data) do
        if v.value_con > score then
            return v
        end
    end
    return data[#data]
end
--对应战区的排名奖励
function GangWarConf:getRankAwards(warZone,rank)
    local data = {}
    for k,v in pairs(self.xianmeng_award) do
        if v.type == 2 and v.zone == warZone then
            table.insert(data, v)
            if rank >= v.value_begin and rank <= v.value_end then
                return v
            end
        end
    end
    return data[#data]
end

return GangWarConf