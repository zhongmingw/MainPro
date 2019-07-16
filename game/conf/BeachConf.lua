--
-- Author: 
-- Date: 2018-01-03 16:02:12
--
local BeachConf = class("BeachConf",base.BaseConf)

function BeachConf:init()
    --温泉配置
    self:addConf("wq_global")
    self:addConf("wq_ranking_award")
    self:addConf("wq_ml_award")
    self:addConf("wq_exp")
    self:addConf("wq_present_cost")
end

function BeachConf:getValue(id)
    -- rank
    return self.wq_global[tostring(id)]
end

function BeachConf:getRewardAll()
    -- body
    return table.values(self.wq_ml_award)
end

function BeachConf:getMlRewardById(id)
    -- body
    return self.wq_ml_award[tostring(id)]
end

function BeachConf:getRankReward(id)
    -- body
    local index = 0
    --print("id",id)
    for k , v in pairs(self.wq_ranking_award) do
        index = math.max(index,v.id)
        --print(v.ranking[1]<= id,id <= v.ranking[2])
        if v.ranking[1]<= id and id <= v.ranking[2] then
            return v
        end
    end
    --找不到默认返回最后一个
    return  self.wq_ranking_award[tostring(index)]
end

function BeachConf:getPresentcost( id )
    -- body
    return self.wq_present_cost[tostring(id)]
end

return BeachConf