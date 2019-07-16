--
-- Author: 
-- Date: 2018-10-31 15:33:36
--
local EightGatesConf = class("EightGatesConf",base.BaseConf)
local table = table
local pairs = pairs
function EightGatesConf:init()
    self:addConf("bm_global")
    self:addConf("bm_condition")--开启条件
    self:addConf("bm_stren")--强化
    self:addConf("bm_jinjie")--升阶
    self:addConf("bm_split")--分解
    self:addConf("bm_rank_award")

    self:addConf("bm_jinjie_map")
    
end

function EightGatesConf:getNextStageId(id)
    return self.bm_jinjie_map[tostring(id)]
end


function EightGatesConf:getValue(id)
    return self.bm_global[tostring(id)]
end

function EightGatesConf:getGatesInfo( ... )
    local data = {}
    for k,v in pairs(self.bm_condition) do
        table.insert(data,v)
    end
    return data
end

function EightGatesConf:getGatesInfoById(id)
    return self.bm_condition[tostring(1000+id)]
end

function EightGatesConf:getStrengInfo(subType,level)
    local id = (1000+subType)*1000+level
    return self.bm_stren[tostring(id)]
end

function EightGatesConf:getStepCost(stageLv)
    local id = 1000+stageLv
    return self.bm_jinjie[tostring(id)]
end

function EightGatesConf:getStep(id)
    local data = {}
    for k,v in pairs(self.bm_jinjie) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

function EightGatesConf:getSplitExp(id)
    return self.bm_split[tostring(id)]
end

function EightGatesConf:getRankAward()
    local data = {}
    for k,v in pairs(self.bm_rank_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end


return EightGatesConf