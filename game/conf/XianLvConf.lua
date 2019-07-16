--
-- Author: 
-- Date: 2018-07-24 11:44:00
--
local XianLvConf = class("XianLvConf",base.BaseConf)

function XianLvConf:init()
    self:addConf("xlpk_global")
    self:addConf("xlpk_hxs_award")--海选赛奖励
    self:addConf("xlpk_zbs_award")--争霸赛奖励

    self:addConf("world_xlpk_hxs_award")--海选赛奖励(全服)
    self:addConf("world_xlpk_zbs_award")--争霸赛奖励(全服)



end

function XianLvConf:getValue(id)
    return self.xlpk_global[tostring(id)]
end

function XianLvConf:getHxsAwardByType(pre,type)
    local data = {}
    for k,v in pairs(self.xlpk_hxs_award) do
        if math.floor(v.id /10000) == pre and type == v.type then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function XianLvConf:getZbsAward(pre)
    local data = {}
    for k,v in pairs(self.xlpk_zbs_award) do
        if math.floor(v.id/10000) == pre then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end


--全服
function XianLvConf:getWorldHxsAwardByType(pre,type)
    local data = {}
    for k,v in pairs(self.world_xlpk_hxs_award) do
        if math.floor(v.id /10000) == pre and type == v.type then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--全服
function XianLvConf:getWorldZbsAward(pre)
    local data = {}
    for k,v in pairs(self.world_xlpk_zbs_award) do
        if math.floor(v.id/10000) == pre then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end


return XianLvConf