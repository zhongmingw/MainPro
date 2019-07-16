--
-- Author: 
-- Date: 2017-08-30 14:59:38
--
--仙盟战配置
local XianMoConf = class("XianMoConf",base.BaseConf)

function XianMoConf:init()
    self:addConf("xianmo_global")
    self:addConf("xianmo_award")--仙魔战奖励

    self.scoreAwards = self:getScoreAwards()
end

function XianMoConf:getValue(id)
    return self.xianmo_global[tostring(id)]
end
--积分奖励
function XianMoConf:getScoreAward(score)
    for k,v in pairs(self.scoreAwards) do
        if score < v.score then
            return v
        end
    end
    return self.scoreAwards[#self.scoreAwards]
end

function XianMoConf:getScoreAwards()
    local list = {}
    for k,v in pairs(self.xianmo_award) do
        if v.type == 4 then
            table.insert(list, v)
        end
    end
    table.sort(list,function(a,b)
        return a.score < b.score
    end)
    return list
end
--1:阵营排名奖励2:阵营胜奖励3:阵营负奖励4:积分目标奖励
function XianMoConf:getXianmoAward(type)
    local list = {}
    for k,v in pairs(self.xianmo_award) do
        if type == v.type then
            table.insert(list, v)
        end
    end
    return list
end

return XianMoConf