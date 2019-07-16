--
-- Author: 
-- Date: 2017-04-07 10:53:51
--
local ArenaConf = class("ArenaConf",base.BaseConf)

function ArenaConf:init()
    --self:addConf(conf)
    self:addConf("arena_global")
    self:addConf("arena_rank_award")
end

function ArenaConf:getValue(id)
    -- body
    return self.arena_global[tostring(id)]
end

function ArenaConf:getRewardByRank(id)
    -- body
    for k ,v in pairs(self.arena_rank_award) do
        if tonumber(v.rank_begin) <= id and id <= tonumber(v.rank_end) then
            return v 
        end
    end

    return nil 
end

function ArenaConf:getMaxRankReward()
    -- body
    return self.arena_rank_award[table.nums(self.arena_rank_award)..""]

end

return ArenaConf