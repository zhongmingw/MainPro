--
-- Author: 
-- Date: 2018-07-02 19:53:42
--世界杯配置

local WorldCupConf = class("WorldCupConf",base.BaseConf)

function WorldCupConf:init()
    self:addConf("worldcup_team_info")--队伍信息
    self:addConf("worldcup_stake_award")--押注奖励
    self:addConf("worldcup_team_field")--比赛信息
    self:addConf("worldcup_exchange_award")--珍品兑换


end
--队伍信息
function WorldCupConf:getTeamName(id)
    return self.worldcup_team_info[tostring(id)]
end
--押注奖励
function WorldCupConf:getAwardsData(id)
    local data = {}
    for k,v in pairs(self.worldcup_stake_award) do
        if id == math.floor(v.id/1000) then
            table.insert(data,v)
        end
    end
    table.sort(data,function ( a,b )
        return a.id < b.id
    end )
    return data
end
--比赛信息
function WorldCupConf:getGameInfo(id)
    return self.worldcup_team_field[tostring(id)]
end

--珍品兑换
function WorldCupConf:getChangeData()
    local data = {}
    for k,v in pairs(self.worldcup_exchange_award) do
        table.insert(data,v)
    end
    table.sort(data,function ( a,b )
        return a.id < b.id
    end )
    return data
end


return WorldCupConf