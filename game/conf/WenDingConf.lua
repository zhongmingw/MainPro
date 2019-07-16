--
-- Author: 
-- Date: 2017-05-04 10:58:54
--
local WenDingConf = class("WenDingConf",base.BaseConf)

function WenDingConf:init()
    self:addConf("wending_global")
    self:addConf("wending_floor_score")
    self:addConf("wending_score_awards")
    self:addConf("wending_rank_awards")
    self:addConf("wending_msg")
end

function WenDingConf:getValue(id)
    return self.wending_global[tostring(id)]
end

function WenDingConf:getFloorData(id)
    return self.wending_floor_score[tostring(id)]
end
--升层奖励
function WenDingConf:getFloorAwards(id)
    local data = self.wending_floor_score[tostring(id)]
    if data then
        return data.floor_awards
    end
end

function WenDingConf:getScoreAwards()
    local data = {}
    for k,v in pairs(self.wending_score_awards) do
        table.insert(data, v)
    end
    table.sort(data,function(a, b)
        return a.id < b.id
    end)
    return data
end

function WenDingConf:getScoreAwardById(id)
    return self.wending_score_awards[tostring(id)]
end
--积分奖励
function WenDingConf:getScoreAward(score)
    local max = table.nums(self.wending_score_awards)
    for i=1,max do
        local data = self:getScoreAwardById(i)
        if data.score > score then
            return data
        end
    end
    return self:getScoreAwardById(max)
end
--排名奖励
function WenDingConf:getRankAwards()
    local data = {}
    for k,v in pairs(self.wending_rank_awards) do
        table.insert(data, v)
    end
    table.sort(data,function(a, b)
        return a.id < b.id
    end)
    return data
end

function WenDingConf:getRankAward(id)
    return self.wending_rank_awards[tostring(id)]
end

function WenDingConf:getWendMsgs()
    local data = {}
    for k,v in pairs(self.wending_msg) do
        table.insert(data, v)
    end
    table.sort(data,function(a, b)
        return a.id < b.id
    end)
    return data
end

return WenDingConf