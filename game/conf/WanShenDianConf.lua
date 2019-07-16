--
-- Author: Your Name
-- Date: 2018-09-12 20:43:56
--万神殿配置
local WanShenDianConf = class("WanShenDianConf",base.BaseConf)

function WanShenDianConf:init()
    self:addConf("wsd_global")
    self:addConf("wsd_scene_ref")--万神殿每个场景刷新精力消耗
end

function WanShenDianConf:getValue(id)
    return self.wsd_global[tostring(id)]
end

--续费精力道具消耗
function WanShenDianConf:getCostItem(sId)
    if self.wsd_scene_ref[tostring(sId)] then
        return self.wsd_scene_ref[tostring(sId)].cost_item
    end
end

--每分钟消耗精力
function WanShenDianConf:getCostJl(sId)
    if self.wsd_scene_ref[tostring(sId)] then
        return self.wsd_scene_ref[tostring(sId)].cost_jl_min
    end
end

--消耗门票数量
function WanShenDianConf:getCostNum(sId)
    if self.wsd_scene_ref[tostring(sId)] then
        return self.wsd_scene_ref[tostring(sId)].ticket_cost
    end
end

return WanShenDianConf