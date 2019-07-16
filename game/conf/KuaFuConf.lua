--
-- Author: 跨服战场配置
-- Date: 2017-06-29 10:34:02
--
local KuaFuConf = class("KuaFuConf",base.BaseConf)

function KuaFuConf:init()
    --世界boss配置
    self:addConf("cross_elite_award") 
    self:addConf("cross_elite_rank_award")
    --跨服三界争霸
    self:addConf("sjzb_global") 
    self:addConf("sjzb_task") 
    self:addConf("sjzb_daily") 
    self:addConf("sjzb_car")
    self:addConf("sjzb_box") 
end

function KuaFuConf:getValue(id)
    -- body
    return self.sjzb_global[tostring(id)]
end

function KuaFuConf:getSjzbTask(id)
    -- body
    return self.sjzb_task[tostring(id)]
end

function KuaFuConf:getSjzbdaily(id)
    -- body
    return self.sjzb_daily[tostring(id)]
end

function KuaFuConf:getSjzbCar(id)
    -- body
    return self.sjzb_car[tostring(id)]
end

function KuaFuConf:getSjzbBox(id)
    -- body
    return self.sjzb_box[tostring(id)]
end

function KuaFuConf:getEliteAwardItem(id)
    -- body
    return self.cross_elite_award[tostring(id)]
end

function KuaFuConf:getRankAwardItem(id)
    -- body
    return self.cross_elite_rank_award[tostring(id)]
end
--根据排名找boss奖励
function KuaFuConf:getEliteAward(sceneId,rank)
    local lists = {}
    local id = tonumber(string.sub(sceneId,4,6))
    for k,v in pairs(self.cross_elite_award) do
        local pex = math.floor(v.id / 1000)
        if v.type == 1 and id == pex then
            table.insert(list, v)
            if rank >= v.rank_begin and rank <= v.rank_end then
                return v
            end
        end
    end
    return list[#list]
end
--根据bossid找boss奖励
function KuaFuConf:getEliteRankAward(sceneId)
    local lists = {}
    for k,v in pairs(self.cross_elite_rank_award) do
        if v.bossid == sceneId then
            table.insert(lists, v)
        end
    end
    table.sort(lists,function(a, b)
        return a.id < b.id
    end)
    return lists
end

return KuaFuConf