--
-- Author: 
-- Date: 2017-11-29 14:34:20
--
--仙盟活动（仙盟争霸，主宰神殿等）
local XmhdConf = class("XmhdConf",base.BaseConf)

function XmhdConf:init()
    self:addConf("xianmeng_global")
    self:addConf("xianmeng_war_awards")
    self:addConf("xianmeng_more_win")
    self:addConf("xianmeng_win_end_awards")--连胜终结
end

function XmhdConf:getValue(id)
    return self.xianmeng_global[tostring(id)]
end

function XmhdConf:getXmWarAward(id)
    return self.xianmeng_war_awards[tostring(id)]
end

function XmhdConf:getXmMoreWins()
    return self.xianmeng_more_win
end

function XmhdConf:getXmMoreWin(id)
    return self.xianmeng_more_win[tostring(id)]
end

function XmhdConf:getXmWinEndAward(id)
    local ids = {}
    for k,v in pairs(self.xianmeng_win_end_awards) do
        if v.id == id then
            return v
        elseif id > v.id then
            table.insert(ids, {id = v.id})
        end
    end
    table.sort(ids, function(a,b)
        return a.id < b.id
    end)
    if #ids > 0 then
        local maxId = ids[#ids].id
        return self.xianmeng_win_end_awards[tostring(maxId)]
    end
end

return XmhdConf