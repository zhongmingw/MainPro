--
-- Author: 
-- Date: 2017-12-26 14:22:44
--
--活动玩法
local ActivityWarConf = class("ActivityWarConf",base.BaseConf)

function ActivityWarConf:init()
    --雪战
    self:addConf("snow_global")
    self:addConf("snow_grid")--采集物格子
    self:addConf("snow_award")--雪人奖励
    self:addConf("snow_collect_ref")--雪地采集物
    --猜灯谜
    self:addConf("holiday_global")
    self:addConf("guess_question_pool")
end

function ActivityWarConf:getSnowGlobal(id)
    return self.snow_global[tostring(id)]
end

function ActivityWarConf:getSnowAward(type,rank)
    for k,v in pairs(self.snow_award) do
        if v.type == type then
            local range = v.rank_range or {}
            if rank >= range[1] and rank <= range[2] then
                return v
            end
        end
    end
    return nil
end
--
function ActivityWarConf:getSnowCollectRef(id)
    return self.snow_collect_ref[tostring(id)]
end
--展示的奖励
function ActivityWarConf:getSnowZsAward(isZsType)
    for k,v in pairs(self.snow_award) do
        if isZsType == v.is_zs_award then
            return v
        end
    end
end

function ActivityWarConf:getActGlobal(id)
    return self.holiday_global[tostring(id)]
end

function ActivityWarConf:getGuessQuestion(id)
    return self.guess_question_pool[tostring(id)]
end

return ActivityWarConf