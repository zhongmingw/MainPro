--
-- Author: Your Name
-- Date: 2018-07-26 00:37:25
--

local DiWangConf = class("DiWangConf", base.BaseConf)

function DiWangConf:ctor()
    self:addConf("dwjx_rank")
    self:addConf("dwjx_global")
    
end

function DiWangConf:getDiWangValue(id)
    return self.dwjx_global[tostring(id)]
end

function DiWangConf:getXianWeiDataByRank(rank)
    local data = {}
    for k,v in pairs(self.dwjx_rank) do
        if tonumber(v.id) == rank then
            data = v
        end
    end
    return data
end

function DiWangConf:getAllTitleData()
    local data = {}
    for k,v in pairs(self.dwjx_rank) do
        data[v.xw_type] = v
    end
    table.sort(data,function(a,b)
        if a.xw_type ~= b.xw_type then
            return a.xw_type < b.xw_type
        end
    end)
    return data
end

return DiWangConf